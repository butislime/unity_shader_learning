Shader "ShaderTest/normal_mapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Ambient ("Ambient", Range(0, 1)) = 0
		_NormalMap ("NormalMap", 2D) = "bump" {}
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
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 tangent : TEXCOORD2;
				float3 binormal : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _LightColor0;
			float _Ambient;
			sampler2D _NormalMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent.xyz));
				o.binormal = normalize(cross(o.normal, o.tangent) * v.tangent.w);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3x3 tangent_transform = float3x3(i.tangent, i.binormal, i.normal);
				float3 normal_local = UnpackNormal(tex2D(_NormalMap, i.uv)).xyz;
				float3 normal_dir = normalize(mul(normal_local, tangent_transform));

				float3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
				float ndotl = dot(normal_dir, light_dir);
                fixed4 tex = tex2D(_MainTex, i.uv);
				fixed4 col = tex * max(_Ambient, ndotl) * _LightColor0;
                return col;
            }
            ENDCG
        }
    }
}
