Shader "URPTraining/URPBasic"
{ 
   Properties {   
   	 _TintColor("Test Color", color) = (1, 1, 1, 1)
	 _Intensity("Range Sample", Range(0, 1)) = 0
     _scale("scale",Range(-10,10))=1
     }  

	SubShader
	{  	
	Tags
        {
        "RenderPipeline"="UniversalPipeline"
        "RenderType"="Opaque"          
        "Queue"="Geometry"		
        }
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
		       	
	half4 _TintColor;
	float _Intensity;
	
			
	

        struct VertexInput
          {
           	float4 vertex : POSITION;
           
          };

        struct VertexOutput
          {
            float4 vertex  	: SV_POSITION;
        	float3 color      : COLOR;
      	  };

      VertexOutput vert(VertexInput v)
        	{
          		VertexOutput o;				
          		o.vertex = TransformObjectToHClip(v.vertex.xyz);
		o.color = TransformObjectToWorld(v.vertex.xyz);				
		return o;
        	}	

        						

        	half4 frag(VertexOutput i) : SV_Target
        	{

        		float4 color = float4(1, 1, 1, 1);
        		color.rgb *= _TintColor * _Intensity * i.color ;
        		return color;
        	}
	  ENDHLSL  
    	  }
     }
}

