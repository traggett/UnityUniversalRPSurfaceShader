#ifndef URP_SURFACE_SHADER_UNLIT_META_PASS_INCLUDED
#define URP_SURFACE_SHADER_UNLIT_META_PASS_INCLUDED

#include "URPUnlitShaderInputs.hlsl"
#include "URPMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

Varyings UniversalVertexMeta(Attributes input)
{
    Varyings output;
	
	////////////////////////////////
	UPDATE_INPUT_VERTEX(input);
	////////////////////////////////

    output.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.texcoord2, input.texcoord3);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
	
#ifdef EDITOR_VISUALIZATION
    UnityEditorVizData(input.positionOS.xyz, input.texcoord, input.texcoord2, input.texcoord3, output.VizUV, output.LightCoord);
#endif
	
	////////////////////////////////
	UPDATE_OUTPUT_VERTEX(output);
	////////////////////////////////
	
    return output;
}

half4 UniversalFragmentMetaUnlit(Varyings input) : SV_Target
{
    MetaInput metaInput = (MetaInput)0;
	
	////////////////////////////////
	half3 color;
	float alpha;
	GET_UNLIT_SURFACE_PROPERTIES(input, color, alpha);
	////////////////////////////////
	
	AlphaDiscard(alpha, _Cutoff);
    color = AlphaModulate(color, alpha);
	
    metaInput.Albedo = color;
	
#ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = fragIn.VizUV;
    metaInput.LightCoord = fragIn.LightCoord;
#endif

    return UnityMetaFragment(metaInput);
}

#endif
