Shader "Unlit/URPUnlit"
{
    Properties
    {
        // MainColor を定義づける属性をつけるとマテリアルのメインカラーと認識する
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        // MainTexture を定義づける属性をつけるとマテリアルのメインテクスチャと認識する
        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        _CutOff("Alpha CutOff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            // URP 用マテリアルを作成する際の定義
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Pass
        {
            Name "UnlitPass"

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            // URP は CGPROGRAM から HLSLPROGRAM に移行したため、HLSLPROGRAM ~ ENDHLSL
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // URP になり UnityCG.cginc から プロジェクトタブの Packages にある該当ファイルからインクルードに
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // URPのテクスチャ変数
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            // SRP Batcherの定義
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _CutOff;
            CBUFFER_END

            struct Attributes
            {
                // OS は Object Spaceの略
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                // UnityObjectToClipPos から TransformObjectToHClip になり、
                // float3 を指定しているので引数には float3 になるように v.vertex.xyz
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                // UnityObjectToWorldNormal から TransformObjectToWorldNormal に
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // URP のテクスチャの記述(引数1 : Texture2D, 引数2 : Sampler, 引数3 : IN)
                half4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                // clip の引数の値が 0 以下の場合、描画しない
                clip(_BaseColor.a * tex.a - _CutOff);
                return _BaseColor * tex;
            }
            ENDHLSL
        }
    }
}
