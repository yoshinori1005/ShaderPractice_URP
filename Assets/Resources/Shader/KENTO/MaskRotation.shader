Shader "Unlit/MaskRotation"
{
    Properties
    {
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        [NoScaleOffset] _MaskTex("Mask Texture", 2D) = "white"{}
        _RotateSpeed("Rotate Speed", Float) = 1.0
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

            CBUFFER_START(UnityPerMaterial)
            float _RotateSpeed;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                o.uv = i.uv;
                o.uv1 = i.uv1;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float timer = _Time.y;

                float angleCos = cos(timer * _RotateSpeed);
                float angleSin = sin(timer * _RotateSpeed);

                float2x2 rotateMatrix = float2x2(angleCos, - angleSin, angleSin, angleCos);

                float2 uv = i.uv - 0.5;

                i.uv = mul(uv, rotateMatrix) + 0.5;

                float4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv1);

                clip(mask.a - 0.5);

                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);

                return col * mask;
            }
            ENDHLSL
        }
    }
}
