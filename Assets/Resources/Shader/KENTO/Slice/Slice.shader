Shader "Unlit/Slice"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        // スライスされる間隔
        _SliceSpace("Slice Space", Range(0, 30)) = 15
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
            float4 _BaseColor;
            float _SliceSpace;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.worldPos = TransformObjectToWorld(i.positionOS.xyz);
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 各頂点のワールド座標(Y軸)それぞれに15をかけてfrac関数で
                // 小数だけ取り出し、0.5を引いてclip関数に渡す(0を下回ったら描画しない)
                clip(frac(i.worldPos.y * _SliceSpace) - 0.5);
                // RGBAにそれぞれのプロパティを当てはめる
                return float4(_BaseColor);
            }
            ENDHLSL
        }
    }
}
