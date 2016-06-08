{-# LANGUAGE DataKinds #-}

module Utils.Shader (
    ShaderBox(..)
  , createShaderBox
  ) where

import           Prologue                            hiding (Bounded)
import           Development.Placeholders
import           Utils.Vector

import           Control.Lens
import           Data.Maybe                          (catMaybes, fromMaybe)

import qualified Data.Array.Linear                   as A
import           Data.Array.Linear.Color.Class
import           Graphics.Rendering.GLSL.SDF         (Object, diff, merge, object, translate)
import           Graphics.Rendering.GLSL.SDF.Figures
import           Graphics.Shading.Flat
import           Graphics.Shading.Material
import           Graphics.Shading.Pattern

import           Math.Space.Metric.Bounded

import qualified Language.GLSL                       as GLSL
import qualified Language.GLSL.Builder               as GLSL

import qualified Graphics.API                        as G



type Size   = Vector2 Double
type Shader = String

data ShaderBox = ShaderBox { _shader       :: Shader
                           , _size         :: Size
                           } deriving (Show, Eq)

makeLenses ''ShaderBox

toFloat :: Double -> Float
toFloat = realToFrac

toDouble :: Float -> Double
toDouble = realToFrac

toExpr :: Double -> GLSL.Expr
toExpr = GLSL.FloatConstant . toFloat

getSize :: G.Figure -> Size
getSize (G.Square s)      = Vector2 s s
getSize (G.Rectangle w h) = Vector2 w h
getSize (G.Circle d)      = Vector2 (2.0 * d) (2.0 * d)

getBound :: G.Figure -> A.BVec 2 Float
getBound shape = let Vector2 w h = getSize shape in A.vec2 (toFloat w) (toFloat h)

toBound :: Size -> A.BVec 2 Float
toBound (Vector2 x y) = A.vec2 (toFloat x) (toFloat y)

fromMaterial :: G.Material -> Material (Layer GLSL.Expr)
fromMaterial (G.SolidColor r g b a) = Material $ [ Fill . Solid $ color4 (toExpr r) (toExpr g) (toExpr b) (toExpr a) ]

-- createComponent :: G.Component -> Bounded Float (Object 2)
-- createComponent component@(G.Component shape color) =
--     Bounded (getBound shape) (createObject component)


-- -- calculateSize :: [G.Component] -> (Double, Double)
-- -- calculateSize components =

-- -- TODO: calculate boundings
-- createObject :: G.Component -> Object 2
-- createObject (G.Component shape color) = (createShape shape) & material .~ (createMtl color)

-- createCompositeComponent :: [G.Component] -> Maybe (Object 2)
-- createCompositeComponent components = createCompositeObject $ fmap createObject components

-- createCompositeObject :: [Object 2] -> Maybe (Object 2)
-- createCompositeObject (object:objects@(x:xs)) = Just $ foldl merge object objects
-- createCompositeObject (object:_)              = Just object
-- createCompositeObject []                      = Nothing

-- -- TODO: compile all components
-- createShader :: G.Shader -> (String, (Double, Double))
-- createShader (G.Shader (component:components)) = createShader' component
-- createShader _ = ("", (0.0, 0.0))

-- createShader' :: G.Component -> (String, (Double, Double))
-- createShader' component@(G.Component shape _) = (fst $ GLSL.compileGLSL $ createComponent component, getSize shape)


-- helpers

mergeObjects :: [Object 2] -> Maybe (Object 2)
mergeObjects (object:objects@(_:_)) = Just $ foldl merge object objects
mergeObjects (object:_)             = Just object
mergeObjects []                     = Nothing

-- calc object

fromFigure :: G.Figure -> Object 2
fromFigure (G.Square s)      = hyperrectangle (A.vec2 (toExpr s) (toExpr s) :: A.BVec 2 GLSL.Expr)
fromFigure (G.Rectangle w h) = hyperrectangle (A.vec2 (toExpr w) (toExpr h) :: A.BVec 2 GLSL.Expr)
fromFigure (G.Circle d)      = ball (toExpr d)

fromPrimitive :: G.Primitive -> Object 2
fromPrimitive (G.Primitive figure point attr) = fromFigure figure

fromShape :: G.Shape -> Object 2
fromShape (G.Single    primitive)     = fromPrimitive primitive
fromShape (G.Merge     shape1 shape2) = merge (fromShape shape1) (fromShape shape2)
fromShape (G.Subtract  shape1 shape2) = diff  (fromShape shape1) (fromShape shape2)
fromShape (G.Intersect shape1 shape2) = $notImplemented

fromSurface :: G.Surface -> Object 2
fromSurface (G.ShapeSurface shape) = fromShape shape
fromSurface G.PolygonSurface       = $notImplemented
fromSurface G.NumbsSurface         = $notImplemented

fromSurfaces :: [G.Surface] -> Maybe (Object 2)
fromSurfaces surfaces = mergeObjects $ fromSurface <$> surfaces

fromGeoComponent :: G.GeoComponent -> Maybe (Object 2)
fromGeoComponent (G.GeoElem  surfaces)   = fromSurfaces surfaces
fromGeoComponent (G.GeoGroup geometries) = fromGeometries geometries

fromGeometry :: G.Geometry -> Maybe (Object 2)
fromGeometry (G.Geometry geoComp trans matMay) = go <$> fromGeoComponent geoComp where
    (G.Transformation _ _ dx dy _ _) = trans
    tr = fromListUnsafe [toExpr dx, toExpr dy, toExpr 0.0] :: A.BVec 3 GLSL.Expr
    go :: Object 2 -> Object 2
    go = goMat . goTrans
    goMat :: Object 2 -> Object 2
    goMat object = case matMay of
        Just mat -> object & material .~ (fromMaterial mat)
        Nothing  -> object
    goTrans :: Object 2 -> Object 2
    goTrans object = case (dx, dy) of
        (0.0, 0.0) -> object
        (dx,  dy)  -> translate tr object

fromGeometries :: [G.Geometry] -> Maybe (Object 2)
fromGeometries geometries = mergeObjects . catMaybes $ fromGeometry <$> geometries

createShader :: Size -> Maybe (Object 2) -> Shader
createShader size objectMay = fromMaybe "" $ compileObject <$> objectMay where
    compileObject :: Object 2 -> Shader
    compileObject object = fst $ GLSL.compileGLSL $ Bounded (toBound size) object

-- calc size

calcGeoSize :: G.Geometry -> Size
calcGeoSize geo = Vector2 1.0 1.0
-- calcGeoSize (G.GeoElem  surfaces)   = Vector2 1.0 1.0
-- calcGeoSize (G.GeoGroup geometries) = Vector2 1.0 1.0

createShaderBox :: G.Geometry -> ShaderBox
createShaderBox geometry = ShaderBox (createShader size objMay) size
    where size   = calcGeoSize geometry
          objMay = fromGeometry geometry

--

test :: IO ()
test = do
    let geometry  = G.Geometry geoComp trans justMat
        trans     = def
        justMat   = Just $ G.SolidColor 1.0 0.0 0.0 1.0
        geoComp   = G.GeoElem [surface]
        surface   = G.ShapeSurface shape
        shape     = G.Single primitive
        primitive = G.Primitive figure def def
        figure    = G.Square 0.25
        ShaderBox shaderTxt (Vector2 w h) = createShaderBox geometry
    return ()




-- ====== test (TODO: remove) ====== --

mtl1     = Material $ [ Fill            . Solid $ color4 0.7 0.2 0.2 1.0
                      , Border 10.0     . Solid $ color4 0.0 1.0 0.0 1.0
                      , Shadow 10.0 2.0 . Solid $ color4 0.0 0.0 0.0 0.2
                      ] :: Material (Layer GLSL.Expr)

mtl2     = Material $ [ Fill            . Solid $ color4 0.6 0.6 0.6 1.0
                      ] :: Material (Layer GLSL.Expr)

mtl3     = Material $ [ Fill            . Solid $ color4 0.3 0.3 0.3 1.0
                      ] :: Material (Layer GLSL.Expr)


myBall :: Bounded Float (Object 2)
myBall = Bounded (A.vec2 400 400) (ball 100.0)
       & material .~ mtl1

testRaw :: IO ()
testRaw = do
    putStrLn "HSProcessing test started."

    let objBall = myBall
        [gw', gh'] = toList $ objBall ^. bounds
        gw = gw'/2;
        gh = gh'/2;

    let (str, u) = GLSL.compileGLSL objBall
    putStrLn str

    putStrLn "HSProcessing test finished."

