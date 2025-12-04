// ============================================================
// VIDEOJUEGO DE COMBATE POR TURNOS - ESTILO RPG TÁCTICO
// Desarrollado en Processing 4
// ============================================================

// ============================================================
// ESTADOS DEL JUEGO (Máquina de Estados)
// ============================================================
final int TURNO_JUGADOR_SELECCION = 0;
final int TURNO_JUGADOR_ANIMACION = 1;
final int TURNO_ENEMIGO = 2;
final int FIN_JUEGO = 3;

int estadoActual = TURNO_JUGADOR_SELECCION;

// ============================================================
// ENTIDADES Y OBJETOS DEL JUEGO
// ============================================================
Entidad jugador;
Entidad enemigo;
ManejadorCombate manejador;

// ============================================================
// VARIABLES DE CONTROL DE UI
// ============================================================
int alturaUI = 200; // Altura del panel de interfaz
String mensajeLog = "¡Empieza la batalla!";
int tiempoAnimacion = 0;
int duracionAnimacion = 60; // frames
boolean esperandoSeleccionDado = false;
int dadoSeleccionado = -1;

// Botones
Boton botonEspada;
Boton botonRevolver;
Boton botonReinicio;

// ============================================================
// CLASE ENTIDAD
// ============================================================
class Entidad {
  int vidaActual;
  int vidaMaxima;
  float posicionX;
  float posicionY;
  color colorEntidad;
  String nombre;
  float ancho;
  float alto;
  
  Entidad(String _nombre, int _vidaMaxima, float _x, float _y, color _color, float _ancho, float _alto) {
    nombre = _nombre;
    vidaMaxima = _vidaMaxima;
    vidaActual = _vidaMaxima;
    posicionX = _x;
    posicionY = _y;
    colorEntidad = _color;
    ancho = _ancho;
    alto = _alto;
  }
  
  void dibujar() {
    // TODO: Reemplazar con imagen
    pushMatrix();
    translate(posicionX, posicionY);
    
    // Dibujar sombra
    fill(0, 0, 0, 50);
    ellipse(0, alto/2 + 10, ancho * 0.8, 20);
    
    // Dibujar cuerpo de la entidad
    fill(colorEntidad);
    stroke(0);
    strokeWeight(3);
    rect(-ancho/2, -alto/2, ancho, alto, 10);
    
    // Detalles visuales
    fill(255, 255, 255, 100);
    rect(-ancho/2 + 10, -alto/2 + 10, ancho - 20, alto/3, 5);
    
    popMatrix();
    
    // Dibujar barra de vida encima
    dibujarBarraVida();
    
    // Dibujar nombre
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text(nombre, posicionX, posicionY - alto/2 - 60);
  }
  
  void dibujarBarraVida() {
    float anchoBarra = 100;
    float altoBarra = 12;
    float xBarra = posicionX - anchoBarra/2;
    float yBarra = posicionY - alto/2 - 40;
    
    // Fondo de la barra
    fill(50);
    stroke(255);
    strokeWeight(2);
    rect(xBarra, yBarra, anchoBarra, altoBarra, 6);
    
    // Barra de vida actual
    float porcentajeVida = (float)vidaActual / vidaMaxima;
    
    // Color de la barra según salud
    if (porcentajeVida > 0.6) {
      fill(50, 200, 50);
    } else if (porcentajeVida > 0.3) {
      fill(255, 200, 0);
    } else {
      fill(255, 50, 50);
    }
    
    noStroke();
    rect(xBarra + 2, yBarra + 2, (anchoBarra - 4) * porcentajeVida, altoBarra - 4, 4);
    
    // Texto de vida
    fill(255);
    textAlign(CENTER);
    textSize(12);
    text(vidaActual + " / " + vidaMaxima, posicionX, yBarra + altoBarra + 15);
  }
  
  void recibirDaño(int cantidad) {
    vidaActual -= cantidad;
    if (vidaActual < 0) vidaActual = 0;
  }
  
  boolean estaVivo() {
    return vidaActual > 0;
  }
}

// ============================================================
// CLASE DADO
// ============================================================
class Dado {
  int numeroCaras;
  boolean usado;
  String tipo; // Para mostrar visualmente (D6, D12, D20)
  
