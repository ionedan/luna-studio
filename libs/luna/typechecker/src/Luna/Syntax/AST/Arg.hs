module Luna.Syntax.AST.Arg where

import Prelude.Luna

import Luna.Syntax.AST.Name

data Arg a = Arg { __aname :: Maybe Name , __arec :: a } deriving (Show, Eq, Ord, Functor, Foldable, Traversable)

instance Repr s a => Repr s (Arg a) where repr (Arg n a) = "Arg" <+> repr n <+> repr a



data NamedArg a = NamedArg Name a deriving (Show, Eq, Ord, Functor, Foldable, Traversable)
