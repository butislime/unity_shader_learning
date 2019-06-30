Shader "Unlit/TriPlanarTextureMapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 world_pos : TEXCOORD0;
				float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				/*
				fixed3 blend = abs(i.normal);
				blend = normalize(max(blend, 0.000001));
				fixed b = (blend.x + blend.y + blend.z);
				blend /= b;

				fixed4 xaxis = tex2D(_MainTex, i.world_pos.yz);
				fixed4 yaxis = tex2D(_MainTex, i.world_pos.xz);
				fixed4 zaxis = tex2D(_MainTex, i.world_pos.xy);

				fixed4 color = xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
				*/

				fixed3 xaxis = tex2D(_MainTex, i.world_pos.yz);
				fixed3 yaxis = tex2D(_MainTex, i.world_pos.xz);
				fixed3 zaxis = tex2D(_MainTex, i.world_pos.xy);

				fixed3 normal = saturate(pow(i.normal * 1.4, 4));
				fixed3 blend = zaxis;
				blend = lerp(blend, xaxis, normal.x);
				blend = lerp(blend, yaxis, normal.y);

				return fixed4(blend, 1);
            }
            ENDCG
        }
    }
}
