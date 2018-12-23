import processing.serial.*;

Serial Control; //Arduino serial port
String data; //Recive de text sent for arduino.
int distance_sm; //Save the data value but in integer format.

boolean juego; //Pausa del juego si es false no entra en el bucle dentro de draw().
int puntajeFinal; //Puntaje al que los jugadores deben llegar.
int[] vel = {-6, -5, -4, 4, 5, 6}; //Velocidades posibles aleatorias.

Campo campo;
Jugador player;
Computadora cpu;
Pelota bocha;

void setup() {
  size(900, 700);
  background(0);

  puntajeFinal = 5;
  campo = new Campo(1, 698, 0, 898);
  player = new Jugador(20, 160, 8, campo.izquierda + 40, height/2);
  cpu = new Computadora(20, 160, 5, campo.derecha - 40, height/2, 1);
  bocha = new Pelota(25, vel[(int)random(vel.length)], vel[(int)random(vel.length)], width/2, height/2);

  Control = new Serial(this, Serial.list()[1], 9600);
  Control.bufferUntil(',');

  juego = false;
  textSize(20);
  text("PAUSE", 30, 30);
  textSize(50);
}
void draw() {
  if (juego) {
    background(0);
    campo.dibujarCampo();
    bocha.dibujarPelota();
    if (juego) {//PORQUE Al REINICIAR SE DIBUJAN DE VUELTA LOS JUGADORES.
      player.dibujarJugador(distance_sm*20);
      cpu.seguirPelota(bocha);
    }
    text(player.puntos, width / 4, 80);
    text(cpu.puntos, width / 4 * 3, 80);
  }
  if (player.puntos == puntajeFinal){//Se prepara el juego para otra partida.
    text ("GANASTE", 100, 200);
    player.puntos = 0;
    cpu.puntos = 0;
  }
  else if (cpu.puntos == puntajeFinal){ 
    text ("PERDISTE", 100, 200);
    player.puntos = 0;
    cpu.puntos = 0;
  }
}

void serialEvent (Serial Control) { //Cada vez que arduino envia un dato.
  data = Control.readStringUntil(','); //Resive el dato
  data = data.substring(0, data.length()-1); //Retira el \n del dato.
  distance_sm = Integer.valueOf(data); //Convierte el dato a entero.
}
void mousePressed() {//Al hacer click se cambia el valor de juego, para entrar o no al bucle while().
  textSize(30);
  if (juego) text("PAUSE", 30, 40);
  juego = !juego;
  textSize(50);
}

class Campo {
  public int arriba, abajo, izquierda, derecha;
  public Campo(int arriba, int abajo, int izquierda, int derecha) {
    this.arriba = arriba;
    this.abajo = abajo;
    this.izquierda = izquierda;
    this.derecha = derecha;
    dibujarCampo();
  }
  public void dibujarCampo() {
    stroke(255);
    strokeWeight(8);
    rectMode(CORNERS);
    fill(0, 255, 0);
    rect(izquierda, arriba, derecha, abajo);
    fill(255);
    dibujarLinea();
    strokeWeight(1);
  }
  public void dibujarLinea() {
    int i;
    rectMode(CORNER);
    for (i = arriba+4; i + 35 <= abajo; i += 50) {
      rect(width/2 - 8, i, 16, 35);
    }
  }
  public void reiniciar() {
    background(0);
    campo.dibujarCampo();
    player.dibujarJugador(player.y);
    cpu.dibujarJugador(cpu.y);
    //bocha.dibujarPelota(); La funcion despues de anotar un punto vuelve a reboteIzquierdo que retorna a su vez a dibujar pelota
    if (bocha.x_velocidad > 0)bocha.x_velocidad = (int)random(4, 6);
    else bocha.x_velocidad = (int)random(-6, -4);
    bocha.y_velocidad = vel[(int)random(vel.length)];
  }
}

class Jugador {
  public int ancho, largo;//Las necesito para los rebotes de la pelota.
  int velocidad, xj, yj, puntos;//Puntos es la cantidad de puntos a los que debe llegar el juegador.
  int top, bottom;//Sirven para que el jugador no se escape del terreno de juego.
  int y; //Valor fijo inicial.

  public Jugador(int ancho, int largo, int velocidad, int xj, int yj) {
    this.ancho = ancho;
    this.largo = largo;
    this.velocidad = velocidad;
    this.xj = xj;
    this.yj = yj;
    this.y = yj;
    this.puntos = 0;
    this.top = campo.arriba + largo/2; //XQ el jugador se dibuja desde la mitad. top suele ser 0 + largo/2. 
    this.bottom = campo.abajo - largo/2;

    dibujarJugador(yj);//Dibuja el jugador al construirlo.
  }

