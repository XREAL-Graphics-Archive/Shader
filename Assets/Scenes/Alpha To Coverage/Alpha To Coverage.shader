Shader "Demo/AlphaToCoverage"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        [Enum(Off, 0, On, 1)] _AlphaToCoverage("Alpha to Coverage", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent"
        }

        Pass
        {
            // Toggle Alpha to Coverage
            AlphaToMask [_AlphaToCoverage]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            half4 frag(VertexOutput i): SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);
                return color;
            }
            ENDHLSL
        }
    }
}