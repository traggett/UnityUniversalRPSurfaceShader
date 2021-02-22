#ifndef URP_EXAMPLE_SURFACE_SHADER_INCLUDED
#define URP_EXAMPLE_SURFACE_SHADER_INCLUDED

// Include this at the start of your file
#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"

// Use these defines to modify the shader (all are optional)
#define UPDATE_VERTEX updateVertex
#define GET_SURFACE_PROPERTIES GetSurfaceData
#define UPDATE_SHADOWS_VERTEX updateShadowsVertex

////////////////////////////////////////
// Use this to update data in the per vertex pass
//

inline void updateVertex(inout VertexInput i)
{
	//Stretch vertex position over time
	float3 wobble = _CosTime[3] * i.positionOS.x;
	i.positionOS.xyz += wobble;
}

inline void updateShadowsVertex(inout VertexInputShadows i)
{
	//Stretch vertex position over time
	float3 wobble = _CosTime[3] * i.positionOS.x;
	i.positionOS.xyz += wobble;
}

////////////////////////////////////////
// Use this to update data in the per pixel pass
//

inline SurfaceData GetSurfaceData(VertexOutput input)
{
	SurfaceData surfaceOutput;
	
    half4 albedoAlpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    surfaceOutput.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);

    half4 specGloss = SampleMetallicSpecGloss(input.uv, albedoAlpha.a);
    surfaceOutput.albedo = albedoAlpha.rgb * _BaseColor.rgb;

#if _SPECULAR_SETUP
    surfaceOutput.metallic = 1.0h;
    surfaceOutput.specular = specGloss.rgb;
#else
    surfaceOutput.metallic = specGloss.r;
    surfaceOutput.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    surfaceOutput.smoothness = specGloss.a;
    surfaceOutput.normalTS = SampleNormal(input.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    surfaceOutput.occlusion = SampleOcclusion(input.uv);
    surfaceOutput.emission = SampleEmission(input.uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));

#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoat = SampleClearCoat(input.uv);
    surfaceOutput.clearCoatMask       = clearCoat.r;
    surfaceOutput.clearCoatSmoothness = clearCoat.g;
#else
    surfaceOutput.clearCoatMask       = 0.0h;
    surfaceOutput.clearCoatSmoothness = 0.0h;
#endif

#if defined(_DETAIL)
	half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, input.uv).a;
	float2 detailUv = input.uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
	surfaceOutput.albedo = ApplyDetailAlbedo(detailUv, surfaceOutput.albedo, detailMask);
	surfaceOutput.normalTS = ApplyDetailNormal(detailUv, surfaceOutput.normalTS, detailMask);
#endif
	
	//Lerp albedo to red over time
	float flash = (_SinTime[3] + 1) * 0.5;
	surfaceOutput.albedo = lerp(surfaceOutput.albedo, half3(1,0,0), flash);
	
	return surfaceOutput;
}

// Include this at the end of your file
#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShader.hlsl"

#endif // URP_EXAMPLE_SURFACE_SHADER_INCLUDED