#ifndef URP_SURFACE_SHADER_UNLIT_GBUFFER_PASS_INCLUDED
#define URP_SURFACE_SHADER_UNLIT_GBUFFER_PASS_INCLUDED

#include "URPUnlitShaderInputs.hlsl"
#include "URPMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Unlit.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif


void InitializeInputData(Varyings input, out InputData inputData)
{
    inputData = (InputData)0;

    inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);

    inputData.positionWS = float3(0, 0, 0);
    inputData.viewDirectionWS = half3(0, 0, 1);
    inputData.shadowCoord = 0;
    inputData.fogCoord = 0;
    inputData.vertexLighting = half3(0, 0, 0);
    inputData.bakedGI = half3(0, 0, 0);
    inputData.normalizedScreenSpaceUV = 0;
    inputData.shadowMask = half4(1, 1, 1, 1);
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

Varyings UnlitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
	
	////////////////////////////////
	UPDATE_INPUT_VERTEX(input);
	////////////////////////////////

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexInput.positionCS;

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    output.normalWS = normalInput.normalWS;
	
#if defined(REQUIRES_VERTEX_COLOR)
    output.color = input.color;
#endif
	
	////////////////////////////////
	UPDATE_OUTPUT_VERTEX(output);
	////////////////////////////////

    return output;
}

FragmentOutput UnlitPassFragment(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half2 uv = input.uv;
    half4 texColor = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    half3 color = texColor.rgb * _BaseColor.rgb;
    half alpha = texColor.a * _BaseColor.a;

    alpha = AlphaDiscard(alpha, _Cutoff);
    color = AlphaModulate(color, alpha);

#ifdef LOD_FADE_CROSSFADE
    LODFadeCrossFade(input.positionCS);
#endif

    InputData inputData;
    InitializeInputData(input, inputData);

#ifdef _DBUFFER
    ApplyDecalToBaseColor(input.positionCS, color);
#endif

    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = color;
    surfaceData.alpha = alpha;

#if defined(_SCREEN_SPACE_OCCLUSION) // GBuffer never has transparents
    float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(normalizedScreenSpaceUV);
    surfaceData.occlusion = aoFactor.directAmbientOcclusion;
#else
    surfaceData.occlusion = 1;
#endif

    return SurfaceDataToGbuffer(surfaceData, inputData, float3(0,0,0), kLightingInvalid);
}

#endif
