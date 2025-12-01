// Graph.pde - Estilo GeoGebra
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
    fill(250, 250, 255);
    noStroke();
    rect(x, y, w, h);

    // Borde
    stroke(100);
    strokeWeight(2);
    noFill();
    rect(x, y, w, h);

    // === GRILLA ESTILO GEOGEBRA ===
    stroke(220, 220, 230);
    strokeWeight(1);

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
    fill(255, 50, 50, 80);
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
    fill(50, 50, 50, 80);
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
    stroke(80);
    strokeWeight(2);
    line(x, y + h, x + w, y + h); // eje X
    line(x, y, x, y + h); // eje Y

    // === CURVAS PRINCIPALES ===
    // Infectados (rojo)
    stroke(220, 20, 20);
    strokeWeight(3);
    noFill();
    beginShape();
    for (int i = 0; i < infectedHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(infectedHistory.get(i), 0, totalPop, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Muertos (negro)
    stroke(20, 20, 20);
    strokeWeight(3);
    beginShape();
    for (int i = 0; i < deadHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(deadHistory.get(i), 0, totalPop, y + h, y);
      vertex(px, py);
    }
    endShape();

    // === TÍTULO ===
    fill(0);
    textSize(16);
    textAlign(CENTER);
    text("Evolución de la Enfermedad", x + w/2, y - 10);

    // === LABELS DE EJES ===
    textSize(12);
    text("Tiempo (frames)", x + w/2, y + h + 25);

    pushMatrix();
    translate(x - 35, y + h/2);
    rotate(-PI/2);
    text("Población", 0, 0);
    popMatrix();

    // === ESCALA EJE Y ===
    textAlign(RIGHT);
    textSize(10);
    for (int i = 0; i <= 4; i++) {
      float labelValue = (totalPop / 4.0) * i;
      float labelY = y + h - (h / 4.0) * i;
      String label = nf(labelValue / 1000000.0, 0, 1) + "M";
      fill(60);
      text(label, x - 5, labelY + 4);
    }

    // === PANEL DE INFORMACIÓN (estilo GeoGebra) ===
    // Fondo panel
    fill(245, 245, 250, 230);
    stroke(100);
    strokeWeight(1);
    rect(x + 10, y + 10, 180, 120);

    // Información
    fill(0);
    textAlign(LEFT);
    textSize(11);

    float infectedIntegral = calculateIntegral(infectedHistory);
    float deadIntegral = calculateIntegral(deadHistory);
    float infectedDerivative = calculateDerivative(infectedHistory);
    float deadDerivative = calculateDerivative(deadHistory);

    text("ANÁLISIS MATEMÁTICO", x + 20, y + 28);

    textSize(10);
    fill(220, 20, 20);
    text("● f(t) = Infectados", x + 20, y + 45);
    fill(0);
    String infIntStr = nf(infectedIntegral / 1000000.0, 0, 2) + "M";
    text("  ∫ f(t)dt = " + infIntStr, x + 20, y + 60);
    text("  f'(t) = " + nf(infectedDerivative, 0, 0) + "/frame", x + 20, y + 73);

    fill(20, 20, 20);
    text("● g(t) = Muertos", x + 20, y + 90);
    fill(0);
    String deadIntStr = nf(deadIntegral / 1000000.0, 0, 2) + "M";
    text("  ∫ g(t)dt = " + deadIntStr, x + 20, y + 105);
    text("  g'(t) = " + nf(deadDerivative, 0, 0) + "/frame", x + 20, y + 118);

    // === LEYENDA (esquina superior derecha) ===
    fill(255, 255, 255, 200);
    rect(x + w - 130, y + 10, 120, 50);

    strokeWeight(3);
    stroke(220, 20, 20);
    line(x + w - 120, y + 25, x + w - 95, y + 25);
    fill(0);
    textAlign(LEFT);
    textSize(11);
    text("Infectados", x + w - 90, y + 28);

    stroke(20, 20, 20);
    line(x + w - 120, y + 45, x + w - 95, y + 45);
    text("Muertos", x + w - 90, y + 48);
  }
}