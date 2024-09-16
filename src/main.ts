import * as THREE from "three";

// @ts-ignore
import { OrbitControls } from "three/addons/controls/OrbitControls";

import fragment from "./shaders/fragment.glsl";
import vertex from "./shaders/vertex.glsl";

const width = window.innerWidth;
const height = window.innerHeight;

export class Sketch {
  bgColor = 0x000000;
  width = window.innerWidth;
  height = window.innerHeight;

  controls: OrbitControls;

  scene = new THREE.Scene();
  renderer = new THREE.WebGLRenderer();
  camera = new THREE.PerspectiveCamera(
    /* The first attribute is the field of view.
       FOV is the extent of the scene that is seen on the display at any given moment.
       The value is in degrees.
    */
    75,
    /* The second one is the aspect ratio. You almost always want to use
       the width of the element divided by the height
    */
    width / height,
    /* The next two attributes are the near and far clipping plane.
       What that means, is that objects further away from the camera 
       than the value of far or closer than near won't be rendered
    */
    0.1,
    1000
  );

  plane: THREE.Mesh;
  // PlaneGeometry(width : Float, height : Float, widthSegments : Integer, heightSegments : Integer)
  geometry = new THREE.PlaneGeometry(1, 1, 1, 1);
  material = new THREE.ShaderMaterial({
    side: THREE.DoubleSide,
    uniforms: {
      uTime: { value: 0 },
      uResolution: { value: new THREE.Vector2(width, height) },
    },
    vertexShader: vertex,
    fragmentShader: fragment,
  });

  // Raycaster
  raycaster = new THREE.Raycaster();
  pointer = new THREE.Vector2();

  raycasterPlane = new THREE.Mesh(
    new THREE.PlaneGeometry(100, 100),
    new THREE.MeshBasicMaterial({
      color: 0xff0000,
      side: THREE.DoubleSide,
    })
  );

  pointerSphere = new THREE.Mesh(
    new THREE.SphereGeometry(0.05, 20, 20),
    new THREE.MeshBasicMaterial({
      color: 0xffffff,
    })
  );

  constructor() {
    this.renderer.setClearColor(this.bgColor, 1);
    this.renderer.setPixelRatio(Math.max(window.devicePixelRatio, 2));

    this.controls = new OrbitControls(this.camera, this.renderer.domElement);

    this.plane = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.plane);

    document.body.append(this.renderer.domElement);

    this.camera.position.set(0, 0, 2);

    this.resize();
    this.setupResize();
    this.addObjects();
    this.renderer.setAnimationLoop(this.render);
    this.mouseEvents();
  }

  render = () => {
    this.renderer.render(this.scene, this.camera);
  };

  resize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;

    this.material.uniforms.uResolution.value.set(width, height);

    this.camera.aspect = this.width / this.height;
    this.camera.updateProjectionMatrix();

    this.renderer.setSize(this.width, this.height);
  }

  setupResize() {
    window.addEventListener("resize", () => this.resize());
  }

  addObjects() {
    this.scene.add(this.pointerSphere);
  }

  mouseEvents() {
    window.addEventListener("pointermove", ({ clientX, clientY }) => {
      // calculate pointer position in normalized device coordinates
      // (-1 to +1) for both components
      this.pointer.x = (clientX / this.width) * 2 - 1;
      this.pointer.y = -(clientY / this.height) * 2 + 1;

      // update the picking ray with the camera and pointer position
      this.raycaster.setFromCamera(this.pointer, this.camera);

      const intersects = this.raycaster.intersectObjects([this.raycasterPlane]);
      if (intersects.length > 0) {
        this.pointerSphere.position.copy(intersects[0].point);
      }
    });
  }
}

const sketch = new Sketch();
