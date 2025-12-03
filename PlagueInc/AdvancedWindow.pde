import processing.core.PApplet;
import processing.core.PVector;
import java.util.ArrayList;

public class AdvancedWindow extends PApplet {
  ArrayList<Float> infectedHistory;
  ArrayList<Float> deadHistory;
  ArrayList<Float> timeHistory;
  int maxPoints = 200;
  AdvancedMathGraph graph;

  float rotationX = -PI/6;
  float rotationY = PI/4;
  boolean isDragging = false;
  int lastMouseX, lastMouseY;

  public AdvancedWindow(ArrayList<Float> infHist, ArrayList<Float> deadHist) {
    this.infectedHistory = infHist;
    this.deadHistory = deadHist;
    this.timeHistory = new ArrayList<Float>();
    this.graph = new AdvancedMathGraph();
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

  float calculateDoubleIntegral() {
    if (infectedHistory.size() < 2) return 0;
    float volume = 0;
    int n = infectedHistory.size();
    for (int i = 0; i < n - 1; i++) {
      float dx = 1.0;
      float dy1 = infectedHistory.get(i);
      float dy2 = infectedHistory.get(i + 1);
      float dz1 = deadHistory.get(i);
      float dz2 = deadHistory.get(i + 1);
      volume += dx * ((dy1 + dy2) / 2.0) * ((dz1 + dz2) / 2.0) / 1000000.0;
    }
    return volume;
  }

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
      float avgInfected = (infected1 + infected2 + infected3) / 3.0;
      float avgDead = (dead1 + dead2 + dead3) / 3.0;
      totalVolume += dt * avgInfected * avgDead / 1000000000000.0;
    }
    return totalVolume;
  }

  PVector calculatePartialDerivatives() {
    if (infectedHistory.size() < 2) return new PVector(0, 0);
    int n = infectedHistory.size();
    float dI_dt = infectedHistory.get(n-1) - infectedHistory.get(n-2);
    float dD_dt = deadHistory.get(n-1) - deadHistory.get(n-2);
    return new PVector(dI_dt, dD_dt);
  }

  PVector calculateGradient() {
    PVector partials = calculatePartialDerivatives();
    float magnitude = PApplet.sqrt(partials.x * partials.x + partials.y * partials.y);
    return new PVector(partials.x, partials.y, magnitude);
  }

  float calculateLimit(ArrayList<Float> data) {
    if (data.size() < 10) return 0;
    float sum = 0;
    int start = PApplet.max(0, data.size() - 10);
    for (int i = start; i < data.size(); i++) {
      sum += data.get(i);
    }
    return sum / (data.size() - start);
  }

  void display(PApplet pg, int x, int y, int w, int h) {
    int totalPop = 10000000;

    // FONDO GENERAL
    pg.fill(248, 248, 252);
    pg.noStroke();
    pg.rect(0, 0, w, h);

    // TÍTULO
    pg.fill(30, 40, 60);  // Más oscuro
    pg.textAlign(PApplet.CENTER);
    pg.textSize(22);  // Aumentado de 20 a 22
    pg.text("Análisis Matemático 3D", w/2, 30);
    pg.textSize(12);
    pg.fill(100, 110, 130);
    pg.text("Arrastra para rotar la gráfica", w/2, 48);

    // ÁREA PARA GRÁFICA 3D CON FONDO ESTILO GEOGEBRA
    int graphX = 20;
    int graphY = 65;  // Ajustado para el nuevo título
    int graphW = w - 270;
    int graphH = h - 225;

    // Fondo blanco para gráfica
    pg.noStroke();
    pg.fill(255, 255, 255);
    pg.rect(graphX, graphY, graphW, graphH);

    // Borde gris suave
    pg.stroke(200, 200, 210);
    pg.strokeWeight(2);
    pg.noFill();
    pg.rect(graphX, graphY, graphW, graphH);

    // Grid de fondo estilo GeoGebra
    pg.stroke(240, 240, 245);
    pg.strokeWeight(1);
    for (int i = 1; i < 10; i++) {
      float gx = graphX + (graphW / 10.0f) * i;
      pg.line(gx, graphY, gx, graphY + graphH);
      float gy = graphY + (graphH / 10.0f) * i;
      pg.line(graphX, gy, graphX + graphW, gy);
    }

    pg.pushMatrix();
    pg.translate(graphX + graphW/2, graphY + graphH/2);
    pg.rotateX(rotationX);
    pg.rotateY(rotationY);

    // EJES 3D
    pg.strokeWeight(2);
    pg.stroke(70, 130, 220);
    pg.line(-graphW/3, 0, 0, graphW/3, 0, 0);
    pg.stroke(220, 70, 70);
    pg.line(0, -graphH/3, 0, 0, graphH/3, 0);
    pg.stroke(80, 80, 80);
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

        float progress = (float)i / infectedHistory.size();
        pg.stroke(255 * (1-progress), 80, 255 * progress, 120);
        pg.strokeWeight(2);

        pg.beginShape(PApplet.QUAD_STRIP);
        pg.fill(255, 120, 120, 70);
        pg.vertex(t1, inf1, 0);
        pg.vertex(t1, inf1, dead1);
        pg.vertex(t2, inf2, 0);
        pg.vertex(t2, inf2, dead2);
        pg.endShape();

        pg.strokeWeight(2.5f);
        pg.stroke(220, 50, 50);
        pg.line(t1, inf1, dead1, t2, inf2, dead2);
      }
    }
    pg.popMatrix();

    // ==========================================
    // PANEL LATERAL MEJORADO - ESTILO COHERENTE
    // ==========================================
    int panelX = w - 250;
    int panelY = 65;  // Ajustado
    int panelW = 230;
    int panelH = h - 85;  // Ajustado

    // Fondo del panel gris claro
    pg.noStroke();
    pg.fill(245, 247, 250);
    pg.rect(panelX, panelY, panelW, panelH, 8);

    // Borde suave
    pg.stroke(200, 205, 215);
    pg.strokeWeight(2);
    pg.noFill();
    pg.rect(panelX, panelY, panelW, panelH, 8);

    // TÍTULO DEL PANEL
    pg.noStroke();
    pg.fill(50, 65, 100);  // Más oscuro
    pg.rect(panelX, panelY, panelW, 58, 8, 8, 0, 0);  // Más alto
    pg.fill(255);
    pg.textAlign(PApplet.CENTER);
    pg.textSize(20);  // Aumentado de 18 a 20
    pg.text("CÁLCULO", panelX + panelW/2, panelY + 25);
    pg.textSize(20);
    pg.text("AVANZADO", panelX + panelW/2, panelY + 46);

    pg.textAlign(PApplet.LEFT);
    int lineY = panelY + 78;
    int lineSpacing = 82;

    // ===== INTEGRAL DOBLE =====
    pg.noStroke();
    pg.fill(220, 235, 255);
    pg.rect(panelX + 8, lineY - 10, panelW - 16, 72, 6);
    pg.strokeWeight(3);
    pg.stroke(70, 130, 220);
    pg.line(panelX + 12, lineY - 8, panelX + 12, lineY + 59);

    pg.noStroke();
    pg.fill(50, 100, 180);  // Más oscuro
    pg.textSize(19);  // Aumentado de 17 a 19
    pg.text("∬ f(x,y) dA", panelX + 22, lineY + 8);

    pg.fill(25, 35, 45);  // Más oscuro
    pg.textSize(16);  // Aumentado de 15 a 16
    float doubleInt = calculateDoubleIntegral();
    pg.text("Vol: " + PApplet.nf(doubleInt, 0, 3) + " M²", panelX + 22, lineY + 30);

    pg.textSize(13);  // Aumentado de 12 a 13
    pg.fill(70, 80, 90);  // Más oscuro
    pg.text("Área bajo superficie", panelX + 22, lineY + 48);

    // ===== INTEGRAL TRIPLE =====
    lineY += lineSpacing;
    pg.fill(255, 230, 245);
    pg.rect(panelX + 8, lineY - 10, panelW - 16, 72, 6);
    pg.strokeWeight(3);
    pg.stroke(200, 80, 160);
    pg.line(panelX + 12, lineY - 8, panelX + 12, lineY + 59);

    pg.noStroke();
    pg.fill(170, 50, 130);  // Más oscuro
    pg.textSize(19);
    pg.text("∭ ρ(x,y,z) dV", panelX + 22, lineY + 8);

    pg.fill(25, 35, 45);
    pg.textSize(16);
    float tripleInt = calculateTripleIntegral();
    pg.text("Vol: " + PApplet.nf(tripleInt, 0, 6), panelX + 22, lineY + 30);

    pg.textSize(13);
    pg.fill(70, 80, 90);
    pg.text("Densidad 3D", panelX + 22, lineY + 48);

    // ===== DERIVADAS PARCIALES =====
    lineY += lineSpacing;
    pg.fill(255, 240, 220);
    pg.rect(panelX + 8, lineY - 10, panelW - 16, 72, 6);
    pg.strokeWeight(3);
    pg.stroke(240, 140, 60);
    pg.line(panelX + 12, lineY - 8, panelX + 12, lineY + 59);

    pg.noStroke();
    pg.fill(200, 110, 30);  // Más oscuro
    pg.textSize(18);  // Aumentado de 16 a 18
    pg.text("Derivadas Parciales", panelX + 22, lineY + 8);

    PVector partials = calculatePartialDerivatives();
    pg.fill(25, 35, 45);
    pg.textSize(15);  // Aumentado de 14 a 15
    pg.text("∂I/∂t = " + PApplet.nf(partials.x, 0, 0), panelX + 22, lineY + 30);
    pg.text("∂D/∂t = " + PApplet.nf(partials.y, 0, 0), panelX + 22, lineY + 48);

    // ===== GRADIENTE =====
    lineY += lineSpacing;
    pg.fill(230, 250, 235);
    pg.rect(panelX + 8, lineY - 10, panelW - 16, 72, 6);
    pg.strokeWeight(3);
    pg.stroke(60, 180, 100);
    pg.line(panelX + 12, lineY - 8, panelX + 12, lineY + 59);

    pg.noStroke();
    pg.fill(40, 140, 70);  // Más oscuro
    pg.textSize(19);
    pg.text("Gradiente ∇f", panelX + 22, lineY + 8);

    PVector grad = calculateGradient();
    pg.fill(25, 35, 45);
    pg.textSize(16);
    pg.text("|∇f| = " + PApplet.nf(grad.z, 0, 1), panelX + 22, lineY + 30);

    pg.textSize(13);
    pg.fill(70, 80, 90);
    pg.text("Máximo cambio", panelX + 22, lineY + 48);

    // ===== LÍMITES =====
    lineY += lineSpacing;
    pg.fill(240, 230, 250);
    pg.rect(panelX + 8, lineY - 10, panelW - 16, 72, 6);
    pg.strokeWeight(3);
    pg.stroke(140, 80, 200);
    pg.line(panelX + 12, lineY - 8, panelX + 12, lineY + 59);

    pg.noStroke();
    pg.fill(110, 50, 160);  // Más oscuro
    pg.textSize(19);
    pg.text("Límites", panelX + 22, lineY + 8);

    float limInf = calculateLimit(infectedHistory);
    float limDead = calculateLimit(deadHistory);
    pg.fill(25, 35, 45);
    pg.textSize(15);
    pg.text("lim I(t) = " + PApplet.nf(limInf/1000000, 0, 2) + "M", panelX + 22, lineY + 30);
    pg.text("lim D(t) = " + PApplet.nf(limDead/1000000, 0, 2) + "M", panelX + 22, lineY + 48);

    // LEYENDA DE EJES
    lineY += lineSpacing + 8;
    pg.textSize(17);  // Aumentado de 15 a 17
    pg.fill(25, 35, 45);  // Mucho más oscuro

    pg.strokeWeight(6);  // Líneas más gruesas (de 5 a 6)
    pg.stroke(70, 130, 220);
    pg.line(panelX + 18, lineY, panelX + 48, lineY);
    pg.noStroke();
    pg.text("Tiempo", panelX + 56, lineY + 6);

    lineY += 26;  // Mayor espaciado
    pg.stroke(220, 70, 70);
    pg.line(panelX + 18, lineY, panelX + 48, lineY);
    pg.noStroke();
    pg.text("Infectados", panelX + 56, lineY + 6);

    lineY += 26;
    pg.stroke(80, 80, 80);
    pg.line(panelX + 18, lineY, panelX + 48, lineY);
    pg.noStroke();
    pg.text("Muertos", panelX + 56, lineY + 6);

    // ECUACIONES EN LA PARTE INFERIOR - ULTRA VISIBLE
    int bottomY = h - 158;

    // Fondo blanco con borde
    pg.fill(255);
    pg.rect(20, bottomY, w - 270, 138, 6);
    pg.stroke(180, 185, 195);  // Borde más oscuro
    pg.strokeWeight(3);  // Borde más grueso
    pg.noFill();
    pg.rect(20, bottomY, w - 270, 138, 6);

    // Título de la sección MÁS GRANDE Y OSCURO
    pg.noStroke();
    pg.fill(35, 50, 80);  // Más oscuro
    pg.rect(20, bottomY, w - 270, 40, 6, 6, 0, 0);  // Header más alto
    pg.fill(255);
    pg.textAlign(PApplet.LEFT);
    pg.textSize(19);  // Aumentado de 18 a 19
    pg.text("Ecuaciones del Sistema", 32, bottomY + 27);

    // Ecuaciones MÁS GRANDES Y MÁS OSCURAS
    pg.fill(10, 20, 30);  // Casi negro
    pg.textSize(16);  // Aumentado de 15 a 16
    pg.text("dI/dt = β·I·(N-I-D)/N  (Tasa de infección)", 32, bottomY + 58);
    pg.text("dD/dt = γ·I  (Tasa de mortalidad)", 32, bottomY + 79);

    pg.textSize(15);  // Aumentado de 14 a 15
    pg.fill(50, 60, 70);  // Más oscuro
    pg.text("Volumen bajo superficie: ∬∬ I(t,D) dt dD", 32, bottomY + 102);
    pg.text("Densidad espacial: ∭∭∭ ρ(x,y,t) dx dy dt", 32, bottomY + 121);
    pg.text("Campo vectorial: F(t) = (∂I/∂t, ∂D/∂t)", 32, bottomY + 140);
  }

  public void settings() {
    size(900, 750, P3D);
  }

  public void setup() {
  }

  public void draw() {
    background(245, 248, 250);
    if (!infectedHistory.isEmpty() && !deadHistory.isEmpty()) {
      addData(infectedHistory.get(infectedHistory.size()-1), deadHistory.get(deadHistory.size()-1));
    }
    display(this, 0, 0, 900, 750);
  }

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

  public void exit() {
    dispose();
  }
}