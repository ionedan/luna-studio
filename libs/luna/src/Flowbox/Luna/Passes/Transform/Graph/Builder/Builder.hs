---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE ConstraintKinds  #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE Rank2Types       #-}

module Flowbox.Luna.Passes.Transform.Graph.Builder.Builder where

import           Control.Applicative
import           Control.Monad.State
import qualified Data.List           as List
import qualified Data.Maybe          as Maybe

import           Flowbox.Luna.Data.Analysis.Alias.GeneralVarMap      (GeneralVarMap)
import           Flowbox.Luna.Data.AST.Expr                          (Expr)
import qualified Flowbox.Luna.Data.AST.Expr                          as Expr
import qualified Flowbox.Luna.Data.AST.Lit                           as Lit
import           Flowbox.Luna.Data.AST.Pat                           (Pat)
import qualified Flowbox.Luna.Data.AST.Pat                           as Pat
import qualified Flowbox.Luna.Data.AST.Utils                         as AST
import           Flowbox.Luna.Data.Graph.Graph                       (Graph)
import qualified Flowbox.Luna.Data.Graph.Graph                       as Graph
import qualified Flowbox.Luna.Data.Graph.Node                        as Node
import           Flowbox.Luna.Data.Graph.Port                        (InPort)
import qualified Flowbox.Luna.Data.Graph.Port                        as Port
import           Flowbox.Luna.Data.PropertyMap                       (PropertyMap)
import           Flowbox.Luna.Passes.Pass                            (Pass)
import qualified Flowbox.Luna.Passes.Pass                            as Pass
import           Flowbox.Luna.Passes.Transform.Graph.Builder.State   (GBState)
import qualified Flowbox.Luna.Passes.Transform.Graph.Builder.State   as State
import qualified Flowbox.Luna.Passes.Transform.Graph.Node.OutputName as OutputName
import           Flowbox.Prelude                                     hiding (error, mapM, mapM_)
import           Flowbox.System.Log.Logger



logger :: LoggerIO
logger = getLoggerIO "Flowbox.Luna.Passes.Transform.Graph.Builder.Builder"


type GBPass result = Pass GBState result


run ::  GeneralVarMap -> PropertyMap -> Expr -> Pass.Result (Graph, PropertyMap)
run gvm pm = (Pass.run_ (Pass.Info "GraphBuilder") $ State.make gvm pm) . expr2graph


expr2graph :: Expr -> GBPass (Graph, PropertyMap)
expr2graph expr = case expr of
    Expr.Function _ _ _ _      _ []   -> do finalize
    Expr.Function _ _ _ inputs _ body -> do parseArgs inputs
                                            mapM_ (buildNode False Nothing) $ init body
                                            buildOutput $ last body
                                            finalize
    _                                 -> fail "expr2graph: Unsupported Expr type"


finalize :: GBPass (Graph, PropertyMap)
finalize = do g <- State.getGraph
              pm <- State.getPropertyMap
              return (g, pm)


parseArgs :: [Expr] -> GBPass ()
parseArgs inputs = do
    let numberedInputs = zip inputs [0..]
    mapM_ parseArg numberedInputs


parseArg :: (Expr, Int) -> GBPass ()
parseArg (input, no) = case input of
    Expr.Arg _ pat _ -> do [p] <- buildPat pat
                           State.addToNodeMap p (Graph.inputsID, Port.Num no)
    _                -> fail "parseArg: Wrong Expr type"


buildOutput :: Expr -> GBPass ()
buildOutput expr = case expr of
    Expr.Assignment {} -> return ()
    Expr.Tuple _ items -> connectArgs True Nothing Graph.outputID items
    _                  -> connectArg  True Nothing Graph.outputID (expr, 0)


