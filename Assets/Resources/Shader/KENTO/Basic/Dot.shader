Shader "Unlit/Dot"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (0, 0, 0, 1)
        _SubColor("Sub Color", Color) = (1, 1, 1, 1)
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
            float4 _BaseColor, _SubColor;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.worldPos = TransformObjectToWorld(v.positionOS);
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 各ピクセルのワールド座標の位置ベクトルを正規化していないパターン
                // float interpolation = dot(i.worldPos, float2(0, 1));

                // 斜め方向のベクトルを利用
                // float interpolation = dot(i.worldPos, normalize(float2(1, 1)));

                // 単位ベクトル同士
                float interpolation = dot(normalize(i.worldPos), float2(0, 1));
                float4 col = lerp(_BaseColor, _SubColor, interpolation);
                return col;
            }
            ENDHLSL
        }
    }
}
