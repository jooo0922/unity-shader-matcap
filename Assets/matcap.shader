Shader "Custom/matcap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Matcap ("Matcap", 2D) = "white" {} // matcap 텍스쳐를 받는 인터페이스 추가
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        
        // 환경광 제거 및 DirectionalLight 도 Scene 에서 제거함으로써, 라이트의 영향을 전혀 안받도록 설정함.
        // Lambert 라이팅 연산 -> nolight 커스텀라이트 함수로 변경
        #pragma surface surf nolight noambient

        sampler2D _MainTex;
        sampler2D _Matcap; // matcap 텍스쳐를 담을 샘플러 변수 선언

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal; // 버텍스 Input 구조체에 버텍스의 월드공간 노멀벡터를 가져올 수 있도록 worldNormal 선언
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            // o.Albedo = c.rgb; // Albedo 연산은 Matcap 에서 사용하지 않으므로 제거! -> 이제 라이트 연산 결과는 o.Emission 에 넣을 수밖에 없음.
            o.Emission = IN.worldNormal; // worldNormal 을 색상으로 출력해 봄
            o.Alpha = c.a;
        }

        // 라이팅 연산을 전혀 하지 않는 커스텀라이트 함수 선언
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
