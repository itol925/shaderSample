// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//最简单的顶点、片元shader

Shader "Custom/simple0" {
	SubShader{
		Pass{
			CGPROGRAM
			//#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag
			
			// POSITION 语义表示将模型的顶点坐标填入
			// SV_POSITION 语义表示输出裁剪空间中的顶点坐标
			float4 vert(float4 v : POSITION) : SV_POSITION{ 
				return UnityObjectToClipPos(v);
			}
			
			// SV_Target表示输出颜色存储到一个渲染目标(默认帧缓存)中
			fixed4 frag() : SV_Target{
				return fixed4(1.0, 0.0, 0.0, 1.0);
			}

			ENDCG
		}
	}
}
