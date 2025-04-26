using UnityEngine;

/// <summary>
/// アニメーションで変化させた値をShaderで使う
/// </summary>
public class ParameterToShader : MonoBehaviour
{
    // シェーダーで利用する値(C#側でAnimatorで変化させる)
    public float timeValue;
    public float alphaValue;

    /// <summary>
    /// Shaderを適用したマテリアル
    /// </summary>
    [SerializeField] private Material material;

    // Shader側に用意した定義済みの値を受け取る変数
    private string timeFactor = "_TimeFactor";
    private string alphaFactor = "_AlphaFactor";

    void Update()
    {
        // Shaderに値を渡す
        material?.SetFloat(timeFactor, timeValue);
        material?.SetFloat(alphaFactor, alphaValue);
    }
}
