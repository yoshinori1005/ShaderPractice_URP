Shader "Unlit/RandomVertexMove"
{
    Properties
    {
        // 頂点の動き幅
        _VertexMoveRange("Vertex Move Range", Range(0, 0.5)) = 0.025
        _MoveSpeed("Move Speed", Float) = 1.0
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
            float _VertexMoveRange, _MoveSpeed;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            // ランダムな値を返す
            float rand(float2 co)
            {
                // 引数はシード値と呼ばれ、同じ値を渡せば同じものを返す
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            Varyings vert (Attributes i)
            {
                Varyings o;
                // ランダムな値生成
                float random = rand(i.positionOS.xy);
                /*ランダムな値をsin関数の引数に渡して経過時間を
                掛け合わせることで各頂点にランダムな変化を与える*/
                float3 vert = float3(i.positionOS.xyz + i.positionOS.xyz * sin(1 + _Time.w * _MoveSpeed * random) * _VertexMoveRange);
                o.positionHCS = TransformObjectToHClip(vert);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                /* シード値に同じ値を渡すと全部同じ値になるので
                引数のシード値に別の値を渡す*/
                float r = rand(i.positionHCS.xy + 0.1);
                float g = rand(i.positionHCS.xy + 0.2);
                float b = rand(i.positionHCS.xy + 0.3);
                return float4(r, g, b, 1);
            }
            ENDHLSL
        }
    }
}
