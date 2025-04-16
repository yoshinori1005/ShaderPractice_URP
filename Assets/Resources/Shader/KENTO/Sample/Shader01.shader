Shader "Unlit/Shader01"
{
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            // URP用の宣言
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            // CGPROGRAM から HLSLPROGRAM へ
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // UnityCG.cginc から URP Shader Core へ
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // appdata から Attrivutes へ(頂点シェーダーへ受け渡すデータ)
            struct Attrivutes
            {
                float4 positionOS : POSITION;
            };

            // v2f から Varyings へ(フラグメントシェーダーへ受け渡すデータ)
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            // 頂点シェーダー
            Varyings vert (Attrivutes v)
            {
                // データ型が v2f から Varyings へ
                Varyings o;
                // UnityObjectToClip から TransformObjectToHClip へ
                // オブジェクト空間からスクリーン空間への変換
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                return o;
            }

            // フラグメントシェーダー(fixed が廃止)
            float4 frag (Varyings i) : SV_Target
            {
                return float4(1, 0, 0, 1);
            }
            // ENDCG から ENDHLSL へ
            ENDHLSL
        }
    }
}
