// AdvancedMathGraph.pde - Gráfica 3D con Cálculo Avanzado
class AdvancedMathGraph {
  ArrayList<Float> infectedHistory;
  ArrayList<Float> deadHistory;
  ArrayList<Float> timeHistory;
  int maxPoints;
  float rotationX, rotationY;
  boolean isDragging;
  int lastMouseX, lastMouseY;

  AdvancedMathGraph() {
    infectedHistory = new ArrayList<Float>();
    deadHistory = new ArrayList<Float>();
    timeHistory = new ArrayList<Float>();
    maxPoints = 200;
    rotationX = -PI/6;
    rotationY = PI/4;
    isDragging = false;
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
    float magnitude = sqrt(partials.x * partials.x + partials.y * partials.y);
    return new PVector(partials.x, partials.y, magnitude);
  }

  // LÍMITE: lim(t→∞)
  float calculateLimit(ArrayList<Float> data) {
    if (data.size() < 10) return 0;

    // Promedio de los últimos 10 valores para estimar el límite
    float sum = 0;
    int start = max(0, data.size() - 10);
    for (int i = start; i < data.size(); i++) {
      sum += data.get(i);
    }
    return sum / (data.size() - start);
  }

  void handleMousePressed(int mx, int my) {
    isDragging = true;
    lastMouseX = mx;
    lastMouseY = my;
  }

  void handleMouseDragged(int mx, int my) {
    if (isDragging) {
      rotationY += (mx - lastMouseX) * 0.01;
      rotationX += (my - lastMouseY) * 0.01;
      lastMouseX = mx;
      lastMouseY = my;

      // Limitar rotación X
      rotationX = constrain(rotationX, -PI/2, 0);
    }
  }

  void handleMouseReleased() {
    isDragging = false;
  }