  Dado(int _caras) {
    numeroCaras = _caras;
    usado = false;
    tipo = "D" + _caras;
  }
  
  int lanzar() {
    usado = true;
    return int(random(1, numeroCaras + 1));
  }
  
  void dibujar(float x, float y, boolean seleccionado) {
    pushMatrix();
    translate(x, y);
    
    // Color según estado
    if (usado) {
      fill(80); // Gris oscuro si está usado
      stroke(100);
    } else if (seleccionado) {
      fill(255, 255, 0); // Amarillo si está seleccionado
      stroke(255, 200, 0);
    } else {
      fill(220); // Blanco si está disponible
      stroke(255);
    }
    
    strokeWeight(2);
    
    // Dibujar dado como cubo isométrico
    float tam = 30;
    rect(-tam/2, -tam/2, tam, tam, 5);
    
    // Puntos en el dado (simplificado)
    if (!usado) {
      fill(0);
      noStroke();
      float puntoTam = 4;
      ellipse(0, 0, puntoTam, puntoTam);
      ellipse(-8, -8, puntoTam, puntoTam);
      ellipse(8, 8, puntoTam, puntoTam);
    }
    
    // Texto del tipo de dado
    fill(usado ? 120 : 0);
    textAlign(CENTER, CENTER);
    textSize(10);
    text(tipo, 0, tam/2 + 12);
    
    popMatrix();
  }
}

// ============================================================
// CLASE MANEJADOR DE COMBATE
// ============================================================
class ManejadorCombate {
  ArrayList<Dado> dadosDisponibles;
  
  ManejadorCombate() {
    dadosDisponibles = new ArrayList<Dado>();
    inicializarDados();
  }
  
  void inicializarDados() {
    // 3 dados D6
    for (int i = 0; i < 3; i++) {
      dadosDisponibles.add(new Dado(6));
    }
    // 2 dados D12
    for (int i = 0; i < 2; i++) {
      dadosDisponibles.add(new Dado(12));
    }
    // 1 dado D20
    dadosDisponibles.add(new Dado(20));
  }
  
  int contarDadosDisponibles() {
    int count = 0;
    for (Dado d : dadosDisponibles) {
      if (!d.usado) count++;
    }
    return count;
  }
  
  Dado obtenerDado(int indice) {
    int currentIndex = 0;
    for (Dado d : dadosDisponibles) {
      if (!d.usado) {
        if (currentIndex == indice) return d;
        currentIndex++;
      }
    }
    return null;
  }
  
  void usarDadosParaRevolver() {
    int dadosUsados = 0;
    for (Dado d : dadosDisponibles) {
      if (!d.usado && dadosUsados < 3) {
        d.usado = true;
        dadosUsados++;
      }
    }
  }
  
  void dibujarDados(float xInicio, float y) {
    float espaciado = 45;
    float xActual = xInicio;
    int indice = 0;
    
    for (Dado d : dadosDisponibles) {
      if (!d.usado) {
        boolean seleccionado = (esperandoSeleccionDado && indice == dadoSeleccionado);
        d.dibujar(xActual, y, seleccionado);
        xActual += espaciado;
        indice++;
      }
    }
  }
}

// ============================================================
// CLASE BOTÓN
// ============================================================
class Boton {
  float x, y, ancho, alto;
  String texto;
  boolean activo;
  color colorNormal;
  color colorHover;
  color colorInactivo;
  
  Boton(float _x, float _y, float _ancho, float _alto, String _texto) {
    x = _x;
    y = _y;
    ancho = _ancho;
    alto = _alto;
    texto = _texto;
    activo = true;
    colorNormal = color(50, 100, 200);
    colorHover = color(70, 120, 220);
    colorInactivo = color(80, 80, 80);
  }
  
  void dibujar() {
    // Determinar color
    color colorActual;
    if (!activo) {
      colorActual = colorInactivo;
    } else if (estaRatonEncima()) {
      colorActual = colorHover;
    } else {
      colorActual = colorNormal;
    }
    
    // Dibujar botón
    fill(colorActual);
    stroke(255);
    strokeWeight(2);
    rect(x, y, ancho, alto, 8);
    
    // Dibujar texto
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(texto, x + ancho/2, y + alto/2);
  }
  
