using UnityEngine;

/// <summary>
/// マウスから出た Ray とオブジェクトの衝突座標を Shader に返す
/// </summary>
public class MouseRayHitPointSendToShader : MonoBehaviour
{
    /// <summary>
    /// ポインターを出したいオブジェクトのレンダラー
    /// 前提:Shader は座標受け取りに対応したものを適用
    /// </summary>
    [SerializeField] private Renderer renderTarget;

    /// <summary>
    /// Shader 側で定義済みの座標を受け取る変数
    /// </summary>
    private string propName = "_MousePosition";
    private Material material;

    void Start()
    {
        material = renderTarget.material;
    }

    void Update()
    {
        // マウスの入力
        if (Input.GetMouseButton(0))
        {
            // Ray を出す
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hitInfo = new RaycastHit();
            float maxDistance = 100f;

            bool isHit = Physics.Raycast(ray, out hitInfo, maxDistance);

            // Ray とオブジェクトが衝突した時の処理
            if (isHit)
            {
                // 衝突
                Debug.Log(hitInfo.point);
                // Shader に座標を渡す
                material.SetVector(propName, hitInfo.point);
            }
        }
    }
}
