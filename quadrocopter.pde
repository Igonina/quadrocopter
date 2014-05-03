
/*class Quadrocopter {
  Quadrocopter() {
    
  }
  Blade[] fans = Blade[4];
  void update() {
  }
  void draw() {
  }
}*/
PShape world;
void createWorld() {
  world = createShape();
  world.beginShape(POLYGON);
  world.stroke(255, 0, 255);
  world.fill(0,0,255);  
  world.beginContour();
  world.vertex(-100, width/3*2, -100);
  world.vertex(1000, width/3*2, -100);
  world.vertex(1000, width/3*2, 1000);
  world.vertex(-100, width/3*2, 1000);
  world.endContour();
  world.endShape(CLOSE);
}
void drawWorld() {
  shape(world);
}

PVector getTrianglePressureForce(PVector r1, PVector r2, PVector r3, PVector V1, PVector V2, PVector V3) {
  PVector a = PVector.sub(r1, r2);
  PVector b = PVector.sub(r1, r3);
  PVector NORM = a.cross(b);
  NORM.normalize();
  
 //   if(random(100) < 1) { println(r1); println(r2); println(r3); println((a.magSq()*b.magSq())); }
 if(a.magSq()*b.magSq() == 0) return new PVector(0,0,0);
 else return PVector.mult(
                                         (PVector.add(
                                                       NORM,
                                                       PVector.div(
                                                                   PVector.add(
                                                                               PVector.add(V1,V2),
                                                                               V3),
                                                                   3))),
                                          PVector.dot(a,b)*0.5 * sqrt(1 - PVector.dot(a,b)*PVector.dot(a,b)/(a.magSq()*b.magSq())));
}

ArrayList<Blade> blades = new ArrayList<Blade>();
  
void updateAllBlades() {
    for(Blade blade : blades) {
      blade.update();
    }
    for(Blade blade : blades) {
      blade.draw();
    }
}


class Blade {
  Blade() {
    generate();
    makeShape();
    
    blades.add(this);
  }
  Blade(Blade father, Blade mother) {
    generate(father, mother);
    makeShape();
    
    blades.add(this);
  }
  void makeShape() {
    bladeShape = createShape(GROUP);

    for(int node = 0; node < 4; ++node) {
      
      for(int N = 0; N < 32; ++N) {
        PShape face = createShape();
        face.beginShape(POLYGON);
        face.stroke(0, 255, 0);
        face.fill(surfaceColor);  
        face.beginContour();
        face.vertex(length[node+1][N][0], length[node+1][N][1], distance[node+1]);
        face.vertex(length[node][N][0], length[node][N][1], distance[node]);
        face.vertex(length[node][(N+1)%32][0], length[node][(N+1)%32][1], distance[node]);
        face.vertex(length[node+1][(N+1)%32][0], length[node+1][(N+1)%32][1], distance[node+1]);
        //face.vertex(60*sin(i)/(node+2), 10*cos(i)/(node+2), 30+60*node);
        //face.vertex(60*sin(i)/(node+1), 10*cos(i)/(node+1), -30+60*node);
        //face.vertex(60*sin(i+(2*3.1415)/32)/(node+1), 10*cos(i+(2*3.1415)/32)/(node+1), -30+60*node);
        //face.vertex(60*sin(i+(2*3.1415)/32)/(node+2), 10*cos(i+(2*3.1415)/32)/(node+2), 30+60*node);
        face.endContour();
        face.endShape(CLOSE);
        bladeShape.addChild(face);
      }
    }
  }
  float[] distance = new float[5];
  void generate() {
    surfaceColor = color(random(255),random(255),random(255));
    
    distance[0] = 0;
    for(int node = 1; node < 5; ++node) {
      distance[node] = distance[node-1] + 60+random(10)-random(10);
    }
    for(int node = 0; node < 4; ++node) {
      distance[node] = (node == 0 ? 0 : distance[node-1] + 60+random(10)-random(10));
      float radiusX = random(100)+random(20);
      float radiusY = random(100)+random(20);
      for(int i = 0; i < 32; ++i) {
        length[node][i][0] = 0.2*(radiusX*sin(i)*(random(2)+0.5)+random(20)-10);
        length[node][i][1] = 0.2*(radiusY*cos(i)*(random(2)+0.5)+random(20)-10);
      }
    }
    for(int i = 0; i < 32; ++i) {
      length[4][i][0] = 0;
      length[4][i][1] = 0;
    }
  }
  void generate(Blade father, Blade mother) {
    //throw new Exception("Not implemented yet!");
    surfaceColor = father.surfaceColor/2 + mother.surfaceColor/2 + color(random(2),random(2),random(2)) - color(random(2),random(2),random(2));//new color((father.surfaceColor + mother.surfaceColor)/2, (father.surfaceColor + mother.surfaceColor)/2, (father.surfaceColor + mother.surfaceColor)/2);
    
    
    distance[0] = 0;
    for(int node = 1; node < 5; ++node) {
      distance[node] = (father.distance[node]+mother.distance[node])/2*(0.9+random(0.2));
    }
    for(int node = 0; node < 4; ++node) {
      for(int i = 0; i < 32; ++i) {
        length[node][i][0] = (father.length[node][i][0]+mother.length[node][i][0])*(0.9+random(0.2))*0.5 + random(10)-5;
        length[node][i][1] = (father.length[node][i][1]+mother.length[node][i][1])*(0.9+random(0.2))*0.5 + random(10)-5;
      }
    }
    for(int i = 0; i < 32; ++i) {
      length[4][i][0] = 0;
      length[4][i][1] = 0;
    }
    
    //taga = (father.taga + mother.taga)/2*(0.9+random(0.2))+random(0.2)-random(0.2);
  }
  
