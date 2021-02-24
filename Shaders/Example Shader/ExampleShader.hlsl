#ifndef URP_EXAMPLE_SURFACE_SHADER_INCLUDED
#define URP_EXAMPLE_SURFACE_SHADER_INCLUDED

/////////////////////////////////////////
// Include this at the start of your file
/////////////////////////////////////////

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"

////////////////////////////////////////////
// Use this define to modify an input vertex 
////////////////////////////////////////////

#define UPDATE_INPUT_VERTEX ModifyInputVertex

inline void ModifyInputVertex(inout Attributes i)
{
	//Stretch vertex position over time
	float3 wobble = _CosTime[3] * i.positionOS.x;
	i.positionOS.xyz += wobble;
}

/////////////////////////////////////////////
// Use this to change the surfaces properties
/////////////////////////////////////////////

#if defined(FORWARD_PASS) || defined(GBUFFER_PASS)

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

#define GET_SURFACE_PROPERTIES GetSurfaceProperties

inline SurfaceData GetSurfaceProperties(Varyings input)
{
	SurfaceData outSurfaceData;
	
	float2 uv = input.uv;
	
	/////////////////////////////////////////////////////////////////////////////////////////
	// Default PBR surface properties match InitializeStandardLitSurfaceData in LitInput.hlsl
	/////////////////////////////////////////////////////////////////////////////////////////
	
	half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);

    half4 specGloss = SampleMetallicSpecGloss(uv, albedoAlpha.a);
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

#if _SPECULAR_SETUP
    outSurfaceData.metallic = 1.0h;
    outSurfaceData.specular = specGloss.rgb;
#else
    outSurfaceData.metallic = specGloss.r;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    outSurfaceData.smoothness = specGloss.a;
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.occlusion = SampleOcclusion(uv);
    outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));

#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoat = SampleClearCoat(uv);
    outSurfaceData.clearCoatMask       = clearCoat.r;
    outSurfaceData.clearCoatSmoothness = clearCoat.g;
#else
    outSurfaceData.clearCoatMask       = 0.0h;
    outSurfaceData.clearCoatSmoothness = 0.0h;
#endif

#if defined(_DETAIL)
    half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, uv).a;
    float2 detailUv = uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
    outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
    outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);

#endif
	
	///////////////////////////////////
	// Animate emission to red over time
	//////////////////////////////////
	
	float flash = (_SinTime[3] + 1) * 0.5;
	outSurfaceData.emission = lerp(outSurfaceData.albedo, half3(1,0,0), flash);
	
	return outSurfaceData;
}

#endif

#endif // URP_EXAMPLE_SURFACE_SHADER_INCLUDED