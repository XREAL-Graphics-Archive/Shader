Shader "Demo/AlphaTest"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _AlphaTest("Alpha Test", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "TransparentCutout" "RenderPipeline" = "UniversalRenderPipeline" "Queue"="AlphaTest"
        }

        Pass
        {
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
            float _AlphaTest;

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
                // _AlphaTest보다 a의 값이 작다면, 버린다
                clip(color.a - _AlphaTest);
                return color;
            }
            ENDHLSL
        }
    }
}