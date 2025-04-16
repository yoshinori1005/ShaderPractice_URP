Shader "Unlit/ToonLambert"
{
    Properties
    {
        [Header(Lambert)]
        _MainTex ("Texture", 2D) = "white" {}
        _LambertThresh("Lambert Thresh", float) = 0.5
        _GradWidth("Shadow Width", Range(0.003, 1)) = 0.1
        _Sat("Sat", Range(0, 2)) = 0.5

        [Header(Outline)]
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineMask("Outline Mask", 2D) = "white"{}
        _OutlineThickness("Outline Thickness", Range(0, 5)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_OutlineMask);
        SAMPLER(sampler_OutlineMask);

        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float _LambertThresh;
        float _GradWidth;
        float _Sat;
        float _OutlineThickness;
        half4 _OutlineColor;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs inputs = GetVertexPositionInputs(v.vertex.xyz);
                // スクリーン座標に変換
                o.vertex = inputs.positionCS;
                // ワールド座標系変換
                o.normal = normalize(TransformObjectToWorldNormal(v.normal));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Main Light情報の取得
                Light mainLight = GetMainLight();

                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // UNorm lambert. 0~1.
                float NdotL = saturate(dot(mainLight.direction.xyz, i.normal) * 0.5f + 0.5f);
                // _LambertThreshを閾値とした二値化
                // step(y, x) ...y < x?1 : 0
                float ramp = step(NdotL, _LambertThresh);

                if(ramp)
                {
                    // 影色の決定
                    half3 multiColor = mainLight.color * color.rgb;
                    // 中間色をオーバーレイでグラデーションするために彩度をあげる
                    half3 hsv = RgbToHsv(mainLight.color);
                    hsv.g *= _Sat;
                    half3 overlayInputColor = HsvToRgb(hsv);

                    // オーバーレイ演算
                    // if(基本色 < 0.5) 結果色 = 基本色 * 合成色 * 2
                    // else if(基本色 > 0.5) 結果色 = 1 - 2 * (1 - 基本色) * (1 - 合成色)
                    half3 overlayThreshold = step(0.5f, multiColor);
                    // overlayThreshold == 0...乗算、overlayThreshold == 1...スクリーン
                    // 乗算カラーをベースにオーバーレイ効果をブレンドする
                    half3 overlayColor = lerp(
                    overlayInputColor * multiColor * 2.0f,
                    1.0f - 2 * (1.0f - overlayInputColor) * (1.0f - multiColor),
                    overlayThreshold
                    );
                    // オーバーレイと乗算をグラデーションして最終陰色を決定
                    color.rgb = lerp(
                    overlayColor,
                    multiColor,
                    1 - saturate(NdotL - (_LambertThresh - _GradWidth)) / _GradWidth
                    );
                }
                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Cull Front
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct a2v
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f o;
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);

                float3 normalWS = vertexNormalInput.normalWS;
                float3 normalCS = TransformWorldToHClipDir(normalWS);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                half mask = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, v.uv, 1.0).r;
                o.positionCS = positionInputs.positionCS + float4(normalCS.xy * 0.001 * _OutlineThickness * mask, 0, 0);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 col = _OutlineColor;

                return col;
            }
            ENDHLSL
        }
    }
}
