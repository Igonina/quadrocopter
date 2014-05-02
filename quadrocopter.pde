
/*class Quadrocopter {
  Quadrocopter() {
    
  }
  Blade[] fans = Blade[4];
  void update() {
  }
  void draw() {
  }
}*/
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
    
    taga = (father.taga + mother.taga)/2*(0.9+random(0.2))+random(0.2)-random(0.2);
  }
  
  float[][][] length = new float[5][32][2];
  PShape bladeShape;
  color surfaceColor;
  void update() {
    velY -= taga;
    velY += 0.2;
    posY += velY;
    velY *= 0.998;
    if(posY > width/3*2) {
      posY = width/3*2;
      velY = -velY*0.85;
    }
  }
  void draw() {
    pushMatrix();
    rotateX(mouseY * 0.01f);
    translate(posX, posY);
    rotateX(60 * 0.01f);
    rotateY(frameCount * 0.01f + frameCount*frameCount * 0.0001f - velY*10);
    
    final int bladeCount = 3;
    for(int N = 0; N < bladeCount; ++N) {
      shape(bladeShape);
      rotateY(3.1415*2/bladeCount);
    }
    popMatrix();
  }
  float posX = width/2, posY = 100;
  float velY = random(1)-random(1);
  
  float taga = 0;
}

Blade father, mother, subling;
void setup() {
  size(1024, 1024, P3D);
  father = new Blade();
  mother = new Blade();
  subling = new Blade(father, mother);
  
  father.posX -= width/4;
  mother.posX += width/4;
}

void draw() {
  background(127);


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
    if((blades.get(i).velY) > (blades.get(min_velY_index).velY)) {
      min_velY_index = i;
    }
  }
  float posX = blades.get(min_velY_index).posX;
  float posY = blades.get(min_velY_index).posY;
  blades.remove(min_velY_index);
  Blade blade = new Blade(blades.get((min_velY_index+1)%blades.size()),blades.get((min_velY_index+2)%blades.size()));
  blade.posX = posX;
  blade.posY = posY;
}

void mouseClicked() {
  replaceSlowest();
}
