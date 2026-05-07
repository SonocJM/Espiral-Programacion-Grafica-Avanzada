Shader "Custom/Rainbow"
{
    Properties
    {
        _BaseMap ("Textura Base (Grises)", 2D) = "white" {}
        _Speed ("Velocidad Movimiento", Float) = 2.0
        _Frequency ("Frecuencia Arcoíris", Float) = 5.0
        _Emission ("Brillo (HDR)", Float) = 2.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Librerías necesarias para Unity 6 / URP
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float _Speed;
                float _Frequency;
                float _Emission;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            // Función de arcoíris compatible con URP
            float3 HueToRGB(float h)
            {
                h = frac(h);
                float r = abs(h * 6.0 - 3.0) - 1.0;
                float g = 2.0 - abs(h * 6.0 - 2.0);
                float b = 2.0 - abs(h * 6.0 - 4.0);
                return saturate(float3(r, g, b));
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // 1. Animación de UVs
                float2 scrollingUV = IN.uv;
                scrollingUV.y -= _Time.y * _Speed;

                // 2. Muestreo de textura
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, scrollingUV);

                // 3. Color Arcoíris
                // Usamos IN.uv.y para que el degradado sea estático en el objeto 
                // pero cambie con el tiempo
                float hue = IN.uv.y * _Frequency + _Time.y;
                float3 rainbow = HueToRGB(hue);

                // 4. Mezcla final con intensidad de brillo
                half3 finalRGB = texColor.rgb * rainbow * _Emission;

                return half4(finalRGB, texColor.a);
            }
            ENDHLSL
        }
    }
}