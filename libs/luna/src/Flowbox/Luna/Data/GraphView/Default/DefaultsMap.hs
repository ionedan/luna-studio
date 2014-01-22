---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Flowbox.Luna.Data.GraphView.Default.DefaultsMap where

import           Data.Map (Map)
import qualified Data.Map as Map

import qualified Flowbox.Luna.Data.Attributes               as Attributes
import qualified Flowbox.Luna.Data.Graph.Node               as Node
import           Flowbox.Luna.Data.GraphView.Default.Value  (Value)
import           Flowbox.Luna.Data.GraphView.PortDescriptor (PortDescriptor)
import           Flowbox.Luna.Data.PropertyMap              (PropertyMap)
import qualified Flowbox.Luna.Data.PropertyMap              as PropertyMap
import           Flowbox.Prelude



type DefaultsMap = Map PortDescriptor (Node.ID, Value)


defaultsMapKey :: String
defaultsMapKey = "Defaults-map"


getDefaultsMap :: Node.ID -> PropertyMap -> DefaultsMap
getDefaultsMap nodeID propertyMap = case PropertyMap.get nodeID Attributes.luna defaultsMapKey propertyMap of
    Nothing -> Map.empty
    Just d  -> read d


setDefaultsMap :: DefaultsMap -> Node.ID -> PropertyMap -> PropertyMap
setDefaultsMap defaults nodeID =
    PropertyMap.set nodeID Attributes.luna defaultsMapKey (show defaults)


addDefault :: PortDescriptor -> (Node.ID, Value) -> Node.ID -> PropertyMap -> PropertyMap
addDefault dstPort default_ nodeID propertyMap = newPropertyMap where
     newDefaults    = Map.insert dstPort default_ $ getDefaultsMap nodeID propertyMap
     newPropertyMap = setDefaultsMap newDefaults nodeID propertyMap


removeDefault :: PortDescriptor -> Node.ID -> PropertyMap -> PropertyMap
removeDefault dstPort nodeID propertyMap = newPropertyMap where
    newDefaults    = Map.delete dstPort $ getDefaultsMap nodeID propertyMap
    newPropertyMap = setDefaultsMap newDefaults nodeID propertyMap
