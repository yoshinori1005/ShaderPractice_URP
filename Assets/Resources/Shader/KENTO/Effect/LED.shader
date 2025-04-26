Shader "Unlit/LED"
{
    Properties
    {
        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        _PixelShapeMap("Pixel Shape Map", 2D) = "white"{}
        _UV_X("Pixel Num X", Range(0, 1680)) = 960
        _UV_Y("Pixel Num Y", Range(0, 1680)) = 360
        _Intensity("Intensity", Float) = 1
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

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_PixelShapeMap);
            SAMPLER(sampler_PixelShapeMap);

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _PixelShapeMap_ST;
            float _UV_X, _UV_Y, _Intensity;
            CBUFFER_END

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 縦横何個並べるか
                float2 size = float2(_UV_X, _UV_Y);
                float2 posterize = floor(i.uv / (1 / size)) * (1 / size) + 1 / size;

                // UVの値が1付近の場合、なぜかモザイクの位置がずれるので調整
                float2 clampPosterize = clamp(posterize, 0, 0.99);
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, clampPosterize);

                float2 uv = i.uv * size;
                float4 pix = SAMPLE_TEXTURE2D(_PixelShapeMap, sampler_PixelShapeMap, uv);
                return col * pix * _Intensity;
            }
            ENDHLSL
        }
    }
}
