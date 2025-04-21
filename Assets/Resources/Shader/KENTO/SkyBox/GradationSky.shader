Shader "Unlit/GradationSky"
{
    Properties
    {
        // グラデーションカラー
        _TopColor("Top Color", Color) = (1, 0.2, 0.2, 1)
        _UnderColor("Under Color", Color) = (1, 0.68, 0.14, 1)
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
            float4 _TopColor, _UnderColor;
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
                float2 uv = rad / float2(2.0 * PI, PI / 2);

                // 整えたUVのY軸方向の座標を利用して色をグラデーションさせる
                return lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
            }
            ENDHLSL
        }
    }
}
