---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Flowbox.Batch.Handler.AST where

import qualified Data.IntSet as IntSet

import           Flowbox.Batch.Batch                               (Batch)
import           Flowbox.Batch.Handler.Common                      (astClassFocusOp, astFocusOp, astFunctionFocusOp, astModuleFocusOp, astOp, libManagerOp, noresult, readonly)
import qualified Flowbox.Batch.Project.Project                     as Project
import           Flowbox.Luna.Data.AST.Crumb.Breadcrumbs           (Breadcrumbs)
import           Flowbox.Luna.Data.AST.Expr                        (Expr)
import qualified Flowbox.Luna.Data.AST.Expr                        as Expr
import           Flowbox.Luna.Data.AST.Module                      (Module)
import qualified Flowbox.Luna.Data.AST.Module                      as Module
import           Flowbox.Luna.Data.AST.Type                        (Type)
import           Flowbox.Luna.Data.AST.Zipper.Focus                (Focus)
import qualified Flowbox.Luna.Data.AST.Zipper.Focus                as Focus
import qualified Flowbox.Luna.Data.AST.Zipper.Zipper               as Zipper
import qualified Flowbox.Luna.Data.PropertyMap                     as PropertyMap
import qualified Flowbox.Luna.Lib.Library                          as Library
import qualified Flowbox.Luna.Passes.Analysis.ID.ExtractIDs        as ExtractIDs
import qualified Flowbox.Luna.Passes.Analysis.NameResolver         as NameResolver
import qualified Flowbox.Luna.Passes.General.Luna.Luna             as Luna
import qualified Flowbox.Luna.Passes.Transform.AST.IDFixer.IDFixer as IDFixer
import qualified Flowbox.Luna.Passes.Transform.AST.Shrink          as Shrink
import           Flowbox.Prelude                                   hiding (cons, focus)
import           Flowbox.System.Log.Logger



loggerIO :: LoggerIO
loggerIO = getLoggerIO "Flowbox.Batch.Handler.AST"


definitions :: Maybe Int -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Focus
definitions mmaxDepth bc libID projectID = readonly . astFocusOp bc libID projectID (\_ focus _ -> do
    shrinked <- Shrink.shrinkFunctionBodies focus
    return (focus, shrinked))


addModule :: Module -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO (Batch, Module)
addModule newModule bcParent libID projectID = astFocusOp bcParent libID projectID (\_ focus maxID -> do
    fixedModule <- Luna.runIO $ IDFixer.runModule maxID True newModule
    newFocus <- case focus of
        Focus.ClassFocus    _ -> fail "Cannot add module to a class"
        Focus.FunctionFocus _ -> fail "Cannot add module to a function"
        Focus.ModuleFocus   m -> return $ Focus.ModuleFocus $ Module.addModule fixedModule m
    return (newFocus, fixedModule))


addClass :: Expr -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO (Batch, Expr)
addClass newClass bcParent libID projectID = astFocusOp bcParent libID projectID (\_ focus maxID -> do
    fixedClass <- Luna.runIO $ IDFixer.runExpr maxID True newClass
    newFocus <- case focus of
        Focus.ClassFocus    c -> return $ Focus.ClassFocus $ Expr.addClass fixedClass c
        Focus.FunctionFocus _ -> fail "Cannot add class to a function"
        Focus.ModuleFocus   m -> return $ Focus.ModuleFocus $ Module.addClass fixedClass m
    return (newFocus, fixedClass))


addFunction :: Expr -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO (Batch, Expr)
addFunction newFunction bcParent libID projectID = astFocusOp bcParent libID projectID (\_ focus maxID -> do
    fixedFunction <- Luna.runIO $ IDFixer.runExpr maxID True newFunction
    newFocus <- case focus of
        Focus.ClassFocus    c -> return $ Focus.ClassFocus $ Expr.addMethod fixedFunction c
        Focus.FunctionFocus _ -> fail "Cannot add function to a function"
        Focus.ModuleFocus   m -> return $ Focus.ModuleFocus $ Module.addMethod fixedFunction m
    return (newFocus, fixedFunction))


