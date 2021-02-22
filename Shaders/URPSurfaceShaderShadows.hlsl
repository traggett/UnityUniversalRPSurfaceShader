#ifndef URP_SURFACE_SHADER_SHADOWS_INCLUDED
#define URP_SURFACE_SHADER_SHADOWS_INCLUDED

#include "URPSurfaceShaderInputs.hlsl"

#ifndef UPDATE_SHADOWS_VERTEX 
	#define UPDATE_SHADOWS_VERTEX dontUpdateShadowsVertex
#endif

#ifndef GET_SHADOWS
	#define GET_SHADOWS GetDefaultShadows
#endif


float3 _LightDirection;

inline void dontUpdateShadowsVertex(inout VertexInputShadows i)
{

}

inline float GetDefaultShadows(VertexOutputShadows input)
{
	Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
	return 0;
}

float4 GetShadowPositionHClip(VertexInputShadows input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

VertexOutputShadows vert(VertexInputShadows input)
{
    VertexOutputShadows output;
    UNITY_SETUP_INSTANCE_ID(input);
	
	UPDATE_SHADOWS_VERTEX(input);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionCS = GetShadowPositionHClip(input);
	
#if defined(REQUIRES_SCREEN_POS)
	output.screenPos = ComputeScreenPos(output.positionCS);
#endif

    return output;
}

half4 frag(VertexOutputShadows input) : SV_TARGET
{ 
    return GET_SHADOWS(input);
}

#endif // URP_SURFACE_SHADER_SHADOWS_INCLUDED