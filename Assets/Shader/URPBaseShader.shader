Shader "Unlit/URPBaseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", color) = (1, 1, 1, 1)
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metallic("Metallic", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            // URP 用マテリアルを作成する際の定義
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward"}

            // URP は CGPROGRAM から HLSLPROGRAM に移行したため、HLSLPROGRAM ~ ENDHLSL
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // URP になり UnityCG.cginc から プロジェクトタブの Packages にある該当ファイルからインクルードに
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                // GI 用のライトマップ UV
                float4 texcoord1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                // URP 用の定義 WS は World Space の略、OS は Object Space
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                // ライトマップ用の球面調和関数(Spherical Harmonics)
                // (引数1 : lightMapName, 引数2 : sphericalHarmonicsName, Index(TEXCOORD.Index))
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _BaseColor;
            float _Smoothness, _Metallic;

            v2f vert (appdata v)
            {
                v2f o;
                // UnityObjectToClipPos から TransformObjectToWorld になり、
                // float3 を指定しているので引数には float3 になるように v.vertex.xyz
                o.positionWS = TransformObjectToWorld(v.vertex.xyz);
                // UnityObjectToWorldNormal から TransformObjectToWorldNormal になり、
                // float3 を指定しているので引数には float3 になるように v.normal.xyz
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                // WorldSpaceViewDir から normalize(_WorldSpaceCameraPos - o.positionWS) になる(要正規化)
                o.viewDir = normalize(_WorldSpaceCameraPos - o.positionWS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UnityObjectToClipPos から TransformWorldToHClip に
                o.vertex = TransformWorldToHClip(o.positionWS);

                // ライトマップの出力(引数1 : lightMapUV, 引数2 : lightMapScaleOffset, 引数3 : 出力)
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapsST, o.lightmapUV);
                // 球面調和関数の出力(引数1 : normalWS, 引数2 : 出力)
                OUTPUT_SH(o.normalWS.xyz, o.vertexSH);

                return o;
            }

            // URP になり fixed は削除され、half に
            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);

                // インプットデータの定義
                InputData inputData = (InputData) 0;
                // 位置の定義
                inputData.positionWS = i.positionWS;
                // 法線の定義
                inputData.normalWS = normalize(i.normalWS);
                // カメラ方向の定義
                inputData.viewDirectionWS = i.viewDir;
                // グローバルイルミネーションの定義
                inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, inputData.normalWS);

                // サーフェスデータの定義
                SurfaceData surfaceData = (SurfaceData) 0;
                // アルベドの定義
                surfaceData.albedo = _BaseColor.rgb;
                // スペキュラーの定義
                surfaceData.specular = 0;
                // メタリックの定義
                surfaceData.metallic = _Metallic;
                // スムースネスの定義
                surfaceData.smoothness = _Smoothness;
                // ノーマルの定義(タンジェント空間)
                surfaceData.normalTS = 0;
                // エミッションの定義
                surfaceData.emission = 0;
                // オクルージョンの定義
                surfaceData.occlusion = 1;
                // 不透明度の定義
                surfaceData.alpha = 0;
                // クリアコートマスクの定義
                surfaceData.clearCoatMask = 0;
                // クリアコートスムースネスの定義
                surfaceData.clearCoatSmoothness = 1;

                // URP のフラグメントシェーダーでの物理シミュレーションマテリアル関数
                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}
