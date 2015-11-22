﻿//The MIT License(MIT)

//Copyright(c) 2015 Phil Lira

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

Shader "Custom/PBR_OutlineInner" 
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalMap ("Normal", 2D) = "bump" {}
		
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		_OutlineThickness ("Outline Thickness", Range(0, 1)) = 0.0 
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
			
		Pass
		{
			Name "OUTLINE_INNER"
			Cull Front
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			half _OutlineThickness;
			fixed4 _OutlineColor;
			
			struct VertexInput		
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
			};
			
			struct V2F
			{
				half4 vertex : SV_POSITION;
				half3 normal : NORMAL;
			};
			
			V2F vert(VertexInput i)
			{
				V2F o;
					
				// Unity5 Does not guarantee normals and tangents to be normalized.
				// http://docs.unity3d.com/Manual/UpgradeGuide5-Shaders.html
				half3 normal = normalize(i.normal);
				
				half4 position = half4(i.vertex + normal * _OutlineThickness, 1.0);
				o.normal = i.normal;
				o.vertex = mul(UNITY_MATRIX_MVP, position);
				return o;
			}
			
			fixed4 frag(V2F i) : COLOR
			{
				return _OutlineColor;
			}			
			
			ENDCG
		}
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		
		sampler2D _MainTex;
		sampler2D _NormalMap;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_NormalMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
			
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
