Shader "Unlit/GradationNightSkyWithMoon"
{
    Properties
    {
        _SquareNum("Square Num", int) = 10
        _MoonColor("MoonColor", Color) = (1, 0.8, 0, 1)

        // グラデーションカラー
        _TopColor("Top Color", Color) = (0, 0, 0.3, 1)
        _UnderColor("Under Color", Color) = (0, 0.12, 0.38, 1)

        // 色の境界の位置
        _ColorBorder("Color Border", Range(0, 3)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Background"
            "Queue" = "Background"
            "PreviewType" = "SkyBox"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define PI 3.14159265359

            CBUFFER_START(UnityPerMaterial)
            int _SquareNum;
            float4 _MoonColor, _TopColor, _UnderColor;
            float _ColorBorder;
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

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.worldPos = TransformObjectToWorld(i.positionOS.xyz);
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float3 dir = normalize(i.worldPos);

                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(PI / 2, PI / 2);

                uv *= _SquareNum;

                float2 ist = floor(uv);
                float2 fst = frac(uv);

                float4 color = 0;

                for(int y =- 1; y <= 1; y ++)
                {
                    for(int x =- 1; x <= 1; x ++)
                    {
                        float2 neighbor = float2(x, y);

                        float2 p = random2(ist);

                        float2 diff = neighbor + p - fst;

                        float r = rand(p + 1);
                        float g = rand(p + 2);
                        float b = rand(p + 3);
                        float4 randColor = float4(r, g, b, 1);

                        float interpolation = 1 - step(0.01, length(diff));
                        color = lerp(color, randColor, interpolation);
                    }
                }

                // 整えたいUVのY軸方向の座標を利用して色をグラデーションさせる
                color += lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);

                // 月
                color = lerp(_MoonColor, color, step(uv.y, _SquareNum * 0.75));

                return color;
            }
            ENDHLSL
        }
    }
}
