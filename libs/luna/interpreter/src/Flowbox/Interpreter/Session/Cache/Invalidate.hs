---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Flowbox Team <contact@flowbox.io>, 2014
-- Proprietary and confidential
-- Unauthorized copying of this file, via any medium is strictly prohibited
---------------------------------------------------------------------------
module Flowbox.Interpreter.Session.Cache.Invalidate where

import           Control.Monad.State hiding (mapM, mapM_)
import qualified Data.List           as List

import qualified Flowbox.Data.MapForest                         as MapForest
import qualified Flowbox.Interpreter.Session.AST.Traverse       as Traverse
import qualified Flowbox.Interpreter.Session.Cache.Cache        as Cache
import           Flowbox.Interpreter.Session.Cache.Info         (CacheInfo)
import qualified Flowbox.Interpreter.Session.Cache.Info         as CacheInfo
import           Flowbox.Interpreter.Session.Cache.Status       (CacheStatus)
import qualified Flowbox.Interpreter.Session.Cache.Status       as CacheStatus
import           Flowbox.Interpreter.Session.Data.CallDataPath  (CallDataPath)
import qualified Flowbox.Interpreter.Session.Data.CallDataPath  as CallDataPath
import           Flowbox.Interpreter.Session.Data.CallPoint     (CallPoint (CallPoint))
import qualified Flowbox.Interpreter.Session.Data.CallPoint     as CallPoint
import           Flowbox.Interpreter.Session.Data.CallPointPath (CallPointPath)
import           Flowbox.Interpreter.Session.Session            (Session)
import qualified Flowbox.Luna.Data.AST.Common                   as AST
import           Flowbox.Luna.Data.AST.Crumb.Breadcrumbs        (Breadcrumbs)
import qualified Flowbox.Luna.Data.Graph.Node                   as Node
import qualified Flowbox.Luna.Lib.Library                       as Library
import           Flowbox.Prelude                                hiding (matching)
import           Flowbox.System.Log.Logger



logger :: LoggerIO
logger = getLoggerIO "Flowbox.Interpreter.Session.Cache.Invalidate"


modifyAll :: Session ()
modifyAll = modifyMatching $ const . const True


modifyLibrary :: Library.ID -> Session ()
modifyLibrary libraryID = modifyMatching matchLib where
    matchLib k _ = last k ^. CallPoint.libraryID == libraryID


modifyDef :: Library.ID -> AST.ID -> Session ()
modifyDef libraryID defID = modifyMatching matchDef where
    matchDef k v = last k ^. CallPoint.libraryID == libraryID
                     && v ^. CacheInfo.defID     == defID


modifyBreadcrumbsRec :: Library.ID -> Breadcrumbs -> Session ()
modifyBreadcrumbsRec libraryID bc = modifyMatching matchBC where
    matchBC k v = last k ^. CallPoint.libraryID   == libraryID
                    && List.isPrefixOf bc (v ^. CacheInfo.breadcrumbs)


modifyBreadcrumbs :: Library.ID -> Breadcrumbs -> Session ()
modifyBreadcrumbs libraryID bc = modifyMatching matchBC where
    matchBC k v = last k ^. CallPoint.libraryID == libraryID
                    && v ^. CacheInfo.breadcrumbs == bc


modifyNode :: Library.ID -> Node.ID -> Session ()
modifyNode libraryID nodeID = modifyMatching matchNode where
    matchNode k _ = last k == CallPoint libraryID nodeID


modifyMatching :: (CallPointPath -> CacheInfo -> Bool) -> Session ()
modifyMatching predicate = do
    matching <- MapForest.find predicate <$> Cache.cached
    mapM_ (setStatusParents CacheStatus.Modified . fst) matching


setStatusParents :: CacheStatus -> CallPointPath -> Session ()
setStatusParents _      []            = return ()
setStatusParents status callPointPath = do
    Cache.setStatus status callPointPath
    setStatusParents status $ init callPointPath


markSuccessors :: CallDataPath -> CacheStatus -> Session ()
markSuccessors callDataPath status =
    Traverse.next callDataPath >>=
    mapM_ (setStatusParents status . CallDataPath.toCallPointPath)

