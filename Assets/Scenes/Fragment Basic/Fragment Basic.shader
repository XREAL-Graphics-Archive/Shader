Shader "Demo/FragmentBasic"
{
    // Shader에 쓰일 asset 또는 값들을 자율적으로 inspector에서 설정하게 할 수 있다
    Properties
    {
        // Texture asset을 설정하는 것 뿐만 아니라, scale offset설정도 제공
        _MainTex("Main Texture", 2D) = "white" {}
        _SecondTex("Second Texture", 2D) = "white" {}
        _ThirdTex("Third Texture", 2D) = "white" {}

        _Intensity("Range Sample", Range(0, 1)) = 0.5
        _TintColor("Tint Color", color) = (1, 1, 1, 1)

        // 자동으로 multi_compile에 쓸 수 있음
        [KeywordEnum(Coupled, Separated)] _Example("Example", Float) = 0
    }
    SubShader
    {
        // Tags는 SubShader 또는 Pass가 어느 환경/상황에서 실행될지 정의
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue"="Geometry"
        }

        Pass
        {
            // HLSL 코드임을 지정하는 block. SRP는 HLSL을 사용
            HLSLPROGRAM
            // Vertex shader로 쓰일 함수 이름을 정의
            #pragma vertex vert
            // Fragment shader로 쓰일 함수 이름을 정의
            #pragma fragment frag
            // KeywordEnum에서 알아서 이 중 1개만 켜지게 해줌
            #pragma multi_compile _EXAMPLE_COUPLED _EXAMPLE_SEPARATED

            // SRP의 Core.hlsl 파일은 HLSL에서 자주 쓰이는 것들의 정의를 포함
            // BIRP의 #include "UnityCG.cginc"와 비슷 (호환은 안됨)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // struct의 정의와 vertex input관련 semantics의 사용
            struct VertexInput
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            // fragment input 관련 semantics의 사용
            struct VertexOutput
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            #if _EXAMPLE_COUPLED
            // _MainTex의 coupled texture and sampler
            sampler2D _MainTex;

            #else
            // sampler2D가 Texture2D와 SamplerState로 분리
            Texture2D _MainTex;
            Texture2D _SecondTex;
            Texture2D _ThirdTex;
            SamplerState sampler_MainTex;
            #endif

            // ST: scale, transition(offset)
            // unity inspector에서 _MainTex에 설정된 scale offset 그대로 xy, zw에
            float4 _MainTex_ST;

            float _Intensity;
            float4 _TintColor;

            // Vertex shader 정의
            VertexOutput vert(VertexInput IN)
            {
                // Vertex ouput으로 쓰일 데이터 선언
                VertexOutput OUT;
                // TransformObjectToHClip함수는 vertex position들을
                // object space 에서 homogenous clip space으로 변환
                // UnityObjectToClipPos와 동일
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // uv 단순 전달
                OUT.uv = IN.uv;
                return OUT;
            }

            // Fragment shader의 정의, fragment output 관련 semantics의 사용          
            half4 frag(VertexOutput IN) : SV_Target
            {
                // tiling 반영
                float2 uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                #if _EXAMPLE_COUPLED
                // 주어진 uv에 대응되는 texture상 color값을 가져옴
                half4 color = tex2D(_MainTex, uv);

                #else
                // 주어진 uv에 대응되는 texture상 color값을 가져옴
                half4 color = _MainTex.Sample(sampler_MainTex, uv);
                color += _SecondTex.Sample(sampler_MainTex, uv);
                color += _ThirdTex.Sample(sampler_MainTex, uv);
                #endif
                return color * _TintColor * _Intensity;
            }

            // HLSL 코드의 끝
            ENDHLSL
        }
    }
}