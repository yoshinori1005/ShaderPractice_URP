Shader "Unlit/SkyboxTest"
{
    Properties
    {
        // スクロールさせるテクスチャ
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Background"
            "Queue" = "Background"
            "PreviewType" = "SkyBox"
            "RenderType" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define PI 3.14159265359

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.worldPos = mul(unity_ObjectToWorld, v.positionOS).xyz;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 描画したいピクセルのワールド座標を正規化
                float3 dir = normalize(i.worldPos);

                // ラジアンを算出する
                // atan(x)と異なり、1周分の角度をラジアンで返す(スカイボックスの円周上のラジアン)
                // asin(x) : - π / 2～π / 2の間で逆正弦を返す(xの範囲は - 1～1)
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(2.0 * PI, PI / 2);

                // テクスチャとUV座標から色の計算を行う
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

                return col;
            }
            ENDHLSL
        }
    }
}
