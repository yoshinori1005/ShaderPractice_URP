Shader "Unlit/GeometryGradientColorful"
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
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            Attributes vert (Attributes v)
            {
                return v;
            }

            [maxvertexcount(3)]
            void geom(triangle Attributes input[3], inout TriangleStream<g2f> stream)
            {
                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    Attributes v = input[i];
                    g2f o;
                    o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                    float r = rand(v.positionOS.xy);
                    float g = rand(v.positionOS.xz);
                    float b = rand(v.positionOS.yz);
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
