import WebGL exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Html
import Html.Lazy exposing (lazy2)
import Html.Attributes as Attrs
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src, style, classList)
import Window exposing (Size)
import Task
import Time exposing (Time)
import AnimationFrame
import Balleidoscope
import TerrianRayMarch
import WebGL.Texture as Texture exposing (Texture, Error)
import Css exposing (..)
import Css.Global as CSSG exposing (global, everything, class)
import StyleSheet exposing (..)



type alias Vertex =
     { position : Vec3 }

-- MESH --


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 -1 1 0)
          , Vertex (vec3 1 1 0)
          , Vertex (vec3 -1 -1 0)
          )
        , ( Vertex (vec3 -1 -1 0)
          , Vertex (vec3 1 1 0)
          , Vertex (vec3 1 -1 0)
          )
        ]

-- MVC --
type alias Model =
  { size : Size
  , time : Float
  --, eye : Vec3
  --, tex : Maybe WebGL.Texture
  }

-- initModel : Model
-- initModel = Model (Size 0 0) 0




type Msg
  = Resize Size
  | Tick Time
  -- | TexLoad WebGL.Texture
  -- | TexError Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Resize s -> { model | size = s } ! []
    Tick t -> { model | time = model.time + t } ! []
    -- TexLoad tex2D -> { model | tex = Just tex2D } ! []
    -- TexError _ -> Debug.crash("Error loading texture")



logoTop : Html.Html Msg
logoTop =
   toUnstyled <|
    div
      [ classList [("container",True),("clearfix",True)]]
      [ header
        [ classList [("logo",True), ("left",True)] ]
        [ ]
      , nav
        [ classList [("right",True)] ]
        [ ul []
          [ li
            []
            [ a [ ] [text "Work"] ]
          ]
        ]
      ]

shaderBG : Size -> Float -> Html.Html Msg
shaderBG size time =
  WebGL.toHtml
      [ Attrs.width size.width
      , Attrs.height size.height
      , Attrs.style [("display","block"),("position","static")]
      ]
      [ WebGL.entity
          Balleidoscope.vert
          Balleidoscope.frag
          mesh
          { iResolution = vec3 (toFloat size.width) (toFloat size.height) 0
          , iGlobalTime = time / 1000
          }
     ]



view : Model -> Html.Html Msg
view {size, time} =
      Html.div []
          [ globalStyles
          , desktopStyles
          , logoTop
          , lazy2 shaderBG size time
          ]



init : (Model, Cmd Msg)
init =
  {size = Size 0 0, time = 0} ! [ Task.perform Resize Window.size
                                -- , Texture.load "graynoise.png" |>
                                --     Task.attempt (\result -> case result of
                                --                                 Err err -> TexError err
                                --                                 Ok val -> TexLoad val )
                                ]


subs : Model -> Sub Msg
subs model =
  Sub.batch
  [ Window.resizes Resize
  , AnimationFrame.diffs Tick ]



-- MAIN --
main : Program Never Model Msg
main = Html.program {
    init = init
    , view = view
    , update = update
    , subscriptions = subs
  }