  boolean estaRatonEncima() {
    return mouseX >= x && mouseX <= x + ancho && 
           mouseY >= y && mouseY <= y + alto;
  }
  
  boolean fuePresionado() {
    return activo && estaRatonEncima();
  }
}

// ============================================================
// FUNCIONES DE SETUP Y DRAW
// ============================================================
void setup() {
  size(1000, 700);
  
  // Inicializar entidades
  jugador = new Entidad("Héroe", 100, 250, 300, color(50, 100, 255), 80, 120);
  enemigo = new Entidad("Monstruo", 80, 750, 300, color(255, 50, 50), 100, 140);
  
  // Inicializar manejador de combate
  manejador = new ManejadorCombate();
  
  // Inicializar botones
  botonEspada = new Boton(50, height - alturaUI + 100, 150, 40, "Usar Espada");
  botonRevolver = new Boton(220, height - alturaUI + 100, 150, 40, "Usar Revólver");
  botonReinicio = new Boton(width/2 - 75, height/2 + 50, 150, 50, "Reiniciar");
}

void draw() {
  // Dibujar escenario
  dibujarEscenario();
  
  // Dibujar entidades
  jugador.dibujar();
  enemigo.dibujar();
  
  // Dibujar UI
  dibujarUI();
  
  // Máquina de estados
  switch(estadoActual) {
    case TURNO_JUGADOR_SELECCION:
      manejarTurnoJugadorSeleccion();
      break;
      
    case TURNO_JUGADOR_ANIMACION:
      manejarAnimacion();
      break;
      
    case TURNO_ENEMIGO:
      manejarTurnoEnemigo();
      break;
      
    case FIN_JUEGO:
      manejarFinJuego();
      break;
  }
}

// ============================================================
// FUNCIONES DE DIBUJO
// ============================================================
void dibujarEscenario() {
  // TODO: Reemplazar con imagen de fondo
  // Fondo gris oscuro
  background(60, 70, 80);
  
  // Gradiente de cielo (opcional)
  for (int i = 0; i < height - alturaUI; i++) {
    float inter = map(i, 0, height - alturaUI, 0, 1);
    stroke(lerpColor(color(100, 120, 140), color(60, 70, 80), inter));
    line(0, i, width, i);
  }
  
  // Dibujar puente (trapecio en perspectiva)
  noStroke();
  fill(90, 70, 50);
  quad(200, 400, 800, 400, 900, 500, 100, 500);
  
  // Detalles del puente
  stroke(70, 50, 30);
  strokeWeight(3);
  for (int i = 0; i < 8; i++) {
    float x = map(i, 0, 7, 200, 800);
    float y1 = 400;
    float y2 = map(i, 0, 7, 500, 500);
    line(x, y1, x + (i-3.5) * 14, y2);
  }
  
  // Barandas del puente
  stroke(80, 60, 40);
  strokeWeight(5);
  line(200, 380, 800, 380);
  line(100, 480, 900, 480);
}

void dibujarUI() {
  // Panel negro de UI
  fill(0);
  noStroke();
  rect(0, height - alturaUI, width, alturaUI);
  
  // Línea separadora
  stroke(100, 150, 255);
  strokeWeight(3);
  line(0, height - alturaUI, width, height - alturaUI);
  
  // Título del turno
  fill(255, 200, 50);
  textAlign(CENTER);
  textSize(24);
  String tituloTurno = "";
  
  switch(estadoActual) {
    case TURNO_JUGADOR_SELECCION:
      tituloTurno = "¡TU TURNO!";
      break;
    case TURNO_JUGADOR_ANIMACION:
      tituloTurno = "TU TURNO";
      break;
    case TURNO_ENEMIGO:
      tituloTurno = "TURNO ENEMIGO";
      break;
    case FIN_JUEGO:
      tituloTurno = "¡FIN DEL JUEGO!";
      break;
  }
  
  text(tituloTurno, width/2, height - alturaUI + 30);
  
  // Log de batalla
  fill(255);
  textSize(14);
  textAlign(LEFT);
  text("Log: " + mensajeLog, 20, height - alturaUI + 60);
  
  // Mostrar dados disponibles
  if (estadoActual == TURNO_JUGADOR_SELECCION) {
    fill(200, 220, 255);
    textSize(14);
    text("Dados disponibles:", 20, height - alturaUI + 155);
    manejador.dibujarDados(50, height - alturaUI + 165);
    
    // Dibujar botones
    botonEspada.activo = manejador.contarDadosDisponibles() > 0;
    botonRevolver.activo = manejador.contarDadosDisponibles() >= 3;
    
    botonEspada.dibujar();
    botonRevolver.dibujar();
    
    // Instrucción especial si está esperando selección
    if (esperandoSeleccionDado) {
      fill(255, 255, 0);
      textAlign(CENTER);
      textSize(16);
      text("¡Haz clic en un dado para usar la espada!", width/2, height - 30);
    }
  }
}

