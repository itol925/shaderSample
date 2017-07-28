
// 自定义vert shader的输入结构体
Shader "Custom/simple1" {
	SubShader{
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;		// 模型的顶点坐标
				float4 normal : NORMAL;			// 模型空间的法线方向[-1, 1]
				float4 texcoord : TEXCOORD0;	// 第一套纹理坐标
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};
			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5); // 法线范围在[-1, 1]，这里将颜色范围映射到[0, 1]之间
				return o;
			}

			fixed4 frag(v2f v) : SV_Target{
				return fixed4(v.color, 1);
			}
			ENDCG
		}
	}
}
