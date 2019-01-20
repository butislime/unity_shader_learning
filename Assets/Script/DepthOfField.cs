using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class DepthOfField : MonoBehaviour
{
	[SerializeField] Camera targetCamera;

	public RenderTexture colorTexture;
	public RenderTexture depthTexture;

	public float focusDistance = 0;
	public float focusWidth = 0;

	private void Awake()
	{
		targetCamera.depthTextureMode |= DepthTextureMode.Depth;
		colorTexture = new RenderTexture(Screen.width, Screen.height, 0);
		colorTexture.Create();
		depthTexture = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
		depthTexture.Create();

		targetCamera.SetTargetBuffers(colorTexture.colorBuffer, depthTexture.depthBuffer);

		{
			CommandBuffer command = new CommandBuffer();
			command.name = "set depth param";
			command.SetGlobalTexture("_DepthTex", depthTexture);
			targetCamera.AddCommandBuffer(CameraEvent.BeforeImageEffects, command);
		}

		{
			CommandBuffer command = new CommandBuffer();
			command.name = "write color buffer";
			command.Blit(colorTexture, BuiltinRenderTextureType.CameraTarget);
			targetCamera.AddCommandBuffer(CameraEvent.BeforeImageEffects, command);
		}

		var material = new Material(Shader.Find("ShaderTest/depth_of_field"));

		{
			CommandBuffer command = new CommandBuffer();
			command.name = "BoxFilterBlur";

			var source = Shader.PropertyToID("_CopiedScreenBuffer");
			command.GetTemporaryRT(source, -1, -1, 0, FilterMode.Bilinear);
			var buf1_prop = Shader.PropertyToID("_ReductionBuffer1");
			command.GetTemporaryRT(buf1_prop, Screen.width / 2, Screen.height / 2, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
			var blur_tex_prop = Shader.PropertyToID("_BlurTexBuffer");
			command.GetTemporaryRT(blur_tex_prop, Screen.width, Screen.height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);

			command.Blit(BuiltinRenderTextureType.CurrentActive, source);
			// ダウンサンプリングパス(0番)でレンダリング
			command.Blit(source, buf1_prop, material, 0);
			// アップサンプリングパス(2番)でレンダリング
			command.Blit(buf1_prop, blur_tex_prop, material, 2);
			// 生成したぼかし画像を設定
			command.SetGlobalTexture("_BlurTex", blur_tex_prop);

			// 出力
			command.Blit(source, BuiltinRenderTextureType.CameraTarget, material, 3);

			command.ReleaseTemporaryRT(source);
			command.ReleaseTemporaryRT(buf1_prop);
			command.ReleaseTemporaryRT(blur_tex_prop);

			targetCamera.AddCommandBuffer(CameraEvent.AfterImageEffects, command);
		}
	}

	private void Update()
	{
		var near_far_dist = targetCamera.farClipPlane - targetCamera.nearClipPlane;
		var dist_in_clip_space = (focusDistance - targetCamera.nearClipPlane) / near_far_dist;
		var width_in_clip_space = focusWidth / near_far_dist;
		Shader.SetGlobalFloat("_FocusDistance", dist_in_clip_space);
		Shader.SetGlobalFloat("_FocusWidth", width_in_clip_space);

	}
}
