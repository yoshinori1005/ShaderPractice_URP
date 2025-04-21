Shader "Unlit/Diffuse"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _DiffuseShade("Diffuse Shade", Range(0, 1)) = 0.5
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1)
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
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor, _AmbientColor;
            float _DiffuseShade;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                // 環境光
                float3 ambientWS : TEXCOORD1;
            };

            Varyings vert (Attributes i)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(i.positionOS);
                // o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(i.normalOS);
                o.normalWS = normalInputs.normalWS;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 1つ目のライトのベクトルを正規化
                float3 L = normalize(GetMainLight().direction);

                // ワールド座標系の法線を正規化
                float3 N = normalize(i.normalWS);

                // ライトベクトルと法線の内積からピクセルの明るさを計算(ランバート調整)
                float4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));

                // 色を乗算
                float4 finalColor = _BaseColor * diffuseColor * float4(GetMainLight().color, 1) * _AmbientColor;

                return finalColor;
            }
            ENDHLSL
        }
    }
}
