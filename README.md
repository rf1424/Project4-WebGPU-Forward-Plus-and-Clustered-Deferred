WebGL Forward+ and Clustered Deferred Shading
======================

**University of Pennsylvania, CIS 565: GPU Programming and Architecture, Project 4**

* (TODO) YOUR NAME HERE
* Tested on: (TODO) **Google Chrome 222.2** on
  Windows 22, i7-2222 @ 2.22GHz 22GB, GTX 222 222MB (Moore 2222 Lab)

### Live Demo

[![](img/thumb.png)](http://TODO.github.io/Project4-WebGPU-Forward-Plus-and-Clustered-Deferred)

### Demo Video/GIF

[![](img/video.mp4)](TODO)
In this project, I implemented three different rendering methods to render a scene with many lights using TypeScript and WebGPU. Below are my implementations, each building on the previous one:

**Naive Forward:** Everything is rendered in one pass. We must compute lighting for every fragment in the scene (including ones later hidden by closer geometry), and every time lighting is calculated, we must iterate through all lights in the scene.

**Forward+/Clustered Forward:** We divide the viewing frustum into a 3D grid of clusters along x, y, and z. In the compute pass, we calculate the lights each cluster contains, and in the shading pass, each fragment only considers lights in the cluster it falls in.

**Clustered Deferred:** In addition to the clustering, we implement a G-buffer. We first calculate a G-buffer pass to store the position, color, and normal of each pixel into textures. In the final shading pass, we read from these textures and shade using the clusters. Thus, we only need to compute expensive lighting on visible pixels rather than all geometry, and only consider lights in each pixel's cluster.
 
### Performance Analysis
All tests were run on the Sponza scene at a 2560 × 1350 canvas resolution. Each value is the average frame time (ms) over 30 frames. Workgroup size was 128 the light movement/clustering compute pass. 

#### Number of Lights 
used a 16 × 9 × 24 cluster grid with max lights per cluster of 512.

Naive rendering scales linearly with light count. This is expected, given every fragment loops over all N lights, so the per-frame cost is O(pixels × lights). 

Forward+ and Clustered Deferred are much faster at every light count. At 5000 lights, Forward+ is about 14× faster than Naive, because each fragment only loops over the lights in its own cluster instead of the full light set. Forward+ stays consistently fast up to ~1000 lights, then slows down from 2000 lights. This is likely because more lights overlap each cluster, so the per-cluster lists grow. Each fragment's loop gets longer, and the clustering compute pass and cluster buffer reads cost more. Forward+ also shades fragments before the depth test resolves visibility, so overdrawn fragments run the light loop and then get discarded by later geometry.

Clustered Deferred removes that overdraw cost. The geometry pass only writes albedo, normal and position to the G-buffer, and lighting runs once per pixel in a fullscreen pass, using only the lights in that pixel's cluster. It stays consistently fast from 500 to 5000 lights. The trade-off is the extra G-buffer memory and bandwidth but the overall performance is successful. 





### Credits

- [Vite](https://vitejs.dev/)
- [loaders.gl](https://loaders.gl/)
- [dat.GUI](https://github.com/dataarts/dat.gui)
- [stats.js](https://github.com/mrdoob/stats.js)
- [wgpu-matrix](https://github.com/greggman/wgpu-matrix)
