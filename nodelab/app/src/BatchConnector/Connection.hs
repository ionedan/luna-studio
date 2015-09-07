module BatchConnector.Connection where

import qualified Data.Binary                 as Binary
import           GHC.Generics                (Generic)
import           GHCJS.Types (JSString)
import           Data.JSString.Text
import           Data.Text (Text)
import           Data.ByteString.Lazy.Char8  (ByteString, pack, toStrict)
import qualified Data.ByteString.Base64.Lazy as Base64
import           Data.Text.Lazy.Encoding     (decodeUtf8)
import           Utils.PreludePlus           hiding (Text)
import           JS.WebSocket

data WebMessage = WebMessage { _topic   :: String
                             , _message :: ByteString
                             } deriving (Show, Generic)

instance Binary.Binary WebMessage

serialize :: WebMessage -> JSString
serialize = lazyTextToJSString . decodeUtf8 . Base64.encode . Binary.encode

deserialize :: String -> WebMessage
deserialize = Binary.decode . Base64.decodeLenient . pack

sendMessage :: WebMessage -> IO ()
sendMessage msg = do
    socket <- getWebSocket
    send socket $ serialize msg