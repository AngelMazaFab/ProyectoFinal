// PROYECTO FINAL: Desierto al cuadrado
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

void setup() {
  size(600,600);
  frameRate(60);
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