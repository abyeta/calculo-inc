import processing.core.PApplet;
import processing.core.PVector;
import java.util.ArrayList;

public class AdvancedWindow extends PApplet {
  // Referencias a los datos del sketch principal
  ArrayList<Float> infectedHistory;
  ArrayList<Float> deadHistory;
  ArrayList<Float> timeHistory;  // Agregado: historial de tiempo
  int maxPoints = 200;  // Agregado: máximo de puntos
  AdvancedMathGraph graph;  // Instancia de la gráfica

  // Variables para rotación (igual que en AdvancedMathGraph)
  float rotationX = -PI/6;
  float rotationY = PI/4;
  boolean isDragging = false;
  int lastMouseX, lastMouseY;

  // Constructor: recibe referencias a los datos
  public AdvancedWindow(ArrayList<Float> infHist, ArrayList<Float> deadHist) {
    this.infectedHistory = infHist;
    this.deadHistory = deadHist;
    this.timeHistory = new ArrayList<Float>();  // Inicializa timeHistory
    this.graph = new AdvancedMathGraph();  // Crea la instancia de la gráfica
  }
  
  void addData(float infected, float dead) {
    infectedHistory.add(infected);
    deadHistory.add(dead);
    timeHistory.add((float)infectedHistory.size());

    if (infectedHistory.size() > maxPoints) {
      infectedHistory.remove(0);
      deadHistory.remove(0);
      timeHistory.remove(0);
    }
  }

  // INTEGRAL DOBLE: ∬ f(x,y) dA
  float calculateDoubleIntegral() {
    if (infectedHistory.size() < 2) return 0;

    float volume = 0;
    int n = infectedHistory.size();

    // Método de Simpson para integral doble
    for (int i = 0; i < n - 1; i++) {
      float dx = 1.0; // paso en tiempo
      float dy1 = infectedHistory.get(i);
      float dy2 = infectedHistory.get(i + 1);
      float dz1 = deadHistory.get(i);
      float dz2 = deadHistory.get(i + 1);

      // Volumen del elemento diferencial
      volume += dx * ((dy1 + dy2) / 2.0) * ((dz1 + dz2) / 2.0) / 1000000.0;
    }

    return volume;
  }

  // INTEGRAL TRIPLE: ∭ densidad dV
  float calculateTripleIntegral() {
    if (infectedHistory.size() < 3) return 0;

    float totalVolume = 0;
    int n = infectedHistory.size();

    for (int i = 0; i < n - 2; i++) {
      float dt = 1.0;
      float infected1 = infectedHistory.get(i);
      float infected2 = infectedHistory.get(i + 1);
      float infected3 = infectedHistory.get(i + 2);

      float dead1 = deadHistory.get(i);
      float dead2 = deadHistory.get(i + 1);
      float dead3 = deadHistory.get(i + 2);

      // Volumen del prisma triangular
      float avgInfected = (infected1 + infected2 + infected3) / 3.0;
      float avgDead = (dead1 + dead2 + dead3) / 3.0;

      totalVolume += dt * avgInfected * avgDead / 1000000000000.0;
    }

    return totalVolume;
  }

  // DERIVADAS PARCIALES
  PVector calculatePartialDerivatives() {
    if (infectedHistory.size() < 2) return new PVector(0, 0);

    int n = infectedHistory.size();
    float dI_dt = infectedHistory.get(n-1) - infectedHistory.get(n-2); // ∂I/∂t
    float dD_dt = deadHistory.get(n-1) - deadHistory.get(n-2); // ∂D/∂t

    return new PVector(dI_dt, dD_dt);
  }

  // GRADIENTE: ∇f = (∂f/∂x, ∂f/∂y)
  PVector calculateGradient() {
    PVector partials = calculatePartialDerivatives();
    float magnitude = PApplet.sqrt(partials.x * partials.x + partials.y * partials.y);
    return new PVector(partials.x, partials.y, magnitude);
  }

  // LÍMITE: lim(t→∞)
  float calculateLimit(ArrayList<Float> data) {
    if (data.size() < 10) return 0;

    // Promedio de los últimos 10 valores para estimar el límite
    float sum = 0;
    int start = PApplet.max(0, data.size() - 10);  // Cambiado: usa PApplet.max
    for (int i = start; i < data.size(); i++) {
      sum += data.get(i);
    }
    return sum / (data.size() - start);
  }
  