  public void dibujarJugador(int y) {//Dibuja el jugador 
    fill(255, 0, 0);
    rectMode(CENTER);//Siempre se coloca en CENTER para usar el ancho y largo de jugador.
    if (y > top && y < bottom) yj = y;//Si el parametro no se sale del espacio de juego se le asigna a yj.  
    rect(xj, yj, ancho, largo);
  }
}
class Computadora extends Jugador {//Jugador oponente CPU.
  int inteligencia;//Pendiente...
  public Computadora(int ancho, int largo, int velocidad, int xj, int yj, int inteligencia) {
    super(ancho, largo, velocidad, xj, yj);
    this.inteligencia = inteligencia;
  }
  public void seguirPelota(Pelota pelota) {//Se desplaza hacia abajo o arriba siguiendo la pelota.
    if (pelota.y_velocidad > 0) {//La pelota va para abajo
      if (pelota.yp > yj - largo/2) dibujarJugador(yj + velocidad);//Para arriba.
      else if (pelota.yp < yj) dibujarJugador(yj - velocidad);
      else dibujarJugador(yj);
    } else {
      if (pelota.yp > yj) dibujarJugador(yj + velocidad);//Para arriba.
      else if (pelota.yp < yj + largo/2) dibujarJugador(yj - velocidad);
      else dibujarJugador(yj);
    }
  }
}
class Pelota {
  int diametro, x_velocidad, y_velocidad, xp, yp;
  int top, bottom;//No uso variable top y bottom, xq no uso para comprobar si choco a la izquierda o derecha o contra un jugador.
  public Pelota(int diametro, int x_velocidad, int y_velocidad, int xp, int yp) {
    this.diametro =diametro;
    this.x_velocidad = 0;
    this.y_velocidad = 0;
    this.xp = xp;
    this.yp = yp;
    dibujarPelota();
    this.x_velocidad = x_velocidad;
    this.y_velocidad = y_velocidad;
    this.top = campo.arriba + diametro/2;
    this.bottom = campo.abajo - diametro/2;
  }
  public void dibujarPelota() {
    ellipseMode(CENTER);
    choqueAlto();
    choqueIzquierda(player, cpu);
    noStroke();
    fill(0, 0, 255);
    ellipse(xp, yp, diametro, diametro);
    fill(255);
  }
  public void choqueAlto() {//Controla si se encuentra con el piso o techo del Campo.
    if (y_velocidad > 0) {//La pelota va hacia abajo.
      if (yp + y_velocidad <= bottom) yp += y_velocidad;
      else {
        yp = bottom - (bottom - (yp + y_velocidad));
        y_velocidad = -(y_velocidad);
      }
    } else if (y_velocidad < 0) {//La pelota va hacia arriba.
      if (yp + y_velocidad >= top) yp += y_velocidad;//Si no se sale del campo que suba.
      else {
        yp = (top + (yp + y_velocidad));//Los corchetes esetan de mas.
        y_velocidad = -(y_velocidad);
      }
    }
  }
  public void choqueIzquierda(Jugador jugador, Jugador cpu) {//Controla si se encuentra con un jugador.
    if (x_velocidad > 0) {//La pelota va hacia la derecha.
      int x_raqueta = cpu.xj - cpu.ancho/2; //El lado del jugador que esta de cara a la cancha.
      int y_raqueta = cpu.yj - cpu.largo/2;//La parte superior del jugador.
      if ((xp + diametro/2) + x_velocidad >= x_raqueta) {
        if (yp > y_raqueta && yp < y_raqueta + cpu.largo) {
          xp = x_raqueta - ((xp + diametro/2) + x_velocidad - x_raqueta);
          x_velocidad = -(x_velocidad+1);
        } else if ((xp + diametro/2) + x_velocidad >= campo.derecha) {
          xp += x_velocidad;
          marcarPunto(player);
        } else xp += x_velocidad;
      } else xp += x_velocidad;
    } else if (x_velocidad < 0) {//La pelota va hacia la izquierda.
      int x_raqueta = jugador.xj + jugador.ancho/2; //El lado del jugador que esta de cara a la cancha.
      int y_raqueta = jugador.yj - jugador.largo/2;//La parte superior del jugador.
      if ((xp - diametro/2) + x_velocidad <= x_raqueta) {
        if (yp > y_raqueta && yp < y_raqueta + jugador.largo) {
          xp = x_raqueta + ((xp - diametro/2) + x_velocidad - x_raqueta);
          x_velocidad = -(x_velocidad-1);
        } else if ((xp - diametro/2) + x_velocidad <= campo.izquierda) {
          xp += x_velocidad;
          marcarPunto(cpu);
        } else xp += x_velocidad;
      } else xp += x_velocidad;
    }
    if (x_velocidad == 10) x_velocidad = 9;
    else if (x_velocidad == -10) x_velocidad = -9;
  }
  public void marcarPunto(Jugador ganador) {
    campo.reiniciar();
    ganador.puntos++;
    xp = width/2;
    yp = height/2;
    juego = !juego;
  }
}