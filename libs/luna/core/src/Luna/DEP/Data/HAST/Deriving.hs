---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Luna.DEP.Data.HAST.Deriving (
    Deriving(..),
    genCode
)where

import Data.String.Utils (join)
import Flowbox.Prelude

data Deriving = Eq
              | Ord
              | Enum
              | Ix
              | Bounded
              | Read
              | Show
              | Generic
              deriving (Show)


genCode :: [Deriving] -> String
genCode d = case d of
        [] -> ""
        _  -> " deriving (" ++ join ", " (map show d) ++ ")"








