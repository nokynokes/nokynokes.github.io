module Background exposing (..)

import WebGL exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Html
import Balleidoscope
import TerrianRayMarch
import WebGL.Texture as Texture exposing (Texture, Error)

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

RaymarchBG : Html msg
RaymarchBG =
  WebGL.toHtml
    [ width size.width
    , height size.height
    , style [("display","block")]
    ]
    [ WebGL.entity
        TerrianRayMarch.vert
        TerrianRayMarch.frag
        mesh
        { iResolution = vec3 (toFloat size.width) (toFloat size.height) 0
        , iGlobalTime = time / 1000
        --, iChannel0 = tex2D
        }
    ]
