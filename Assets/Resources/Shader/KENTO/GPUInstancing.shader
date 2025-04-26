Shader "Unlit/GPUInstancing"
{
    Properties
    {
        // 色、陰影
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _AmbientLight("Ambient Light", Color) = (0.5, 0.5, 0.5, 1)
        _AmbientPower("Ambient Power", Range(0, 3)) = 1

        // 出現する表現で利用
        _Alpha("Alpha", Float) = 1
        _Size("Size", Float) = 1

        // 揺れ表現で利用
        _Frequency("Frequency", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
        _WaveSpeed("Wave Speed", Range(0, 20)) = 10
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ランダムな値を返す
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // パーリンノイズ
            float perlinNoise(float2 st)
            {
                float2 p = floor(st);
                float2 f = frac(st);
                float2 u = f * f * (3.0 - 2.0 * f);

                float v00 = rand(p + float2(0, 0));
                float v10 = rand(p + float2(1, 0));
                float v01 = rand(p + float2(0, 1));
                float v11 = rand(p + float2(1, 1));

                return lerp(
                lerp(dot(v00, f - float2(0, 0)), dot(v10, f - float2(1, 0)), u.x),
                lerp(dot(v01, f - float2(0, 1)), dot(v11, f - float2(1, 1)), u.x),
                u.y) + 0.5f;
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                // 法線を受け取るための変数
                float3 normalOS : NORMAL;
                // GPUインスタンシングに必要な変数
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
            };

            float4 _BaseColor;
            float4 _AmbientLight;

            CBUFFER_START(UnityPerMaterial)
            float _AmbientPower;
            float _Alpha;
            float _Size;
            float _Frequency;
            float _Amplitude;
            float _WaveSpeed;
            CBUFFER_END

            Varyings vert (Attributes v, uint instanceID : SV_InstanceID)
            {
                Varyings o;

                // GPUインスタンシングに必要な変数を設定する
                UNITY_SETUP_INSTANCE_ID(v);

                // スケールのための行列を計算
                float4x4 scaleMatrix = float4x4(
                1, 0, 0, 0,
                0, _Size * clamp(rand(instanceID), 0.7, 1.0) * 1.2, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
                );
                v.positionOS = mul(scaleMatrix, v.positionOS);

                // 揺らめく表現
                float2 factors = _Time.w * _WaveSpeed + v.positionOS.xy * _Frequency;
                float2 offsetFactor = sin(factors) * _Amplitude * (v.positionOS.y) * perlinNoise(_Time * rand(instanceID));
                v.positionOS.xz += offsetFactor.x + offsetFactor.y;

                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float4 col = _BaseColor;

                // ライト情報を取得
                Light light = GetMainLight();

                // ピクセルの法線とライトの方向の内積を計算する
                float t = dot(i.normalWS, light.direction);

                // 内積の値を0以上の値にする
                t = max(0, t);

                // 拡散反射光を計算する
                float3 diffuseLight = light.color * t;

                // 拡散反射光を反映
                col.rgb *= diffuseLight * _AmbientLight * _AmbientPower;

                // アルファ値を設定
                col.a = _Alpha;

                return col;
            }
            ENDHLSL
        }
    }
}
