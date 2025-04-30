Shader "Unlit/URPRim"
{
    Properties
    {
        [MainColor] _TintColor("Tint Color", Color) = (0, 0.5, 1, 1)
        _RimColor("Rim Color", Color) = (0, 1, 1, 1)
        _RimPower("Rim Power", Range(0, 1)) = 0.4
    }

    Category
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            ColorMask 0
        }

        Pass
        {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _TintColor;
            float4 _RimColor;
            float _RimPower;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalDirWS : TEXCOORD1;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.positionWS = TransformObjectToWorld(v.positionOS);
                o.normalDirWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // カメラのベクトルを計算
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.positionWS);

                // 法線とカメラのベクトルの内積を計算し、補間値を算出
                float rim = 1.0 - saturate(dot(viewDirection, i.normalDirWS));

                // 補間値で塗分け
                float4 col = lerp(_TintColor, _RimColor, rim * _RimPower);

                return col;
            }
            ENDHLSL
        }
    }
}
