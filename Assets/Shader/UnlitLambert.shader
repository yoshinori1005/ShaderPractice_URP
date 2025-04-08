Shader "Unlit/UnlitLambert"
{
    Properties
    {
        [Header(Main)]
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _RampTex("Ramp Tex", 2D) = "white"{}
        [Header(Specular)]
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularStrength("Specular Strength", Range(0, 1)) = 0.5
        [Header(Outline)]
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineMask("Outline Mask", 2D) = "white"{}
        _OutlineWidth("Outline Width", Range(0.0, 0.1)) = 0.02
        [Header(RimLight)]
        _RimColor("Rim Light Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Light Power", Range(0.01, 10)) = 3
        [Header(MatCap)]
        _MatCapTex("MatCap Tex", 2D) = "gray"{}
        _MatCapStrength("MatCap Strength", Range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            // "RenderPipeline" = "UniversalRenderPipeline"
            "Queue" = "Geometry"
        }
        LOD 100

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_RampTex);
        SAMPLER(sampler_RampTex);
        TEXTURE2D(_OutlineMask);
        SAMPLER(sampler_OutlineMask);
        TEXTURE2D(_MatCapTex);
        SAMPLER(sampler_MatCapTex);

        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _Color;
        float _MatCapStrength;
        float4 _RimColor;
        float _RimPower;
        float4 _SpecularColor;
        float _SpecularStrength;
        half4 _OutlineColor;
        float _OutlineWidth;
        CBUFFER_END
        ENDHLSL

        // メインシェーダー
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                float3 viewDirWS : TEXCOORD1;
                float3 posWS : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetWorldSpaceViewDir(OUT.posWS));
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normalWS = normalize(IN.normalWS);
                float3 viewDirWS = normalize(IN.viewDirWS);

                // URPのMainLightからライト情報を取得
                Light light = GetMainLight();
                float3 lightDir = normalize(light.direction);

                // float NdotL = saturate(dot(normalWS, lightDir));
                float NdotL = max(dot(normalWS, light.direction), 0.0);
                float3 lambert = light.color * NdotL;

                // ランプシェーディング
                float2 rampUV = float2(NdotL, 0.0);
                float3 rampColor = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, rampUV).rgb;

                // メインカラー
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float3 finalColor = texColor.rgb * _Color.rgb * lambert * rampColor;

                // スペキュラー
                float3 H = normalize(lightDir + viewDirWS);
                float NdotH = saturate(dot(normalWS, H));
                float spec = pow(NdotH, 64.0) * _SpecularStrength;
                finalColor += spec * _SpecularColor.rgb;

                // リムライト
                float rim = saturate(dot(viewDirWS, normalWS));
                rim = 1 - pow(rim, _RimPower);
                finalColor += rim * _RimColor.rgb;

                // マットキャップ
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalWS);
                float2 matcapUV = viewNormal.xy * 0.5 + 0.5;
                float3 matcap = SAMPLE_TEXTURE2D(_MatCapTex, sampler_MatCapTex, matcapUV).rgb;
                finalColor = lerp(finalColor, matcap, _MatCapStrength);

                return float4(finalColor, 1.0);
            }
            ENDHLSL
        }

        // アウトライン描画用パス
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

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                float3 normalWS = vertexNormalInput.normalWS;
                float3 normalCS = TransformWorldToHClipDir(normalWS);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                half mask = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, IN.uv, 1.0).r;
                OUT.positionCS = positionInputs.positionCS + float4(normalCS.xy * _OutlineWidth * mask, 0, 0);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 col = _OutlineColor;

                return col;
            }
            ENDHLSL
        }
    }
    Fallback "Hidden/InternalErrorShader"
}