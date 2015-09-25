module JS.ConnectionPen where

import Utils.PreludePlus
import Utils.Vector
import GHCJS.Types
import GHCJS.Foreign.Callback
import GHCJS.Foreign
import JavaScript.Array


foreign import javascript unsafe "connectionPen.beginPath($1, $2, $3)" beginPath'   :: Int -> Int -> Bool -> IO ()

beginPath :: Vector2 Int -> Bool -> IO ()
beginPath (Vector2 x y) tpe = beginPath' x y tpe

foreign import javascript unsafe "connectionPen.endPath()"             endPath      :: IO ()
foreign import javascript unsafe "connectionPen.clearCanvas()"         clearCavnas  :: IO ()
foreign import javascript unsafe "connectionPen.drawSegment($1, $2)"   drawSegment' :: Int -> Int -> IO ()

drawSegment :: Vector2 Int -> IO ()
drawSegment (Vector2 x y) = drawSegment' x y

foreign import javascript unsafe "connectionPen.requestWidgetsBetween($1, $2, $3, $4)"
    requestWidgetsBetween' :: Int -> Int -> Int -> Int -> IO ()

requestWidgetsBetween :: Vector2 Int -> Vector2 Int -> IO ()
requestWidgetsBetween (Vector2 ax ay) (Vector2 bx by) = requestWidgetsBetween' ax ay bx by

foreign import javascript unsafe "connectionPen.callback = $1"
    registerCallback' :: Callback (JSRef () -> IO ()) -> IO ()

foreign import javascript unsafe "connectionPen.callback = function(){ return null; }"
    unregisterCallback' :: Callback (JSRef () -> IO ()) -> IO ()

foreign import javascript unsafe "$r = $1" toJSArray :: JSRef () -> JSArray


registerCallback :: (JSRef () -> IO ()) -> IO (IO ())
registerCallback callback = do
    wrappedCallback <- asyncCallback1 callback
    registerCallback' wrappedCallback
    return $ unregisterCallback' wrappedCallback >> releaseCallback wrappedCallback


