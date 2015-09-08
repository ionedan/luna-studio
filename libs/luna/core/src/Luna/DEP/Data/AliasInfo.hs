---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

{-# LANGUAGE TemplateHaskell #-}

module Luna.DEP.Data.AliasInfo where

import Flowbox.Prelude

import GHC.Generics (Generic)


import           Data.IntMap      (IntMap)
import           Data.Map         (Map)
import qualified Data.Maps        as Map
import           Luna.DEP.AST.AST (AST, ID)
import qualified Luna.DEP.AST.AST as AST


----------------------------------------------------------------------
-- Data types
----------------------------------------------------------------------

type IDMap = IntMap


data Error  = LookupError {key :: String}
            deriving (Show, Eq, Generic, Read)


data Scope = Scope { _varnames  :: Map String ID
                   , _typenames :: Map String ID
                   } deriving (Show, Eq, Generic, Read)

makeLenses (''Scope)


data AliasInfo = AliasInfo  { _scope   :: IDMap Scope
                            , _alias   :: IDMap ID
                            , _orphans :: IDMap Error
                            , _parent  :: IDMap ID
                            , _ast     :: IDMap AST
                            } deriving (Show, Eq, Generic, Read)

makeLenses (''AliasInfo)


----------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------

regParent  id pid  = parent %~ Map.insert id pid
regAST     id a    = ast    %~ Map.insert id a
regVarName pid id name info = setScope info pid $ Scope (vnmap & at name ?~ id) tnmap where
    (vnmap, tnmap) = scopeLookup pid info

regOrphan id err = orphans %~ Map.insert id err

regTypeName pid id name info = setScope info pid $ Scope vnmap (tnmap & at name ?~ id) where
    (vnmap, tnmap) = scopeLookup pid info

setScope info id s = info & scope.at id ?~ s

scopeLookup pid info = case Map.lookup pid (_scope info) of
        Nothing          -> (mempty, mempty)
        Just (Scope v t) -> (v,t)

------------------------------------------------------------------------
-- Instances
------------------------------------------------------------------------

instance Monoid Scope where
    mempty      = Scope mempty mempty
    mappend a b = Scope (mappend (a ^. varnames)  (b ^. varnames))
                        (mappend (a ^. typenames) (b ^. typenames))


instance Monoid AliasInfo where
    mempty      = AliasInfo mempty mempty mempty mempty mempty
    mappend a b = AliasInfo (mappend (a ^. scope)   (b ^. scope))
                            (mappend (a ^. alias)   (b ^. alias))
                            (mappend (a ^. orphans) (b ^. orphans))
                            (mappend (a ^. parent)  (b ^. parent))
                            (mappend (a ^. ast)     (b ^. ast))


instance Default Scope where
    def = Scope def def

instance Default AliasInfo where
    def = AliasInfo def def def def def