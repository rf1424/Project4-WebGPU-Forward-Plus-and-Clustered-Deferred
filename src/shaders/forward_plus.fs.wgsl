@group(${bindGroup_scene}) @binding(1) var<storage, read> lightSet: LightSet;
@group(${bindGroup_scene}) @binding(0) var<uniform> cameraUniforms: CameraUniforms;
@group(${bindGroup_scene}) @binding(2) var<storage, read> clusterSet: ClusterSet;

@group(${bindGroup_material}) @binding(0) var diffuseTex: texture_2d<f32>;
@group(${bindGroup_material}) @binding(1) var diffuseTexSampler: sampler;

struct FragmentInput
{
    @builtin(position) fragCoord: vec4f, 
    @location(0) pos: vec3f,
    @location(1) nor: vec3f,
    @location(2) uv: vec2f
}
// ------------------------------------
// Shading process:
// ------------------------------------
// Determine which cluster contains the current fragment.
// Retrieve the number of lights that affect the current fragment from the cluster’s data.
// Initialize a variable to accumulate the total light contribution for the fragment.
// For each light in the cluster:
//     Access the light's properties using its index.
//     Calculate the contribution of the light based on its position, the fragment’s position, and the surface normal.
//     Add the calculated contribution to the total light accumulation.
// Multiply the fragment’s diffuse color by the accumulated light contribution.
// Return the final color, ensuring that the alpha component is set appropriately (typically to 1).

fn getClusterFromPt(uv: vec2f, pos: vec3f) -> u32 {
    let grid = vec3f(${clusterX}, ${clusterY}, ${clusterZ});
    let cx = u32(uv.x * grid.x);
    let cy = u32((1.0 - uv.y) * grid.y);

    let viewZ = -(cameraUniforms.view * vec4f(pos, 1.0)).z;
    let cz = u32((viewZ - cameraUniforms.near) / (cameraUniforms.far - cameraUniforms.near) * grid.z);

    let clusterIdx = min(cx, ${clusterX} - 1)
               + min(cy, ${clusterY} - 1) * ${clusterX}
               + min(cz, ${clusterZ} - 1) * ${clusterX} * ${clusterY};
    return clusterIdx;
}

@fragment 
fn main(in: FragmentInput) -> @location(0) vec4f {

    let diffuseColor = textureSample(diffuseTex, diffuseTexSampler, in.uv);
    if (diffuseColor.a < 0.5f) {
        discard;
    }

    // get the cluster 
    let clusterIdx = getClusterFromPt(in.fragCoord.xy / cameraUniforms.screenSize, in.pos);

    var totalLightContrib = vec3f(0, 0, 0);
    let numLights = clusterSet.clusters[clusterIdx].numLights;
    for (var i = 0u; i < numLights; i++) {
        let lightIdx = clusterSet.clusters[clusterIdx].lightIndices[i];
        let light = lightSet.lights[lightIdx];
        totalLightContrib += calculateLightContrib(light, in.pos, normalize(in.nor));
    }

    var finalColor = diffuseColor.rgb * totalLightContrib;
    // return vec4f(f32(numLights) / 40.0);
    return vec4(finalColor, 1);
}