{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE JavaScriptFFI #-}

module Utils.Viz where

import           Utils.PreludePlus
import           Data.Text.Lazy      (Text)

import           GHCJS.Foreign
import           GHCJS.Types         (JSString)
import           Data.JSString.Text  (lazyTextToJSString)


foreign import javascript safe "window.open('data:image/svg+xml;base64,'+btoa(Viz($1, 'svg', 'dot')), 'graph')"
    displayGraphJS :: JSString -> IO ()

displayGraph :: Text -> IO ()
displayGraph = displayGraphJS . lazyTextToJSString
