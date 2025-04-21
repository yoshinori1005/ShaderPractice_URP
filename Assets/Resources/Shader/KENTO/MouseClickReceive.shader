Shader "Unlit/MouseClickReceive"
{
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
            float4 _MousePosition;
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
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                o.worldPos = TransformObjectToWorld(i.positionOS.xyz);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // ベースカラー
                float4 baseColor = float4(1, 1, 1, 1);

                /*マウスから出たRayとオブジェクトの衝突箇所(ワールド座標)と
                描画しようとしているピクセルのワールド座標の距離を求める*/
                float dist = distance(_MousePosition.xyz, i.worldPos);

                /* 求めた距離が任意の距離以下なら
                描画しようとしているピクセルの色を変える*/
                // if(dist < 0.1)
                // {
                    // // 赤色乗算代入
                    // baseColor *= float4(1, 0, 0, 1);
                // }
                // 三項演算子での記述
                baseColor *= (dist < 0.1) ? float4(1, 0, 0, 1) : float4(1, 1, 1, 1);
                return baseColor;
            }
            ENDHLSL
        }
    }
}
