#include "common_vs_fxc.h"

struct VS_INPUT {
	float4 vPos		 : POSITION;
	float4 vTexCoord : TEXCOORD0;
	float3 vNormal   : NORMAL0;
};

struct VS_OUTPUT {
	float4 proj_pos      : POSITION;
	float2 uv            : TEXCOORD0;	
	float3 pos           : TEXCOORD1;
	float3 normal        : TEXCOORD2;
};

VS_OUTPUT main(VS_INPUT vert) {
	float3 startPos = cAmbientCubeX[0];
	float3 startTangent = cAmbientCubeX[1];
	float3 endTangent = cAmbientCubeY[0];
	float3 endPos = cAmbientCubeY[1];
	float3 offset = cAmbientCubeZ[0];
	float scale = cAmbientCubeZ[1].x;
	
	float3 derivative0 = 3 * (startTangent - startPos);
	float3 derivative1 = 3 * (endTangent - startTangent);
	float3 derivative2 = 3 * (endPos - endTangent);

	// We're also going to send the vertex normal to our shader for some basic lighitng
	// so we need to skin it too
	float3 world_normal;
	float3 world_pos;

	world_pos += offset;
	float t = world_pos.y * scale;
	float3 bezier = Bezier3(t, startPos, startTangent, endTangent, endPos);
	float3 derivative = Bezier2(t, derivative0, derivative1, derivative2);

	float3 pos = {derivative.y, -derivative.x, world_pos.z};

	world_pos = bezier + pos

	SkinPositionAndNormal(0, vert.vPos, vert.vNormal, 0, 0, world_pos, world_normal);

	float4 proj_pos = mul(float4(world_pos, 1), cViewProj);

	VS_OUTPUT output = (VS_OUTPUT)0;
	output.proj_pos = proj_pos;
	output.uv = vert.vTexCoord.xy;
	output.pos = world_pos;
	output.normal = world_normal;

	return output;
};

float3 Bezier2(float t, float3 p0, float3 p1, float3 p2) {
	float u = 1 - t;
	return u * u * p0 + 2 * u * t * p1 + t * t * p2;
}

float3 Bezier3(float t, float3 p0, float3 p1, float3 p2, float3 p3) {
	float u = 1 - t;
	return u * u * u * p0 + 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t * p3;
}
