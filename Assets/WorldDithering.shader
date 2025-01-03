Shader "Hidden/WorldDithering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color1", Color) = (1,1,1,1)
        _Color2 ("Color2", Color) = (1,1,1,1)
        _Color3 ("Color3", Color) = (1,1,1,1)
        _Color4 ("Color4", Color) = (1,1,1,1)
        _Color5 ("Color5", Color) = (1,1,1,1)
        _Color6 ("Color6", Color) = (1,1,1,1)
        _Color7 ("Color7", Color) = (1,1,1,1)
        _Color8 ("Color8", Color) = (1,1,1,1)

        _DitheringThreshold ("DitheringThreshold", Float) = 0.5
        _RandomFactor ("RandomFactor", Float) = 5000
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float4 _Color4;
            float4 _Color5;
            float4 _Color6;
            float4 _Color7;
            float4 _Color8;

            float _DitheringThreshold;
            float _RandomFactor;

            float4x4 _I_VP;

            fixed4 quantize(float4 col){
                float distances[8] = {
                    distance(col, _Color1),
                    distance(col, _Color2),
                    distance(col, _Color3),
                    distance(col, _Color4),
                    distance(col, _Color5),
                    distance(col, _Color6),
                    distance(col, _Color7),
                    distance(col, _Color8),
                };

                float4 colors[8] = {
                    _Color1,
                    _Color2,
                    _Color3,
                    _Color4,
                    _Color5,
                    _Color6,
                    _Color7,
                    _Color8
                };

                fixed4 resultCol = colors[0];
                float minDistance = distances[0];

                for(int i = 1; i < 8; i++){
                    resultCol = minDistance > distances[i] ? colors[i] : resultCol;
                    minDistance = minDistance > distances[i] ? distances[i] : minDistance;
                }

                return resultCol;
            }

            float rand(float f){
                return (frac(sin(f) * _RandomFactor) - 0.5) * 2;
            }

            float cut(float f, int precision){
                return (f * precision - frac(f)) / precision;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float4 pPos = float4(i.uv * 2.0 - 1.0, rawDepth, 1.0);
                
                #if UNITY_UV_STARTS_AT_TOP
                pPos.y = -pPos.y;
                #endif

                float4 tmp = mul(_I_VP, pPos);
                float3 wpos = tmp.xyz / tmp.w;

                float4 quantizedCol = quantize(col);
                int precision = 10;
                float random = rand(rand(cut(wpos.x, precision)) + rand(cut(wpos.y, precision)) + rand(cut(wpos.z, precision)));
                if(random < _DitheringThreshold){
                    return quantizedCol;
                }

                return quantize(quantizedCol) + random / 2;
            }
            ENDCG
        }
    }
}
