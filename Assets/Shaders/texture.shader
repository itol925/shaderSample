// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// phong模型下的纹理测试

Shader "Custom/texture" {
	Properties {
		_Color("Color Tint", Color) = (1, 1, 1, 1) //整体色调
		_MainTex("MainTex", 2D) = "white" {} //white为内置纹理的名字，纯白纹理
		
		//镜面反射属性
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
		SubShader{
			Pass{
			Tags{ "LightModel" = "FowardBase"}

			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

		sampler2D _MainTex;
		float4 _MainTex_ST; // 注：必须定义纹理属性　纹理名_ST，否则取不到uv
		fixed3 _Color;

		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex : POSITION;
			fixed3 normal : NORMAL;
			float3 texcoord : TEXCOORD0;
		};
		struct v2f {
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float2 uv : TEXCOORD2;
		};
		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // 获取纹理UV坐标

			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // 模型空间坐标转世界空间
			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb; // 采样底色
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;	// 环境光
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir)); // 漫反射
			
			fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
			//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss); //镜面反射

			//fixed3 halfDir = normalize(worldLightDir + viewDir);
			//fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss); //blinn-phong镜面反射
			return fixed4(ambient + diffuse + specular, 1); 
		}
		ENDCG
}
	}
}
