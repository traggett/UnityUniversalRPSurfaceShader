#ifndef URP_SURFACE_SHADER_INCLUDED
#define URP_SURFACE_SHADER_INCLUDED

#include "URPSurfaceShaderInputs.hlsl"

#ifndef UPDATE_VERTEX 
	#define UPDATE_VERTEX dontUpdateVertex
#endif

#ifndef GET_SURFACE_PROPERTIES 
	#define GET_SURFACE_PROPERTIES GetDefaultSurfaceData
#endif

void InitializeInputData(VertexOutput input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

    half3 viewDirWS = SafeNormalize(input.viewDirWS);
#ifdef _NORMALMAP
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
#else
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

    inputData.fogCoord = input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
}


///////////////////////////////////////////////////////////////////////////////
//                  Surface Functions			                             //
///////////////////////////////////////////////////////////////////////////////

inline void dontUpdateVertex(inout VertexInput i)
{

}

inline SurfaceData GetDefaultSurfaceData(VertexOutput input)
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
	
	return surfaceOutput;
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

VertexOutput vert(VertexInput input)
{
    VertexOutput output = (VertexOutput)0;

	UPDATE_VERTEX(input);

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    float3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    output.viewDirWS = viewDirWS;
#ifdef _NORMALMAP
    real sign = input.tangentOS.w * GetOddNegativeScale();
    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;

#if defined(REQUIRES_WORLD_REFL)
	output.worldRefl = reflect(output.viewDirWS, output.normalWS);
#endif
#if defined(REQUIRES_SCREEN_POS)
	output.screenPos = ComputeScreenPos(output.positionCS);
#endif

    return output;
}

half4 frag(VertexOutput input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceData surfaceData = GET_SURFACE_PROPERTIES(input);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);

    half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha);

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, _Surface);

    return color;
}

#endif
