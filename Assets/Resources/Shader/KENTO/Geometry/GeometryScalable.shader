Shader "Unlit/GeometryScalable"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _ScaleFactor("Scale Factor", Range(0, 1)) = 0.5
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
            float _ScaleFactor;
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

            [maxvertexcount(3)]
            void geom(triangle Attributes input[3], inout TriangleStream<g2f> stream)
            {
                // 1舞のポリゴンの中心
                float3 center = (input[0].positionOS.xyz + input[1].positionOS.xyz + input[2].positionOS.xyz) / 3;

                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    Attributes v = input[i];
                    g2f o;
                    // 中心を起点にスケールを変える
                    v.positionOS.xyz = (v.positionOS.xyz - center) * (1.0 - _ScaleFactor) + center;
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
