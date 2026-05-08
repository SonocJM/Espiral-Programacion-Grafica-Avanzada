Shader "Custom/WaterfallShader"
{
    Properties
    {
        _MainTex ("Water Texture", 2D) = "white" {}
        _Speed ("Flow Speed", Float) = 1.0
        _Tint ("Water Tint", Color) = (0.4,0.7,1,1)
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;

            float _Speed;
            float4 _Tint;

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

                float3 pos = v.positionOS.xyz;

                // pequeña deformación procedural
                pos.x += sin(_Time.y * 3 + pos.y * 4) * 0.05;

                o.positionHCS =
                    TransformObjectToHClip(float4(pos,1));

                o.uv = v.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                float2 uv = i.uv;

                // movimiento vertical
                uv.y -= _Time.y * _Speed;

                float4 tex = tex2D(_MainTex, uv);

                // tinte azul
                tex *= _Tint;

                return tex;
            }

            ENDHLSL
        }
    }
}
