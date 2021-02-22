#ifndef URP_EXAMPLE_SURFACE_SHADER_SHADOWS_INCLUDED
#define URP_EXAMPLE_SURFACE_SHADER_SHADOWS_INCLUDED

// Include this at the start of your file
#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderInputs.hlsl"

// Use these defines to modify the shader (all are optional)
#define UPDATE_SHADOWS_VERTEX updateShadowsVertex
#define GET_SHADOWS getShadows

////////////////////////////////////////
// Use this to update data in the per vertex pass
//

inline void updateShadowsVertex(inout VertexInputShadows i)
{
	//Stretch vertex position over time
	float3 wobble = _CosTime[3] * i.positionOS.x;
	i.positionOS.xyz += wobble;
}

inline float getShadows(VertexOutputShadows input)
{
	Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
	return 0;
}

// Include this at the end of your file
#include "Assets/ThirdParty/UnityUniversalRPSurfaceShader/Shaders/URPSurfaceShaderShadows.hlsl"

#endif // URP_EXAMPLE_SURFACE_SHADER_SHADOWS_INCLUDED