module TextEditor.Handler.ProjectManager
    ( handle
    ) where


import           JS.Atom
import qualified LunaStudio.API.Atom.OpenFile           as OpenFile
import qualified LunaStudio.API.Atom.IsSaved            as IsSaved
import qualified LunaStudio.API.Response                as Response
import qualified TextEditor.Action.Batch              as BatchCmd (closeFile, isSaved, openFile, saveFile, setProject)
import           TextEditor.Action.Command            (Command)
import qualified TextEditor.Event.Batch               as Batch
import           TextEditor.Event.Event               (Event (Batch, Atom))
import           TextEditor.Event.Internal            (InternalEvent(..), ActionType(..))
import           TextEditor.Handler.Backend.Common    (doNothing, handleResponse)
import           Common.Prelude
import           TextEditor.State.Global              (State)
import           Data.Char                          (toUpper)

handle :: Event -> Maybe (Command State ())
handle (Atom (InternalEvent SetProject path _)) = Just $ BatchCmd.setProject path
handle (Atom (InternalEvent CloseFile path _))  = Just $ BatchCmd.closeFile path
handle (Atom (InternalEvent OpenFile path _))   = Just $ BatchCmd.openFile path
handle (Atom (InternalEvent SaveFile path _))   = Just $ BatchCmd.saveFile path
handle (Atom (InternalEvent IsSaved path _))    = Just $ BatchCmd.isSaved path

handle (Batch (Batch.ProjectSet response))    = Just $ handleResponse response doNothing doNothing
handle (Batch (Batch.FileOpened response))    = Just $ handleResponse response success doNothing where
    success result = do
        let uri  = response ^. Response.request . OpenFile.filePath
            status = "ok"
        liftIO $ pushStatus (convert "FileSaved") (convert uri) (convert status)
handle (Batch (Batch.FileClosed response))    = Just $ handleResponse response doNothing doNothing
handle (Batch (Batch.FileSaved response))     = Just $ handleResponse response doNothing doNothing
handle (Batch (Batch.IsSaved response))       = Just $ handleResponse response success doNothing where
   success result = do
       let uri  = response ^. Response.request . IsSaved.filePath
           status = map toUpper . show $ result ^. IsSaved.status
       liftIO $ pushStatus (convert "IsSaved") (convert uri) (convert status)

handle _ = Nothing