// StatsGraph.pde - Gráfica de Infectivity, Severity, Lethality
class StatsGraph {
  ArrayList<Float> infectivityHistory;
  ArrayList<Float> severityHistory;
  ArrayList<Float> lethalityHistory;
  ArrayList<Float> integralInfectivity;
  int maxPoints;

  StatsGraph() {
    infectivityHistory = new ArrayList<Float>();
    severityHistory = new ArrayList<Float>();
    lethalityHistory = new ArrayList<Float>();
    integralInfectivity = new ArrayList<Float>();
    maxPoints = 300;
  }

  void addData(float infectivity, float severity, float lethality) {
    infectivityHistory.add(infectivity * 10000 / 2.0);
    severityHistory.add(severity * 10000 / 2.0);
    lethalityHistory.add(lethality * 10000 / 2.0);

    float currentIntegral = calculateIntegral(infectivityHistory);
    integralInfectivity.add(currentIntegral);

    if (infectivityHistory.size() > maxPoints) {
      infectivityHistory.remove(0);
      severityHistory.remove(0);
      lethalityHistory.remove(0);
      integralInfectivity.remove(0);
    }
  }

  float calculateIntegral(ArrayList<Float> data) {
    if (data.size() < 2) return 0;
    float area = 0;
    for (int i = 0; i < data.size() - 1; i++) {
      float y1 = data.get(i);
      float y2 = data.get(i + 1);
      float base = 1;
      area += ((y1 + y2) / 2.0) * base;
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
    // Fondo
    fill(250, 250, 255);
    noStroke();
    rect(x, y, w, h);

    textSize(20);
    textAlign(CENTER);
    fill(0);
    text("Evolución de Estadísticas de la Enfermedad", x + w/2, y - 15);

    // ===== ÁREA BAJO LA CURVA (ROSADO) =====
    fill(255, 100, 200, 100);
    noStroke();
    beginShape();
    vertex(x, y + h);

    if (infectivityHistory.size() > 0 && integralInfectivity.size() > 0) {
      float maxIntegral = 0;
      for (Float val : integralInfectivity) {
        if (val > maxIntegral) maxIntegral = val;
      }
      if (maxIntegral == 0) maxIntegral = 1;

      for (int i = 0; i < integralInfectivity.size(); i++) {
        float px = map(i, 0, maxPoints, x, x + w);
        float normalizedValue = integralInfectivity.get(i) / maxIntegral;
        float py = map(normalizedValue, 0, 1, y + h, y);
        vertex(px, py);
      }
      float lastX = map(min(integralInfectivity.size(), maxPoints) - 1, 0, maxPoints, x, x + w);
      vertex(lastX, y + h);
    }
    vertex(x, y + h);
    endShape(CLOSE);

    // Línea de Infectivity - ROSADO
    stroke(255, 50, 150);
    strokeWeight(3);
    noFill();
    beginShape();
    for (int i = 0; i < infectivityHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(infectivityHistory.get(i), 0, 100, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Línea de Severity - TURQUESA
    stroke(0, 200, 220);
    strokeWeight(2.5);
    noFill();
    beginShape();
    for (int i = 0; i < severityHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(severityHistory.get(i), 0, 100, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Línea de Lethality - MORADO
    stroke(150, 50, 200);
    strokeWeight(3);
    noFill();
    beginShape();
    for (int i = 0; i < lethalityHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(lethalityHistory.get(i), 0, 100, y + h, y);
      vertex(px, py);
    }
    endShape();

    textSize(14);
    textAlign(LEFT);

    fill(0);
    text("Rosado: Infectivity (" + (infectivityHistory.size() > 0 ? nf(infectivityHistory.get(infectivityHistory.size()-1), 0, 1) : "0") + "%)", x + 20, y + 30);

    fill(0);
    text("Turquesa: Severity (" + (severityHistory.size() > 0 ? nf(severityHistory.get(severityHistory.size()-1), 0, 1) : "0") + "%)", x + 20, y + 50);

    fill(0);
    text("Morado: Lethality (" + (lethalityHistory.size() > 0 ? nf(lethalityHistory.get(lethalityHistory.size()-1), 0, 1) : "0") + "%)", x + 20, y + 70);

    // Valor de la integral
    if (integralInfectivity.size() > 0) {
      float currentIntegral = integralInfectivity.get(integralInfectivity.size() - 1);
      textSize(12);
      textAlign(RIGHT);
      fill(0);
      text("∫infectivity dt: " + nf(currentIntegral, 0, 1), x + w - 10, y + 25);
    }

    // Fondo rosado
    textSize(12);
    textAlign(LEFT);
    fill(0);
    text("Fondo rosado: ∫infectivity dt (área bajo curva)", x + 20, y + 95);

    // Fórmula matemática
    textSize(11);
    fill(0);
    text("Área = ∑[(infectivityᵢ + infectivityᵢ₊₁)/2 × Δt]", x + 20, y + 115);

    // TASAS DE CAMBIO
    textSize(13);
    fill(0);
    text("Tasas de cambio:", x + 20, y + 140);

    if (infectivityHistory.size() > 1) {
      float dInf = calculateDerivative(infectivityHistory);
      float dSev = calculateDerivative(severityHistory);
      float dLet = calculateDerivative(lethalityHistory);

      textSize(12);
      fill(0);
      text("dInf/dt = " + nf(dInf, 0, 3) + "/frame", x + 20, y + 160);
      fill(0);
      text("dSev/dt = " + nf(dSev, 0, 3) + "/frame", x + 20, y + 180);
      fill(0);
      text("dLet/dt = " + nf(dLet, 0, 3) + "/frame", x + 20, y + 200);
    }
  }
}