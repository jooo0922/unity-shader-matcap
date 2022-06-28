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

            // 월드공간 노말벡터를 뷰공간 노말벡터로 변환하기 위해 유니티 내장 view 행렬과 곱해줌
            // cf. UNITY_MATRIX_V 는 유니티 내장 뷰행렬, mul() 은 유니티 내장 행렬곱셈 함수
            float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, IN.worldNormal.rgb);

            // 뷰공간 노말벡터를 색상으로 출력해 봄.
            // -> 뷰 공간 노말벡터는 말 그대로 카메라를 기준으로 계산되는 노말벡터이므로, 카메라를 움직일 때마다 노말벡터 색상이 달라짐
            // o.Emission = viewNormal;  

            // 이제 Matcap 텍스쳐를 샘플링할 uv 로 이 뷰 공간 노말벡터의 x, y 컴포넌트를 사용해줄 것임!
            // 그런데, 모든 노말벡터는 180도를 표현해야 하기 때문에, 컴포넌트들이 -1 ~ 1 사이의 값으로 되어있음.
            // 0 ~ 1 사이의 값은 0 ~ 90도까지의 각도 범위밖에 표현못함. (내적의 결과값을 생각해보자. 기본적으로 -1 ~ 1 사이의 결과값이 나오고, 90도의 내적값은 0이잖아?)
            // 그러나, uv에는 0 ~ -1 사이의 범위가 없지? uv는 0 ~ 1 사이의 좌표계잖아!
            // 그래서 -1 ~ 1 사이의 뷰 공간 노말벡터에 '* 0.5 + 0.5' 해줘서 0 ~ 1 사이의 값으로 매핑해준 것임!
            float2 MatcapUV = viewNormal.xy * 0.5 + 0.5;

            // 이제 뷰 공간 노말벡터로부터 샘플링할 uv 좌표를 얻어서 Matcap 텍스쳐를 샘플링하기 때문에,
            // 카메라가 움직일 때마다 샘플링하는 uv좌표가 바뀔 것이고, 샘플링한 텍셀값도 달라지겠지?
            // 결과적으로 Matcap 텍스쳐가 마치 카메라를 움직임에 따라 빛이 연산되는 듯한 라이팅처럼 움직이게 될 것임.
            o.Emission = tex2D(_Matcap, MatcapUV) * c.rgb; // 이제 여기에 Albedo 텍스쳐의 텍셀값인 c.rgb 만 곱해주면 Matcap 의 텍셀값은 라이팅 연산처럼 사용하면서 물체의 원 색상(c.rgb)도 보여줄 수 있게 됨.
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
