---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------
{-# LANGUAGE FlexibleContexts, NoMonomorphismRestriction, ConstraintKinds, TupleSections #-}

module Flowbox.Luna.Passes.Pass where

import           Control.Monad.State        hiding (fail)
import           Control.Monad.RWS          hiding (fail)
import           Control.Monad.Trans.Either   

import           Flowbox.System.Log.Logger    
import qualified Flowbox.System.Log.Logger  as Logger
import           Flowbox.Prelude            hiding (error, fail)
  

type PassError              = String

type PassMonad    s m       = (Functor m, MonadRWS Info LogList s m)
type PassMonadIO  s m       = (Functor m, MonadRWS Info LogList s m, MonadIO m)
type Transformer  s b       = EitherT PassError (RWS Info LogList s) b 
type TransformerT s a m b   = EitherT a (RWST Info LogList s m) b
type Result       m output  = ResultT m output
type ResultT      m         = EitherT PassError m

data NoState = NoState deriving (Show)

data Info = Info { name :: String
                 } deriving (Show)


logger :: Logger
logger = getLogger "Flowbox.Luna.Passes.Pass"


run ::  PassMonad s m => Info -> state -> Transformer state b -> Result m (b, state)
run inf s f = do
    logPassExec inf
    runLogic inf s f


run_ :: PassMonad outstate m => Info -> state -> Transformer state b -> Result m b
run_ inf s f = do
    (result, _) <- run inf s f
    return result


runTRaw :: Info -> s -> TransformerT s a m b -> m (Either a b, s, LogList)
runTRaw inf s f = runRWST (runEitherT f) inf s


runT :: PassMonad ns m => Info -> s -> TransformerT s PassError (ResultT m) b  -> Result m (b,s)
runT inf s f = do
    runLogicT inf s f


runT_ :: PassMonad ns m => Info -> s -> TransformerT s PassError (ResultT m) b  -> Result m b
runT_ inf s f = do
    logPassExec inf
    (result, _) <- runT inf s f
    return result


run'_ :: PassMonad outstate m => Info -> state -> Transformer state b -> Result m state
run'_ inf s f = do
    (_, state') <- runLogic inf s f
    return state'


fail :: PassMonad s m => String -> ResultT m a
fail msg = do
    inf <- ask
    logger error $ "Pass error [" ++ name inf ++ "]: " ++ msg
    left msg


runLogicT :: PassMonad ns m => Info -> s -> TransformerT s PassError (ResultT m) b  -> Result m (b,s)
runLogicT inf s f = do
    out <- runRWST (runEitherT f) inf s
    hoistLogic out


runLogic :: PassMonad s m => Info -> state -> Transformer state b -> Result m (b, state)
runLogic inf s f = hoistLogic $ runRWS (runEitherT f) inf s


hoistLogic :: MonadWriter LogList m => (Either PassError r, s, LogList) -> Result m (r, s)
hoistLogic (result', state', logs') = do
    let out = case result' of
                  Left  e  -> Left e
                  Right r  -> Right (r, state')
    Logger.append logs'
    hoistEither out 


logPassExec :: LogWriter m => Info -> m ()
logPassExec inf = logger debug $ "Running pass: " ++ name inf
