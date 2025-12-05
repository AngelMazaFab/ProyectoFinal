class InterfazHUD {
  
  void dibujar(int puntaje, float velocidad, Jugador j) {
    dibujarFondo();
    dibujarPuntaje(puntaje);
    dibujarParry(j);
    dibujarArma(j);
    dibujarVelocidad(velocidad);
  }
  
  void dibujarFondo() {
    fill(0, 180);
    noStroke();
    rect(0, 0, width, 90);
    
    stroke(COLOR_HUD);
    strokeWeight(4);
    line(0, 88, width, 88);
    strokeWeight(1);
  }
  
  void dibujarPuntaje(int puntaje) {
    fill(COLOR_HUD);
    textSize(24);
    textAlign(LEFT);
    text("Puntos: " + puntaje, 20, 35);
  }
  
  void dibujarParry(Jugador j) {
    float cdRestante = j.getCooldownParry();
    if (cdRestante < 0) cdRestante = 0;
    
    fill(50, 50, 80);
    stroke(COLOR_HUD);
    strokeWeight(2);
    rect(20, 50, 120, 20);
    
    noStroke();
    if (cdRestante <= 0) fill(COLOR_PARRY);
    else fill(255, 100, 100);
    
    float anchoBarra = map(cdRestante, j.cooldownParry, 0, 0, 116);
    rect(22, 52, anchoBarra, 16);
    
    fill(COLOR_HUD);
    textSize(16);
    text("Parreate (espacio)", 150, 67);
  }
  
  void dibujarArma(Jugador j) {
    if (j.armaActual == ARMA_PISTOLA) {
      dibujarPistola(j);
    } else if (j.armaActual == ARMA_HACHA) {
      dibujarHacha(j);
    }
  }
  
  void dibujarPistola(Jugador j) {
    fill(COLOR_HUD);
    textSize(20);
    textAlign(RIGHT);
    text("(>) Munitzione: " + j.balas, width - 20, 35);
    
    float tiempoRecarga = millis() - j.tiempoUltimaRecarga;
    float anchoRecarga = map(tiempoRecarga, 0, j.tiempoParaRecarga, 0, 100);
    
    fill(50, 50, 80);
    stroke(255, 200, 0);
    strokeWeight(2);
    rect(width - 120, 45, 100, 15);
    
    noStroke();
    fill(255, 200, 0);
    rect(width - 118, 47, constrain(anchoRecarga, 0, 96), 11);
  }
  
  void dibujarHacha(Jugador j) {
    float cdRestanteHacha = j.getCooldownHacha();
    if (cdRestanteHacha < 0) cdRestanteHacha = 0;
    
    fill(COLOR_HUD);
    textSize(20);
    textAlign(RIGHT);
    
    if (cdRestanteHacha <= 0) text("(>) ¡Hacheate!", width - 20, 35);
    else text("Hachiesperate", width - 20, 35);
    
    float tiempoCooldown = millis() - j.tiempoUltimoHacha;
    float anchoCooldown = map(tiempoCooldown, 0, j.cooldownHacha, 0, 100);
    
    fill(50, 50, 80);
    stroke(255, 100, 100);
    strokeWeight(2);
    rect(width - 120, 45, 100, 15);
    
    noStroke();
    if (cdRestanteHacha <= 0) fill(0, 255, 100);
    else fill(255, 100, 100);
    rect(width - 118, 47, constrain(anchoCooldown, 0, 96), 11);
  }
  
  void dibujarVelocidad(float velocidad) {
    fill(200, 200, 255);
    textSize(14);
    textAlign(LEFT);
    text("Velocida': " + nf(velocidad, 1, 1), 20, 105);
  }
}
