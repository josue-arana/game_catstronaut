import processing.sound.*;
SoundFile music, crash, over_sound, over_voice, life;
float dist_big;
/******************* ASTEROID FUNCTION ****************************/
class Life{
  float x, y, xmov;
  Life(){
    x = 0;
    y = random(height);
  }
  void display(){
    x += 2;
    image(redHeart, x, y, 40, 40);
  }
  void reset(){
    x = 0;
    y = random(height);
  }
  
}
class Asteroid {
  float cx, cy;
  float num, val, volume;
  float xSpeed = random(2, 8);
  PImage ast1;

  Asteroid(int num) {
    cx = 0 ; 
    cy = random(height);
    this.num = num;
    val = random(1, 6);
    ast1 = loadImage("ast"+String.valueOf((int)val)+".png");
    volume = pow(random(1), 4)*150+50;
    
    if (volume > 100)
       dist_big = volume;
  }

  void reset() {
    cx = 0;
    cy = random(height);
  }

  void display() {
    cx += xSpeed; 
    fill(#5F5C5B);

    imageMode(CENTER);
    println(volume);
    //circle(cx,cy,volume);
    image(ast1, cx, cy, volume, volume);
    
      
    for(int k = 0; k< 5; k++){
      fill(255,20);
      stroke(255);
      circle(cx+random(10,width),random(height),1);
    }
  }
}

/******************* PARTICLE FUNCTION ****************************/
class Particle {
  float x, y, vx, vy, diameter, drag;
  PVector pos, vel;   //position and velocity of PFactorial
  float theta; 

  Particle() {      //constructor
    pos = new PVector(rx+20, ry);
    x = mouseX;
    y = mouseY;
    vx = mvx*.25+random(-5, 5);
    vy = mvy*.25+random(-5, 5);
    vel = new PVector(vx, vy);
    diameter = random(10, 120);
    drag = 0.96;
  }