buildNode :: Bool -> Maybe String -> Expr -> GBPass AST.ID
buildNode astFolded outName expr = case expr of
    Expr.Accessor   i name dst -> do let node = Node.Expr name (genName name i)
                                     State.addNode i Port.All node astFolded noAssignment
                                     connectArg True Nothing  i (dst, 0)
                                     return i
    Expr.Assignment i pat dst  -> do let patStr = Pat.lunaShow pat
                                     if isRealPat pat
                                         then do patIDs <- buildPat pat
                                                 let node = Node.Expr ('=': patStr) (genName "pattern" i)
                                                 State.insNode (i, node) astFolded noAssignment
                                                 case patIDs of
                                                    [patID] -> State.addToNodeMap patID (i, Port.All)
                                                    _       -> mapM_ (\(n, patID) -> State.addToNodeMap patID (i, Port.Num n)) $ zip [0..] patIDs
                                                 dstID <- buildNode True Nothing dst
                                                 State.connect dstID i 0
                                                 return dummyValue
                                         else do [p] <- buildPat pat
                                                 j <- buildNode False (Just patStr) dst
                                                 State.addToNodeMap p (j, Port.All)
                                                 return dummyValue
    Expr.App        _ src args -> do srcID       <- buildNode (astFolded || False) Nothing src
                                     (srcNID, _) <- State.gvmNodeMapLookUp srcID
                                     connectArgs True Nothing srcNID args
                                     return srcID
    Expr.Infix  i name src dst -> do let node = Node.Expr name (genName name i)
                                     State.addNode i Port.All node astFolded noAssignment
                                     connectArg True Nothing i (src, 0)
                                     connectArg True Nothing i (dst, 1)
                                     return i
    Expr.Var        i name     -> if astFolded
                                     then return i
                                     else do let node = Node.Expr name (genName name i)
                                             State.addNode i Port.All node astFolded noAssignment
                                             return i
    Expr.Con        i name     -> do let node = Node.Expr name (genName name i)
                                     State.addNode i Port.All node astFolded noAssignment
                                     return i
    Expr.Lit        i lvalue   -> do let litStr = Lit.lunaShow lvalue
                                         node = Node.Expr litStr (genName litStr i)
                                     State.addNode i Port.All node astFolded noAssignment
                                     return i
    Expr.Tuple      i items    -> do let node = Node.Expr "Tuple" (genName "tuple" i)
                                     State.addNode i Port.All node astFolded noAssignment
                                     connectArgs True Nothing i items
                                     return i
    Expr.Wildcard   i          -> fail $ "GraphBuilder: Unexpected Expr.Wildcard with id=" ++ show i
    where
        genName base num = case outName of
            Nothing   -> OutputName.generate base num
            Just name -> name

        noAssignment = case outName of
            Nothing -> True
            Just _  -> False


buildArg :: Bool -> Maybe String -> Expr -> GBPass (Maybe AST.ID)
buildArg astFolded outName expr = case expr of
    Expr.Wildcard _ -> return Nothing
    _               -> Just <$> buildNode astFolded outName expr


connectArgs :: Bool -> Maybe String -> AST.ID -> [Expr] -> GBPass ()
connectArgs astFolded outName dstID exprs =
    mapM_ (connectArg astFolded outName dstID) $ zip exprs [0..]


connectArg :: Bool -> Maybe String -> AST.ID -> (Expr, InPort) -> GBPass ()
connectArg astFolded outName dstID (expr, dstPort) = do
    msrcID <- buildArg astFolded outName expr
    case msrcID of
        Nothing    -> return ()
        Just srcID -> State.connect srcID dstID dstPort

isRealPat :: Pat -> Bool
isRealPat p = case p of
    Pat.Var {}-> False
    _         -> True


buildPat :: Pat -> GBPass [AST.ID]
buildPat p = case p of
    Pat.Var      i _      -> return [i]
    Pat.Lit      i _      -> return [i]
    Pat.Tuple    _ items  -> List.concat <$> mapM buildPat items
    Pat.Con      i _      -> return [i]
    Pat.App      _ _ args -> List.concat <$> mapM buildPat args
    Pat.Typed    _ pat _  -> buildPat pat
    Pat.Wildcard i        -> return [i]


-- REMOVE ME --
dummyValue :: Int
dummyValue = (-1)
--------------
