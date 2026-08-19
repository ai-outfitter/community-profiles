---
name: replicad
description: >-
  Code-CAD with replicad v0.19 on the OpenCASCADE B-rep kernel compiled to
  WASM (replicad-opencascadejs): model parts as functions, compose
  subassemblies and assemblies, export STL/STEP, and view the result in a
  minimal HTML page next to the reference image.
---

# Replicad

Model CAD as code in Node. Parts are functions; assemblies compose them.
The scaffold is meant to be discarded or promoted into project tooling.

## Setup

```sh
npm init -y && npm install replicad@^0.19.0 replicad-opencascadejs@^0.19.0
```

## Minimal build script

```js
// build.mjs — run with: node build.mjs
import { createRequire } from "node:module";
import { writeFileSync } from "node:fs";
import { setOC, drawRoundedRectangle } from "replicad";

const require = createRequire(import.meta.url);
const initOC = require("replicad-opencascadejs/src/replicad_single.js");
const wasm = require.resolve("replicad-opencascadejs/src/replicad_single.wasm");
setOC(await initOC({ locateFile: () => wasm }));

// A part is a function that returns a shape.
const plate = () => drawRoundedRectangle(60, 40, 5).sketchOnPlane().extrude(4);

// A subassembly composes placed parts; an assembly composes subassemblies.
const assembly = () => [plate(), plate().translate([0, 0, 20])];

let i = 0;
for (const shape of assembly()) {
  writeFileSync(`part-${i}.stl`, Buffer.from(await shape.blobSTL().arrayBuffer()));
  writeFileSync(`part-${i}.step`, Buffer.from(await shape.blobSTEP().arrayBuffer()));
  i += 1;
}
```

Keep the part → subassembly → assembly layering in functions from the
start: the marketing reference describes the whole; the model tree builds it
from placeable units.

## Minimal viewer

One HTML page shows the exported mesh next to the reference image. Serve the
directory (`python3 -m http.server`) — modules and STL fetches fail from
`file://`.

```html
<!-- view.html: reference image left, STL right -->
<div style="display:flex"><img src="reference.png" style="width:50%">
<canvas id="c" style="width:50%"></canvas></div>
<script type="module">
import * as THREE from "https://esm.sh/three@0.160.0";
import { STLLoader } from "https://esm.sh/three@0.160.0/examples/jsm/loaders/STLLoader.js";
import { OrbitControls } from "https://esm.sh/three@0.160.0/examples/jsm/controls/OrbitControls.js";
const canvas = document.getElementById("c");
const renderer = new THREE.WebGLRenderer({ canvas });
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(50, 1, 0.1, 1000);
camera.position.set(80, 80, 80);
new OrbitControls(camera, canvas);
scene.add(new THREE.AmbientLight(0xffffff, 0.6));
const sun = new THREE.DirectionalLight(0xffffff, 1); sun.position.set(1, 2, 3);
scene.add(sun);
new STLLoader().load("part-0.stl", (g) =>
  scene.add(new THREE.Mesh(g, new THREE.MeshStandardMaterial())));
renderer.setAnimationLoop(() => renderer.render(scene, camera));
</script>
```

## Notes

- The kernel is real B-rep (OpenCASCADE), not a mesh library: booleans,
  fillets, and STEP export are exact. Export STL only for viewing and
  printing.
- Code blocks here are sketches to adapt, not pinned tooling.
