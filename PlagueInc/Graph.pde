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
  fill(250, 250, 255);
  noStroke();
  rect(x, y, w, h);

  stroke(100);
  strokeWeight(2);
  noFill();
  rect(x, y, w, h);

  textSize(16);
  textAlign(CENTER);
  fill(0);
  text("Evolución de Muertes (%) - Con Líneas Constantes", x + w/2, y - 10);
  

  // Dibujar líneas horizontales para valores constantes
  stroke(20, 20, 20);
  strokeWeight(2);  // Grosor para que se vea
  for (int i = 1; i < deadHistory.size(); i++) {
    if (abs(deadHistory.get(i) - deadHistory.get(i-1)) < 0.01) {  // Si prácticamente constante (tolerancia pequeña)
      float yLevel = map(deadHistory.get(i), 0, 100, y + h, y);
      float x1 = map(i-1, 0, maxPoints, x, x + w);
      float x2 = map(i, 0, maxPoints, x, x + w);
      line(x1, yLevel, x2, yLevel);  // Línea horizontal
    }
  }

  // Línea principal (conectando todos los puntos)
  stroke(20, 20, 20);
  strokeWeight(3);
  noFill();
  beginShape();
  for (int i = 0; i < deadHistory.size(); i++) {
    float px = map(i, 0, maxPoints, x, x + w);
    float py = map(deadHistory.get(i), 0, 100, y + h, y);
    vertex(px, py);
  }
  endShape();

  // Onditas (derivadas) - igual que antes
  ArrayList<Float> deathDerivatives = new ArrayList<Float>();
  for (int i = 1; i < deadHistory.size(); i++) {
    float dPerc = deadHistory.get(i) - deadHistory.get(i-1);
    deathDerivatives.add(dPerc);
  }

  // Área bajo la curva
  fill(255, 50, 50, 80);
  noStroke();
  beginShape();
  vertex(x, y + h);
  for (int i = 0; i < deathDerivatives.size(); i++) {
    float px = map(i, 0, maxPoints, x, x + w);
    float py = map(deathDerivatives.get(i), -0.5, 0.5, y + h, y);
    vertex(px, py);
  }
  if (deathDerivatives.size() > 0) {
    float lastX = map(deathDerivatives.size() - 1, 0, maxPoints, x, x + w);
    vertex(lastX, y + h);
  }
  endShape(CLOSE);

  // Línea de derivada
  stroke(255, 100, 0);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i < deathDerivatives.size(); i++) {
    float px = map(i, 0, maxPoints, x, x + w);
    float py = map(deathDerivatives.get(i), -0.5, 0.5, y + h, y);
    vertex(px, py);
  }
  endShape();

  // Etiquetas
  textSize(12);
  textAlign(LEFT);
  fill(20, 20, 20);
  text("● % Muertes (líneas constantes)", x + 20, y + 30);
  fill(255, 100, 0);
  text("● d%/dt (Onditas)", x + 20, y + 50);
  textSize(10);
  text("Líneas horizontales = valores constantes", x + 20, y + 70);
}
float cureProgress = 0;
void setCureProgress(float cp) { cureProgress = cp; }
}
