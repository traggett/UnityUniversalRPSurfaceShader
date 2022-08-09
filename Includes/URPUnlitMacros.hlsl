#ifndef URP_SURFACE_SHADER_UNLIT_MACROS_INCLUDED
#define URP_SURFACE_SHADER_UNLIT_MACROS_INCLUDED

#include "URPUnlitInput.hlsl"

///////////////////////////////////////////////////////////////////////////////
//                  Surface Functions			                             //
///////////////////////////////////////////////////////////////////////////////

#ifndef GET_UNLIT_SURFACE_PROPERTIES 

#define GET_UNLIT_SURFACE_PROPERTIES GetDefaultInputData

inline InputData GetDefaultInputData(Varyings input)
{
	InputData inputData = (InputData)0;
	
#if defined(DEBUG_DISPLAY)
    inputData.positionWS = input.positionWS;
    inputData.normalWS = input.normalWS;
    inputData.viewDirectionWS = input.viewDirWS;
#else
    inputData.positionWS = float3(0, 0, 0);
    inputData.normalWS = half3(0, 0, 1);
    inputData.viewDirectionWS = half3(0, 0, 1);
#endif
    inputData.shadowCoord = 0;
    inputData.fogCoord = 0;
    inputData.vertexLighting = half3(0, 0, 0);
    inputData.bakedGI = half3(0, 0, 0);
    inputData.normalizedScreenSpaceUV = 0;
    inputData.shadowMask = half4(1, 1, 1, 1);
	
	return inputData;
}

#endif

#ifndef UPDATE_SHADOW_SURFACE

#define UPDATE_SHADOW_SURFACE UpdateDefaultShadowSurfaceData

inline void UpdateDefaultShadowSurfaceData(Varyings input)
{

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
