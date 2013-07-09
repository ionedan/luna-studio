---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module Luna.DefaultValue(
DefaultValue(..)
) where

data DefaultValue = DefaultInt Int
				  | DefaultString String 
				  deriving (Show, Read)
