Shader "Unlit/GeometryColorful"
{
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

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct g2f
            {
                float4 positionHCS : SV_POSITION;
                float4 color : COLOR;
            };

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43785.5453);
            }

            Attributes vert (Attributes v)
            {
                return v;
            }

            [maxvertexcount(3)]
            void geom(triangle Attributes input[3], inout TriangleStream<g2f> stream)
            {
                float3 center = (input[0].positionOS.xyz + input[1].positionOS.xyz + input[2].positionOS.xyz) / 3;

                // ランダムな値
                float r = rand(center.xy);
                float g = rand(center.xz);
                float b = rand(center.yz);

                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    Attributes v = input[i];
                    g2f o;
                    o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                    o.color = float4(r, g, b, 1);
                    stream.Append(o);
                }
            }

            float4 frag (g2f i) : SV_Target
            {
                return i.color;
            }
            ENDHLSL
        }
    }
}
