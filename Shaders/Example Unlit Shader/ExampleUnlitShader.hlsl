#ifndef URP_EXAMPLE_SURFACE_SHADER_INCLUDED
#define URP_EXAMPLE_SURFACE_SHADER_INCLUDED

/////////////////////////////////////////
// Include this at the start of your file
/////////////////////////////////////////

#include "Packages/com.clarky.urpsurfaceshader/Includes/URPUnlitShaderInputs.hlsl"

////////////////////////////////////////////
// Use this define to modify an input vertex 
////////////////////////////////////////////

#define UPDATE_INPUT_VERTEX ModifyInputVertex

inline void ModifyInputVertex(inout Attributes i)
{
	//Stretch vertex position over time
	float3 wobble = _CosTime[3] * i.positionOS.x;
	i.positionOS.xyz += wobble;
}

/////////////////////////////////////////////
// Use this to change the surfaces properties
/////////////////////////////////////////////

#define GET_UNLIT_SURFACE_PROPERTIES GetUnlitSurfaceData

inline void GetUnlitSurfaceData(Varyings input, out half3 color, out float alpha)
{
	half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    color = texColor.rgb * _BaseColor.rgb;
    alpha = texColor.a * _BaseColor.a;
	
	///////////////////////////////////
	// Animate color to red over time
	//////////////////////////////////
	
	float flash = (_SinTime[3] + 1) * 0.5;
	color = lerp(color, half3(1,0,0), flash);
}

#endif // URP_EXAMPLE_SURFACE_SHADER_INCLUDED