Shader "Unlit/Shader04"
{
    Properties
    {
        _RedValue("Red Value", Float) = 0.5
        _GreenValue("Green Value", Float) = 0.5
        _BlueValue("Blue Value", Float) = 0.5
        _AlphaValue("Alpha Value", Range(0, 1)) = 1
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

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float _RedValue, _GreenValue, _BlueValue, _AlphaValue;

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // RGB にそれぞれのプロパティを当てはめる
                return float4(_RedValue, _GreenValue, _BlueValue, _AlphaValue);
            }
            ENDHLSL
        }
    }
}
