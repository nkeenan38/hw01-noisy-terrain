import {vec2, vec3} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import Plane from './geometry/Plane';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

let prevLavaHeight: number = 10;
let prevScale: number = 5.0;
let prevSharpness: number = 0.2

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  'Load Scene': loadScene, // A function pointer, essentially
  lavaHeight : 0.5,
  scale : 5.0,
  sharpness : 0.2
};

let square: Square;
let plane : Plane;
let lava : Plane;
let steam_overlay : Square;
let ember_mid : Square;
let ember_back : Square;
let wPressed: boolean;
let aPressed: boolean;
let sPressed: boolean;
let dPressed: boolean;
let planePos: vec2;

function loadScene() {
  square = new Square(vec3.fromValues(0, 0, 0.9999));
  square.create();
  plane = new Plane(vec3.fromValues(0,0,0), vec2.fromValues(100,100), 20);
  plane.create();
  lava = new Plane(vec3.fromValues(0, controls.lavaHeight, 0), vec2.fromValues(100, 100), 2);
  lava.create();
  steam_overlay = new Square(vec3.fromValues(0, 0, 0.0));
  steam_overlay.create();
  ember_mid = new Square(vec3.fromValues(0, 0, 0.99));
  ember_mid.create();
  ember_back = new Square(vec3.fromValues(0, 0, 0.9998));
  ember_back.create();

  wPressed = false;
  aPressed = false;
  sPressed = false;
  dPressed = false;
  planePos = vec2.fromValues(0,0);
}

function main() {
  window.addEventListener('keypress', function (e) {
    // console.log(e.key);
    switch(e.key) {
      case 'w':
      wPressed = true;
      break;
      case 'a':
      aPressed = true;
      break;
      case 's':
      sPressed = true;
      break;
      case 'd':
      dPressed = true;
      break;
    }
  }, false);

  window.addEventListener('keyup', function (e) {
    switch(e.key) {
      case 'w':
      wPressed = false;
      break;
      case 'a':
      aPressed = false;
      break;
      case 's':
      sPressed = false;
      break;
      case 'd':
      dPressed = false;
      break;
    }
  }, false);

  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'lavaHeight', -5.0, 5.0);
  gui.add(controls, 'scale', 1, 10).step(1);
  gui.add(controls, 'sharpness', 0.01, 2.0);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 10, 50), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(164.0 / 255.0, 233.0 / 255.0, 1.0, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/terrain-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/terrain-frag.glsl')),
  ]);
  lambert.setTerrainScale(controls.scale);
  lambert.setTarrainSharpness(controls.sharpness);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  const transparent = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/transparent-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/transparent-frag.glsl'))
   ]);

  const steam = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/overlay-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/overlay-frag.glsl'))
  ]);

  const ember = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/embers-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/embers-frag.glsl'))
  ]);

  function processKeyPresses() {
    let velocity: vec2 = vec2.fromValues(0,0);
    if(wPressed) {
      velocity[1] += 1.0;
    }
    if(aPressed) {
      velocity[0] += 1.0;
    }
    if(sPressed) {
      velocity[1] -= 1.0;
    }
    if(dPressed) {
      velocity[0] -= 1.0;
    }
    let newPos: vec2 = vec2.fromValues(0,0);
    vec2.add(newPos, velocity, planePos);
    lambert.setPlanePos(newPos);
    transparent.setPlanePos(newPos);
    flat.setPlanePos(newPos);
    steam.setPlanePos(newPos);
    ember.setPlanePos(newPos);
    planePos = newPos;
  }

  // This function will be called every frame
  function tick() {
    if (prevLavaHeight !== controls.lavaHeight)
    {
      prevLavaHeight = controls.lavaHeight;
      lava = new Plane(vec3.fromValues(0, controls.lavaHeight, 0), vec2.fromValues(100, 100), 2);
      lava.create();
    }
    if (prevScale !== controls.scale)
    {
      prevScale = controls.scale;
      lambert.setTerrainScale(controls.scale);
    }
    if (prevSharpness !== controls.sharpness)
    {
      prevSharpness = controls.sharpness;
      lambert.setTarrainSharpness(controls.sharpness);
    }
    transparent.incrementTime();
    lambert.incrementTime();
    flat.incrementTime();
    steam.incrementTime();
    ember.incrementTime();

    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    processKeyPresses();
    renderer.render(camera, lambert, [
      plane,
    ]);
    renderer.render(camera, transparent, [
      lava
    ]);
    renderer.render(camera, flat, [
      square,
    ]);
    renderer.render(camera, ember, [
      ember_mid,
      ember_back
    ])
    renderer.render(camera, steam, [
      steam_overlay,
    ])
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
