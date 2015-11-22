Shader "Custom/CurveShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BentStartPoint("BendRadius", Float) = 1.0
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 _BendRadius;
			
			float3 RotateY(float3 v, float theta)
			{
				// rotation around up vector
				// | cos(theta), 0, -sin(theta) | ( x )
				// |     0     , 0,       0     | ( y )
				// | sin(theta), 0,  cos(theta) | ( z )
				float cosT = cos(theta);
				float sinT = sin(theta);
				return float3(v.x * cosT - v.z * sinT, v.y, v.x * sinT + v.z * cosT);
			}

			float3 ApplyCurve(float3 vertex)
			{
				float radius = vertex.z - _WorldSpaceCameraPos.z;
				float3 startPointToCam = float3(_WorldSpaceCameraPos.x, _WorldSpaceCameraPos.y, radius);

				float s = vertex.x - _WorldSpaceCameraPos.x;

				// Right hand system rotates yaw right as negative angle
				float theta = s / radius;

				return RotateY(vertex.xyz, -theta);
			}

			v2f vert (appdata v)
			{
				v2f o;
								
				float4 vertex = mul(_Object2World, v.vertex);
				vertex.xyz = ApplyCurve(vertex.xyz);

				o.vertex = mul(UNITY_MATRIX_VP, vertex);
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);				
				return col;
			}
			ENDCG
		}
	}
}
