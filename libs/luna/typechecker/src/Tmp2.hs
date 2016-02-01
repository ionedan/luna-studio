{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE UndecidableInstances      #-}
{-# LANGUAGE FunctionalDependencies    #-}
{-# LANGUAGE RecursiveDo               #-}
{-# LANGUAGE RankNTypes                #-}

-- {-# LANGUAGE PartialTypeSignatures     #-}

{-# LANGUAGE ScopedTypeVariables #-}

module Tmp2 where

import Prologue hiding (simple, empty, Indexable, Simple, cons, lookup, index, children, Cons, Ixed, Repr, repr, minBound, maxBound, (#), assert, Index, read)

import Data.Record hiding (Layout)


import Luna.Syntax.AST.Term2 hiding (Lit, Val, Thunk, Expr, Draft, Target)
import qualified Luna.Syntax.AST.Term2 as Term
import Luna.Syntax.Model.Layer.Labeled


import Data.Layer.Cover
import Data.Coat
import Data.Construction

import Control.Monad.Identity
import Control.Monad.State
import Data.Container hiding (impossible)

import           Luna.Syntax.Model.Graph (Graph, GraphBuilder, MonadGraphBuilder, nodes, edges)
import qualified Luna.Syntax.Model.Graph as Graph

import Data.Construction

--import Control.Monad.Reader

import qualified Luna.Syntax.Model.Builder.Type as Type
import           Luna.Syntax.Model.Builder.Type (MonadTypeBuilder, TypeBuilder, TypeBuilderT)

import Luna.Syntax.Model.Builder.Self (MonadSelfBuilder, SelfBuilderT, self, setSelf, buildMe, buildAbsMe)
import qualified Luna.Syntax.Model.Builder.Self as Self

import Type.Bool

import Luna.Syntax.AST.Layout (Static, Dynamic)



newtype Tagged t a = Tagged a deriving (Show, Eq, Ord, Functor, Traversable, Foldable)

makeWrapped ''Tagged


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------



class HasIdx a where idx :: Lens' a (Index a)


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------



----------------------------
-- === TypeConstraint === --
----------------------------

-- === Definitions === --

newtype TypeConstraint (ctx :: * -> * -> Constraint) t (tp :: *) m a = TypeConstraint (m a) deriving (Show)

makeWrapped ''TypeConstraint


class Equality_Full a b
instance a ~ b => Equality_Full a b

class Equality_M1 a b
instance (a ~ ma pa, b ~ mb pb, ma ~ mb) => Equality_M1 a b

class Equality_M2 a b
instance (a ~ m1a (m2a pa), b ~ m1b (m2b pb), m1a ~ m1b, m2a ~ m2b) => Equality_M2 a b 

class Equality_M3 a b
instance (a ~ m1a (m2a (m3a pa)), b ~ m1b (m2b (m3b pb)), m1a ~ m1b, m2a ~ m2b, m3a ~ (m3b :: ([*] -> *) -> *)) => Equality_M3 a b 
-- FIXME[WD]: remove the kind constraint above


-- === Utils === ---

constrainType :: Proxy ctx -> t -> Proxy tp -> TypeConstraint ctx t tp m a -> m a
constrainType _ _ _ = unwrap'

constrainTypeEq :: t -> Proxy tp -> TypeConstraint Equality_Full t tp m a -> m a
constrainTypeM1 :: t -> Proxy tp -> TypeConstraint Equality_M1   t tp m a -> m a
constrainTypeM2 :: t -> Proxy tp -> TypeConstraint Equality_M2   t tp m a -> m a
constrainTypeM3 :: t -> Proxy tp -> TypeConstraint Equality_M3   t tp m a -> m a
constrainTypeEq = constrainType (p :: P Equality_Full)
constrainTypeM1 = constrainType (p :: P Equality_M1)
constrainTypeM2 = constrainType (p :: P Equality_M2)
constrainTypeM3 = constrainType (p :: P Equality_M3)


-- === Instances === --

instance Applicative m => Applicative (TypeConstraint ctx t tp m) where pure       = wrap' ∘ pure                         ; {-# INLINE pure   #-}
                                                                        (<*>)  f a = wrap' $ unwrap' f <*> unwrap' a      ; {-# INLINE (<*>)  #-}
instance Monad    m    => Monad       (TypeConstraint ctx t tp m) where (>>=) tc f = wrap' $ unwrap' tc >>= unwrap' <$> f ; {-# INLINE (>>=)  #-}
instance Functor  m    => Functor     (TypeConstraint ctx t tp m) where fmap     f = wrapped %~ fmap f                    ; {-# INLINE fmap   #-}
instance MonadFix m    => MonadFix    (TypeConstraint ctx t tp m) where mfix     f = wrap' $ mfix $ unwrap' <$> f         ; {-# INLINE mfix   #-}
instance MonadIO  m    => MonadIO     (TypeConstraint ctx t tp m) where liftIO     = wrap' ∘ liftIO                       ; {-# INLINE liftIO #-}
instance                  MonadTrans  (TypeConstraint ctx t tp)   where lift       = wrap'                                ; {-# INLINE lift   #-}


----instance {-# OVERLAPPABLE #-} (Monad m, Builder t (a x) m, (tp) ~ (a)) => Builder t (a x) (TypeConstraint t (tp y) m) where register = lift ∘∘ register
--instance {-# OVERLAPPABLE #-} (Monad m, Builder t (a x) m, b ~ a x, tp ~ tpa (tpx :: (* -> *) -> *), tpa ~ a) => Builder t b (TypeConstraint t tp m) where register = lift ∘∘ register


-- Registration time type constraint

instance {-# OVERLAPPABLE #-} (Monad m, Register t a m, ctx a tp) => Register t a (TypeConstraint ctx t  tp m) where register_ = lift ∘∘ register_
instance {-# OVERLAPPABLE #-} (Monad m, Register t a m)           => Register t a (TypeConstraint ctx t' tp m) where register_ = lift ∘∘ register_



----------------------
-- === Register === --
----------------------
-- | The `register` function can be used to indicate that a particular element is "done".
--   It does not provide any general special meaning. In general, this information can be lost when not used explicitly.
--   For a specific usage look at the `Network` builder, where `register` is used to add type constrains on graph nodes and edges.
--   The `t` parameter is the type of registration, like `Node` or `Edge`. Please keep in mind, that `Node` indicates a "kind" of a structure.
--   It does not equals a graph-like node - it can be a "node" in flat AST representation, like just an ordinary term.


data ELEMENT    = ELEMENT    deriving (Show)
data CONNECTION = CONNECTION deriving (Show)

class Monad m => Register t a m where 
    register_ :: t -> a -> m ()


-- === Utils === --

registerM :: Register t a m => t -> m a -> m a
registerM t ma = do
    a <- ma
    register_ t a
    return a
{-# INLINE registerM #-}

register :: Register t a m => t -> a -> m a
register t a = a <$ register_ t a ; {-# INLINE register #-}


-- === Instances === --

instance Register t a m => Register t a (Graph.GraphBuilderT n e m) where register_     = lift ∘∘ register_ ; {-# INLINE register_ #-}
instance Register t a m => Register t a (StateT                s m) where register_     = lift ∘∘ register_ ; {-# INLINE register_ #-}
instance Register t a m => Register t a (TypeBuilderT          s m) where register_     = lift ∘∘ register_ ; {-# INLINE register_ #-}
instance Register t a m => Register t a (SelfBuilderT          s m) where register_     = lift ∘∘ register_ ; {-# INLINE register_ #-}
instance                   Register t a IO                          where register_ _ _ = return ()         ; {-# INLINE register_ #-}
instance                   Register t a Identity                    where register_ _ _ = return ()         ; {-# INLINE register_ #-}




------------------------------
-- === Graph references === --
------------------------------

-- === Definitions === --

data Ptr i = Ptr i         deriving (Show, Eq, Ord, Functor, Traversable, Foldable)
data Ref a = Ref (Ptr Int) deriving (Show, Eq, Ord, Functor, Traversable, Foldable)

makeWrapped ''Ptr
makeWrapped ''Ref

type family Target a

class HasPtr   a where ptr   :: Lens' a (Ptr (Index  a))
class HasRef   a where ref   :: Lens' a (Ref (Target a))

class Reader m a where read  :: Ref a -> m a
class Writer m a where write :: Ref a -> a -> m ()


-- === Instances === --

-- Ptr type instances

type instance Index  (Ptr i) = i
instance      HasIdx (Ptr i) where idx = wrapped'
instance      HasPtr (Ptr i) where ptr = id

-- Ref type instances

type instance Unlayered  (Ref a) = a
type instance Destructed (Ref a) = a
type instance Target     (Ref a) = a
type instance Index      (Ref a) = Index (Unwrapped (Ref a))
instance      HasRef     (Ref a) where ref = id
instance      HasIdx     (Ref a) where idx = ptr ∘ idx
instance      HasPtr     (Ref a) where ptr = wrapped'

-- Ref construction

instance (MonadGraphBuilder n e m, Castable a n) => Constructor m (Ref (Node a)) where 
    construct n = Ref ∘ Ptr <$> Graph.modify (nodes $ swap ∘ ixed add (cast ast)) where
        ast = unwrap' n :: a

instance (MonadGraphBuilder n e m, Castable (Edge src tgt) e) => Constructor m (Ref (Edge src tgt)) where 
    construct e = Ref ∘ Ptr <$> Graph.modify (edges $ swap ∘ ixed add (cast e)) where

instance Constructor m (Ref ref) => LayerConstructor m (Ref ref) where
    constructLayer = construct ; {-# INLINE constructLayer #-}

-- Ref reading / writing

instance (MonadGraphBuilder n e m, Castable n a) => Reader m (Node a) where
    read ref = Node ∘ cast ∘ index_ (ref ^. idx) ∘ view nodes <$> Graph.get ; {-# INLINE read #-}

instance (MonadGraphBuilder n e m, Castable a n) => Writer m (Node a) where
    write ref val = Graph.modify_ $ nodes %~ unchecked inplace insert_ (ref ^. idx) (cast $ unwrap' val) ; {-# INLINE write #-}

-- Conversions

instance Castable a a' => Castable (Ref a) (Ref a') where cast = rewrap ; {-# INLINE cast #-}


--------------------------------
-- === Network Structures === --
--------------------------------

data Network (ls :: [*]) = Network

newtype Node       a = Node a                   deriving (Show, Eq, Ord, Functor, Traversable, Foldable)
data    Edge src tgt = Edge (Ref src) (Ref tgt) deriving (Show, Eq, Ord)
type    Link       a = Edge a a

makeWrapped ''Node


-- === Utils === --

edge :: Ref (Node src) -> Ref (Node tgt) -> Edge src tgt
edge src tgt = Edge (rewrap src) (rewrap tgt)


type family Connection src dst
class Connectible src dst m where connection :: src -> dst -> m (Connection src dst)


type instance Connection (Ref a) (Ref b) = Ref (Connection a b)
type instance Connection (Node a) (Node b) = Edge a b

instance (LayerConstructor m c, Register CONNECTION c m, Unlayered c ~ Edge src tgt, c ~ Connection (Ref (Node src)) (Ref (Node src))) 
      => Connectible (Ref (Node src)) (Ref (Node src)) m where
         connection src tgt = register CONNECTION =<< constructLayer (edge src tgt)

--connection :: (LayerConstructor m c, Register CONNECTION c m, Unlayered c ~ Edge src tgt) => Ref (Node src) -> Ref (Node tgt) -> m c
--connection src tgt = register CONNECTION =<< constructLayer (edge src tgt)


-- === Instances === --

type instance Unlayered (Node a) = a
instance      Layered   (Node a)

instance Monad m => LayerConstructor m (Node a) where
    constructLayer = return ∘ Node ; {-# INLINE constructLayer #-}

instance (Castable (Ref src) (Ref src'), Castable (Ref tgt) (Ref tgt')) => Castable (Edge src tgt) (Edge src' tgt') where 
    cast (Edge src tgt) = Edge (cast src) (cast tgt) ; {-# INLINE cast #-}

instance Castable a a' => Castable (Node a) (Node a') where
    cast = wrapped %~ cast


---------------------------
-- === Network Terms === --
---------------------------

-- === Definitions === --

type family TermWrapper (a :: *) :: * -> [*] -> *

data    Raw      (ls :: [*]) = Raw Data                                deriving (Show)

newtype Lit   rt (ls :: [*]) = Lit   (Term (Network ls) Term.Lit   rt) deriving (Show)
newtype Val   rt (ls :: [*]) = Val   (Term (Network ls) Term.Val   rt) deriving (Show)
newtype Thunk rt (ls :: [*]) = Thunk (Term (Network ls) Term.Thunk rt) deriving (Show)
newtype Expr  rt (ls :: [*]) = Expr  (Term (Network ls) Term.Expr  rt) deriving (Show)
newtype Draft rt (ls :: [*]) = Draft (Term (Network ls) Term.Draft rt) deriving (Show)


-- === Instances === --

-- Wrappers

makeWrapped ''Raw

makeWrapped ''Lit
makeWrapped ''Val
makeWrapped ''Thunk
makeWrapped ''Expr
makeWrapped ''Draft

-- Term bindings

type instance TermWrapper Term.Lit   = Lit
type instance TermWrapper Term.Val   = Val
type instance TermWrapper Term.Thunk = Thunk
type instance TermWrapper Term.Expr  = Expr
type instance TermWrapper Term.Draft = Draft

-- Records

type instance RecordOf (Lit   rt ls) = RecordOf (Unwrapped (Lit   rt ls))
type instance RecordOf (Val   rt ls) = RecordOf (Unwrapped (Val   rt ls))
type instance RecordOf (Thunk rt ls) = RecordOf (Unwrapped (Thunk rt ls))
type instance RecordOf (Expr  rt ls) = RecordOf (Unwrapped (Expr  rt ls))
type instance RecordOf (Draft rt ls) = RecordOf (Unwrapped (Draft rt ls))

instance IsRecord (Lit   rt ls) where asRecord = wrapped' ∘ asRecord
instance IsRecord (Val   rt ls) where asRecord = wrapped' ∘ asRecord
instance IsRecord (Thunk rt ls) where asRecord = wrapped' ∘ asRecord
instance IsRecord (Expr  rt ls) where asRecord = wrapped' ∘ asRecord
instance IsRecord (Draft rt ls) where asRecord = wrapped' ∘ asRecord

-- Conversions

instance Castable (Lit   rt ls) (Raw ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Val   rt ls) (Raw ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Thunk rt ls) (Raw ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Expr  rt ls) (Raw ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Draft rt ls) (Raw ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}

instance Castable (Raw ls) (Lit   rt ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Raw ls) (Val   rt ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Raw ls) (Thunk rt ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Raw ls) (Expr  rt ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}
instance Castable (Raw ls) (Draft rt ls) where cast = wrap' ∘ cast ∘ unwrap' ; {-# INLINE cast #-}



--------------------
-- === Layers === --
--------------------

-- === Definition === --

data Layer t a = Layer (LayerData (Layer t a)) a
type family AttachedData d a


-- === Utils === --

type family LayerData l where LayerData (Layer t a) = Tagged t (AttachedData t (Uncovered a))


-- === Instances === --

deriving instance (Show (AttachedData t (Uncovered a)), Show a) => Show (Layer t a)

type instance Unlayered (Layer t a) = a
instance      Layered (Layer t a) where
    layered = lens (\(Layer _ a) -> a) (\(Layer d _) a -> Layer d a) ; {-# INLINE layered #-}

instance (Maker m (LayerData (Layer t a)), Functor m)
      => LayerConstructor m (Layer t a) where
    constructLayer a = flip Layer a <$> make ; {-# INLINE constructLayer #-}

instance (Castable a a', Castable (LayerData (Layer t a)) (LayerData (Layer t' a')))
      => Castable (Layer t a) (Layer t' a') where
    cast (Layer d a) = Layer (cast d) (cast a) ; {-# INLINE cast #-}



--------------------------
-- === Basic layers === --
--------------------------

-- === Note === --

data Note = Note deriving (Show)
type instance AttachedData Note t = String

instance Monad m => Maker m (Tagged Note String) where make = return $ Tagged $ ""



--------------------
-- === Shell === ---
--------------------

data (layers :: [*]) :< (a :: [*] -> *) = Shell (ShellStrcture layers (a layers))

type family ShellStrcture ls a where 
    ShellStrcture '[]       a = Cover a
    ShellStrcture (l ': ls) a = Layer l (ShellStrcture ls a)


-- === Instances === --

deriving instance Show (Unwrapped (ls :< a)) => Show (ls :< a)

makeWrapped ''(:<)
type instance Unlayered (ls :< a) = Unwrapped (ls :< a)
instance      Layered   (ls :< a)

instance Monad m => LayerConstructor m (ls :< a) where
    constructLayer = return ∘ wrap' ; {-# INLINE constructLayer #-}

instance Castable (Unwrapped (ls :< a)) (Unwrapped (ls' :< a')) => Castable (ls :< a) (ls' :< a') where
    cast = wrapped %~ cast ; {-# INLINE cast #-}



------------------------------------
-- === Network Implementation === --
------------------------------------

type instance Layout (Network ls) term rt = Ref $ Link (ls :< TermWrapper term rt)



-----------------------------------------
-- === Abstract building utilities === --
-----------------------------------------

class    Builder t el m  a where build :: t -> el -> m a
instance Builder I el m  a where build = impossible ; {-# INLINE build #-}
instance Builder t I  m  a where build = impossible ; {-# INLINE build #-}
instance Builder t el IM a where build = impossible ; {-# INLINE build #-}
--instance Builder t el m  I where build = impossible ; {-# INLINE build #-} -- Commented out because it prevents from working the hack of star_draft etc constructors


-- === Utils === --

type ElemBuilder = Builder ELEMENT
buildElem :: ElemBuilder el m a => el -> m a
buildElem = build ELEMENT ; {-# INLINE buildElem #-}


-- === Instances === --

instance ( SmartCons el (Uncovered a)
         , CoverConstructor m a
         , Register ELEMENT a m
         , MonadSelfBuilder s m
         , Castable a s
         ) => Builder ELEMENT el m a where 
    build _ el = register ELEMENT =<< buildAbsMe (constructCover $ cons el)
    {-# INLINE build #-}



-------------------------------
-- === Node constructors === --
-------------------------------

star :: ElemBuilder Star m a => m a
star = buildElem Star

unify :: ( MonadFix m
         , ElemBuilder (Unify (Connection b u)) m u
         , Connectible a u m
         , Connectible b u m
         , Connection b u ~ Connection a u
         ) => a -> b -> m u
unify a b = mdo
    ca  <- connection a out
    cb  <- connection b out
    out <- buildElem $ Unify ca cb
    return out



star_draft :: (ElemBuilder Star m a, Uncovered a ~ Draft Static ls) => m a
star_draft = buildElem Star

unify_draft :: ( MonadFix m
               , ElemBuilder (Unify (Connection b u)) m u
               , Connectible a u m
               , Connectible b u m
               , Connection b u ~ Connection a u
               , Uncovered u ~ Draft Static ls
               ) => a -> b -> m u
unify_draft = unify 


-------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST --
-------------------------------------------------------------------------------------------------------------------------------------------------

type NetLayers = '[Note]

type NetGraph = Graph (NetLayers :< Raw) (Link (NetLayers :< Raw))

buildNetwork  = runIdentity ∘ buildNetworkM
buildNetworkM = rebuildNetworkM def
rebuildNetworkM (net :: NetGraph) = flip Self.evalT (undefined ::        Ref $ Node (NetLayers :< Raw))
                                  ∘ flip Type.evalT (Nothing   :: Maybe (Ref $ Node (NetLayers :< Raw)))
                                  ∘ constrainTypeM1 CONNECTION (Proxy :: Proxy $ Ref c)
                                  ∘ constrainTypeM3 ELEMENT    (Proxy :: Proxy $ Ref $ Node (NetLayers :< n))
                                  ∘ flip Graph.runT net
{-# INLINE   buildNetworkM #-}
{-# INLINE rebuildNetworkM #-}

foo :: IO (Ref $ Node (NetLayers :< Draft Static), NetGraph)
foo = rebuildNetworkM def
    $ do
    s <- star_draft
    sv <- read s
    write s sv

    star_draft
    star_draft

    u <- unify_draft s s

    --(u :: Ref $ Node $ '[Note] :< Draft Static) <- unify s s
            --c <- connection s s


            --(s1 :: Ref $ Node $ '[Note] :< Draft Static) <- star_draft
            --(s2 :: Ref $ Node $ '[Note] :< Draft Static) <- star_draft

            --(cs :: Ref $ Link ('[Note] :< Draft Static)) <- connection s1 s2 

            --let u = cons (Unify cs cs) :: Draft Static '[Note]






    return u
    --star_draft


mytest :: IO ()
mytest = do 

    (s2, g) <- foo
    print s2
    print g

    --print $ caseTest s $ do
        --match $ \ -> "oh"
        --match $ \ANY -> "oh"

    return ()

--Ref $ Link $ '[Note] :> Draft Static --> read
--      Link $ '[Note] :> Draft Static --> target
--Ref $ Node $ '[Note] :> Draft Static --> read
--      Node $ '[Note] :> Draft Static --> uncover
--                        Draft Static '[Note]

---

--Ref $ Node '[Note] Static Draft --> read
--      Node '[Note] Static Draft --> uncover
--      Term (Network '[Note]) Static Draft

--Ref $ Link $ Node '[Note] Static Draft --> read
--      Link $ Node '[Note] Static Draft --> target
--       Ref $ Node '[Note] Static Draft --> read
--             Node '[Note] Static Draft --> uncover
--             Term (Network '[Note]) Static Draft


--Ref $ Link $ Node ('[Note] :> Draft Static) --> read
--      Link $ Node ('[Note] :> Draft Static) --> target
--       Ref $ Node ('[Note] :> Draft Static) --> read
--             Node ('[Note] :> Draft Static) --> uncover
--                              Draft Static '[Note]

--Ref $ Link $ '[Note] :> Draft Static --> read
--      Link $ '[Note] :> Draft Static --> target
--       Ref $ '[Note] :> Draft Static --> read
--             '[Note] :> Draft Static --> uncover
--                        Draft Static '[Note]
