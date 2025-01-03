using UnityEngine;

public class ColorPalette : MonoBehaviour
{
    [SerializeField] Material m_mat;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, m_mat);
	}
}