  void display(PApplet pg, int x, int y, int w, int h) {
    int totalPop = 10000000;

    // FONDO
    pg.fill(245, 248, 250);
    pg.noStroke();
    pg.rect(0, 0, w, h);  // Coordenadas relativas al pg (ventana externa)

    // BORDE
    pg.stroke(100);
    pg.strokeWeight(2);
    pg.noFill();
    pg.rect(0, 0, w, h);

    // TÍTULO
    pg.fill(0);
    pg.textAlign(PApplet.CENTER);
    pg.textSize(18);
    pg.text("Análisis Matemático Avanzado 3D", w/2, 25);
    pg.textSize(12);
    pg.fill(100);
    pg.text("Arrastra para rotar la gráfica", w/2, 42);

    // ÁREA PARA GRÁFICA 3D
    int graphX = 20;  // Relativo al pg
    int graphY = 60;
    int graphW = w - 240;
    int graphH = h - 240;

    pg.pushMatrix();
    pg.translate(graphX + graphW/2, graphY + graphH/2);

    // Aplicar rotación
    pg.rotateX(rotationX);
    pg.rotateY(rotationY);

    // EJES 3D
    pg.strokeWeight(2);

    // Eje X (Tiempo) - Azul
    pg.stroke(0, 100, 255);
    pg.line(-graphW/3, 0, 0, graphW/3, 0, 0);

    // Eje Y (Infectados) - Rojo
    pg.stroke(255, 50, 50);
    pg.line(0, -graphH/3, 0, 0, graphH/3, 0);

    // Eje Z (Muertos) - Negro
    pg.stroke(50, 50, 50);
    pg.line(0, 0, -100, 0, 0, 100);

    // SUPERFICIE 3D
    if (infectedHistory.size() > 1) {
      for (int i = 0; i < infectedHistory.size() - 1; i++) {
        float t1 = PApplet.map(i, 0, maxPoints, -graphW/3, graphW/3);
        float t2 = PApplet.map(i + 1, 0, maxPoints, -graphW/3, graphW/3);

        float inf1 = PApplet.map(infectedHistory.get(i), 0, totalPop, graphH/3, -graphH/3);
        float inf2 = PApplet.map(infectedHistory.get(i + 1), 0, totalPop, graphH/3, -graphH/3);

        float dead1 = PApplet.map(deadHistory.get(i), 0, totalPop, -100, 100);
        float dead2 = PApplet.map(deadHistory.get(i + 1), 0, totalPop, -100, 100);

        // Superficie con gradiente de color
        float progress = (float)i / infectedHistory.size();
        pg.stroke(255 * (1-progress), 100, 255 * progress, 150);
        pg.strokeWeight(2);

        pg.beginShape(PApplet.QUAD_STRIP);
        pg.fill(255, 100, 100, 80);
        pg.vertex(t1, inf1, 0);
        pg.vertex(t1, inf1, dead1);

        pg.vertex(t2, inf2, 0);
        pg.vertex(t2, inf2, dead2);
        pg.endShape();

        // Línea de la trayectoria
        pg.strokeWeight(3);
        pg.stroke(255, 0, 0);
        pg.line(t1, inf1, dead1, t2, inf2, dead2);
      }
    }

    pg.popMatrix();

    // PANEL DE CÁLCULOS
    int panelX = w - 210;  // Relativo al pg
    int panelY = 60;

    pg.fill(255, 255, 255, 250);
    pg.stroke(100);
    pg.strokeWeight(1);
    pg.rect(panelX, panelY, 200, h - 80);

    pg.fill(0);
    pg.textAlign(PApplet.LEFT);
    pg.textSize(14);
    pg.text("CÁLCULO AVANZADO", panelX + 10, panelY + 20);

    pg.textSize(11);
    int lineY = panelY + 40;
    int lineSpacing = 45;

    // Integral Doble
    pg.fill(0, 100, 200);
    pg.text("∬ f(x,y) dA", panelX + 10, lineY);
    pg.fill(0);
    pg.textSize(10);
    float doubleInt = calculateDoubleIntegral();
    pg.text("Vol: " + PApplet.nf(doubleInt, 0, 3) + " M²", panelX + 10, lineY + 12);
    pg.text("(Área bajo superficie)", panelX + 10, lineY + 24);

    // Integral Triple
    lineY += lineSpacing;
    pg.fill(200, 0, 100);
    pg.textSize(11);
    pg.text("∭ ρ(x,y,z) dV", panelX + 10, lineY);
    pg.fill(0);
    pg.textSize(10);
    float tripleInt = calculateTripleIntegral();
    pg.text("Vol: " + PApplet.nf(tripleInt, 0, 6), panelX + 10, lineY + 12);
    pg.text("(Densidad 3D)", panelX + 10, lineY + 24);

    // Derivadas Parciales
    lineY += lineSpacing;
    pg.fill(255, 100, 0);
    pg.textSize(11);
    pg.text("Derivadas Parciales", panelX + 10, lineY);
    pg.fill(0);
    pg.textSize(10);
    PVector partials = calculatePartialDerivatives();
    pg.text("∂I/∂t = " + PApplet.nf(partials.x, 0, 0), panelX + 10, lineY + 12);
    pg.text("∂D/∂t = " + PApplet.nf(partials.y, 0, 0), panelX + 10, lineY + 24);

    // Gradiente
    lineY += lineSpacing;
    pg.fill(0, 150, 0);
    pg.textSize(11);
    pg.text("Gradiente ∇f", panelX + 10, lineY);
    pg.fill(0);
    pg.textSize(10);
    PVector grad = calculateGradient();
    pg.text("|∇f| = " + PApplet.nf(grad.z, 0, 1), panelX + 10, lineY + 12);
    pg.text("(Máximo cambio)", panelX + 10, lineY + 24);

    // Límites
    lineY += lineSpacing;
    pg.fill(100, 0, 200);
    pg.textSize(11);
    pg.text("Límites", panelX + 10, lineY);
    pg.fill(0);
    pg.textSize(10);
    float limInf = calculateLimit(infectedHistory);
    float limDead = calculateLimit(deadHistory);
    pg.text("lim I(t) = " + PApplet.nf(limInf/1000000, 0, 2) + "M", panelX + 10, lineY + 12);
    pg.text("lim D(t) = " + PApplet.nf(limDead/1000000, 0, 2) + "M", panelX + 10, lineY + 24);

    // LEYENDA DE EJES
    lineY += lineSpacing + 10;
    pg.textSize(10);

    pg.stroke(0, 100, 255);
    pg.strokeWeight(3);
    pg.line(panelX + 10, lineY, panelX + 30, lineY);
    pg.fill(0);
    pg.text("Tiempo", panelX + 35, lineY + 4);

    lineY += 15;
    pg.stroke(255, 50, 50);
    pg.line(panelX + 10, lineY, panelX + 30, lineY);
    pg.fill(0);
    pg.text("Infectados", panelX + 35, lineY + 4);

    lineY += 15;
    pg.stroke(50, 50, 50);
    pg.line(panelX + 10, lineY, panelX + 30, lineY);
    pg.fill(0);
    pg.text("Muertos", panelX + 35, lineY + 4);

    // ECUACIONES EN LA PARTE INFERIOR
    int bottomY = h - 160;
    pg.fill(240, 243, 245);
    pg.rect(20, bottomY, w - 240, 140);

    pg.fill(0);
    pg.textSize(12);
    pg.text("Ecuaciones del Sistema:", 30, bottomY + 20);

    pg.textSize(10);
    pg.text("dI/dt = β·I·(N-I-D)/N  (Tasa de infección)", 30, bottomY + 40);
    pg.text("dD/dt = γ·I  (Tasa de mortalidad)", 30, bottomY + 55);
    pg.text("", 30, bottomY + 70);
    pg.text("Volumen bajo superficie: ∬∬ I(t,D) dt dD", 30, bottomY + 85);
    pg.text("Densidad espacial: ∭∭∭ ρ(x,y,t) dx dy dt", 30, bottomY + 100);
    pg.text("Campo vectorial: F(t) = (∂I/∂t, ∂D/∂t)", 30, bottomY + 115);
  }

