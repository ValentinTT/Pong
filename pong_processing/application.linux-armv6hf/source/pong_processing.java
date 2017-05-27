import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pong_processing extends PApplet {

/*
*************Pong Game*************
Sat 17 January 2016 15:45:00
Coded by Valentin TT
*/


Serial Control;
int movimiento;

boolean juego = false;
int yrect;
int speed;
int field_width, field_height;
int largo_rect;

public void setup() {
  
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
public void draw() {

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
public void mousePressed() {
  if (juego) text("PAUSE", 30, 35);
  juego = !juego;
}
  public void settings() {  size(1600, 900); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "pong_processing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
