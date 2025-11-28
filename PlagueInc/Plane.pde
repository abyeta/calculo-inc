class Plane {
  float angle;
  City from;
  City dest;
  boolean isDiseased;
  float x;
  float y;
  PImage planeImg;

  Plane(float x, float y, City from, City dest, boolean isDiseased) {
    this.from = from;
    this.dest = dest;
    this.x = x;
    this.y = y;
    this.isDiseased = isDiseased;
    if (!isDiseased) {
      planeImg = from.planeImg1;
    } else {
      planeImg = from.planeImg2;
    }
    setAngle();
  }

  void setAngle() {
    float dx = Math.abs(dest.x - from.x);
    float dy = Math.abs(dest.y - from.y);
    float theta = atan(dy / dx);
    angle = 0;
    if (dest.x > from.x && dest.y > from.y) {
      angle = PI - theta;
    } else if (dest.x > from.x && dest.y < from.y) {
      angle = (PI/2) - theta;
    } else if (dest.x < from.x && dest.y > from.y) {
      angle = PI + theta;
    } else if (dest.x < from.x && dest.y < from.y) {
      angle = (3*PI / 2) + theta;
    }
  }

  void send() {
    x += (dest.x - from.x)/100;
    y += (dest.y - from.y)/100;
    image(planeImg, x, y, 50, 50);
  }
}  
