class GestorJuego {
  int estadoActual;
  int puntaje;
  float velocidadGlobal;
  boolean seleccionDeArmaRealizada;
  
  GestorJuego() {
    estadoActual = ESTADO_SELECCION;
    puntaje = 0;
    velocidadGlobal = 4.0;
    seleccionDeArmaRealizada = false;
  }
  
  void actualizar() {
    if (estadoActual == ESTADO_JUGANDO) {
      actualizarJuego();
    } else if (estadoActual == ESTADO_SELECCION) {
      mostrarSeleccion();
    } else if (estadoActual == ESTADO_GAMEOVER) {
      mostrarGameOver();
    }
  }
  
  void actualizarJuego() {
    gestionarDificultad();
    jugador.actualizar();
    jugador.dibujar();
    
    for (Enemigo e : enemigos) {
      e.mover(velocidadGlobal);
      e.dibujar();
      
      if (jugador.colisionaCon(e)) {
        if (jugador.tieneParryActivo()) {
          e.resetPos();
          puntaje += 5;
          enemigoMuerto[indiceSonidoEM].play();
          indiceSonidoEM++;
          if (indiceSonidoEM >= enemigoMuerto.length) {
            indiceSonidoEM = 0;
          }
        } else {
          estadoActual = ESTADO_GAMEOVER;
          morir.play();
        }
      }
    }
    
    hud.dibujar(puntaje, velocidadGlobal, jugador);
  }
  void gestionarDificultad() {
    int nivelVelocidad = puntaje / 10;
    velocidadGlobal = 3.0 + (nivelVelocidad * 0.5);
    if (velocidadGlobal > MAX_VELOCIDAD) velocidadGlobal = MAX_VELOCIDAD;
    
    int cantidadDeseada = 1;
    if (puntaje >= 60) cantidadDeseada = 4;
    else if (puntaje >= 30) cantidadDeseada = 3;
    else if (puntaje >= 10) cantidadDeseada = 2;
    
    while (enemigos.size() < cantidadDeseada) {
      enemigos.add(new Enemigo());
    }
  }
  
  void mostrarSeleccion() {
    fill(0, 200);
    rect(0, 0, width, height);
    
    textAlign(CENTER);
    fill(COLOR_HUD);
    textSize(36);
    text("¡Empiezale pues!", width/2, 120);
    
    fill(255, 255, 100);
    textSize(24);
    text("Escoja su rifle master (O hacha, lol)", width/2, 180);
    
    stroke(COLOR_HUD);
    strokeWeight(3);
    noFill();
    rect(width/2 - 120, 230, 240, 80);
    
    fill(COLOR_HUD);
    textSize(28);
    text("^ Pistolón", width/2, 265);
    textSize(18);
    text("(11 de plomo, 2 de cd )", width/2, 295);
    
    stroke(255, 100, 100);
    strokeWeight(3);
    noFill();
    rect(width/2 - 120, 360, 240, 80);
    
    fill(255, 100, 100);
    textSize(28);
    text("v Hacha", width/2, 395);
    textSize(18);
    text("(Golpea cada 2 segundos)", width/2, 425);
    
    strokeWeight(1);
  }
  
  void mostrarGameOver() {
    fill(0, 220);
    rect(0, 0, width, height);
    
    if (millis() % 1000 < 500) fill(255, 50, 100);
    else fill(255, 100, 150);
    
    textAlign(CENTER);
    textSize(60);
    text("Tssss...", width/2, height/2 - 40);
    
    fill(COLOR_HUD);
    textSize(30);
    text("Puntillos: " + puntaje, width/2, height/2 + 20);
    
    fill(255, 255, 100);
    textSize(22);
    text("Pícale r para reiniciar", width/2, height/2 + 80);
  }
  
  void manejarTeclaPresionada(int codigo, char tecla) {
    if (tecla == 'r' || tecla == 'R') reiniciar();
    
    if (estadoActual == ESTADO_JUGANDO) {
      jugador.manejarTeclaPresionada(codigo, tecla);
      
      if (codigo == RIGHT) {
        jugador.atacar(enemigos);
        actualizarPuntajePorAtaque();
      }
    } else if (estadoActual == ESTADO_SELECCION) {
      if (codigo == UP) {
        jugador.seleccionarArma(ARMA_PISTOLA);
        seleccionDeArmaRealizada = true;
        estadoActual = ESTADO_JUGANDO;
      } else if (codigo == DOWN) {
        jugador.seleccionarArma(ARMA_HACHA);
        seleccionDeArmaRealizada = true;
        estadoActual = ESTADO_JUGANDO;
      }
    }
  }
  
  void manejarTeclaSoltada(int codigo) {
    jugador.manejarTeclaSoltada(codigo);
  }
  
  void actualizarPuntajePorAtaque() {
    for (Enemigo e : enemigos) {
      if (e.fueEliminado) {
        puntaje++;
        e.fueEliminado = false;
      }
    }
  }
  
  void reiniciar() {
    estadoActual = ESTADO_SELECCION;
    puntaje = 0;
    velocidadGlobal = 4.0;
    enemigos.clear();
    enemigos.add(new Enemigo());
    jugador.reiniciar();
    seleccionDeArmaRealizada = false;
  }
  
  void incrementarPuntaje(int cantidad) {
    puntaje += cantidad;
  }
  void gestionarMusica() {
  if (!musicaFondo1.isPlaying() && !musicaFondo2.isPlaying()) {
    
    if (random(1.0) > 0.5) {
      musicaFondo1.play();
    } else {
      musicaFondo2.play();
    }
  }
}
}
