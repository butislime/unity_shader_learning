Shader "ShaderTest/phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
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
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _LightColor0;
			float4 _SpecColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				float3 normal = normalize(i.worldNormal);
				float3 light_dir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float ndotl = dot(normal, light_dir);
				float4 diffuse = col * _LightColor0 * max(0, ndotl);

				float3 view_dir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float ndotv = dot(normal, view_dir);
				float3 reflection = -1 * view_dir + 2 * ndotv * normal;
				float ldotr = dot(light_dir, reflection);
				float spec_power = pow(max(0, ldotr), 10);
				float4 specular = spec_power * _SpecColor * _LightColor0;

				col = diffuse + specular;

                return col;
            }
            ENDCG
        }
    }
}
