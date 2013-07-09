---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module Luna.Edge(
Edge(..),
EdgeCls(..),
noEdges
) where
	
data EdgeCls = Standard | Arrow deriving (Show, Read)

noEdges :: [Edge]
noEdges = [] 

data Edge = Edge { 
	inn :: String,
	out :: String,
	cls :: EdgeCls
} deriving (Show, Read)
