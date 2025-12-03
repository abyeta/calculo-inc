// Graph.pde - Estilo GeoGebra MEJORADO
class Graph {
  ArrayList<Float> infectedHistory;
  ArrayList<Float> deadHistory;
  int maxPoints;

  Graph() {
    infectedHistory = new ArrayList<Float>();
    deadHistory = new ArrayList<Float>();
    maxPoints = 300;
  }

  void addData(float infected, float dead) {
    infectedHistory.add(infected);
    deadHistory.add(dead);

    if (infectedHistory.size() > maxPoints) {
      infectedHistory.remove(0);
      deadHistory.remove(0);
    }
  }

  float calculateIntegral(ArrayList<Float> data) {
    if (data.size() < 2) return 0;
    float area = 0;
    for (int i = 0; i < data.size() - 1; i++) {
      float y1 = data.get(i);
      float y2 = data.get(i + 1);
      area += (y1 + y2) / 2.0;
    }
    return area;
  }

  float calculateDerivative(ArrayList<Float> data) {
    if (data.size() < 2) return 0;
    int n = data.size();
    float y2 = data.get(n - 1);
    float y1 = data.get(n - 2);
    return y2 - y1;
  }

  void display(int x, int y, int w, int h) {
    int totalPop = 10000000;

    // === FONDO ESTILO GEOGEBRA ===
    fill(252, 252, 255);
    noStroke();
    rect(x, y, w, h);

    // Borde más oscuro y grueso
    stroke(80, 80, 90);
    strokeWeight(3);
    noFill();
    rect(x, y, w, h);

    // === GRILLA ESTILO GEOGEBRA ===
    stroke(215, 215, 225);
    strokeWeight(1.5);

    // Líneas verticales
    for (int i = 0; i <= 10; i++) {
      float gridX = x + (w / 10.0) * i;
      line(gridX, y, gridX, y + h);
    }

    // Líneas horizontales
    for (int i = 0; i <= 8; i++) {
      float gridY = y + (h / 8.0) * i;
      line(x, gridY, x + w, gridY);
    }

    // === ÁREA BAJO LA CURVA (INTEGRAL) ===
    // Infectados
    fill(255, 70, 70, 100);  // Más opaco
    noStroke();
    beginShape();
    vertex(x, y + h);
    for (int i = 0; i < infectedHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(infectedHistory.get(i), 0, totalPop, y + h, y);
      vertex(px, py);
    }
    if (infectedHistory.size() > 0) {
      float lastX = map(infectedHistory.size() - 1, 0, maxPoints, x, x + w);
      vertex(lastX, y + h);
    }
    endShape(CLOSE);

    // Muertos
    fill(60, 60, 60, 100);  // Más opaco
    beginShape();
    vertex(x, y + h);
    for (int i = 0; i < deadHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(deadHistory.get(i), 0, totalPop, y + h, y);
      vertex(px, py);
    }
    if (deadHistory.size() > 0) {
      float lastX = map(deadHistory.size() - 1, 0, maxPoints, x, x + w);
      vertex(lastX, y + h);
    }
    endShape(CLOSE);

    // === EJES PRINCIPALES ===
    stroke(60, 60, 70);
    strokeWeight(3);  // Más grueso
    line(x, y + h, x + w, y + h); // eje X
    line(x, y, x, y + h); // eje Y

    // === CURVAS PRINCIPALES MÁS GRUESAS ===
    // Infectados (rojo)
    stroke(230, 30, 30);
    strokeWeight(4);  // Más grueso
    noFill();
    beginShape();
    for (int i = 0; i < infectedHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(infectedHistory.get(i), 0, totalPop, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Muertos (negro)
    stroke(30, 30, 30);
    strokeWeight(4);  // Más grueso
    beginShape();
    for (int i = 0; i < deadHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(deadHistory.get(i), 0, totalPop, y + h, y);
      vertex(px, py);
    }
    endShape();

    // === TÍTULO MÁS GRANDE ===
    fill(20, 30, 40);
    textSize(20);  // Aumentado de 16 a 20
    textAlign(CENTER);
    text("Evolución de la Enfermedad", x + w/2, y - 12);

    // === LABELS DE EJES MÁS GRANDES ===
    textSize(15);  // Aumentado de 12 a 15
    fill(40, 50, 60);
    text("Tiempo (frames)", x + w/2, y + h + 30);

    pushMatrix();
    translate(x - 40, y + h/2);
    rotate(-PI/2);
    text("Población", 0, 0);
    popMatrix();

    // === ESCALA EJE Y MÁS GRANDE ===
    textAlign(RIGHT);
    textSize(13);  // Aumentado de 10 a 13
    fill(40, 50, 60);
    for (int i = 0; i <= 4; i++) {
      float labelValue = (totalPop / 4.0) * i;
      float labelY = y + h - (h / 4.0) * i;
      String label = nf(labelValue / 1000000.0, 0, 1) + "M";
      text(label, x - 8, labelY + 5);
    }

    // === PANEL DE INFORMACIÓN MÁS GRANDE Y VISIBLE ===
    // Fondo panel
    fill(248, 248, 253, 240);
    stroke(90, 90, 100);
    strokeWeight(2);
    rect(x + 12, y + 12, 220, 145, 6);  // Más grande

    // Información
    fill(20, 30, 40);
    textAlign(LEFT);
    textSize(15);  // Aumentado de 11 a 15

    float infectedIntegral = calculateIntegral(infectedHistory);
    float deadIntegral = calculateIntegral(deadHistory);
    float infectedDerivative = calculateDerivative(infectedHistory);
    float deadDerivative = calculateDerivative(deadHistory);

    text("ANÁLISIS MATEMÁTICO", x + 24, y + 32);

    textSize(13);  // Aumentado de 10 a 13
    fill(230, 30, 30);
    text("● f(t) = Infectados", x + 24, y + 52);
    fill(20, 30, 40);
    String infIntStr = nf(infectedIntegral / 1000000.0, 0, 2) + "M";
    text("  ∫ f(t)dt = " + infIntStr, x + 24, y + 70);
    text("  f'(t) = " + nf(infectedDerivative, 0, 0) + "/frame", x + 24, y + 86);

    fill(30, 30, 30);
    text("● g(t) = Muertos", x + 24, y + 107);
    fill(20, 30, 40);
    String deadIntStr = nf(deadIntegral / 1000000.0, 0, 2) + "M";
    text("  ∫ g(t)dt = " + deadIntStr, x + 24, y + 125);
    text("  g'(t) = " + nf(deadDerivative, 0, 0) + "/frame", x + 24, y + 141);

    // === LEYENDA MÁS GRANDE (esquina superior derecha) ===
    fill(255, 255, 255, 230);
    stroke(90, 90, 100);
    strokeWeight(2);
    rect(x + w - 150, y + 12, 138, 65, 6);  // Más grande

    strokeWeight(5);  // Líneas más gruesas
    stroke(230, 30, 30);
    line(x + w - 140, y + 30, x + w - 110, y + 30);
    fill(20, 30, 40);
    textAlign(LEFT);
    textSize(14);  // Aumentado de 11 a 14
    text("Infectados", x + w - 105, y + 35);

    stroke(30, 30, 30);
    line(x + w - 140, y + 55, x + w - 110, y + 55);
    text("Muertos", x + w - 105, y + 60);
  }
}