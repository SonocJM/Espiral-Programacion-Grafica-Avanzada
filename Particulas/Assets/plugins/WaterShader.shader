Shader "Custom/WaterShader"
{
    Properties
    {
        _MainTex ("Water Texture", 2D) = "white" {}
        _Speed ("Wave Speed", Float) = 0.1
        _Amplitude ("Wave Strength", Float) = 0.02
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;

            float _Speed;
            float _Amplitude;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes v)
            {
                Varyings o;

                float wave =
                    sin(_Time.y * 2.0 + v.positionOS.x * 2.0) * _Amplitude;
                float3 pos = v.positionOS.xyz;

                pos.y += wave;

                o.positionHCS =
                    TransformObjectToHClip(float4(pos, 1.0));

                o.uv = v.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                float2 uv = i.uv;

                uv.x += _Time.y * _Speed;

                float4 col = tex2D(_MainTex, uv);

                return col;
            }

            ENDHLSL
        }
    }
}