using UnityEngine;

public class MeshGenerator : MonoBehaviour
{
    public Material material;

    // 初期化
    void Start()
    {
        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshRenderer.material = material;

        Mesh mesh = new Mesh();

        // 空間に単純な四角形を作るので、2つの三角形になる頂点が必要
        mesh.vertices = new Vector3[]
        {
            new Vector3(-0.5f,-0.5f,0f),    // 0
            new Vector3(0.5f,-0.5f,0f),     // 1
            new Vector3(0.5f,0.5f,0f),      // 2
            new Vector3(-0.5f,0.5f,0f)      // 3
        };

        // コードや3Dモデリングソフトウェアから、頂点の色を読み書きできる
        mesh.colors = new Color[]
        {
            Color.red,      // 0
            Color.green,    // 1
            Color.blue,     // 2
            Color.gray      // 3
        };

        // この場合、頂点番号 0 を共有する
        mesh.triangles = new int[]
        {
            0,2,1,
            0,3,2
        };

        mesh.RecalculateBounds();

        MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = mesh;
    }
}