remove :: Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
remove bc libID projectID = noresult . astOp libID projectID (\_ ast propertyMap -> do
    focus <- Zipper.focusBreadcrumbs' bc ast
    ids   <- Luna.runIO $ ExtractIDs.run $ Zipper.getFocus focus
    let newPropertyMap = foldr PropertyMap.delete propertyMap $ IntSet.toList ids
    newAst <- Zipper.close $ Zipper.defocusDrop focus
    return ((newAst, newPropertyMap), ()))


resolveDefinition :: (Applicative m, Monad m)
                  => String -> Breadcrumbs -> Library.ID -> Project.ID -> Batch
                  -> m [(Breadcrumbs, Library.ID)]
resolveDefinition name bc libID projectID = readonly . libManagerOp projectID (\_ libManager -> do
    results <- NameResolver.resolve name bc libID libManager
    return (libManager, results))


updateModuleCls :: Type -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateModuleCls cls bc libID projectID = noresult . astModuleFocusOp bc libID projectID (\_ m maxID -> do
    fixedCls <- Luna.runIO $ IDFixer.runType maxID True cls
    return (m & Module.cls .~ fixedCls, ()))


updateModuleImports :: [Expr] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateModuleImports imports bc libID projectID = noresult . astModuleFocusOp bc libID projectID (\_ m maxID -> do
    fixedImports <- Luna.runIO $ IDFixer.runExprs maxID True imports
    return (m & Module.imports .~ fixedImports, ()))


updateModuleFields :: [Expr] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateModuleFields fields bc libID projectID = noresult . astModuleFocusOp bc libID projectID (\_ m maxID -> do
    fixedFields <- Luna.runIO $ IDFixer.runExprs maxID True fields
    return (m & Module.fields .~ fixedFields, ()))


updateDataCls :: Type -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateDataCls cls bc libID projectID = noresult . astClassFocusOp bc libID projectID (\_ m maxID -> do
    fixedCls <- Luna.runIO $ IDFixer.runType maxID True cls
    return (m & Expr.cls .~ fixedCls, ()))


updateDataCons :: [Expr] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateDataCons cons bc libID projectID = noresult . astClassFocusOp bc libID projectID (\_ m maxID -> do
    fixedCons <- Luna.runIO $ IDFixer.runExprs maxID True cons
    return (m & Expr.cons .~ fixedCons, ()))


updateDataClasses :: [Expr] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateDataClasses classes bc libID projectID = noresult . astClassFocusOp bc libID projectID (\_ m maxID -> do
    fixedClasses <- Luna.runIO $ IDFixer.runExprs maxID True classes
    return (m & Expr.classes .~ fixedClasses, ()))


updateDataMethods :: [Expr] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateDataMethods methods bc libID projectID = noresult . astClassFocusOp bc libID projectID (\_ m maxID -> do
    fixedMethods <- Luna.runIO $ IDFixer.runExprs maxID True methods
    return (m & Expr.methods .~ fixedMethods, ()))


updateFunctionName :: String -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateFunctionName name bc libID projectID = noresult . astFunctionFocusOp bc libID projectID (\_ m _ ->
    return (m & Expr.name .~ name, ()))


updateFunctionPath :: [String] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateFunctionPath path bc libID projectID = noresult . astFunctionFocusOp bc libID projectID (\_ m _ ->
    return (m & Expr.path .~ path, ()))


updateFunctionInputs :: [Expr] -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateFunctionInputs inputs bc libID projectID = noresult . astFunctionFocusOp bc libID projectID (\_ m maxID -> do
    fixedInputs <- Luna.runIO $ IDFixer.runExprs maxID True inputs
    return (m & Expr.inputs .~ fixedInputs, ()))


updateFunctionOutput :: Type -> Breadcrumbs -> Library.ID -> Project.ID -> Batch -> IO Batch
updateFunctionOutput output bc libID projectID = noresult . astFunctionFocusOp bc libID projectID (\_ m maxID -> do
    fixedOutput <- Luna.runIO $ IDFixer.runType maxID True output
    return (m & Expr.output .~ fixedOutput, ()))
