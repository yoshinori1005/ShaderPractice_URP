Shader "Unlit/Repeat"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (0, 0, 0, 1)
        _SubColor("Sub Color", Color) = (1, 1, 1, 1)
        _ScrollSpeed("Scroll Speed", Float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor, _SubColor;
            float _ScrollSpeed;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.worldPos = TransformObjectToWorld(i.positionOS);
                o.positionHCS = TransformObjectToHClip(i.positionOS);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float dotResult = dot(i.worldPos, normalize(float2(1, 1)));
                float repeat = abs(dotResult - _Time.w * _ScrollSpeed);
                // fmod(a, b)はaをbで除算した正の剰余
                float interpolation = step(fmod(repeat, 1), 0.1);
                float4 col = lerp(_BaseColor, _SubColor, interpolation);
                return col;
            }
            ENDHLSL
        }
    }
}
