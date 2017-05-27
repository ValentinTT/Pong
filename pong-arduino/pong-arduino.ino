/*
*************Pong Game*************
Sat 17 January 2016 17:45:00
Coded by Valentin TT
*/
const int Trig = 2; 
const int Echo = 3;
const int cerca = 4;
const int lejos = 5;

void setup()
{
  pinMode(Trig, OUTPUT); //Salida del pulso.
  pinMode(Echo, INPUT); //Entrada del pulso.
  pinMode(cerca, OUTPUT);
  pinMode(lejos, OUTPUT);
  Serial.begin(9600); 
}
unsigned int time_us = 0; //Tiempo que tarda el sonido en viajar
unsigned int distance_sm = 0; //Almacena la distancia en cm en un número entero.
unsigned int last_distance = 0;

void loop()
{
  digitalWrite(Trig, HIGH); //Se envia un pulso de diez microsegundos al disparador. 
  delayMicroseconds(10); 
  digitalWrite(Trig, LOW); 
  time_us = pulseIn(Echo, HIGH); //Resive el tiempo que tardo el sonido en salir y llegar a Echo.
  distance_sm = time_us / 58; //Se calcula la distancia en centimetros.
  Serial.print(distance_sm); //Imprime o envia por el puerto serial la distancia.
  Serial.print(","); //Sirve para separar datos en processing. //Podría usar println.
  if(distance_sm > last_distance){
    digitalWrite(lejos, HIGH);
    digitalWrite(cerca, LOW);
  }
  else if(distance_sm < last_distance){
    digitalWrite(cerca, HIGH);
    digitalWrite(lejos, LOW);
  }
  delay(100); //Tiempo que tarda en mandar otro dato a processing.
  last_distance = distance_sm;
}
