Shader "Unlit/StripeScroll"
{
    Properties
    {
        // 色
        _StripeColor1("Stripe Color1", Color) = (1, 0, 0, 1)
        _StripeColor2("Stripe Color2", Color) = (0, 1, 0, 1)
        _SliceSpace("Slice Space", Range(0, 30)) = 15
        _SliceWidth("Slice Width", Range(0, 1)) = 0.5
        _ScrollSpeed("Scroll Speed", Float) = 2.0
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

            CBUFFER_START(UnityPerMaterial)
            float4 _StripeColor1, _StripeColor2;
            float _SliceSpace, _SliceWidth, _ScrollSpeed;
            CBUFFER_END

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
                o.uv = i.uv + _Time.y * _ScrollSpeed;
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 補間値の計算
                // step関数 : step(t, x)
                // x の値が tの値よりも小さい場合には0、大きい場合には1を返す
                float interpolation = step(frac(i.uv.y * _SliceSpace), _SliceWidth);
                // Color1かColor2のどちらかを返す
                float4 color = lerp(_StripeColor1, _StripeColor2, interpolation);
                // 計算し終わったピクセルの色を返す
                return color;
            }
            ENDHLSL
        }
    }
}
