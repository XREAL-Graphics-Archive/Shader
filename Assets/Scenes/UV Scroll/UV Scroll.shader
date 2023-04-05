Shader "Demo/UVScroll"
{
    Properties
    {
        _MainTex("Texture 1", 2D) = "white" {}
        // ST를 사용하지 않겠다는 뜻
        [NoScaleOffset] _Flowmap("Flowmap", 2D) = "white"{}
        _FlowTime("Flow Time", Float) = 1
        _FlowIntensity("Flow Intensity", Float) = 0.1

        [KeywordEnum(Simple, Flowmap)] _Example("Example", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue"="Geometry"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _EXAMPLE_SIMPLE _EXAMPLE_FLOWMAP

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            Texture2D _MainTex;
            float4 _MainTex_ST;
            Texture2D _Flowmap;
            SamplerState sampler_MainTex;

            float _FlowTime;
            float _FlowIntensity;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            half4 frag(VertexOutput i): SV_Target
            {
                #if _EXAMPLE_SIMPLE
                i.uv.x += _Time.x;
                i.uv.y += _Time.y;
                #else
                float4 flow = _Flowmap.Sample(sampler_MainTex, i.uv);
                i.uv += frac(_Time.x * _FlowTime) + flow.rg * _FlowIntensity;
                #endif

                float4 color = _MainTex.Sample(sampler_MainTex, i.uv);
                return color;
            }
            ENDHLSL
        }
    }
}