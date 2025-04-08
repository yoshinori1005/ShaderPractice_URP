Shader "Unlit/UnlitSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            // URPの宣言
            "RnderPipeline" = "UniversalPipeline"
        }
        LOD 100

        // 各Passでcbufferが変わらないようにここで定義する
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        // URPのテクスチャ変数
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        // SRP Batcherの定義
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _Color;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            // UPRのライティング記述
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // URP用のHLSL宣言
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            // Universal Pipeline shadow keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            // URPのインクルード
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float fogFactor : TEXCOORD1;
                float3 posWS : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // URPのオブジェクト空間からカメラ空間への変換
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // URPのフォグの記述
                o.fogFactor = ComputeFogFactor(o.vertex.z);
                // UPRのオブジェクト空間からワールド座標への変換
                o.posWS = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // URPのテクスチャコード(fixedは廃止、SAMPLE_TEXTURE2D(引数3))
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                float4 shadowCoord = TransformWorldToShadowCoord(i.posWS);
                Light mainLight = GetMainLight(shadowCoord);
                half shadow = mainLight.shadowAttenuation;
                Light addLight0 = GetAdditionalLight(0, i.posWS);
                shadow *= addLight0.shadowAttenuation;
                col.rgb *= shadow;

                // apply fog
                // URPのフォグコード
                col.rgb = MixFog(col.rgb, i.fogFactor);
                return col * _Color;
            }
            ENDHLSL
        }

        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ShadowCasterPass.hlsl に定義されているグローバルな変数
            float3 _LightDirection;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                // ShadowsCasterPass.hlsl の GetShadowPositionHClip() を参考に
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldNormal(v.normal);
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                o.pos = positionCS;

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return 0.0;
            }
            ENDHLSL
        }
    }
}
