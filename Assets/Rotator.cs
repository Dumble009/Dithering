using UnityEngine;

public class Rotator : MonoBehaviour
{
	[SerializeField] float m_rotatingSpeed;
	void Update()
	{
		var euler = transform.rotation.eulerAngles;
		euler.y += m_rotatingSpeed * Time.deltaTime;
		transform.rotation = Quaternion.Euler(euler);
	}
}