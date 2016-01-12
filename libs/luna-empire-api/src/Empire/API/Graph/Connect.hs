module Empire.API.Graph.Connect where

import           Prologue
import           Data.Binary                   (Binary)

import           Empire.API.Data.GraphLocation (GraphLocation)
import           Empire.API.Data.Node          (NodeId)
import           Empire.API.Data.Port          (OutPort, InPort)
import           Empire.API.Data.PortRef       (OutPortRef(..), InPortRef(..))
import qualified Empire.API.Response           as Response

data Request = Request { _location  :: GraphLocation
                       , _srcNodeId :: NodeId
                       , _srcPort   :: OutPort
                       , _dstNodeId :: NodeId
                       , _dstPort   :: InPort
                       } deriving (Generic, Show, Eq)
type Response = Response.SimpleResponse Request

makeLenses ''Request

instance Binary Request

src' :: Request -> OutPortRef
src' r = OutPortRef (r ^. srcNodeId) (r ^. srcPort)

src :: Getter Request OutPortRef
src = to src'

dst' :: Request -> InPortRef
dst' r = InPortRef (r ^. dstNodeId) (r ^. dstPort)

dst :: Getter Request InPortRef
dst = to dst'
