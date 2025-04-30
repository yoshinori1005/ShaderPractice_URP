Shader "Unlit/TransparencyEdge"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        _Edge("Edge", Range(0, 1)) = 0.5
        _Alpha("Alpha", Range(0, 1)) = 0.8
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        // 不当明度を利用するときに必要 文字通り、
        // 1 - フラグメントシェーダーのAlpha値という意味
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //Core機能をまとめたhlslを参照可能にする
            // いろんな便利関数や事前定義された値が利用可能となる
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _Edge;
            float _Alpha;
            CBUFFER_END

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                float2 centerUV = float2(0.5, 0.5);
                float dist = distance(i.uv, centerUV);
                float transparency = saturate(1.5 - dist / _Edge);
                col.a = transparency * _Alpha;
                return col * i.color;
            }
            ENDHLSL
        }
    }
}
