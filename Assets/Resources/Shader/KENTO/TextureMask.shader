Shader "Unlit/TextureMask"
{
    Properties
    {
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        [NoScaleOffset] _MaskTex("Mask Texture", 2D) = "white"{}
    }
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

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                o.uv = i.uv;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // マスク用画像のピクセルの色を計算
                float4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv);
                // 引数の値が 0 以下なら描画しない(Alpha が 0.5 以下なら描画しない)
                clip(mask.a - 0.5);
                // メイン画像のピクセルの色を計算
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                // メイン画像とマスク画像のピクセルの計算結果を掛け合わせる
                return col * mask;
            }
            ENDHLSL
        }
    }
}
