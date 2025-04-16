Shader "Unlit/GeometryRotation"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _RotationFactor("Rotation Factor", Float) = 0.5
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
            float _RotationFactor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct g2f
            {
                float4 positionHCS : SV_POSITION;
            };

            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                a.x * a.x * r + c, a.y * a.x * r * a.z * s, a.z * a.x * r - a.y * s,
                a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            Attributes vert (Attributes v)
            {
                return v;
            }

            [maxvertexcount(3)]
            void geom(triangle Attributes input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> stream)
            {
                float3 center = (input[0].positionOS.xyz + input[1].positionOS.xyz + input[2].positionOS.xyz) / 3;
                // - 1 < r < 1
                float r = 2.0 * rand(center.xy) - 0.5;
                // xyzに全部同じ値を入れる
                float3 r3 = r.xxx;

                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    Attributes v = input[i];
                    g2f o;
                    // 中心を起点に回転させる
                    v.positionOS.xyz = center + rotate(v.positionOS.xyz - center, (pid + _Time.y) * _RotationFactor, r3);
                    o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                    stream.Append(o);
                }
                stream.RestartStrip();
            }

            float4 frag (g2f i) : SV_Target
            {
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}
