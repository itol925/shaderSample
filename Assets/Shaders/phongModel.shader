// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


//逐顶点　环境光＋漫反射＋高光反射　即phong光照模型　

Shader "Custom/phongModel" {
	Properties{
		// 漫反射属性
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)

		//镜面反射属性
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

		SubShader{
			Pass{
				Tags {"LightMode" = "ForwardBase"} //只有定义了正确的LightMode才能得到一些Unity内置的光照变量，如_LightColor0
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"		// 包括一些unity内置变量

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;
				
				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
							};
				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 color : COLOR;
				};

				// 获取环境光
				fixed3 getAmbient()
				{
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					return ambient;
				}

				// 获取漫反射光
				fixed3 getDiffuse(fixed3 normal)
				{
					fixed3 worldNormal = UnityObjectToWorldDir(normal);			// 世界空间下的法向量
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);		// 世界空间下的光的方向

					// saturate(x) : 把x截取在[0, 1]内，如果是矢量，则截取每一个分量
					fixed intensity = saturate(dot(worldNormal, worldLight));		// 计算该点漫反射强度　

					//计算漫反射．_LightColor0：入射光 
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * intensity;
					return diffuse;
				}

				// 获取镜面反射
				fixed3 getSpecular(float4 vertex, fixed3 normal)
				{
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 worldNormal = UnityObjectToWorldDir(normal);			// 世界空间下的法向量

					fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, vertex).xyz);
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

					return specular;
				}
				// 漫反射部分的计算都在顶点着色器中进行
				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					
					o.color = getAmbient() + getDiffuse(v.normal) + getSpecular(v.vertex, v.normal);

					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					return fixed4(i.color, 1);
				}
			ENDCG
		}
	}
}
