module Empire.API.Data.Port where

import Prologue
import Data.Binary                  (Binary)

import Empire.API.Data.DefaultValue (PortDefault)

data InPort  = Self | Arg Int        deriving (Generic, Show, Eq)
data OutPort = All  | Projection Int deriving (Generic, Show, Eq)

instance Binary InPort
instance Binary OutPort

data PortId = InPortId InPort | OutPortId OutPort deriving (Generic, Show, Eq)

instance Ord PortId where
  (InPortId  _) `compare` (OutPortId _) = LT
  (OutPortId _) `compare` (InPortId  _) = GT
  (InPortId  a) `compare` (InPortId  b) = a `compare` b
  (OutPortId a) `compare` (OutPortId b) = a `compare` b

instance Ord InPort where
  Self `compare` Self = EQ
  Self `compare` (Arg _) = LT
  (Arg _) `compare` Self = GT
  (Arg a) `compare` (Arg b) = a `compare` b

instance Ord OutPort where
  All            `compare` All            = EQ
  All            `compare` (Projection _) = LT
  (Projection _) `compare` All            = GT
  (Projection a) `compare` (Projection b) = a `compare` b

newtype ValueType = ValueType { _unValueType :: String } deriving (Show, Eq, Generic)

data Port = Port { _portId       :: PortId
                 , _valueType    :: ValueType
                 , _defaultValue :: Maybe PortDefault
                 } deriving (Show, Eq, Generic)

makeLenses ''Port

instance Binary ValueType
instance Binary PortId
instance Binary Port