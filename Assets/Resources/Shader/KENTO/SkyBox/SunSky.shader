Shader "Unlit/SunSky"
{
    Properties
    {
        _BGColor("Background Color", Color) = (0.05, 0.9, 1, 1)
        _SunColor("Sun Color", Color) = (1, 0.8, 0.5, 1)
        _SunDir("Sun Direction", Vector) = (0, 0.5, 1, 0)
        _SunStrength("Sun Strength", Range(0, 200)) = 30
    }
    SubShader
    {
        Tags
        {
            // 最背面に描画するのでBackground
            "RenderType" = "Background"
            "Queue" = "Background"
            // マテリアルのプレビューがスカイボックスるになる
            "PreviewType" = "SkyBox"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            // 常に最背面に描画するので深度情報の書き込み不要
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _BGColor, _SunColor;
            float3 _SunDir;
            float _SunStrength;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 dirWS : TEXCOORD0;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                float3 posWS = TransformObjectToWorld(v.positionOS);
                // カメラからの方向ベクトル
                o.dirWS = normalize(posWS - GetCameraPositionWS());
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float sunAmount = pow(saturate(dot(normalize(_SunDir), normalize(i.dirWS))), _SunStrength);
                float3 color = _BGColor.rgb + _SunColor.rgb * sunAmount;

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
