Shader "Unlit/UVRotation"
{
    Properties
    {
        // テクスチャ(オフセット、タイリングなし)
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        // 回転の速度
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

            CBUFFER_START(UnityPerMaterial)
            float _RotateSpeed;
            CBUFFER_END

            struct Attrivutes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert (Attrivutes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                // 受け取った UV 座標をフラグメントシェーダーに渡す
                o.uv = v.uv;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // Time を入力して現在の回転角度を作る
                float timer = _Time.y;

                // 回転行列を作る
                float angleCos = cos(timer * _RotateSpeed);
                float angleSin = sin(timer * _RotateSpeed);

                // 2次元回転行列の公式 R(Θ) = float2x2(cosΘ, - sinΘ, sinΘ, cosΘ)
                float2x2 rotateMatrix = float2x2(angleCos, - angleSin, angleSin, angleCos);

                // 中心
                float2 uv = i.uv - 0.5;

                // 中心を起点に UV を回転させる
                i.uv = mul(uv, rotateMatrix) + 0.5;

                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);

                return col;
            }
            ENDHLSL
        }
    }
}
