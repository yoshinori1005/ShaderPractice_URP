Shader "Unlit/Tessellation"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        _DisTex("Displacement Texture", 2D) = "gray"{}
        _MinDist("Min Distance", Range(0.1, 50)) = 10
        _MaxDist("Max Distance", Range(0.1, 50)) = 25
        // 分割レベル
        _TessFactor("Tessellation", Range(1, 50)) = 10
        // 変位
        _Displacement("Displacement", Range(0, 1)) = 0.3
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
            #pragma hull hull
            #pragma domain domain

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 定数を定義
            #define INPUT_PATCH_SIZE 3
            #define OUTPUT_PATCH_SIZE 3

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_DisTex);
            SAMPLER(sampler_DisTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float _MinDist, _MaxDist, _TessFactor, _Displacement;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // 頂点シェーダーからハルシェーダーに渡す構造体(制御点)
            struct HsInput
            {
                float3 positionOS : POS;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // ハルシェーダーからテッセレーター経由でドメインシェーダーに渡す構造体(制御点)
            struct HsControlPointOutput
            {
                float3 positionOS : POS;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // Patch - Constant - Functionからテッセレーター経由でドメインシェーダーに渡す構造体
            struct HsConstantOutput
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            // ドメインシェーダーからフラグメントシェーダーに渡す構造体
            struct DsOutput
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            HsInput vert (Attributes v)
            {
                HsInput o;
                o.positionOS = v.positionOS;
                o.normalOS = v.normalOS;
                o.uv = v.uv;
                return o;
            }

            // コントロールポイント：頂点分割で使う制御点
            // パッチ：ポリゴン分割処理を行う際に使用するコントロールポイントの集合

            // ハルシェーダー
            // パッチに対してコントロールポイントを割り当てて出力する
            // コントロールポイントごとに1回実行
            // 分割に利用する形状を指定 "tri" "quad" "isoline"から選択
            [domain("tri")]
            // 分割方法 "integer" "fractional_eve" "fractional_odd" "pow2"から選択
            [partitioning("integer")]
            // 出力された頂点が形成するトポロジー(形状) "point" "line" "triangle_cw" "triangle_ccw" から選択
            [outputtopology("triangle_cw")]
            // Patch - Constant - Functionの指定
            [patchconstantfunc("hullConst")]
            // 出力されるコントロールポイントの集合の数
            [outputcontrolpoints(OUTPUT_PATCH_SIZE)]
            HsControlPointOutput hull(InputPatch<HsInput, INPUT_PATCH_SIZE> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOutput o = (HsControlPointOutput) 0;
                // 頂点シェーダーに対してコントロールポイントを割当て
                o.positionOS = i[id].positionOS;
                o.normalOS = i[id].normalOS;
                o.uv = i[id].uv;
                return o;
            }

            // Patch - Constant - Function
            // どの程度頂点を分割するかを決める係数を詰め込んでテッセレーターに渡す
            // パッチごとに一回実行される
            HsConstantOutput hullConst(InputPatch<HsInput, INPUT_PATCH_SIZE> i)
            {
                HsConstantOutput o = (HsConstantOutput) 0;

                float3 worldPos0 = TransformObjectToWorld(i[0].positionOS);
                float3 worldPos1 = TransformObjectToWorld(i[1].positionOS);
                float3 worldPos2 = TransformObjectToWorld(i[2].positionOS);

                // 頂点からカメラまでの距離を計算しテッセレーション係数を距離に応じて計算しなおす(LOD)
                float3 camPos = GetCameraPositionWS();
                float dist0 = distance(worldPos0, camPos);
                float dist1 = distance(worldPos1, camPos);
                float dist2 = distance(worldPos2, camPos);
                float avgDist = (dist0 + dist1 + dist2) / 3.0;

                float tess = lerp(_TessFactor, 1.0, saturate((avgDist - _MinDist) / (_MaxDist - _MinDist)));

                o.tessFactor[0] = tess;
                o.tessFactor[1] = tess;
                o.tessFactor[2] = tess;
                o.insideTessFactor = tess;

                return o;
            }

            // ドメインシェーダー
            // テッセレーターから出てきた分割位置で頂点を計算し出力する
            // 分割に利用する形状を指定 "tri" "quad" "isoline"から選択
            [domain("tri")]
            DsOutput domain(
            HsConstantOutput hsConst,
            const OutputPatch<HsControlPointOutput, INPUT_PATCH_SIZE> i,
            float3 bary : SV_DomainLocation
            )
            {
                DsOutput o = (DsOutput) 0;

                // 新しく出力する各頂点の座標を計算
                float3 positionOS =
                bary.x * i[0].positionOS +
                bary.y * i[1].positionOS +
                bary.z * i[2].positionOS;

                // 新しく出力する各頂点の法線を計算
                float3 normalOS = normalize(
                bary.x * i[0].normalOS +
                bary.y * i[1].normalOS +
                bary.z * i[2].normalOS
                );

                //新しく出力する各頂点のUV座標を計算
                o.uv =
                bary.x * i[0].uv +
                bary.y * i[1].uv +
                bary.z * i[2].uv;

                // tex2Dlodはフラグメントシェーダー以外の箇所でもテクスチャをサンプリングできる関数
                // ここでrだけ利用することで波紋の高さに応じて頂点の変位を操作できる
                float dis = SAMPLE_TEXTURE2D_LOD(_DisTex, sampler_DisTex, o.uv, 0).r * _Displacement;
                positionOS += normalOS * dis;

                float3 positionWS = TransformObjectToWorld(positionOS);
                o.positionHCS = TransformWorldToHClip(positionWS);

                return o;
            }

            float4 frag (DsOutput i) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                return texColor * _BaseColor;
            }
            ENDHLSL
        }
    }
}
