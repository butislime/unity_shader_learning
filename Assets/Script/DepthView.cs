using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DepthView : MonoBehaviour
{
	[SerializeField] RawImage depthImage;
	[SerializeField] DepthOfField dof;

	void Start()
	{
		depthImage.texture = dof.depthTexture;
	}
}
