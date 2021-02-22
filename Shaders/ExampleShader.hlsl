#ifndef URP_EXAMPLE_SURFACE_SHADER_INCLUDED
#define URP_EXAMPLE_SURFACE_SHADER_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

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

inline void GetSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
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
	
	//Lerp albedo to red over time
	float flash = (_SinTime[3] + 1) * 0.5;
	outSurfaceData.albedo = lerp(outSurfaceData.albedo, half3(1,0,0), flash);
}

#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShader.hlsl"

#endif // URP_EXAMPLE_SURFACE_SHADER_INCLUDED