  float[][][] length = new float[5][32][2];
  PShape bladeShape;
  color surfaceColor;
  void update() {
    PVector F = new PVector(0,0,0);
    PVector V1 = new PVector(0,0,0), V2 = new PVector(0,0,0), V3 = new PVector(0,0,0), V4 = new PVector(0,0,0);
    PVector r1, r2, r3, r4;
    for(int node = 0; node < 4; ++node) {      
      for(int N = 0; N < 32; ++N) {
          r1 = new PVector(length[node+1][N][0], length[node+1][N][1], distance[node+1]); 
          r2 = new PVector(length[node][N][0], length[node][N][1], distance[node]);       
          r3 = new PVector(length[node][(N+1)%32][0], length[node][(N+1)%32][1], distance[node]);
          r4 = new PVector(length[node+1][(N+1)%32][0], length[node+1][(N+1)%32][1], distance[node+1]);
          
          float rotVel = rotAngle()/frameCount;
          float range1 = new PVector(r1.x, r1.y, 0).mag();
          float range2 = new PVector(r2.x, r2.y, 0).mag();
          float range3 = new PVector(r3.x, r3.y, 0).mag();
          float range4 = new PVector(r4.x, r4.y, 0).mag();
          PVector velDirection1 = new PVector(-r1.y, r1.x, 0);
          PVector velDirection2 = new PVector(-r2.y, r2.x, 0);
          PVector velDirection3 = new PVector(-r3.y, r3.x, 0);
          PVector velDirection4 = new PVector(-r4.y, r4.x, 0);
          velDirection1.normalize();
          velDirection2.normalize();
          velDirection3.normalize();
          velDirection4.normalize();
          
          V1 = velDirection1;
          V2 = velDirection2;
          V3 = velDirection3;
          V4 = velDirection4;
          V1.mult(rotVel * range1);
          V2.mult(rotVel * range2);
          V3.mult(rotVel * range3);
          V4.mult(rotVel * range4);
          
          F.add(getTrianglePressureForce(r1,r2,r3,V1,V2,V3));
          F.add(getTrianglePressureForce(r1,r3,r4,V1,V3,V4));      
        }
      }
    F.y += 0.2;
    //vel.add(F);
    pos.add(vel);
    vel.mult(0.998);
    if(pos.y > width/3*2) {
      pos.y = width/3*2;
      vel.y = -vel.y*0.85;
    }
  }
  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotateX(60 * 0.01f);
    rotateY(rotAngle());
    
    final int bladeCount = 3;
    for(int N = 0; N < bladeCount; ++N) {
      shape(bladeShape);
      rotateY(3.1415*2/bladeCount);
    }
    popMatrix();
  }
  PVector pos = new PVector(width/2, 100, 0);
  PVector vel = PVector.random3D();
  /* In radians */
  float rotAngle() { return frameCount * 0.01f * (frameCount * 0.01f) * mouseX/500; }
}

Blade father, mother, subling;
void setup() {
  size(1024, 1024, P3D);
  father = new Blade();
  mother = new Blade();
  subling = new Blade(father, mother);
  
  father.pos.x -= width/4;
  mother.pos.x += width/4;
  
  createWorld();
}

void draw() {
  background(127);


  
  rotateX(mouseY * 0.01f);
  drawWorld();
  updateAllBlades();
  /*father.update();
  father.draw();
  
  mother.update();
  mother.draw();
  
  subling.update();
  subling.draw();*/
}

void replaceSlowest() {
  int min_velY_index = 0;
  for(int i = 0; i < blades.size(); ++i) {
    if((blades.get(i).vel.y) > (blades.get(min_velY_index).vel.y)) {
      min_velY_index = i;
    }
  }
  PVector pos = blades.get(min_velY_index).pos;
  blades.remove(min_velY_index);
  Blade blade = new Blade(blades.get((min_velY_index+1)%blades.size()),blades.get((min_velY_index+2)%blades.size()));
  blade.pos = pos;
}

void mouseClicked() {
  replaceSlowest();
}
