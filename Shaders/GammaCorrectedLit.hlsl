#ifndef GAMMA_CORRECTED_LIT_SHADER_INCLUDED
#define GAMMA_CORRECTED_LIT_SHADER_INCLUDED

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"
#if UNITY_COLORSPACE_GAMMA
#include "GammaCorrectedPBR.hlsl"
#endif

#define GET_SURFACE_PROPERTIES GetSurfaceData

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

#if UNITY_COLORSPACE_GAMMA
	specGloss.rgb = pow(specGloss.rgb, half3(GAMMA, GAMMA, GAMMA));
	surfaceOutput.albedo = pow(surfaceOutput.albedo, half3(GAMMA, GAMMA, GAMMA));
#endif

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

#if UNITY_COLORSPACE_GAMMA
	surfaceOutput.occlusion = pow(surfaceOutput.occlusion, half3(GAMMA, GAMMA, GAMMA));
	surfaceOutput.emission = pow(surfaceOutput.emission, half3(GAMMA, GAMMA, GAMMA));
#endif

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

	return surfaceOutput;
}

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShader.hlsl"

half4 fragGamma(VertexOutput input) : SV_Target
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

#endif // GAMMA_CORRECTED_LIT_SHADER_INCLUDED