Shader "Custom/normalTexture" {
	Properties{
		_Color("Color Tint", Color) = (1, 1, 1, 1) //整体色调

		//镜面反射属性
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20

		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {} // bump为模型自带的法线信息
		_BumpScale("Bump Scale", Float) = 1
	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM
	#include "Lighting.cginc"
	#pragma vertex vert
	#pragma fragment frag

				fixed3 _Color;

			fixed4 _Specular;
			float _Gloss;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v {
				float4 vertex : POSITION;
				float4 tangent : TANGENT; // 顶点的切线方向
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				// 计算副法线 注：为什么要乘以v.tangent.w？因为与法线和切线垂直的方向有２个，w分量决定了选其中哪一个方向
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				// 构造从模型空间到切线空间的转换矩阵
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				// 或直接用macro TANGENT_SPACE_ROTATION

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz; // 获取切线空间下的顶点到光源方向
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;	// 获取切线空间下的顶点到摄像机方向
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap, i.uv);
				fixed3 tangentNormal;
				//注：由于像素纹理值范围在[0,1],法线分量范围在[-1,1]，因此在传递前会对法线进行一次package：pixel = (normal + 1)/2
				//    所以在解析时需要一次unpack：normal = pixel * 2 - 1
				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;	// 环境光
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir)); // 漫反射

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss); //blinn-phong镜面反射
				return fixed4(ambient + diffuse + specular/**/, 1);
			}
				ENDCG
			}
		}

}
