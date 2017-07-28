// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


//逐像素漫反射光照

Shader "Custom/diffuse_frag" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}

		SubShader{
			Pass{
				Tags {"LightMode" = "ForwardBase"} //只有定义了正确的LightMode才能得到一些Unity内置的光照变量，如_LightColor0
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"		// 包括一些unity内置变量

				fixed4 _Diffuse;
				
				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
							};
				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 worldNormal : TEXCOORD0;
				};

				// 漫反射部分的计算都在顶点着色器中进行
				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldDir(v.normal);			// 世界空间下的法向量

					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;					// 获取环境光部分
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);		// 世界空间下的光的方向

					// saturate(x) : 把x截取在[0, 1]内，如果是矢量，则截取每一个分量
					fixed intensity = saturate(dot(i.worldNormal, worldLight));		// 计算该点漫反射强度　
														
					//计算漫反射．_LightColor0：入射光. 
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * intensity;
					fixed3 color = ambient + diffuse;
					return fixed4(color, 1);
				}
			ENDCG
		}
	}
}
