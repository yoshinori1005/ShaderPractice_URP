Shader "Unlit/GeometryNormalMove"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseScale("Base Scale", Range(0.01, 1)) = 0.5
        _MoveSpeed("Move Speed", Float) = 1.0
        _PositionFactor("Position Factor", Float) = 0.5
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
            #pragma geometry geom
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float _BaseScale, _MoveSpeed, _PositionFactor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct g2f
            {
                float4 positionHCS : SV_POSITION;
            };

            Attributes vert (Attributes v)
            {
                return v;
            }

            // ジオメトリシェーダー
            /*引数inputは頂点シェーダーからの入力、streamは参照渡しで、
            次の処理に値を受け渡している TriangleStream<>で三角面を出力する*/
            // 出力する頂点の最大数
            [maxvertexcount(3)]
            void geom(triangle Attributes input[3], inout TriangleStream<g2f> stream)
            {
                // 法線を計算
                float3 vec1 = input[1].positionOS.xyz - input[0].positionOS.xyz;
                float3 vec2 = input[2].positionOS.xyz - input[0].positionOS.xyz;
                float3 normal = normalize(cross(vec1, vec2));

                // 繰り返す処理を畳み込んで最適化
                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    Attributes v = input[i];
                    g2f o;
                    // 法線ベクトルに沿って頂点を移動
                    v.positionOS.xyz += normal * (sin(_Time.y * _MoveSpeed) + _BaseScale) * _PositionFactor;
                    o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                    stream.Append(o);
                }
            }

            float4 frag (g2f i) : SV_Target
            {
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}
