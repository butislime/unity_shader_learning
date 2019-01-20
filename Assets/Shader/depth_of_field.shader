Shader "ShaderTest/depth_of_field"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

		CGINCLUDE

		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _MainTex_TexelSize;

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		half3 sampleMain(float2 uv)
		{
			return tex2D(_MainTex, uv).rgb;
		}
		half3 sampleBox(float2 uv, float delta)
		{
			float4 offset = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
			half3 sum = sampleMain(uv + offset.xy) + sampleMain(uv + offset.zy) + 
				sampleMain(uv + offset.xw) + sampleMain(uv + offset.zw);
			return sum * 0.25;
		}

		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_first
			#pragma fragment frag_down

			v2f vert_first (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				/*
				// プラットフォーム差の吸収
				#ifdef UNITY_UV_STARTS_AT_TOP
				o.uv = float2(v.uv.x, 1 - v.uv.y);
				#else
				o.uv = v.uv;
				#endif
				*/
				o.uv = v.uv;

				return o;
			}

            fixed4 frag_down (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				// 1ピクセルずらし
				col.rgb = sampleBox(i.uv, 2);
                return col;
            }
			ENDCG
		}

        Pass
        {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag_down

            fixed4 frag_down (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				// 1ピクセルずらし
				col.rgb = sampleBox(i.uv, 1.0);
                return col;
            }

            ENDCG
        }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag_up

			fixed4 frag_up (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// 0.5ピクセルずらし
				col.rgb = sampleBox(i.uv, 0.5);
				return col;
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag_final

			sampler2D _BlurTex;
			sampler2D _DepthTex;
			float _FocusDistance;
			float _FocusWidth;

			fixed4 frag_final (v2f i) : SV_Target
			{
				fixed4 main_col = tex2D(_MainTex, i.uv);
				fixed4 blur_col = tex2D(_BlurTex, i.uv);
				fixed depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_DepthTex, i.uv));
				return lerp(main_col, blur_col, saturate((abs(depth - _FocusDistance) - _FocusWidth)*64));
				//return fixed4(saturate(abs(depth - _FocusDistance) - _FocusWidth).xxx * 64, 1);
			}
			ENDCG
		}
    }
}
