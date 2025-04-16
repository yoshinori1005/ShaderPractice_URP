Shader "Unlit/GeometryAnimation"
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

            // C#側から受け取る変数
            CBUFFER_START(UnityPerMaterial)
            float _PositionFactor, _RotationFactor, _ScaleFactor, _GravityFactor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 positionLS : TEXCOORD0;
            };

            struct g2f
            {
                float4 positionHCS : SV_POSITION;
                float4 color : COLOR;
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
                Attributes o;
                o.positionLS = v.positionOS.xyz;
                return v;
            }

            [maxvertexcount(3)]
            void geom(triangle Attributes input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> stream)
            {
                float3 vec1 = input[1].positionOS.xyz - input[0].positionOS.xyz;
                float3 vec2 = input[2].positionOS.xyz - input[0].positionOS.xyz;
                float3 normal = normalize(cross(vec1, vec2));

                float3 center = (input[0].positionOS.xyz + input[1].positionOS.xyz + input[2].positionOS.xyz) / 3;
                float random = 2.0 * rand(center.xy) - 0.5;
                float3 r3 = random.xxx;

                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    Attributes v = input[i];
                    g2f o;
                    v.positionOS.xyz += normal * _PositionFactor * abs(r3);
                    v.positionOS.xyz = center + rotate(
                    v.positionOS.xyz - center,
                    (pid + _Time.y) * _RotationFactor,
                    r3
                    );
                    v.positionOS.xyz = center + (v.positionOS.xyz - center) * (1.0 - _ScaleFactor);
                    v.positionOS.y += _GravityFactor;
                    o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);

                    float r = rand(v.positionLS.xy);
                    float g = rand(v.positionLS.xz);
                    float b = rand(v.positionLS.yz);

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
