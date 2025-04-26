using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms.GameCenter;

public class DrawMeshInstancing : MonoBehaviour
{
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;
    [SerializeField] private float areaWidth = 5.0f;
    [SerializeField] private float areaHeight = 15.0f;
    [SerializeField] private Vector3 adjustPosition;
    [SerializeField] private Vector3 adjustScale;
    [SerializeField] private int meshCount = 512;
    [SerializeField] private float rotationAngleDegrees;

    private Matrix4x4[] matrices;
    private List<Vector3> positions;

    void Start()
    {
        positions = GenerateCoordinates(
            areaWidth,
            areaHeight,
            meshCount,
            transform.position,
            rotationAngleDegrees
        );

        matrices = new Matrix4x4[positions.Count];

        for (var i = 0; i < positions.Count; i++)
        {
            var pos = positions[i] * Random.Range(0.99f, 1.01f);
            var meshPosition = new Vector3(
                pos.x + adjustPosition.x,
                positions[i].y + adjustPosition.y,
                pos.z + adjustPosition.z
            );

            matrices[i % meshCount] = Matrix4x4.TRS(
                meshPosition,
                Quaternion.identity,
                adjustScale
                );
        }
    }

    private List<Vector3> GenerateCoordinates(
        float width,
        float height,
        int totalCoordinates,
        Vector3 center,
        float rotationAngleDegrees)
    {
        var coordinateList = new List<Vector3>();
        var rowCount = Mathf.FloorToInt(Mathf.Sqrt(totalCoordinates * (width / height)));
        var columnCount = totalCoordinates / rowCount;

        var spacingX = width / rowCount;
        var spacingZ = height / columnCount;

        var rotationAngleRadians = rotationAngleDegrees * Mathf.Deg2Rad;

        for (var col = 0; col < columnCount; col++)
        {
            for (var row = 0; row < rowCount; row++)
            {
                var x = row * spacingX - width / 2 + center.x;
                var z = col * spacingZ - height / 2 + center.z;

                var pos = RotatePoint(new Vector3(x, center.y, z), center, rotationAngleRadians);
                coordinateList.Add(pos);

                if (coordinateList.Count >= totalCoordinates)
                    return coordinateList;
            }
        }

        return coordinateList;
    }

    private Vector3 RotatePoint(Vector3 point, Vector3 center, float angleRadians)
    {
        var cosTheta = Mathf.Cos(angleRadians);
        var sinTheta = Mathf.Sin(angleRadians);

        var rotatedX = cosTheta * (point.x - center.x) - sinTheta * (point.z - center.z) + center.x;
        var rotatedZ = sinTheta * (point.x - center.x) + cosTheta * (point.z - center.z) + center.z;

        return new Vector3(rotatedX, point.y, rotatedZ);
    }

    void Update()
    {
        Graphics.DrawMeshInstanced(mesh, 0, material, matrices, positions.Count);
    }
}
