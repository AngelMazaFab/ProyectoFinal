// PROYECTO: Juego de Evasión 8-BITS | AUTORES: Angel y Pablo

GestorJuego gestor;
Jugador jugador;
InterfazHUD hud;
ArrayList<Enemigo> enemigos;
ArrayList<Estrella> estrellas;

void setup() {
  size(600, 600);
  
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
  
  gestor.actualizar();
}

void keyPressed() {
  gestor.manejarTeclaPresionada(keyCode, key);
}

void keyReleased() {
  gestor.manejarTeclaSoltada(keyCode);
}