// ============================================================
// FUNCIONES DE LÓGICA DE ESTADOS
// ============================================================
void manejarTurnoJugadorSeleccion() {
  // El jugador debe seleccionar una acción
  // La interacción se maneja en mousePressed()
}

void manejarAnimacion() {
  tiempoAnimacion++;
  
  // Efecto visual simple durante el ataque
  if (tiempoAnimacion % 10 < 5) {
    jugador.posicionX += 2;
  } else {
    jugador.posicionX -= 2;
  }
  
  if (tiempoAnimacion >= duracionAnimacion) {
    // Restaurar posición
    jugador.posicionX = 250;
    
    // Verificar si el enemigo sigue vivo
    if (!enemigo.estaVivo()) {
      estadoActual = FIN_JUEGO;
      mensajeLog = "¡Has derrotado al enemigo!";
    } else {
      estadoActual = TURNO_ENEMIGO;
      tiempoAnimacion = 0;
    }
  }
}

void manejarTurnoEnemigo() {
  tiempoAnimacion++;
  
  // Animación del enemigo
  if (tiempoAnimacion % 10 < 5) {
    enemigo.posicionX -= 2;
  } else {
    enemigo.posicionX += 2;
  }
  
  // Esperar un momento antes de atacar
  if (tiempoAnimacion == 30) {
    // El enemigo ataca
    int dañoEnemigo = int(random(3, 9)); // Entre 3 y 8
    jugador.recibirDaño(dañoEnemigo);
    mensajeLog = "¡El enemigo te golpeó por " + dañoEnemigo + " de daño!";
  }
  
  if (tiempoAnimacion >= 60) {
    // Restaurar posición
    enemigo.posicionX = 750;
    tiempoAnimacion = 0;
    
    // Verificar si el jugador sigue vivo
    if (!jugador.estaVivo()) {
      estadoActual = FIN_JUEGO;
      mensajeLog = "¡Has sido derrotado!";
    } else {
      estadoActual = TURNO_JUGADOR_SELECCION;
    }
  }
}

