import WebGL exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)

import Html exposing (..)
import Html.Lazy exposing (..)
import Html.Attributes as Attrs exposing (..)
import Window exposing (Size)
import Task
import Time exposing (Time)
import AnimationFrame

import Components.Shaders.Funkshader exposing (..)
import Bootstrap.Grid as Grid exposing (..)

import Bootstrap.Navbar as Navbar
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block

import Bootstrap.Utilities.Spacing as Spacing

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
  , navbarState : Navbar.State
  }





type Msg
  = Resize Size
  | Tick Time
  | NavbarMsg Navbar.State



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Resize s -> { model | size = s } ! []
    Tick t -> { model | time = model.time + t } ! []
    NavbarMsg state -> {model | navbarState = state} ! []


shaderBG : Size -> Float -> Html.Html Msg
shaderBG size time =
    WebGL.toHtml
          [ width size.width
          , height size.height
          , style
              [ ("position","fixed")
              , ("top","0")
              , ("left","0")
              --, ("z-index","-1")
              ]
          ]
          [ WebGL.entity
              vert
              frag
              mesh
              { iResolution = vec3 (toFloat size.width) (toFloat size.height) 0
              , iGlobalTime = time / 1000
              }
         ]


navBar : Navbar.State -> Html.Html Msg
navBar state =
  Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.attrs
            [ style
                [ ("margin-top","33px")
                , ("margin-bottom","33px")
                , ("margin-right","33px")
                , ("float","right")
                ]
            ]
        |> Navbar.items
            [ Navbar.itemLink [href "https://github.com/nokynokes"] [ text "GitHub"]
            , Navbar.itemLink [href "https://www.linkedin.com/in/nolan-cretney-164078106/"] [ text "LinkedIn"]
            , Navbar.itemLink [href "static/web/index.html"] [ text "Other"]
            ]
        |> Navbar.view state

logo : Html.Html Msg
logo =
  Card.config [ Card.attrs [ style [ ("margin-top","33px"),("margin-bottom","33px") ] ] ]
    |> Card.header [ class "text-left" ]
        [ img [ src "static/img/me2.png"
              , style [("max-height","150 px"),("max-width","200px"),("margin","auto")]
              ] []
        , h3 [ Spacing.mt2 ] [ text "Nolan Cretney" ] ]
    |> Card.block []
        [ Block.titleH4 [] [ text "About Me" ]
        , Block.text [] [ text "Recent Graduate from the University of Colorado, Boulder with an interest in web development. Some of my other interests lie in functional programming, and learning WebGL and glsl/hlsl development"  ]
        --, Block.custom <|
          --  Button.button [ Button.primary ] [ text "Go somewhere" ]
        ]
    |> Card.view

top : Navbar.State -> Html.Html Msg
top state =
  Grid.container [ style [("position","relative"),("z-index","1")] ]
     [ Grid.row  []
       [ Grid.col [] [ logo ]
       , Grid.col [] []
       , Grid.col [] [ lazy navBar state ]
       ]
     ]



view : Model -> Html.Html Msg
view {size, time, navbarState} =
      Html.div []
          [ top navbarState
          , shaderBG size time
          ]




init : (Model, Cmd Msg)
init =
  let
    (state, navbarCmd) = Navbar.initialState NavbarMsg
  in
    {size = Size 0 0, time = 0, navbarState = state} ! [ Task.perform Resize Window.size, navbarCmd]


subs : Model -> Sub Msg
subs model =
  Sub.batch
  [ Window.resizes Resize
  , AnimationFrame.diffs Tick
  , Navbar.subscriptions model.navbarState NavbarMsg
  ]



-- MAIN --
main : Program Never Model Msg
main = Html.program {
    init = init
    , view = view
    , update = update
    , subscriptions = subs
  }
