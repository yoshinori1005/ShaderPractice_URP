Shader "Unlit/UseCameraDistance"
{
    Properties
    {
        [NoScaleOffset] _NearTex ("Near Texture", 2D) = "white" {}
        [NoScaleOffset] _FarTex("Far Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_NearTex);
            SAMPLER(sampler_NearTex);
            TEXTURE2D(_FarTex);
            SAMPLER(sampler_FarTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.positionOS).xyz;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // それぞれのテクスチャとUVからピクセルの色を計算
                float4 nearCol = SAMPLE_TEXTURE2D(_NearTex, sampler_NearTex, i.uv);
                float4 farCol = SAMPLE_TEXTURE2D(_FarTex, sampler_FarTex, i.uv);

                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos : 定義済みの値(ワールド座標系のカメラの位置)
                float cameraToObjLength = length(_WorldSpaceCameraPos - i.worldPos);

                // Lerp関数を使って色を変化、補間値にカメラとオブジェクトの距離を使用
                float4 col = float4(lerp(nearCol, farCol, cameraToObjLength * 0.05));

                // Alphaが0以下なら描画しない
                clip(col);

                // 最終的なピクセルの色を返す
                return col;
            }
            ENDHLSL
        }
    }
}
