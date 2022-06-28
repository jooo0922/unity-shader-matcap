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

            // ������� �븻���͸� ����� �븻���ͷ� ��ȯ�ϱ� ���� ����Ƽ ���� view ��İ� ������
            // cf. UNITY_MATRIX_V �� ����Ƽ ���� �����, mul() �� ����Ƽ ���� ��İ��� �Լ�
            float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, IN.worldNormal.rgb);

            // ����� �븻���͸� �������� ����� ��.
            // -> �� ���� �븻���ʹ� �� �״�� ī�޶� �������� ���Ǵ� �븻�����̹Ƿ�, ī�޶� ������ ������ �븻���� ������ �޶���
            // o.Emission = viewNormal;  

            // ���� Matcap �ؽ��ĸ� ���ø��� uv �� �� �� ���� �븻������ x, y ������Ʈ�� ������� ����!
            // �׷���, ��� �븻���ʹ� 180���� ǥ���ؾ� �ϱ� ������, ������Ʈ���� -1 ~ 1 ������ ������ �Ǿ�����.
            // 0 ~ 1 ������ ���� 0 ~ 90�������� ���� �����ۿ� ǥ������. (������ ������� �����غ���. �⺻������ -1 ~ 1 ������ ������� ������, 90���� �������� 0���ݾ�?)
            // �׷���, uv���� 0 ~ -1 ������ ������ ����? uv�� 0 ~ 1 ������ ��ǥ���ݾ�!
            // �׷��� -1 ~ 1 ������ �� ���� �븻���Ϳ� '* 0.5 + 0.5' ���༭ 0 ~ 1 ������ ������ �������� ����!
            float2 MatcapUV = viewNormal.xy * 0.5 + 0.5;

            // ���� �� ���� �븻���ͷκ��� ���ø��� uv ��ǥ�� �� Matcap �ؽ��ĸ� ���ø��ϱ� ������,
            // ī�޶� ������ ������ ���ø��ϴ� uv��ǥ�� �ٲ� ���̰�, ���ø��� �ؼ����� �޶�������?
            // ��������� Matcap �ؽ��İ� ��ġ ī�޶� �����ӿ� ���� ���� ����Ǵ� ���� ������ó�� �����̰� �� ����.
            o.Emission = tex2D(_Matcap, MatcapUV) * c.rgb; // ���� ���⿡ Albedo �ؽ����� �ؼ����� c.rgb �� �����ָ� Matcap �� �ؼ����� ������ ����ó�� ����ϸ鼭 ��ü�� �� ����(c.rgb)�� ������ �� �ְ� ��.
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
