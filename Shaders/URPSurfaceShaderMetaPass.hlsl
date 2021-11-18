#ifndef UNIVERSAL_LIT_META_PASS_INCLUDED
#define UNIVERSAL_LIT_META_PASS_INCLUDED

#include "URPSurfaceShaderInputs.hlsl"
#include "URPSurfaceShaderMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

Varyings UniversalVertexMeta(Attributes input)
{
    Varyings output;
	
	UPDATE_INPUT_VERTEX(input);

    output.positionCS = MetaVertexPosition(input.positionOS, input.uv1, input.uv2, unity_LightmapST, unity_DynamicLightmapST);
    output.uv = TRANSFORM_TEX(input.uv0, _BaseMap);
	
	UPDATE_OUTPUT_VERTEX(output);
	
    return output;
}

half4 UniversalFragmentMeta(Varyings input) : SV_Target
{
	SurfaceData surfaceData = GET_SURFACE_PROPERTIES(input);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.Emission = surfaceData.emission;
	
#ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = fragIn.VizUV;
    metaInput.LightCoord = fragIn.LightCoord;
#endif
	
	return UnityMetaFragment(metaInput);
}

#endif
