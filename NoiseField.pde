import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

PeasyCam cam;
Minim minim;
FFT listen;
AudioInput in;

float level;
float spLevel;
float easing = 0.01;
float spEasing = 0.05;
float flying = 0;
float volume;

void setup() {
  size(displayWidth, displayHeight, P3D);
  smooth();
  cam = new PeasyCam(this, 540, 540, 540, 50);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048, 192000.0);
  listen = new FFT(in.bufferSize(), in.sampleRate());
}

void draw() {
  stage();
  drawField((spLevel * 0.0004), ((level * 5) + 24));
}

void stage() {
  background(0);
  stroke(255);
  noFill();
  listen.forward(in.mix);
  volume = map(listen.getBand(1), 0.0, 10, 0, 255); 
  level += (volume - level) * easing;
  spLevel += (volume - spLevel) * spEasing;
}

void drawField(float speed, float peaks) {
  int cols, rows, stacks;
  int scale = 40;
  int w = 1080;
  int h = 1080;
  int d = 1080;
  float deformity = 0.1;
  float[][][] terrain;
  float yoff = flying;
  
  cols = w / scale;
  rows = h / scale;
  stacks = d / scale;
  flying -= speed;
  terrain = new float[cols][rows][stacks];
  pushMatrix();
  translate(513,513,513);
  box(1280);
  popMatrix();
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      float zoff = 0;
      for (int z = 0; z < stacks; z++) {
        terrain[x][y][z] = map(noise(xoff, yoff, zoff), 0, 1, -peaks, peaks);
        zoff += deformity;
      }
      xoff += deformity;
    }
    yoff += deformity;
  }
  
  for (int y = 0; y < rows - 1; y++) {
    beginShape();
    for (int x = 0; x < cols; x++) {
      for (int z = 0; z < stacks; z++) {
         point(x*scale + terrain[x][y][z], y* scale + terrain[x][y][z], z*scale + terrain[x][y][z]);
      }
    }
    endShape();
  }
}
