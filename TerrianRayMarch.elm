module TerrianRayMarch exposing (..)

import WebGL exposing (..)
import WebGL.Texture
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)

-- type alias Vertex =
--     { position : Vec3
--     }


type alias Uniforms =
  { iResolution : Vec3
  , iGlobalTime : Float
  }

type alias Varying =
  { vFragCoord : Vec2 }

vert : Shader { position : Vec3 } Uniforms Varying
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

        vec3 eye = vec3(-5, -5, 10);
        const float FOV = 180.0;
        const float FD = 20.0;

        float nse(vec2 v){
        	return sin(v.y*5.0)*cos(v.x*5.56)*sin(sin(v.y*2.18)*cos(v.x*1.16))/0.65;
        }
        float dts(vec3 eye, vec3 mdir, float depth, float e, float time) {
        	for (int i = 0; i < 128; i++) {
        		vec3 ptgr = (eye + depth * mdir) + vec3(0,0,3);
        		vec2 o = vec2(-time,-time);
        		float h = nse((ptgr.xy+o) * 0.1);
        		float b = h+nse((ptgr.xy+o) * 0.7) / (0.5 * sin(iGlobalTime) + 3.0 );
        		float w = clamp(0.5+0.5*(b-h)/0.3, 0.0, 1.0 );
        		float sm = mix( b, h, w ) - 0.3*w*(1.0-w);
        		float dist = min(1.0, dot(ptgr,vec3(0.5,0.5,0.5)) + sm);
        		if (dist < 0.000001)
        			return depth;
        		depth += dist;
        		if (depth >= e)
        			return e;
        	}
        	return e;
        }
        void mainImage(out vec4 fragColor, in vec2 fc){
            vec2 fragCoord = vec2(fc.x, fc.y);
            if (fragCoord.y > 0.5) fragCoord.y = 1.0 - fragCoord.y;
            //if (fragCoord.x > 0.5) fragCoord.x = 1.0 - fragCoord.x;
            vec2 scr = vec2(1);
            float t = iGlobalTime;
        	vec3 f = normalize(vec3(0.25,1.0,-4.0) - eye+vec3(cos(t)/2.0,-sin(t)/2.0,0.0));
        	vec3 s = normalize(cross(f, vec3(0.0,0.0,1.0)));
        	vec3 u = cross(s, f);
        	float dist = dts(eye, (
        		mat4(vec4(s, 0.0),vec4(u, 0.0),vec4(-f, 0.0),vec4(0.0, 0.0, 0.0, 1.0))
        		*vec4(normalize(vec3(fragCoord - scr / 2.0, -scr.y / tan(radians(73.0+FOV) / 2.0))), 0.0)
        	).xyz, 1.0, 100.0, t);
            if (dist > 100.0){
                fragColor = vec4(1.0);
            }
        	vec4 ret = vec4(vec4(0.1,0.1,0.1,1)-vec4(0.0,0.0,0.0,smoothstep(0.0, FD, dist)))/1.0+(fragCoord.y/3.0);
        	fragColor = vec4(1.0,0.9,0.9,1.0)-vec4(vec3(0.2)+ret.rgb*3.0*ret.a,0.0);
        }

        void main(){
          mainImage(gl_FragColor, vFragCoord);
        } |]
