using System;
using System.Collections;
using UnityEngine;

public class CameraMover : MonoBehaviour
{
    // カメラの移動量
    [SerializeField, Range(0.1f, 10.0f)]
    float positionStep = 2.0f;
    // Shift キーでの速度倍率
    [SerializeField, Range(1.0f, 5.0f)]
    float speedMultiplier = 1.2f;
    // マウス感度
    [SerializeField, Range(30.0f, 150.0f)]
    float mouseSensitive = 90.0f;

    // カメラ操作の有効無効
    bool cameraMoveActive = true;
    // カメラの Transform
    Transform cameraTransform;
    // マウスの始点
    Vector3 startMousePos;
    // カメラ回転の始点情報
    Vector3 presentCamRotation;
    Vector3 presentCamPos;
    // 回転初期状態
    Quaternion initialCamRotation;
    // UIメッセージ表示
    bool uiMessageActive;

    void Start()
    {
        cameraTransform = this.gameObject.transform;

        // 回転初期値の保存
        initialCamRotation = this.gameObject.transform.rotation;
    }

    void Update()
    {
        CamControlIsActive();

        if (cameraMoveActive)
        {
            ResetCameraRotation();
            CameraRotationMouseControl();
            CameraSlideMouseControl();
            CameraPositionKeyControl();
        }
    }

    // カメラ操作の有効、無効を決めるメソッド
    private void CamControlIsActive()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            cameraMoveActive = !cameraMoveActive;

            if (uiMessageActive == false)
            {
                StartCoroutine(DisplayUIMessage());
            }

            Debug.Log("CamControl :" + cameraMoveActive);
        }
    }

    // UIメッセージの表示メソッド
    IEnumerator DisplayUIMessage()
    {
        uiMessageActive = true;
        // float time = 0;
        // while (time < 2)
        // {
        //     time = time + Time.deltaTime;
        //     yield return null;
        // }
        yield return new WaitForSeconds(2);
        uiMessageActive = false;
    }

    // カメラの回転角度をリセットするメソッド
    private void ResetCameraRotation()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            this.gameObject.transform.rotation = initialCamRotation;
            Debug.Log("Cam Rotate :" + initialCamRotation.ToString());
        }
    }

    // カメラの回転操作をマウスで行なうメソッド
    private void CameraRotationMouseControl()
    {
        if (Input.GetMouseButtonDown(0))
        {
            startMousePos = Input.mousePosition;
            presentCamRotation.x = cameraTransform.transform.eulerAngles.x;
            presentCamRotation.y = cameraTransform.transform.eulerAngles.y;
        }

        if (Input.GetMouseButton(0))
        {
            // (移動開始座標-マウスの現在座標)/解像度で正規化
            float x = (startMousePos.x - Input.mousePosition.x) / Screen.width;
            float y = (startMousePos.y - Input.mousePosition.y) / Screen.height;

            // 回転開始角度+マウスの変化量*マウスの感度
            float eulerX = presentCamRotation.x + y * mouseSensitive;
            float eulerY = presentCamRotation.y + x * mouseSensitive;

            cameraTransform.rotation = Quaternion.Euler(eulerX, eulerY, 0);
        }
    }

    // カメラの縦横移動をマウスで行なうメソッド
    private void CameraSlideMouseControl()
    {
        if (Input.GetMouseButtonDown(1))
        {
            startMousePos = Input.mousePosition;
            presentCamPos = cameraTransform.position;
        }

        if (Input.GetMouseButton(1))
        {
            // (移動開始座標-マウスの現在座標)/解像度で正規化
            float x = (startMousePos.x - Input.mousePosition.x) / Screen.width;
            float y = (startMousePos.y - Input.mousePosition.y) / Screen.height;

            x *= positionStep;
            y *= positionStep;

            Vector3 velocity = cameraTransform.rotation * new Vector3(x, y, 0);
            // velocity += presentCamPos;
            cameraTransform.position = presentCamPos + velocity;
        }
    }

    // カメラのキー入力移動メソッド
    private void CameraPositionKeyControl()
    {
        Vector3 campos = cameraTransform.position;
        float speed = positionStep * speedMultiplier;

        if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
        {

        }

        if (Input.GetKey(KeyCode.D))
        {
            campos += cameraTransform.right * Time.deltaTime * positionStep;

            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
            {
                campos += cameraTransform.right * Time.deltaTime * speed;
            }
        }
        if (Input.GetKey(KeyCode.A))
        {
            campos -= cameraTransform.right * Time.deltaTime * positionStep;

            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
            {
                campos -= cameraTransform.right * Time.deltaTime * speed;
            }
        }
        if (Input.GetKey(KeyCode.E))
        {
            campos += cameraTransform.up * Time.deltaTime * positionStep;

            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
            {
                campos += cameraTransform.up * Time.deltaTime * speed;
            }
        }
        if (Input.GetKey(KeyCode.Q))
        {
            campos -= cameraTransform.up * Time.deltaTime * positionStep;

            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
            {
                campos -= cameraTransform.up * Time.deltaTime * speed;
            }
        }
        if (Input.GetKey(KeyCode.W))
        {
            campos += cameraTransform.forward * Time.deltaTime * positionStep;

            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
            {
                campos += cameraTransform.forward * Time.deltaTime * speed;
            }
        }
        if (Input.GetKey(KeyCode.S))
        {
            campos -= cameraTransform.forward * Time.deltaTime * positionStep;

            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
            {
                campos -= cameraTransform.forward * Time.deltaTime * speed;
            }
        }

        cameraTransform.position = campos;
    }

    private void OnGUI()
    {
        if (uiMessageActive == false) return;

        GUI.color = Color.white;
        

        if (cameraMoveActive == true)
        {
            GUI.Label(new Rect(
                Screen.width / 2 - 50,
                Screen.height/2 - 30,
                300,
                60
                ),
                "カメラ操作 有効");
        }

        if (cameraMoveActive == false)
        {
            GUI.Label(new Rect(
                Screen.width / 2 - 50,
                Screen.height/2 - 30,
                300,
                60
                ),
                "カメラ操作 無効");
        }
    }
}
