class Enemigo {
  float x, y;
  int tamanio;
  int tipoDado;
  color colorEnemigo;
  boolean fueEliminado;
  
  Enemigo() {
    resetPos();
    x = random(width + 100, width + 500);
    colorEnemigo = color(random(200, 255), random(50, 150), random(100, 200));
    fueEliminado = false;
  }
  
  void resetPos() {
    float offset = random(100, 300);
    x = width + offset;
    y = random(height - 50);
    tamanio = 50;
    tipoDado = int(random(0, 5));
    colorEnemigo = color(random(200, 255), random(50, 150), random(100, 200));
    fueEliminado = false;
  }
  
  void mover(float velocidad) {
    x -= velocidad;
    if (x < -tamanio) {
      gestor.incrementarPuntaje(1);
      resetPos();
    }
  }
  
  void dibujar() {
    pushMatrix();
    translate(x, y);
    
    fill(colorEnemigo);
    stroke(255);
    strokeWeight(3);
    rect(0, 0, tamanio, tamanio);
    
    fill(0);
    noStroke();
    rect(10, 15, 8, 8);
    rect(32, 15, 8, 8);
    
    fill(100, 0, 50);
    rect(15, 32, 20, 6);
    
    stroke(255, 100);
    strokeWeight(1);
    line(0, 0, tamanio, 0);
    line(0, 0, 0, tamanio);
    
    popMatrix();
  }
}