void manejarFinJuego() {
  // Mostrar mensaje de fin
  fill(0, 200);
  rect(0, 0, width, height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  
  if (jugador.estaVivo()) {
    fill(100, 255, 100);
    text("¡VICTORIA!", width/2, height/2 - 50);
  } else {
    fill(255, 100, 100);
    text("DERROTA", width/2, height/2 - 50);
  }
  
  fill(255);
  textSize(20);
  text(mensajeLog, width/2, height/2);
  
  // Botón de reinicio
  botonReinicio.activo = true;
  botonReinicio.dibujar();
}

// ============================================================
// FUNCIONES DE COMBATE
// ============================================================
void usarEspada(int indiceDado) {
  Dado dadoUsado = manejador.obtenerDado(indiceDado);
  
  if (dadoUsado != null) {
    int daño = dadoUsado.lanzar();
    enemigo.recibirDaño(daño);
    mensajeLog = "¡Usaste la espada! Lanzaste un " + dadoUsado.tipo + " y sacaste " + daño + ". El enemigo recibió " + daño + " de daño!";
    
    esperandoSeleccionDado = false;
    dadoSeleccionado = -1;
    
    // Cambiar a animación
    estadoActual = TURNO_JUGADOR_ANIMACION;
    tiempoAnimacion = 0;
  }
}

void usarRevolver() {
  if (manejador.contarDadosDisponibles() >= 3) {
    // Gastar 3 dados
    manejador.usarDadosParaRevolver();
    
    // Realizar 3 disparos
    int balasAcertadas = 0;
    int dañoTotal = 0;
    String detalles = "";
    
    // Tiro 1: 80% de acierto
    if (random(1) < 0.8) {
      balasAcertadas++;
      dañoTotal += 5;
      detalles += "[Tiro 1: ¡Acierto!] ";
    } else {
      detalles += "[Tiro 1: Fallo] ";
    }
    
    // Tiro 2: 60% de acierto
    if (random(1) < 0.6) {
      balasAcertadas++;
      dañoTotal += 5;
      detalles += "[Tiro 2: ¡Acierto!] ";
    } else {
      detalles += "[Tiro 2: Fallo] ";
    }
    
    // Tiro 3: 40% de acierto
    if (random(1) < 0.4) {
      balasAcertadas++;
      dañoTotal += 5;
      detalles += "[Tiro 3: ¡Acierto!]";
    } else {
      detalles += "[Tiro 3: Fallo]";
    }
    
    enemigo.recibirDaño(dañoTotal);
    mensajeLog = "¡Disparaste 3 veces y acertaste " + balasAcertadas + "! Daño total: " + dañoTotal + ". " + detalles;
    
    // Imprimir en consola
    println("=== REVÓLVER ===");
    println(detalles);
    println("Balas acertadas: " + balasAcertadas);
    println("Daño total: " + dañoTotal);
    
    // Cambiar a animación
    estadoActual = TURNO_JUGADOR_ANIMACION;
    tiempoAnimacion = 0;
  }
}

// ============================================================
// EVENTOS DE MOUSE
// ============================================================
void mousePressed() {
  if (estadoActual == TURNO_JUGADOR_SELECCION) {
    // Verificar clic en botón de espada
    if (botonEspada.fuePresionado()) {
      esperandoSeleccionDado = true;
      dadoSeleccionado = 0; // Seleccionar el primer dado por defecto
      mensajeLog = "¡Haz clic en un dado para seleccionarlo!";
    }
    
    // Verificar clic en botón de revólver
    else if (botonRevolver.fuePresionado()) {
      usarRevolver();
    }
    
    // Si está esperando selección de dado, verificar clic en dados
    else if (esperandoSeleccionDado) {
      float xInicio = 50;
      float y = height - alturaUI + 165;
      float espaciado = 45;
      
      int dadosDisponibles = manejador.contarDadosDisponibles();
      for (int i = 0; i < dadosDisponibles; i++) {
        float xDado = xInicio + i * espaciado;
        float distancia = dist(mouseX, mouseY, xDado, y);
        
        if (distancia < 20) { // Radio de clic
          usarEspada(i);
          break;
        }
      }
    }
  }
  
  // Verificar clic en botón de reinicio
  else if (estadoActual == FIN_JUEGO) {
    if (botonReinicio.fuePresionado()) {
      reiniciarJuego();
    }
  }
}

void mouseMoved() {
  // Efecto visual al pasar el mouse sobre los dados
  if (estadoActual == TURNO_JUGADOR_SELECCION && esperandoSeleccionDado) {
    float xInicio = 50;
    float y = height - alturaUI + 165;
    float espaciado = 45;
    
    int dadosDisponibles = manejador.contarDadosDisponibles();
    for (int i = 0; i < dadosDisponibles; i++) {
      float xDado = xInicio + i * espaciado;
      float distancia = dist(mouseX, mouseY, xDado, y);
      
      if (distancia < 20) {
        dadoSeleccionado = i;
        cursor(HAND);
        return;
      }
    }
    cursor(ARROW);
  }
}

// ============================================================
// FUNCIÓN DE REINICIO
// ============================================================
void reiniciarJuego() {
  // Reiniciar entidades
  jugador.vidaActual = jugador.vidaMaxima;
  enemigo.vidaActual = enemigo.vidaMaxima;
  
  // Reiniciar dados
  manejador = new ManejadorCombate();
  
  // Reiniciar estado
  estadoActual = TURNO_JUGADOR_SELECCION;
  mensajeLog = "¡Nueva batalla comienza!";
  esperandoSeleccionDado = false;
  dadoSeleccionado = -1;
  tiempoAnimacion = 0;
}
