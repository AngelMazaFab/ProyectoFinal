class Jugador {
  float x, y;
  float velocidad;
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

  Jugador(float posX, float posY) {
    x = posX;
    y = posY;
    velocidad = 5;
    
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
    y = constrain(y, imgJugador.height/2, height - imgJugador.height/2);
    
    if (parryActivo && millis() - tiempoInicioParry > duracionParry) {
      parryActivo = false;
    }
    
    if (armaActual == ARMA_PISTOLA && millis() - tiempoUltimaRecarga > tiempoParaRecarga) {
      balas++;
      tiempoUltimaRecarga = millis();
    }
  }
  
  void dibujar() {
    pushMatrix();
    translate(x, y);
    
    dibujarCuerda();
    dibujarParry();
    
    imageMode(CENTER);
    image(imgJugador, 0, 0); 
    
    dibujarEfectosAtaque();
    
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
      
      float diametro = max(imgJugador.width, imgJugador.height) * 0.8;
      
      for (int i = 0; i < 3; i++) {
        ellipse(0, 0, diametro + (i * 8), diametro + (i * 8));
      }
      strokeWeight(1);
    }
  }
  
  void dibujarEfectosAtaque() {
    
    // 1. PISTOLA
    if (millis() - tiempoDisparoVisual < 100) {
      pushMatrix();
      translate(imgJugador.width/4 + 10, 0); 
      
      stroke(255, 255, 0);
      strokeWeight(4);
      
      float inicioRayoX = imgRevolver.width/2; 
      line(inicioRayoX, -5, width - x, -5); 
      
      stroke(255, 200, 0);
      strokeWeight(8);
      point(inicioRayoX, -5); 
      strokeWeight(1);
      
      imageMode(CENTER);
      image(imgRevolver, 0, 0); 
      
      popMatrix();
    }
    
    // 2. HACHA
    float duracion = 200;
    float tiempo = millis() - tiempoAnimacionHacha;
    
    if (tiempo < duracion) {
      pushMatrix();
      translate(imgJugador.width/2 + 20, 0); 
      
      float yPos = map(tiempo, 0, duracion, -200, 200);
      
      imageMode(CENTER);
      image(imgHacha, 0, yPos); 
      
      popMatrix();
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
        float margenY = ((imgRevolver.height/2) + (imgsEnemigos[0].height/2)) * 0.4;
        
        if (abs(e.y - y) < margenY && e.x > x) {
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
        float alcanceX = (imgJugador.width + imgHacha.width/2) * 0.6;
        float alcanceY = (imgHacha.height/2 + imgsEnemigos[0].height/2) * 0.7;

        if (e.x > x && e.x - x < alcanceX && abs(e.y - y) < alcanceY) {
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

  void activarParry() {
    if (millis() - ultimoParry > cooldownParry) {
      parryActivo = true;
      tiempoInicioParry = millis();
      ultimoParry = millis();
      sonidoParry.play();
    }
  }
  
  boolean colisionaCon(Enemigo e) {
    // --- REDUCCIÓN DE HITBOX ---
    // Ajustado de 0.55 a 0.45 (Reducción del 10%)
    
    float radioJugador = (imgJugador.width / 2.0) * 0.45;
    float radioEnemigo = (imgsEnemigos[e.tipoImagen].width / 2.0) * 0.45;
    
    float distancia = dist(x, y, e.x, e.y);
    return distancia < (radioJugador + radioEnemigo);
  }
  
  boolean tieneParryActivo() {
    return parryActivo;
  }
  
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