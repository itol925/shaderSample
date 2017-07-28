//使用Properties

Shader "Custom/useProperties" {
	Properties{
		_Color("color tint", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader{
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color; //注：必须定义一个与属性名称和类型都匹配的变量来关联属性

			struct a2v {
				float3 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 c = v.color;
				c *= _Color.rgb;
				return fixed4(c, 1);
			}
			ENDCG
		}
	}
}
