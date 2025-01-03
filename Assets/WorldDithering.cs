using UnityEngine;

public class WorldDithering : MonoBehaviour
{
	[SerializeField] Material m_mat;
	Camera m_camera;

	private void Awake()
	{
		m_camera = GetComponent<Camera>();
		m_camera.depthTextureMode = DepthTextureMode.Depth;
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		var v = m_camera.worldToCameraMatrix;
		var p = GL.GetGPUProjectionMatrix(m_camera.projectionMatrix, true);
		var ivp = (p * v).inverse;
		m_mat.SetMatrix("_I_VP", ivp);

		m_mat.SetMatrix("_ViewToWorld", m_camera.cameraToWorldMatrix);

		Graphics.Blit(source, destination, m_mat);
	}
}
