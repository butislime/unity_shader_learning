Shader "ShaderTest/cube_map"
{
    Properties
    {
        [NoScaleOffset] _CubeMap ("Cube", Cube) = "" {}
    }
    SubShader
    {
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
				float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float3 world_pos : TEXCOORD1;
				half3 normal : TEXCOORD2;
            };

            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.world_pos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				half3 view_dir = _WorldSpaceCameraPos - i.world_pos;
				half3 ref_dir = reflect(-1 * view_dir, i.normal);
				half4 ref_color = texCUBE(_CubeMap, ref_dir);
                return ref_color;
            }
            ENDCG
        }
    }
}
