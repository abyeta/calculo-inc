// Graph.pde - Estilo GeoGebra con ÁREA BAJO LA CURVA DE INFECCIÓN (integral)
class Graph {
  ArrayList<Float> infectedHistory;
  ArrayList<Float> deadHistory;
  ArrayList<Float> cureHistory;
  ArrayList<Float> integralHistory;  // Historial de la integral acumulada de INFECCIÓN
  int maxPoints;

  Graph() {
    infectedHistory = new ArrayList<Float>();
    deadHistory = new ArrayList<Float>();
    cureHistory = new ArrayList<Float>();
    integralHistory = new ArrayList<Float>();  // Integral de INFECCIÓN
    maxPoints = 300;
  }

  void addData(float infected, float dead, float cure) {
    infectedHistory.add(infected);
    deadHistory.add(dead);
    cureHistory.add(cure);
    
    // Calcular integral acumulada de la INFECCIÓN (área bajo la curva)
    float currentIntegral = calculateIntegral(infectedHistory);
    integralHistory.add(currentIntegral);

    if (infectedHistory.size() > maxPoints) {
      infectedHistory.remove(0);
      deadHistory.remove(0);
      cureHistory.remove(0);
      integralHistory.remove(0);
    }
  }

  float calculateIntegral(ArrayList<Float> data) {
    if (data.size() < 2) return 0;
    float area = 0;
    for (int i = 0; i < data.size() - 1; i++) {
      float y1 = data.get(i);
      float y2 = data.get(i + 1);
      // Método del trapecio para aproximar integral: Área = ((y1 + y2)/2) * base
      float base = 1; // Cada punto representa un intervalo de tiempo igual
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
    text("Evolución (%) - Muertes, Infección y Cura", x + w/2, y - 10);

    // ===== ÁREA BAJO LA CURVA DE INFECCIÓN (INTEGRAL) =====
    // Esto muestra la aplicación de integrales - área acumulada de INFECCIÓN
    fill(255, 100, 100, 120);  // Rojo semitransparente
    noStroke();
    beginShape();
    
    // Empezar en esquina inferior izquierda
    vertex(x, y + h);
    
    // Dibujar el área bajo la curva de INFECCIÓN
    if (infectedHistory.size() > 0 && integralHistory.size() > 0) {
      // Normalizar la integral para que se ajuste al gráfico
      // Encontrar el valor máximo de la integral para escalar
      float maxIntegral = 0;
      for (Float val : integralHistory) {
        if (val > maxIntegral) maxIntegral = val;
      }
      
      // Si no hay datos aún, evitar división por cero
      if (maxIntegral == 0) maxIntegral = 1;
      
      // Dibujar el área (integral normalizada de INFECCIÓN)
      for (int i = 0; i < integralHistory.size(); i++) {
        float px = map(i, 0, maxPoints, x, x + w);
        // Mapear la integral normalizada a la altura del gráfico
        float normalizedValue = integralHistory.get(i) / maxIntegral;
        float py = map(normalizedValue, 0, 1, y + h, y);
        vertex(px, py);
      }
      
      // Cerrar el área en la esquina inferior derecha
      float lastX = map(min(integralHistory.size(), maxPoints) - 1, 0, maxPoints, x, x + w);
      vertex(lastX, y + h);
    }
    
    // Volver al punto de inicio
    vertex(x, y + h);
    endShape(CLOSE);

    // Línea de infección - naranja (porcentaje ACTUAL de infección)
    stroke(255, 100, 0);
    strokeWeight(2);
    noFill();
    beginShape();
    for (int i = 0; i < infectedHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(infectedHistory.get(i), 0, 100, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Línea de cura - azul (avance en porcentaje)
    stroke(0, 150, 255);
    strokeWeight(2);
    noFill();
    beginShape();
    for (int i = 0; i < cureHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(cureHistory.get(i), 0, 100, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Línea de muertes - negra
    stroke(0, 0, 0);
    strokeWeight(3);
    noFill();
    beginShape();
    for (int i = 0; i < deadHistory.size(); i++) {
      float px = map(i, 0, maxPoints, x, x + w);
      float py = map(deadHistory.get(i), 0, 100, y + h, y);
      vertex(px, py);
    }
    endShape();

    // Mostrar valor actual de la integral (área acumulada de INFECCIÓN)
    if (integralHistory.size() > 0) {
      float currentIntegral = integralHistory.get(integralHistory.size() - 1);
      textSize(10);
      textAlign(RIGHT);
      fill(200, 0, 0);
      text("∫infección dt: " + nf(currentIntegral, 0, 1), x + w - 10, y + 20);
    }

    // Etiquetas explicativas
    textSize(12);
    textAlign(LEFT);
    fill(0, 0, 0);
    text("Negro: muertes (% actual)", x + 20, y + 30);
    text("Naranja: infección (% actual)", x + 20, y + 50);
    text("Azul: cura (% actual)", x + 20, y + 70);
    textSize(10);
    text("Fondo rojo: ∫infección dt (área bajo curva)", x + 20, y + 90);
    
    // Explicación matemática (para el proyecto)
    textSize(9);
    text("Área = ∑[(infecciónᵢ + infecciónᵢ₊₁)/2 × Δt]", x + 20, y + 110);
  }

  float cureProgress = 0;
  void setCureProgress(float cp) { cureProgress = cp; }
}
