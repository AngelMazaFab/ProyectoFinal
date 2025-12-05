class Enemigo {
  float x, y;
  int tipoImagen; 
  boolean fueEliminado;

  Enemigo() {
    resetPos();
    x = random(width + 100, width + 500);
    tipoImagen = int(random(0, 3)); 
    fueEliminado = false;
  }

  void resetPos() {
    float offset = random(100, 300);
    x = width + offset;
    y = random(height - 50);
    
    tipoImagen = int(random(0, 3)); 
    fueEliminado = false;
  }

  void mover(float velocidad) {
    x -= velocidad;
    if (x < -imgsEnemigos[tipoImagen].width) {
      gestor.incrementarPuntaje(1);
      resetPos();
      enemigoMuerto[indiceSonidoEM].play();
      indiceSonidoEM++;
      if (indiceSonidoEM >= enemigoMuerto.length) {
        indiceSonidoEM = 0;
      }
    }
  }

  void dibujar() {
    pushMatrix();
    translate(x, y);

    imageMode(CENTER);
    image(imgsEnemigos[tipoImagen], 0, 0);

    popMatrix();
  }
}