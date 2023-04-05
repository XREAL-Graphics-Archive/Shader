Shader "Demo/TextureSplatting"
{
    Properties
    {
        _MainTex("Texture 1", 2D) = "white" {}
        _MainTex2("Texture 2", 2D) = "white" {}

        _MaskTex("Mask Texture", 2D) = "white" {}

        [KeywordEnum(UV, Lerp, WithMask)] _Example("Example", Float) = 0
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
            #pragma multi_compile _EXAMPLE_UV _EXAMPLE_LERP _EXAMPLE_WITHMASK

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
            Texture2D _MainTex2;
            float4 _MainTex2_ST;
            SamplerState sampler_MainTex;

            Texture2D _MaskTex;
            float4 _MaskTex_ST;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                // 서로 다른 scale과 offset
                o.uv2 = v.uv * _MainTex2_ST.xy + _MainTex2_ST.zw;
                return o;
            }

            half4 frag(VertexOutput i): SV_Target
            {
                float4 color = _MainTex.Sample(sampler_MainTex, i.uv);
                float4 color2 = _MainTex2.Sample(sampler_MainTex, i.uv2);
                float4 mask = _MaskTex.Sample(sampler_MainTex, i.uv);

                #if _EXAMPLE_UV
                // u를r로 v를g로 값이 어떤지 눈으로 볼 수 있음
                color = float4(i.uv.x, i.uv.y, 0, 1);
                #elif _EXAMPLE_LERP
                // lerp: builtin 함수 a + x(b - a)
                color = lerp(color, color2, i.uv.x);
                #else
                // mask texture의 값을 lerp의 정도로 이용
                color = lerp(color, color2, mask.g);
                #endif

                return color;
            }
            ENDHLSL
        }
    }
}