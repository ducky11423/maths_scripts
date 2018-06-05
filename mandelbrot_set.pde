double top = 1;
double bottom = -1;
double left = -2;
double right = 1;

void setup(){
  size(1920, 1080);
  frameRate(60);
  
  draw();
}

void draw(){
  background(255);
  
  zoom(0.78, mouseX, mouseY);
  
  loadPixels();
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      double re = map((double)i, 0, width, left, right);
      double im = map((double)j, 0, height, top, bottom);
      
      int loops = checkInSet(re, im);
      pixels[i+j*width] = lerpColor(color(0, 0, 255), color(255), norm(loops, 0, 1000));
      if(loops == 1000) pixels[i + j * width] = color(0);
      
      
    }
  }
  updatePixels();
  
  fill(0, 102, 153);
  text(frameRate, 20, 20);
  
}

void zoom(double a, double x, double y){
  double w = right - left;
  double h = top - bottom;
  
  double newW = w * a;
  double newH = h * a;
  
  double xNorm = norm(x, 0, width);
  double yNorm = norm(y, 0, height);
  
  double xPos = lerp(xNorm, left, right);
  double yPos = lerp(yNorm, top, bottom);
  
  double leftOffset = xNorm * newW;
  double topOffset = yNorm * newH;

  
  left = xPos - leftOffset;
  top = yPos + topOffset;
  
  right = left + newW;
  bottom = top - newH;
  
}

int checkInSet(double re, double im){
  double r = 0;
  double i = 0;
  
  int count = 0;
  
  while(r * r + i * i < 4 && count < 1000){
    double tempr = r * r - (i * i);
    double tempi = 2 * r * i;
    
    r = tempr + re;
    i = tempi + im;
    count++;
  }
  
  return count;
}

double norm(double a, double b, double c){
  return (a - b) / (c - b);
}

double lerp(double a, double b, double c){
  return (c - b) * a + b;
}

double map(double a, double b, double c, double d, double e){
  return lerp(norm(a, b, c), d, e);
}