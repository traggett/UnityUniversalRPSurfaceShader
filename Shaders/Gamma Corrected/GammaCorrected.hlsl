#ifndef GAMMA_CORRECTED_SHADER_INCLUDED
#define GAMMA_CORRECTED_SHADER_INCLUDED

/////////////////////////////////////////
// Include this at the start of your file
/////////////////////////////////////////

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"

#if UNITY_COLORSPACE_GAMMA
#include "GammaCorrectedPBR.hlsl"
#endif

/////////////////////////////////////////////
// Use this to change the surfaces properties
/////////////////////////////////////////////

#if defined(FORWARD_PASS) || defined(GBUFFER_PASS)

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

#define GET_SURFACE_PROPERTIES GetGammaCorrectedSurfaceProperties

inline SurfaceData GetGammaCorrectedSurfaceProperties(Varyings input)
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

#if UNITY_COLORSPACE_GAMMA
	specGloss.rgb = pow(specGloss.rgb, half3(GAMMA, GAMMA, GAMMA));
	outSurfaceData.albedo = pow(outSurfaceData.albedo, half3(GAMMA, GAMMA, GAMMA));
#endif

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

#if UNITY_COLORSPACE_GAMMA
	outSurfaceData.occlusion = pow(outSurfaceData.occlusion, half3(GAMMA, GAMMA, GAMMA));
	outSurfaceData.emission = pow(outSurfaceData.emission, half3(GAMMA, GAMMA, GAMMA));
#endif

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

	return outSurfaceData;
}


#if defined(FORWARD_PASS)

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderLightingPass.hlsl"

half4 LitPassFragmentGamma(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

#if defined(_PARALLAXMAP)
#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
#else
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, input.viewDirWS);
#endif
    ApplyPerPixelDisplacement(viewDirTS, input.uv);
#endif

    SurfaceData surfaceData = GET_SURFACE_PROPERTIES(input);

    InputData inputData;   

#if UNITY_COLORSPACE_GAMMA
	InitializeInputDataGamma(input, surfaceData.normalTS, inputData);
    half4 color = UniversalFragmentPBRGamma(inputData, surfaceData);
	color = pow(color, half4(INV_GAMMA, INV_GAMMA, INV_GAMMA, 1));
#else
	InitializeInputData(input, surfaceData.normalTS, inputData);
    half4 color = UniversalFragmentPBR(inputData, surfaceData);
#endif

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, _Surface);

    return color;
}

#elif defined(GBUFFER_PASS)

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderLitGBufferPass.hlsl"

FragmentOutput LitGBufferPassFragmentGamma(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

#if defined(_PARALLAXMAP)
#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
#else
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, input.viewDirWS);
#endif
    ApplyPerPixelDisplacement(viewDirTS, input.uv);
#endif

    SurfaceData surfaceData = GET_SURFACE_PROPERTIES(input);
	
    InputData inputData;
#if UNITY_COLORSPACE_GAMMA
	InitializeInputDataGamma(input, surfaceData.normalTS, inputData);
#else
	InitializeInputData(input, surfaceData.normalTS, inputData);
#endif

    // Stripped down version of UniversalFragmentPBR().

#ifdef _SPECULARHIGHLIGHTS_OFF
    bool specularHighlightsOff = true;
#else
    bool specularHighlightsOff = false;
#endif

    // in LitForwardPass GlobalIllumination (and temporarily LightingPhysicallyBased) are called inside UniversalFragmentPBR
    // in Deferred rendering we store the sum of these values (and of emission as well) in the GBuffer
    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surfaceData.occlusion, inputData.normalWS, inputData.viewDirectionWS);

#if UNITY_COLORSPACE_GAMMA
	color = pow(color, half4(INV_GAMMA, INV_GAMMA, INV_GAMMA, 1));
#endif

    return BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color);
}

#endif


#endif // defined(FORWARD_PASS) || defined(GBUFFER_PASS)

#endif // GAMMA_CORRECTED_LIT_SHADER_INCLUDED