#ifndef URP_EXAMPLE_SURFACE_SHADER_INCLUDED
#define URP_EXAMPLE_SURFACE_SHADER_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"

////////////////////////////////////////
// Use this to update data in the per vertex pass
//

#define UPDATE_VERTEX updateVertex

inline void updateVertex(inout VertexInput i)
{
	//Stretch vertex position over time
	float3 wobble = _CosTime[3] * i.positionOS.x;
	i.positionOS.xyz += wobble;
}

////////////////////////////////////////
// Use this to update data in the per pixel pass
//

#define GET_SURFACE_PROPERTIES GetSurfaceData

inline SurfaceData GetSurfaceData(VertexOutput vertex)
{
	SurfaceData surfaceOutput;
	
    half4 albedoAlpha = SampleAlbedoAlpha(vertex.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    surfaceOutput.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);

    half4 specGloss = SampleMetallicSpecGloss(vertex.uv, albedoAlpha.a);
    surfaceOutput.albedo = albedoAlpha.rgb * _BaseColor.rgb;

#if _SPECULAR_SETUP
    surfaceOutput.metallic = 1.0h;
    surfaceOutput.specular = specGloss.rgb;
#else
    surfaceOutput.metallic = specGloss.r;
    surfaceOutput.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    surfaceOutput.smoothness = specGloss.a;
    surfaceOutput.normalTS = SampleNormal(vertex.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    surfaceOutput.occlusion = SampleOcclusion(vertex.uv);
    surfaceOutput.emission = SampleEmission(vertex.uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
	
	//Lerp albedo to red over time
	float flash = (_SinTime[3] + 1) * 0.5;
	surfaceOutput.albedo = lerp(surfaceOutput.albedo, half3(1,0,0), flash);
	
	return surfaceOutput;
}

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShader.hlsl"

#endif // URP_EXAMPLE_SURFACE_SHADER_INCLUDED