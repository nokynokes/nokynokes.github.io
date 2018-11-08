module Components.Shaders.ChromaticDelay exposing (..)

import WebGL exposing (..)
import WebGL.Texture
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)

type alias Vertex =
    { position : Vec3
    }


type alias Uniforms =
  { iResolution : Vec3
  , iGlobalTime : Float
  , iChannel0 : WebGL.Texture
  }

type alias Varying =
  { vFragCoord : Vec2 }

vert : Shader Vertex Uniforms Varying
vert =
  [glsl|
        precision mediump float;
        attribute vec3 position;
        varying vec2 vFragCoord;
        uniform vec3 iResolution;
        void main () {
            gl_Position = vec4(position, 1.0);
            vFragCoord = position.xy;
        }
    |]

frag : Shader {} Uniforms Varying
frag =
  [glsl|
        precision mediump float;
        varying vec2 vFragCoord;
        uniform float iGlobalTime;
        uniform vec3 iResolution;
        uniform sampler2D iChannel0;
        const float RADIUS = 0.5;
        const float AB_SCALE  = 0.5;

        float diskColorr(in vec2 uv, vec2 offset)
        {
            uv = uv - smoothstep(0.01,1.8,texture2D(iChannel0, (uv*1.0 - vec2((iGlobalTime+0.06) /3.0,(iGlobalTime+0.06) /8.0)) + offset).r) * 0.3;

            float d = length(uv)-RADIUS;
            return smoothstep(0.01,0.015,d);
        }
        float diskColorg(in vec2 uv, vec2 offset)
        {
            uv = uv - smoothstep(0.01,1.8,texture2D(iChannel0, (uv*1.0 - vec2(iGlobalTime /3.0,(iGlobalTime) /8.0)) + offset).r) * 0.3;

            float d = length(uv)-RADIUS;
            return smoothstep(0.01,0.015,d);
        }
        float diskColorb(in vec2 uv, vec2 offset)
        {
            uv = uv - smoothstep(0.01,1.8,texture2D(iChannel0, (uv*1.0 - vec2((iGlobalTime-0.06) /3.0,(iGlobalTime-0.06) /8.0)) + offset).r) * 0.3;

            float d = length(uv)-RADIUS;
            return smoothstep(0.01,0.015,d);
        }

        void mainImage(out vec4 fragColor, in vec2 fragCoord)
        {
        	vec2 uv = fragCoord;

            vec3 color = vec3(0);
            color.r+=diskColorr(uv, vec2(0.00, 0.00) * AB_SCALE);
            color.g+=diskColorg(uv, vec2(0.00, 0.00) * AB_SCALE);
            color.b+=diskColorb(uv, vec2(0.00, 0.00) * AB_SCALE);
            fragColor = vec4(color, 1.0);
        }


        void main(){
          mainImage(gl_FragColor, vFragCoord);
        } |]
