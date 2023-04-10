Shader "Lighting/Fresnel2" 
{
Properties
{
_RimPower("Rim Power", Range(0.01, 0.1)) = 0.1 
_RimInten("Rim Intensity", Range(0.01, 100)) = 1 
[HDR]_RimColor("Rim Color", color) = (1,1,1,1)
}


SubShader 
{


Tags {"RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"} 


Pass 
{
Name "Universal Forward"
Tags {"LightMode" = "UniversalForward"}

HLSLPROGRAM
#pragma prefer_hlslcc gles
#pragma exclude_renderers d3d11_9x
#pragma vertex vert
#pragma fragment frag
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct VertexInput 
{
float4 vertex : POSITION;
float3 normal : NORMAL; 
};

struct VertexOutput 
{
float4 vertex : SV_POSITION;
float3 normal : NORMAL;
float3 WorldSpaceViewDirection : TEXCOORD0;
};


float _RimPower, _RimInten; 
half4 _RimColor;

VertexOutput vert(VertexInput v) 
{
VertexOutput o;
o.vertex = TransformObjectToHClip(v.vertex.xyz);
o.normal = TransformObjectToWorldNormal(v.normal);
// 지정된 객체 공간 정점 위치에서 카메라 방향으로 월드 공간 방향을 계산하고 정규화 함
//월드공간 카메라 좌표 - 월드공간버텍스 좌표
o.WorldSpaceViewDirection = normalize(_WorldSpaceCameraPos.xyz -TransformObjectToWorld(v.vertex.xyz));
//버텍스 쉐이더에서 프래그먼트 쉐이더로 위치 값을 전달할 때, 클립 공간 좌표 외에 월드 공간 좌표도 
//추가로 전달해서 계산한다. 

// o.WorldSpaceViewDirection = normalize(_WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz);

return o; 
}

half4 frag(VertexOutput i) : SV_Target 
{
float3 light = _MainLightPosition.xyz; 
float4 color = float4(0, 0, 0, 1);
    
//월드 카메라 벡터와 노멀을 내적해 방향에 대한 값을 구합니다.(비교)
//바라보는 방향이 같은 1(밝음) 90도면 0(어두움)이 됩니다.
half face = saturate(dot(i.WorldSpaceViewDirection, i.normal));
half3 rim = 1.0 - (pow(face, _RimPower));
   //half3 rim = 1.0 - face;
//Finally, in the function, you can find the operation pow( XRG, NRG ) 
//which allows you to increase or decrease the range of reflection.
//지수승으로 하는 것임!

//emissive term
//color.rgb *= saturate(dot(i.normal, light)) * _MainLightColor.rgb + ambient ;
//emissive term
color.rgb += rim * _RimInten * _RimColor;
   // color.rgb+=_RimColor*_RimInten*face;
 
return color; 
}
ENDHLSL
} 
}
}