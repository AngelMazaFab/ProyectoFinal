// PROYECTO FINAL: Círculo Mágico Espacial 2 (mejor que el primero, peor que el tercero)
//AUTORES: Angel Maza Fabila y Jesús Pablo Damián Nava

import processing.sound.*;

GestorJuego gestor;
Jugador jugador;
InterfazHUD hud;
ArrayList<Enemigo> enemigos;
ArrayList<Estrella> estrellas;

SoundFile sonidoDisparo;
SoundFile sonidoParry;
SoundFile sonidoHacha;
SoundFile [] enemigoMuerto = new SoundFile[3];
int indiceSonidoEM = 0;
SoundFile musicaFondo1;
SoundFile musicaFondo2;
SoundFile morir;

PImage imgJugador;
PImage imgRevolver;
PImage imgHacha;
PImage[] imgsEnemigos = new PImage[3]; 

void setup() {
  size(600,600);
  frameRate(60);

  COLOR_FONDO = color(10, 10, 30);
  COLOR_JUGADOR = color(0, 255, 200);
  COLOR_ENEMIGO = color(255, 50, 100);
  COLOR_HUD = color(100, 200, 255);
  COLOR_PARRY = color(0, 255, 100);
  
  imgJugador = loadImage("Texturas/Hero_01.png");
  imgJugador.resize(0, 100); 

  imgRevolver = loadImage("Texturas/Revolver_01.png");
  imgRevolver.resize(0, 50);

  imgHacha = loadImage("Texturas/Axe_01.png");
  imgHacha.resize(0, 300);
  
  imgsEnemigos[0] = loadImage("Texturas/1d4_01.png");
  imgsEnemigos[1] = loadImage("Texturas/1d6_01.png");
  imgsEnemigos[2] = loadImage("Texturas/1d8_01.png");
  
  for(int i = 0; i < 3; i++){
    imgsEnemigos[i].resize(0, 100);
  }

  musicaFondo1 = new SoundFile(this, "musicaFondo1.mp3");
  musicaFondo2 = new SoundFile(this, "musicaFondo2.mp3");
  sonidoDisparo = new SoundFile(this, "sonidoPistola.mp3");
  enemigoMuerto [0] = new SoundFile(this, "enemigoMuere1.mp3");
  enemigoMuerto [1] = new SoundFile(this, "enemigoMuere2.mp3");
  enemigoMuerto [2] = new SoundFile(this, "enemigoMuere3.mp3");
  morir = new SoundFile(this, "muelto.mp3");
  sonidoHacha = new SoundFile(this, "sonidoHacha.mp3");
  sonidoParry = new SoundFile(this, "sonidoParry.mp3");
  
  gestor = new GestorJuego();
  jugador = new Jugador(100, height/2);
  hud = new InterfazHUD();
  
  estrellas = new ArrayList<Estrella>();
  for (int i = 0; i < 100; i++) {
    estrellas.add(new Estrella());
  }
  
  enemigos = new ArrayList<Enemigo>();
  enemigos.add(new Enemigo());
}

void draw() {
  background(COLOR_FONDO);
  
  for (Estrella e : estrellas) {
    e.actualizar();
    e.dibujar();
  }
  gestor.gestionarMusica();
  gestor.actualizar();
}

void keyPressed() {
  gestor.manejarTeclaPresionada(keyCode, key);
}

void keyReleased() {
  gestor.manejarTeclaSoltada(keyCode);
}