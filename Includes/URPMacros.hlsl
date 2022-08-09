#ifndef URP_SURFACE_SHADER_MACROS_INCLUDED
#define URP_SURFACE_SHADER_MACROS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

///////////////////////////////////////////////////////////////////////////////
//                  Surface Functions			                             //
///////////////////////////////////////////////////////////////////////////////

#ifndef GET_SURFACE_PROPERTIES 

#define GET_SURFACE_PROPERTIES GetDefaultSurfaceData

inline SurfaceData GetDefaultSurfaceData(Varyings input)
{
	SurfaceData surfaceOutput;	
	InitializeStandardLitSurfaceData(input.uv, surfaceOutput);
	return surfaceOutput;
}

#endif

#ifndef UPDATE_SHADOW_SURFACE

#define UPDATE_SHADOW_SURFACE UpdateDefaultShadowSurfaceData

inline void UpdateDefaultShadowSurfaceData(Varyings input)
{

}

#endif

#ifndef GET_UNLIT_SURFACE_PROPERTIES 

#define GET_UNLIT_SURFACE_PROPERTIES GetDefaultUnlitSurfaceData

inline void GetDefaultUnlitSurfaceData(Varyings input, out half3 color, out float alpha)
{
	half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    color = texColor.rgb * _BaseColor.rgb;
    alpha = texColor.a * _BaseColor.a;
}

#endif

///////////////////////////////////////////////////////////////////////////////
//                  Vertex functions                           				 //
///////////////////////////////////////////////////////////////////////////////

#ifndef UPDATE_INPUT_VERTEX 

#define UPDATE_INPUT_VERTEX DontModifyInputVertex

inline void DontModifyInputVertex(inout Attributes i)
{

}

#endif

#ifndef UPDATE_OUTPUT_VERTEX 

#define UPDATE_OUTPUT_VERTEX DontModifyOutputVertex

inline void DontModifyOutputVertex(inout Varyings i)
{

}

#endif

#endif //URP_SURFACE_SHADER_MACROS_INCLUDED
