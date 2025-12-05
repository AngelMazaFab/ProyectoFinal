class Jugador {
  float x, y;
  float velocidad;
  int radio;
  boolean moverArriba, moverAbajo;

  boolean parryActivo;
  int tiempoInicioParry;
  int duracionParry;
  int cooldownParry;
  int ultimoParry;
  
  int armaActual;
  int balas;
  int tiempoUltimaRecarga;
  int tiempoParaRecarga;
  int tiempoDisparoVisual;
  
  int tiempoAnimacionHacha;
  int tiempoUltimoHacha;
  int cooldownHacha;

  // Acuerdate que aquí se definen los cds y tiempos para las armas

  Jugador(float posX, float posY) {
    x = posX;
    y = posY;
    velocidad = 5;
    radio = 50;
    
    parryActivo = false;
    tiempoInicioParry = 0;
    duracionParry = 500;
    cooldownParry = 3000;
    ultimoParry = -3000;
    
    armaActual = ARMA_NINGUNA;
    balas = 11;
    tiempoUltimaRecarga = millis();
    tiempoParaRecarga = 2000;
    tiempoDisparoVisual = 0;
    
    tiempoAnimacionHacha = 0;
    tiempoUltimoHacha = -2000;
    cooldownHacha = 2000;
  }
  
  void actualizar() {
    if (moverArriba) y -= velocidad;
    if (moverAbajo) y += velocidad;
    y = constrain(y, radio/2, height - radio/2);
    
    if (parryActivo && millis() - tiempoInicioParry > duracionParry) {
      parryActivo = false;
    }
    
    if (armaActual == ARMA_PISTOLA && millis() - tiempoUltimaRecarga > tiempoParaRecarga) {
      balas++;
      tiempoUltimaRecarga = millis();
    }
    
    dibujarEfectosAtaque();
  }
  
  void dibujar() {
    pushMatrix();
    translate(x, y);
    
    dibujarCuerda();
    dibujarParry();
    dibujarCuerpo();
    dibujarSombrero();
    
    popMatrix();
  }
  
  void dibujarCuerda() {
    stroke(150, 100, 50);
    strokeWeight(3);
    for (int i = 0; i < y; i += 10) {
      line(0, -(i+5), 0, -i);
    }
    strokeWeight(1);
  }
  
  void dibujarParry() {
    if (parryActivo) {
      noFill();
      stroke(COLOR_PARRY);
      strokeWeight(4);
      for (int i = 0; i < 3; i++) {
        ellipse(0, 0, radio + 10 + (i * 8), radio + 10 + (i * 8));
      }
      strokeWeight(1);
    }
  }
  
  void dibujarCuerpo() {
    fill(COLOR_JUGADOR);
    stroke(255);
    strokeWeight(2);
    
    rectMode(CENTER);
    rect(0, 0, radio * 0.7, radio * 0.7);
    
    fill(0);
    noStroke();
    rect(-8, -5, 6, 6);
    rect(8, -5, 6, 6);
  }
  
  void dibujarSombrero() {
    fill(200, 150, 100);
    stroke(150, 100, 50);
    strokeWeight(2);
    
    rect(0, -radio/2 - 8, radio * 0.9, 8);
    rect(0, -radio/2 - 18, radio * 0.5, 12);
    
    strokeWeight(1);
    rectMode(CORNER);
  }
  
  void dibujarEfectosAtaque() {
    if (millis() - tiempoDisparoVisual < 100) {
      stroke(255, 255, 0);
      strokeWeight(6);
      line(x, y, width, y);
      
      stroke(255, 200, 0);
      strokeWeight(10);
      point(x + 20, y);
      point(x + 40, y);
      strokeWeight(1);
    }
    
    if (millis() - tiempoAnimacionHacha < 200) {
      stroke(200, 200, 255);
      strokeWeight(15);
      line(x + 50, 0, x + 50, height);
      
      stroke(255, 255, 255, 150);
      strokeWeight(8);
      line(x + 50, 0, x + 50, height);
      strokeWeight(1);
    }
  }
  
  void atacar(ArrayList<Enemigo> enemigos) {
    if (armaActual == ARMA_PISTOLA) {
      atacarConPistola(enemigos);
    } else if (armaActual == ARMA_HACHA) {
      atacarConHacha(enemigos);
    }
  }
  
  void atacarConPistola(ArrayList<Enemigo> enemigos) {
    if (balas > 0) {
      balas--;
      tiempoDisparoVisual = millis();
      sonidoDisparo.play();
      
      for (Enemigo e : enemigos) {
        if (abs((e.y + e.tamanio/2) - y) < 30) {
          e.resetPos();
          gestor.incrementarPuntaje(4);
          e.fueEliminado = true;
          enemigoMuerto[indiceSonidoEM].play();
          indiceSonidoEM++;
          if (indiceSonidoEM >= enemigoMuerto.length) {
            indiceSonidoEM = 0;
          }
        }
      }
    }
  }
  
  void atacarConHacha(ArrayList<Enemigo> enemigos) {
    if (millis() - tiempoUltimoHacha > cooldownHacha) {
      tiempoAnimacionHacha = millis();
      tiempoUltimoHacha = millis();
      sonidoHacha.play();
      
      for (Enemigo e : enemigos) {
        if (abs(e.x - (x + 50)) < 50) {
          e.resetPos();
          e.fueEliminado = true;
          gestor.incrementarPuntaje(4);
          enemigoMuerto[indiceSonidoEM].play();
          indiceSonidoEM++;
          if (indiceSonidoEM >= enemigoMuerto.length) {
            indiceSonidoEM = 0;
          }
        }
      }
    }
  }
  //La neta no supe como hacer que el parry sirva, hazlo tú XD
  void activarParry() {
    if (millis() - ultimoParry > cooldownParry) {
      parryActivo = true;
      tiempoInicioParry = millis();
      ultimoParry = millis();
      sonidoParry.play();
    }
  }
  
  boolean colisionaCon(Enemigo e) {
    float distancia = dist(x, y, e.x + e.tamanio/2, e.y + e.tamanio/2);
    return distancia < (radio/2 + e.tamanio/2);
  }
  
  boolean tieneParryActivo() {
    return parryActivo;
  }
  
  //ya quedo el parry, ahi le metes cd y todo eso

  void seleccionarArma(int arma) {
    armaActual = arma;
  }
  
  void manejarTeclaPresionada(int codigo, char tecla) {
    if (codigo == UP) moverArriba = true;
    if (codigo == DOWN) moverAbajo = true;
    if (tecla == ' ') activarParry();
  }
  
  void manejarTeclaSoltada(int codigo) {
    if (codigo == UP) moverArriba = false;
    if (codigo == DOWN) moverAbajo = false;
  }
  
  void reiniciar() {
    y = height/2;
    armaActual = ARMA_NINGUNA;
    balas = 6;
    tiempoUltimaRecarga = millis();
    moverArriba = false;
    moverAbajo = false;
  }
  
  float getCooldownParry() {
    return cooldownParry - (millis() - ultimoParry);
  }
  
  float getCooldownHacha() {
    return cooldownHacha - (millis() - tiempoUltimoHacha);
  }
}
