using UnityEngine;

/// <summary>
/// 自作ポストエフェクトを適用する
/// ImageEffectAllowedInSceneViewというアトリビュートを使うことで
/// シーンビューにも反映される
/// </summary>
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomColorPostEffect : MonoBehaviour
{
    [SerializeField] private Material colorEffectMaterial;

    private enum UsePass
    {
        UsePass1, UsePass2
    }

    [SerializeField] private UsePass usePass;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, colorEffectMaterial, (int)usePass);
    }
}
