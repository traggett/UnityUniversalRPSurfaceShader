#ifndef URP_SURFACE_SHADER_UNLIT_META_PASS_INCLUDED
#define URP_SURFACE_SHADER_UNLIT_META_PASS_INCLUDED

#include "URPUnlitInput.hlsl"
#include "URPUnlitMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

Varyings UniversalVertexMetaUnlit(Attributes input)
{
    Varyings output;
	
	UPDATE_INPUT_VERTEX(input);

    output.positionCS = MetaVertexPosition(input.positionOS, input.uv1, input.uv2, unity_LightmapST, unity_DynamicLightmapST);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
	
	UPDATE_OUTPUT_VERTEX(output);
	
    return output;
}

half4 UniversalFragmentMetaUnlit(Varyings input) : SV_Target
{
    MetaInput metaInput = (MetaInput)0;
    metaInput.Albedo = _BaseColor.rgb * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;

    return UnityMetaFragment(metaInput);
}
#endif
