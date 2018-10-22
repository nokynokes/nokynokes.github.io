module Funkshader exposing (..)

import WebGL exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)

type alias Vertex =
    { position : Vec3
    }


type alias Uniforms =
  { iResolution : Vec3
   , iGlobalTime : Float }

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

        const float PI = 3.14159;



        void mainImage( out vec4 fragColor, in vec2 fragCoord ){
        	//coordinate system
            vec2 pixel = fragCoord;

            //wave parameters
            vec2 dotFrequency = vec2(12.0, 7.0) * PI;

            vec2 offsetAmplitude = vec2(2.0 * sin(iGlobalTime));
            vec2 offsetFrequency= vec2(2.0) * PI;
            vec2 offsetVelocity= vec2(1.0);

            //offset equation
            vec2 offset= offsetAmplitude * sin( offsetFrequency * pixel + (offsetVelocity * iGlobalTime));


            //y-component of visual
            float value= sin( pixel.y * dotFrequency.y + offset.x) / 2.;

            //x-component of visual
            value+= sin( pixel.x * dotFrequency.x + offset.y) /2.;

            //boundary parameters
            float threshold= 1.3 * sin((0.5 * iGlobalTime) + ( 0.5 * pixel.x));
            float epsilon= 0.3;

            vec3 color;

            if (value > threshold + epsilon) {
                color= vec3( 0.5 , 0.5 + sin(iGlobalTime ) / 2.0, 0.0);
            }
            else if (value < threshold - epsilon) {
                color= vec3(0.5 + sin(iGlobalTime) / -2.0, 1.0 , 0.5 + sin(iGlobalTime) / 2.0);
            }
            else {
                color= vec3(0.5 + sin(iGlobalTime) / -2.0, 0.0 , 0.5);
            }

        	fragColor = vec4( color, 1.0);
        }

        void main(){
          mainImage(gl_FragColor, vFragCoord);
        } |]
