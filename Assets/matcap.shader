Shader "Custom/matcap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Matcap ("Matcap", 2D) = "white" {} // matcap �ؽ��ĸ� �޴� �������̽� �߰�
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        
        // ȯ�汤 ���� �� DirectionalLight �� Scene ���� ���������ν�, ����Ʈ�� ������ ���� �ȹ޵��� ������.
        // Lambert ������ ���� -> nolight Ŀ���Ҷ���Ʈ �Լ��� ����
        #pragma surface surf nolight noambient

        sampler2D _MainTex;
        sampler2D _Matcap; // matcap �ؽ��ĸ� ���� ���÷� ���� ����

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal; // ���ؽ� Input ����ü�� ���ؽ��� ������� ��ֺ��͸� ������ �� �ֵ��� worldNormal ����
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            // o.Albedo = c.rgb; // Albedo ������ Matcap ���� ������� �����Ƿ� ����! -> ���� ����Ʈ ���� ����� o.Emission �� ���� ���ۿ� ����.
            o.Emission = IN.worldNormal; // worldNormal �� �������� ����� ��
            o.Alpha = c.a;
        }

        // ������ ������ ���� ���� �ʴ� Ŀ���Ҷ���Ʈ �Լ� ����
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
