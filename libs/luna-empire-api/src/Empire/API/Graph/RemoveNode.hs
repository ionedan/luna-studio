module Empire.API.Graph.RemoveNode where

import           Prologue
import           Data.Binary                   (Binary)

import           Empire.API.Data.GraphLocation (GraphLocation)
import           Empire.API.Data.Node          (NodeId)
import qualified Empire.API.Response           as Response

data Request = Request { _location :: GraphLocation
                       , _nodeId   :: NodeId
                       } deriving (Generic, Show, Eq)

data Update = Update { _removedNodeId :: NodeId
                     } deriving (Generic, Show, Eq)

type Response = Response.Response Request Update

makeLenses ''Request
makeLenses ''Update

instance Binary Request
instance Binary Update
