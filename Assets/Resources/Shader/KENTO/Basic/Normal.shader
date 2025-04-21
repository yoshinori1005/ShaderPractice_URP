Shader "Unlit/Normal"
{
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(i.positionOS);
                // ローカル座標系の法線
                // o.normalWS = v.normalOS;
                o.normalWS = TransformObjectToWorldNormal(i.normalOS);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                return float4(i.normalWS, 1);
            }
            ENDHLSL
        }
    }
}
