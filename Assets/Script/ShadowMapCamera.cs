using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowMapCamera : MonoBehaviour
{
	public RenderTexture shadowMap { get; private set; }
	public new Camera camera { get; private set; }

	readonly int projectionShadowMapID = Shader.PropertyToID("_ProjectionShadowMap");
	readonly int projectionViewProjID = Shader.PropertyToID("_ProjectionViewProj");
	void Awake()
	{
		camera = GetComponent<Camera>();

		shadowMap = RenderTexture.GetTemporary(256, 256, 16, RenderTextureFormat.ARGB32);
		Shader.SetGlobalTexture(projectionShadowMapID, shadowMap);
		camera.targetTexture = shadowMap;
	}

	void OnPreRender()
	{
		Matrix4x4 view = camera.worldToCameraMatrix;
		Matrix4x4 proj = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true);
		Shader.SetGlobalMatrix(projectionViewProjID, proj * view);
	}
}
