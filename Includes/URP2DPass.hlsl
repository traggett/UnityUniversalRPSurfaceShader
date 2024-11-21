#ifndef URP_SURFACE_SHADER_2D_INCLUDED
#define URP_SURFACE_SHADER_2D_INCLUDED

#include "URPShaderInputs.hlsl"
#include "URPMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
	
	UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
	
	////////////////////////////////
	UPDATE_INPUT_VERTEX(input);
	////////////////////////////////
	
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.vertex = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
	

#if defined(REQUIRES_VERTEX_COLOR)
	//output.color = input.color;
#endif

	////////////////////////////////
	UPDATE_OUTPUT_VERTEX(output);
	////////////////////////////////

    return output;
}

half4 frag(Varyings input) : SV_Target
{
	UNITY_SETUP_INSTANCE_ID(input);
	
    half2 uv = input.uv;
    half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    half3 color = texColor.rgb * _BaseColor.rgb;
    half alpha = texColor.a * _BaseColor.a;
    AlphaDiscard(alpha, _Cutoff);

#ifdef _ALPHAPREMULTIPLY_ON
    color *= alpha;
#endif
    return half4(color, alpha);
}

#endif //URP_SURFACE_SHADER_2D_INCLUDED
