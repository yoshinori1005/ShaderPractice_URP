using UnityEngine;

/// <summary>
/// アニメーションで変化させた値を Shader で使ってみる
/// </summary>
// これをつけておくと Editor でプレビュー可能
// [ExecuteAlways]
public class AnimationUseToShader : MonoBehaviour
{
    // シェーダーで利用する値(C# 側で Animator で変化させる)
    public float gravityValue;
    public float positionValue;
    public float rotationValue;
    public float scaleValue;

    /// <summary>
    /// ジオメトリシェーダーを適用したオブジェクトのレンダラー
    /// </summary>
    [SerializeField] private Renderer renderTarget;

    // Shader 側に用意した定義済みの値を受け取る変数
    private string gravityFactor = "_GravityFactor";
    private string positionFactor = "_PositionFactor";
    private string rotationFactor = "_RotationFactor";
    private string scaleFactor = "_ScaleFactor";

    private Material material;

    void Start()
    {
        // Editor 上でマテリアルのインスタンスを作ろうとするとエラーがでるので shaderMaterial を利用
        material = renderTarget.sharedMaterial;
    }

    void Update()
    {
        // Shader に値を渡す
        material.SetFloat(gravityFactor, gravityValue);
        material.SetFloat(positionFactor, positionValue);
        material.SetFloat(rotationFactor, rotationValue);
        material.SetFloat(scaleFactor, scaleValue);
    }
}