  // Configura la ventana secundaria
  public void settings() {
    size(900, 750, P3D);  // Tamaño de la ventana 3D (ajusta si quieres más grande/pequeña)
  }

  public void setup() {
    // Inicializaciones si es necesario (ej. colores)
  }

  public void draw() {
    background(245, 248, 250);  // Fondo de la ventana 3D
    // Actualiza y dibuja la gráfica con los datos más recientes
    if (!infectedHistory.isEmpty() && !deadHistory.isEmpty()) {
      addData(infectedHistory.get(infectedHistory.size()-1), deadHistory.get(deadHistory.size()-1));  // Usa addData de esta clase
    }
    display(this, 0, 0, 900, 750);  // Dibuja en esta ventana (cambia a display de la misma clase)
  }

  // Manejo de mouse para rotación
  public void mousePressed() {
    isDragging = true;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }

  public void mouseDragged() {
    if (isDragging) {
      rotationY += (mouseX - lastMouseX) * 0.01;
      rotationX += (mouseY - lastMouseY) * 0.01;
      lastMouseX = mouseX;
      lastMouseY = mouseY;
      rotationX = constrain(rotationX, -PI/2, 0);
    }
  }

  public void mouseReleased() {
    isDragging = false;
  }

  // Método para cerrar la ventana
  public void exit() {
    dispose();  // Cierra la ventana
  }
}
