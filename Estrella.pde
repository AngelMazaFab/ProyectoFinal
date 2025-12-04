class Estrella {
  float x, y;
  float velocidad;
  int tamano;
  int brillo;
  
  Estrella() {
    x = random(width);
    y = random(height);
    velocidad = random(0.5, 2);
    tamano = int(random(1, 4));
    brillo = int(random(150, 255));
  }
  
  void actualizar() {
    x -= velocidad;
    if (x < 0) {
      x = width;
      y = random(height);
    }
  }
  
  void dibujar() {
    if (frameCount % 30 < 15) fill(brillo, brillo, brillo);
    else fill(brillo - 50, brillo - 50, brillo - 50);
    noStroke();
    
    if (tamano == 1) {
      rect(x, y, 2, 2);
    } else if (tamano == 2) {
      rect(x, y, 3, 3);
      fill(brillo + 50);
      rect(x + 1, y + 1, 1, 1);
    } else {
      rect(x, y, 4, 4);
      rect(x - 2, y + 1, 2, 2);
      rect(x + 4, y + 1, 2, 2);
      rect(x + 1, y - 2, 2, 2);
      rect(x + 1, y + 4, 2, 2);
    }
  }
}
