Shader "Custom/VelaEfectoURP"
{
    Properties
    {
        [Header(Colores)]
        _ColorMin ("Rojo (Inicio)", Color) = (1, 0, 0, 1)
        _ColorMax ("Amarillo (Fin)", Color) = (1, 1, 0, 1)
        
        [Header(Animacion)]
        _Velocidad ("Velocidad de Parpadeo", Range(0.1, 10)) = 2.0
        _Intensidad ("Intensidad Emision", Range(0, 10)) = 2.0
        
        [Header(Opciones)]
        [Toggle(_AFECTAR_ENTORNO_ON)] _AfectarEntorno ("¿Afectar Entorno?", Float) = 1.0
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _AFECTAR_ENTORNO_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorMin;
                float4 _ColorMax;
                float _Velocidad;
                float _Intensidad;
            CBUFFER_END

            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            float4 frag (Varyings input) : SV_Target
            {
                float tiempo = _Time.y * _Velocidad;
                
                float oscilacion = (sin(tiempo) * 0.5 + 0.5) * (sin(tiempo * 2.1) * 0.2 + 0.8);
                oscilacion = clamp(oscilacion, 0.0, 1.0);
                
                float3 colorBase = lerp(_ColorMin.rgb, _ColorMax.rgb, oscilacion);
                
                float3 colorFinal = colorBase;
                
                #ifdef _AFECTAR_ENTORNO_ON
                    colorFinal *= (oscilacion * _Intensidad);
                #else
                    colorFinal *= 0.5; 
                #endif

                return float4(colorFinal, 1.0);
            }
            ENDHLSL
        }
    }
}