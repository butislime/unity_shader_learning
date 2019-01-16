using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BoxFilterBlur : MonoBehaviour
{
	[SerializeField] Camera targetCamera;
	[SerializeField] Material blurMaterial;

	CommandBuffer cmd;

	private void Awake()
	{
		cmd = new CommandBuffer();
		cmd.name = "BoxFilterBlur";

		var source = Shader.PropertyToID("_CopiedScreenBuffer");
		cmd.GetTemporaryRT(source, -1, -1, 0, FilterMode.Bilinear);
		var prop1 = Shader.PropertyToID("_ReductionBuffer1");
		cmd.GetTemporaryRT(prop1, Screen.width / 2, Screen.height / 2, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
		var prop2 = Shader.PropertyToID("_ReductionBuffer2");
		cmd.GetTemporaryRT(prop2, Screen.width / 4, Screen.height / 4, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);

		cmd.Blit(BuiltinRenderTextureType.CurrentActive, source);
		// ダウンサンプリングパス(0番)でレンダリング
		cmd.Blit(source, prop1, blurMaterial, 0);
		cmd.Blit(prop1, prop2, blurMaterial, 0);
		// アップサンプリングパス(1番)でレンダリング
		cmd.Blit(prop2, prop1, blurMaterial, 1);
		cmd.Blit(prop1, BuiltinRenderTextureType.CameraTarget, blurMaterial, 1);

		cmd.ReleaseTemporaryRT(prop1);
		cmd.ReleaseTemporaryRT(prop2);

		targetCamera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
	}
}