  void display(int x, int y, int w, int h) {
    int totalPop = 10000000;

    // FONDO
    fill(245, 248, 250);
    noStroke();
    rect(x, y, w, h);

    // BORDE
    stroke(100);
    strokeWeight(2);
    noFill();
    rect(x, y, w, h);

    // TÍTULO
    fill(0);
    textAlign(CENTER);
    textSize(18);
    text("Análisis Matemático Avanzado 3D", x + w/2, y + 25);
    textSize(12);
    fill(100);
    text("Arrastra para rotar la gráfica", x + w/2, y + 42);

    // ÁREA PARA GRÁFICA 3D
    int graphX = x + 20;
    int graphY = y + 60;
    int graphW = w - 240;
    int graphH = h - 240;

    pushMatrix();
    translate(graphX + graphW/2, graphY + graphH/2);

    // Aplicar rotación
    rotateX(rotationX);
    rotateY(rotationY);

    // EJES 3D
    strokeWeight(2);

    // Eje X (Tiempo) - Azul
    stroke(0, 100, 255);
    line(-graphW/3, 0, 0, graphW/3, 0, 0);

    // Eje Y (Infectados) - Rojo
    stroke(255, 50, 50);
    line(0, -graphH/3, 0, 0, graphH/3, 0);

    // Eje Z (Muertos) - Negro
    stroke(50, 50, 50);
    line(0, 0, -100, 0, 0, 100);

    // SUPERFICIE 3D
    if (infectedHistory.size() > 1) {
      for (int i = 0; i < infectedHistory.size() - 1; i++) {
        float t1 = map(i, 0, maxPoints, -graphW/3, graphW/3);
        float t2 = map(i + 1, 0, maxPoints, -graphW/3, graphW/3);

        float inf1 = map(infectedHistory.get(i), 0, totalPop, graphH/3, -graphH/3);
        float inf2 = map(infectedHistory.get(i + 1), 0, totalPop, graphH/3, -graphH/3);

        float dead1 = map(deadHistory.get(i), 0, totalPop, -100, 100);
        float dead2 = map(deadHistory.get(i + 1), 0, totalPop, -100, 100);

        // Superficie con gradiente de color
        float progress = (float)i / infectedHistory.size();
        stroke(255 * (1-progress), 100, 255 * progress, 150);
        strokeWeight(2);

        beginShape(QUAD_STRIP);
        fill(255, 100, 100, 80);
        vertex(t1, inf1, 0);
        vertex(t1, inf1, dead1);

        vertex(t2, inf2, 0);
        vertex(t2, inf2, dead2);
        endShape();

        // Línea de la trayectoria
        strokeWeight(3);
        stroke(255, 0, 0);
        line(t1, inf1, dead1, t2, inf2, dead2);
      }
    }

    popMatrix();

    // PANEL DE CÁLCULOS
    int panelX = x + w - 210;
    int panelY = y + 60;

    fill(255, 255, 255, 250);
    stroke(100);
    strokeWeight(1);
    rect(panelX, panelY, 200, h - 80);

    fill(0);
    textAlign(LEFT);
    textSize(14);
    text("CÁLCULO AVANZADO", panelX + 10, panelY + 20);

    textSize(11);
    int lineY = panelY + 40;
    int lineSpacing = 45;

    // Integral Doble
    fill(0, 100, 200);
    text("∬ f(x,y) dA", panelX + 10, lineY);
    fill(0);
    textSize(10);
    float doubleInt = calculateDoubleIntegral();
    text("Vol: " + nf(doubleInt, 0, 3) + " M²", panelX + 10, lineY + 12);
    text("(Área bajo superficie)", panelX + 10, lineY + 24);

    // Integral Triple
    lineY += lineSpacing;
    fill(200, 0, 100);
    textSize(11);
    text("∭ ρ(x,y,z) dV", panelX + 10, lineY);
    fill(0);
    textSize(10);
    float tripleInt = calculateTripleIntegral();
    text("Vol: " + nf(tripleInt, 0, 6), panelX + 10, lineY + 12);
    text("(Densidad 3D)", panelX + 10, lineY + 24);

    // Derivadas Parciales
    lineY += lineSpacing;
    fill(255, 100, 0);
    textSize(11);
    text("Derivadas Parciales", panelX + 10, lineY);
    fill(0);
    textSize(10);
    PVector partials = calculatePartialDerivatives();
    text("∂I/∂t = " + nf(partials.x, 0, 0), panelX + 10, lineY + 12);
    text("∂D/∂t = " + nf(partials.y, 0, 0), panelX + 10, lineY + 24);

    // Gradiente
    lineY += lineSpacing;
    fill(0, 150, 0);
    textSize(11);
    text("Gradiente ∇f", panelX + 10, lineY);
    fill(0);
    textSize(10);
    PVector grad = calculateGradient();
    text("|∇f| = " + nf(grad.z, 0, 1), panelX + 10, lineY + 12);
    text("(Máximo cambio)", panelX + 10, lineY + 24);

    // Límites
    lineY += lineSpacing;
    fill(100, 0, 200);
    textSize(11);
    text("Límites", panelX + 10, lineY);
    fill(0);
    textSize(10);
    float limInf = calculateLimit(infectedHistory);
    float limDead = calculateLimit(deadHistory);
    text("lim I(t) = " + nf(limInf/1000000, 0, 2) + "M", panelX + 10, lineY + 12);
    text("lim D(t) = " + nf(limDead/1000000, 0, 2) + "M", panelX + 10, lineY + 24);

    // LEYENDA DE EJES
    lineY += lineSpacing + 10;
    textSize(10);

    stroke(0, 100, 255);
    strokeWeight(3);
    line(panelX + 10, lineY, panelX + 30, lineY);
    fill(0);
    text("Tiempo", panelX + 35, lineY + 4);

    lineY += 15;
    stroke(255, 50, 50);
    line(panelX + 10, lineY, panelX + 30, lineY);
    fill(0);
    text("Infectados", panelX + 35, lineY + 4);

    lineY += 15;
    stroke(50, 50, 50);
    line(panelX + 10, lineY, panelX + 30, lineY);
    fill(0);
    text("Muertos", panelX + 35, lineY + 4);

    // ECUACIONES EN LA PARTE INFERIOR
    int bottomY = y + h - 160;
    fill(240, 243, 245);
    rect(x + 20, bottomY, w - 240, 140);

    fill(0);
    textSize(12);
    text("Ecuaciones del Sistema:", x + 30, bottomY + 20);

    textSize(10);
    text("dI/dt = β·I·(N-I-D)/N  (Tasa de infección)", x + 30, bottomY + 40);
    text("dD/dt = γ·I  (Tasa de mortalidad)", x + 30, bottomY + 55);
    text("", x + 30, bottomY + 70);
    text("Volumen bajo superficie: ∬∬ I(t,D) dt dD", x + 30, bottomY + 85);
    text("Densidad espacial: ∭∭∭ ρ(x,y,t) dx dy dt", x + 30, bottomY + 100);
    text("Campo vectorial: F(t) = (∂I/∂t, ∂D/∂t)", x + 30, bottomY + 115);
  }
}