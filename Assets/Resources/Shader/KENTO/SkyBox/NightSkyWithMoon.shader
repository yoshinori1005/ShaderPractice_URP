Shader "Unlit/NightSkyWithMoon"
{
    Properties
    {
        _SquareNum("Square Num", int) = 10
        _NightColor("Night Color", Color) = (0, 0, 0, 1)
        _MoonColor("Moon Color", Color) = (1, 0.8, 0, 1)
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
            float4 _NightColor, _MoonColor;
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

            // ランダムな値を生成する
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // ランダムな値を生成する
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

                // 格子状のマス目作成 UVにかけた数分だけ同じUVが繰り返し展開される
                uv *= _SquareNum;

                // 各マス目の起点
                float2 ist = floor(uv);
                // 各マス目の起点からの描画したい位置
                float2 fst = frac(uv);

                float4 color = 0;

                // 自身含む周囲のマスをチェック
                for(int y =- 1; y <= 1; y ++)
                {
                    for(int x =- 1; x <= 1; x ++)
                    {
                        // 周辺1x1のエリア
                        float2 neighbor = float2(x, y);

                        // 点のxy座標
                        float2 p = random2(ist);

                        // 点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        // 色を星ごとにランダムに当てはめる(星の座標を利用)
                        float r = rand(p + 1);
                        float g = rand(p + 2);
                        float b = rand(p + 3);
                        float4 randColor = float4(r, g, b, 1);

                        // 補間値を計算
                        // step(t, x) はxがtより大きい場合1を返す
                        float interpolation = 1 - step(0.01, length(diff));

                        // 補間値を利用して夜空と星を塗り分け
                        color += lerp(_NightColor, randColor, interpolation);

                        // グリッドの描画
                        // color.r += step(0.98, fst.x) + step(0.98, fst.y);
                    }
                }

                // 月
                // if(uv.y > _SquareNum * 0.75)
                // {
                    // color = _MoonColor;
                // }
                // 月
                color = lerp(_MoonColor, color, step(uv.y, _SquareNum * 0.75));

                return color;
            }
            ENDHLSL
        }
    }
}
