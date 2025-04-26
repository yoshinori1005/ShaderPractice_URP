using UnityEngine;

/// <summary>
/// 影の描画距離をShaderのグローバル変数で設定する
/// </summary>
[ExecuteAlways]
public class SetShadowDistance : MonoBehaviour
{
    void Start()
    {
        Shader.SetGlobalFloat("_ShadowDistance", QualitySettings.shadowDistance);
    }

    void Update()
    {
        // 設定値をリアルタイムに反映するのはEditor上だけで良い
        if (!Application.isEditor) return;
        Shader.SetGlobalFloat("_ShadowDistance", QualitySettings.shadowDistance);
    }
}
