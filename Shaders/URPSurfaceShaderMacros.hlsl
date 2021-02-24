#ifndef URP_SURFACE_SHADER_MACROS_INCLUDED
#define URP_SURFACE_SHADER_MACROS_INCLUDED

#include "URPSurfaceShaderInputs.hlsl"
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

///////////////////////////////////////////////////////////////////////////////
//                  Vertex functions                           				 //
///////////////////////////////////////////////////////////////////////////////

#ifndef UPDATE_INPUT_VERTEX 

#define UPDATE_INPUT_VERTEX DontModifyInputVertex

inline void DontModifyInputVertex(inout Attributes i)
{

}

#endif

#endif //URP_SURFACE_SHADER_MACROS_INCLUDED