  void update() {
    theta = noise(pos.x*.02, pos.y*.02, frameCount*.02)*TWO_PI;
    vel.x += sin(theta)*0.02;
    vel.y += cos(theta)*0.02;
    vel.x += noise(pos.x*.02, pos.y*.02, frameCount*.02);
    vel.y += noise(pos.x*.02, pos.y*.02, frameCount*.02+2225)-0.5;
    vx *= drag;
    vy *= drag;
    vel.mult(drag); 
    pos.add(vel);
    x += vx;
    y += vy;
    diameter *= 0.98;  //diameter shrinks
  }
  void display() {
    noStroke();
    //#FA9C05
    fill(#03FF3B, 10);
    pushMatrix();
    translate(pos.x, pos.y);
    circle(0, 0, diameter/2);
    popMatrix();
  }
}


ArrayList<Particle> parts;
ArrayList<Asteroid> aster;
ArrayList<Life> liv;
PImage rocket, redHeart, ast2, explosion;
float mvx, mvy;
float rocket_size;
float rx, ry, xSpeed, ySpeed, speed_limit;
int lives;
boolean damage;
int num, score; 
float x, y, hx, hy; //position in x and y
int s,m; //seconds and minutes
boolean new_life;

//void settings(){
//size(3840,1080,P2D);  //- where x is either P3D or P2D
//}


/******************* SETUP FUNCTION ****************************/
void setup() {  
  fullScreen(P3D);
  textSize(128);
  //size(3840,1080,P2D); //full size = 2560 x 1600.
  //size(1300,400,P2D);
  //surface.setLocation(-3840,0);

  num =(int) random(1, 10);
  aster = new ArrayList<Asteroid>();  //asteroid
  parts = new ArrayList<Particle>();  //rocket trail
  liv = new ArrayList<Life>();
  
  rocket = loadImage("cat.png");
  redHeart = loadImage("h2.png");
  explosion = loadImage("explosion_image2.png");
  
  hx = 0;
  hy = random(height);
  

  rx = width-100;
  ry = height/2;
  ySpeed = xSpeed = 0;
  speed_limit = 8;
  lives = 3;
  score = s = m = 0;
  new_life = false;

  for (int i=0; i< 10; i++) {   //generate rocket trail
    parts.add(new Particle());
  }
  for (int i=0; i< 4; i++) {    //generate first asteroids
    aster.add(new Asteroid((int)random(1, 10)));
  }

  music = new SoundFile(this, "Shooting Stars.mp3");
  crash = new SoundFile(this, "explosion2.mp3");
  over_sound = new SoundFile(this, "game_over_sound.mp3");
  over_voice = new SoundFile(this, "game_over_voice.mp3");
  life = new SoundFile(this, "lifeup.mp3");
  
  music.play();
  music.loop();
} 


/******************* DRAW FUNCTION ****************************/
void draw() { 
  background(0);
  
  if (score == 200 || score == 600 || score == 1000){
    new_life = true;
    liv.add(new Life());
  } 
  
  if (new_life){
    liv.get(0).display();
    
    float d = dist(liv.get(0).x, liv.get(0).y, rx, ry);
    
    if ( d < 30) {
        life.play();
        lives++;
        new_life = false;
        liv.get(0).reset();
    }
    if (liv.get(0).x > width){
      new_life = false;
       liv.get(0).reset();
    }
  
  }
  
  
  //keep track of the lives
  int pos = width-60;
  for (int i = 0; i < lives; i++) {
    image(redHeart, pos, 20, 40, 40);
    pos -= 60 ;
  }
  
  
  //show time/score
  if (lives!= 0) {
     
     s = second();
     m = minute();
   
    if (second() != -1) {
      score +=1;
    }
  }
  textSize(20);
  fill(255);
  text("Score:"+(String.valueOf(score)), (width-160), (height-60));
  text("Time:"+(String.valueOf(second())), (width-160), (height-30));
  //high score
  text("High Score:"+(String.valueOf(13252)), (50), (height-30));

  //End game if no more lives left
  if (lives == 0) {
    background(0);
    music.stop();
    text128();
    text36();
    
  } else {
    rocket_size = 100; //190
    checkBounds();
    rx += xSpeed;
    ry += ySpeed;

    //draw rocket trail 
    if (xSpeed<0 || abs(ySpeed)>0) {
      for (int i=0; i< 10; i++)
        parts.add(new Particle());
    }

    if (frameCount % (1*10) == 0) /// LEVEL DIFFICULTY 
      aster.add(new Asteroid((int)random(1, 10)));

    for (int i=0; i < aster.size(); ) { //changed for loop 

      aster.get(i).display(); 

      if (aster.get(i).cx > width) {
        aster.remove(i);
      } 
      i++;   //update i at the bottom to not mess us the size
    }


    //check distance
    for (int j=0; j< aster.size(); j++) {
      float d; 
      d = dist(aster.get(j).cx, aster.get(j).cy, rx, ry);

      if ( d < 40) {
        crash.play();
        image(explosion, rx, ry, rocket_size, rocket_size);
        aster.remove(j);
        updateDamage();
      }
    }


    //Update the rocket trail
    for (int i=0; i<parts.size(); ) { //changed for loop
      if (parts.get(i).diameter < 2) {
        parts.remove(i);
      } else {
        parts.get(i).update();
        parts.get(i).display();
        stroke(200, 0, 0);
        i++;      //update i at the bottom to not mess us the size
      }
    }

    //image(rocket, mouseX-(rocket_size/2),mouseY-(rocket_size/2),rocket_size,rocket_size);
    //image(rocket, rx-(rocket_size-20), ry-(rocket_size/2), rocket_size, rocket_size);
    imageMode(CENTER);
    image(rocket, rx, ry, 90, 70);
  }
}
void new_asteroids() {
  for (int i=0; i< 3; i++) {
    aster.add(new Asteroid((int)random(1, 10)));
  }
  
  
}


/******************* MENU FUNCTION ****************************/
void menu(){
  fill(255);
  textSize(128);
  textAlign(CENTER, CENTER);
  text("PLAY AGAIN", width/2, 3*height/10, 0);
}

void text128(){  
  fill(255, 0, 0);
  textSize(128);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, 3*height/10, 0);
}

void text36(){  
  fill(255, 0, 0);
  textSize(36);
  textAlign(CENTER, CENTER);
  text("Score:"+ (String.valueOf(score)), width/2, 5*height/10, 0);
}
void ending(){
  over_voice.play();
}


void updateDamage() {  
  parts = new ArrayList<Particle>();
  aster = new ArrayList<Asteroid>();
  rocket = loadImage("cat.png");
  redHeart = loadImage("h2.png");

  rx = width-100;
  ry = height/2;
  ySpeed = 0;
  xSpeed = 0;
  speed_limit = 8;

  lives -= 1;
  over_sound.play();
  num = (int)random(1, 10);
  
  if (lives == 0)
   ending();
}

void checkBounds() {
  if ( rx < rocket_size/2) {
    xSpeed = 0 ; 
    rx = rocket_size/2;
  } else if (rx > width-rocket_size ) {
    xSpeed = 0;
    rx = width-rocket_size;
  }
  if (ry < 0) { 
    ry = height;
  }
  if (ry > height) { 
    ry = 0;
  }
}


void mouseMoved() {
  for (int i=0; i< 10; i++) {
    parts.add(new Particle());
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP && ySpeed >= -1*speed_limit) {
      ySpeed -=4;
    } else if (keyCode == DOWN && ySpeed <= speed_limit) {
      ySpeed +=4;
      ry += ySpeed;
    } else if (keyCode == LEFT && xSpeed >= -1*speed_limit ) {
      xSpeed -=4;
    } else if (keyCode == RIGHT && xSpeed <= speed_limit ) {
      xSpeed +=4;
    }
  } else {
    image(rocket, rx, ry, rocket_size, rocket_size);
  }
}
