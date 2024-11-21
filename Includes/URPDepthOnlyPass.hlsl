#ifndef URP_SURFACE_SHADER_DEPTH_ONLY_PASS_INCLUDED
#define URP_SURFACE_SHADER_DEPTH_ONLY_PASS_INCLUDED

#include "URPShaderInputs.hlsl"
#include "URPMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
	
	UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
	
	////////////////////////////////
	UPDATE_INPUT_VERTEX(input);
	////////////////////////////////

    #if defined(_ALPHATEST_ON)
        output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    #endif
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
	
	////////////////////////////////
	UPDATE_OUTPUT_VERTEX(output);
	////////////////////////////////
	
    return output;
}

half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

	#if defined(_ALPHATEST_ON)
        Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    #endif

    #if defined(LOD_FADE_CROSSFADE)
        LODFadeCrossFade(input.positionCS);
    #endif
	
    return 0;
}
#endif
