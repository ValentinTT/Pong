/*
*************Pong Game*************
Sat 17 January 2016 15:45:00
Coded by Valentin TT
*/
import processing.serial.*;

Serial Control;
int movimiento;

boolean juego = false;
int yrect;
int speed;
int field_width, field_height;
int largo_rect;

void setup() {
  size(1600, 900);
  background(0);
  noFill();
  stroke(255);
  strokeWeight(10);
  rectMode(CENTER);

  String nombreControl = Serial.list()[1];
  Control = new Serial(this, nombreControl, 9600);

  yrect = height/2;
  speed = 5;
  field_width = width - 20;
  field_height = height - 20;
  largo_rect = 160;

  rect(width/2, height/2, field_width, field_height);
  for (int i = 20; i <= field_height; i += 25)
    line(width/2, i, width/2, i+10);
  rect(60, yrect, 10, largo_rect);

  text("PAUSE", 30, 35);
}
void draw() {

  if (juego) {
    background(0);
    rect(width/2, height/2, field_width, field_height);
    for (int i = 20; i <= field_height; i += 25)
      line(width/2, i, width/2, i+10);
    rect(60, yrect, 10, largo_rect);    
    if (Control.available() > 0) {
      movimiento = Control.read();
      text(movimiento, 50, 50);
    }
    if (movimiento == 1) yrect -= speed;
    else if (movimiento == 2) yrect = yrect;
    else if (movimiento == 3) yrect += speed;
    if (keyPressed && key == 'w' && yrect > 20+largo_rect/2)
      yrect -= speed;
    if (keyPressed && key == 'x' && yrect < field_height-largo_rect/2)
      yrect += speed;
  }
}
void mousePressed() {
  if (juego) text("PAUSE", 30, 35);
  juego = !juego;
}