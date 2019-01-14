using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShadowMapView : MonoBehaviour
{
	[SerializeField] RawImage shadowMapImage;
	[SerializeField] Camera shadowMapCamera;

	void Start()
	{
		shadowMapImage.texture = shadowMapCamera.targetTexture;
	}
}
