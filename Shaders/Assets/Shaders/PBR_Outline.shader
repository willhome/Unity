Shader "Graphics/PBR_Outline" 
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
		Tags { "RenderType"="Opaque+1" }
		LOD 200
			
		Pass
		{ 
			Name "OUTLINE"
			Cull Front
			ZTest Always
			
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
		
		
		ZTest Always
		
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
