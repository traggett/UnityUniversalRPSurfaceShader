#ifndef URP_SURFACE_SHADER_UNLIT_INPUT_INCLUDED
#define URP_SURFACE_SHADER_UNLIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

#if defined(GBUFFER_PASS)

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#endif

/////////////////////////////////////////
// Forward Lighting
/////////////////////////////////////////

#if defined(FORWARD_PASS)

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
	float3 normalOS : NORMAL;
	float4 color	: COLOR;
    #if defined(DEBUG_DISPLAY)  
    float4 tangentOS : TANGENT;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float fogCoord : TEXCOORD1;
    float4 positionCS : SV_POSITION;

#if defined(REQUIRES_VERTEX_COLOR)
    float4 color               		: COLOR;
#endif

    #if defined(DEBUG_DISPLAY)
    float3 positionWS : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
    float3 viewDirWS : TEXCOORD4;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

/////////////////////////////////////////
// SHADOWS
/////////////////////////////////////////

#elif defined(SHADOWS_PASS)

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
};

/////////////////////////////////////////
// G Buffer
/////////////////////////////////////////

#elif defined(GBUFFER_PASS)

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    float3 normalOS : NORMAL;
	float4 color	: COLOR;
	
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
	
#if defined(REQUIRES_VERTEX_COLOR)
    float4 color               		: COLOR;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

/////////////////////////////////////////
// Depth Only
/////////////////////////////////////////

#elif defined(DEPTH_ONLY_PASS)

struct Attributes
{
    float4 positionOS   : POSITION;
    float2 texcoord     : TEXCOORD0;
    float3 normalOS     : NORMAL;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

/////////////////////////////////////////
// Depth Normals
/////////////////////////////////////////

#elif defined(DEPTH_NORMALS_PASS)

struct Attributes
{
    float3 normalOS      : NORMAL;
    float4 positionOS   : POSITION;
	float2 texcoord     : TEXCOORD0;
    float4 tangentOS    : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float3 normalWS     : TEXCOORD1;
	float2 uv           : TEXCOORD2;
	 
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


/////////////////////////////////////////
// Meta
/////////////////////////////////////////

#elif defined(META_PASS)

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord2    : TEXCOORD1;
    float2 texcoord3    : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
#ifdef EDITOR_VISUALIZATION
    float2 VizUV        : TEXCOORD1;
    float4 LightCoord   : TEXCOORD2;
#endif
};


#endif

#endif
