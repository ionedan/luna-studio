{-# LANGUAGE ExistentialQuantification #-}

module Object.Widget.Chart where

import           Utils.PreludePlus
import           Utils.Vector
import           Data.Fixed
import qualified Data.Text.Lazy as Text
import           Data.Text.Lazy (Text)

import           Object.Widget
import           Numeric

data ChartType = Line   | Bar | Scatter  | Area       deriving (Show, Eq)
data AxisType  = Linear
               | Logarithmic
               | Percentage
               | Category
               | Time
               deriving (Show, Eq)

data Chart = Chart   { _pos       :: Vector2 Double
                     , _size      :: Vector2 Double
                     , _tpe       :: ChartType
                     , _xMeasure  :: Text
                     , _xScale    :: AxisType
                     , _yMeasure  :: Text
                     , _yScale    :: AxisType
                     } deriving (Eq, Show, Typeable)

makeLenses ''Chart

instance IsDisplayObject Chart
