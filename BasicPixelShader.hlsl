#include "BasicShaderHeader.hlsli"

float4 BasicPS(Output input) : SV_TARGET
{
	// 光の進むベクトル
	float3 light = normalize(float3(1, -1, 1));
	// ライトのカラー
	float3 lightColor = float3(0, 0, 1);
	// ディフーズ計算
	float diffuseB = saturate(dot(-light, input.normal));
	float4 toonDif = toon.Sample(smpToon, float2(0, 1.0 - diffuseB));
	// 光の反射ベクトル
	float3 refLight = normalize(reflect(light, input.normal.xyz));
	float3 specularB = pow(saturate(dot(refLight, -input.ray)), specular.a);
	// スフィアマップ用uv
	float2 sphereMapUV = input.vnormal.xy;
	sphereMapUV = (sphereMapUV + float2(1, -1)) * float2(0.5, -0.5);
	// テクスチャカラー
	float4 texColor = tex.Sample(smp, input.uv);

	return max(saturate(toonDif
			* diffuse
			* texColor
			* sph.Sample(smp, sphereMapUV))
			+ saturate(spa.Sample(smp, sphereMapUV) * texColor
			+ float4(specularB * specular.rgb, 1))
			, float4(texColor * ambient, 1));

}