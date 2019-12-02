MyFontTexture mft;
ArrayList<GlitchLetter> letters = new ArrayList<GlitchLetter>();
int spaceWidth = 20;
int leftMargin = 50;
float yOff;
int nLines;
float corruptionLevel = 0.0f;

int numText = 0;
String textDir;
File[] textFiles;


void settings() {
  System.setProperty("jogl.disable.openglcore", "false");
  size(800, 600, P2D);
  //fullScreen(P2D);
}


void setup() {
  //size(800, 600, P2D);
  //frameRate(12);
  textureMode(IMAGE);
  
  PFont font = loadFont("LiberationMono-36.vlw");
  mft = new MyFontTexture(font);
  
  textDir = dataPath("texts");
  textFiles = listFiles(textDir);

  char[] text = readFile(textFiles[numText].getPath());
  mft.processText(text);
  buildText(text);

  yOff = -height;
  noStroke();
  background(127);
  fill(0, 160);
  
  // Lance la corruption du texte actuelle dans un autre processus (Python)
  textCorrupt(textFiles[numText].getPath(), dataPath("corrupt.txt"));
}


void draw() {
  //background(0);
  fill(0, 0, 255, 200);
  rect(0, 0, width, height);
  yOff += 4 + (int) corruptionLevel*0.1;
  if (yOff>nLines*mft.getFontSize()+10) {
    yOff=-height;    
    corruptionLevel += 1.4f;
    
    if (corruptionLevel > 10.0) {
      //println(corruptionLevel);
      corruptionLevel = 0.0f;
      numText += 1;
      if (numText == textFiles.length)
        numText = 0;
      
      char[] text = readFile(textFiles[numText].getPath());
      mft.processText(text);
      letters.clear();
      buildText(text);
      
      textCorrupt(textFiles[numText].getPath(), dataPath("corrupt.txt"));
    } else {
      char[] text = readFile(dataPath("corrupt.txt"));
      mft.processText(text);
      letters.clear();
      buildText(text);
      
      textCorrupt(dataPath("corrupt.txt"), dataPath("corrupt.txt"));
    }
  }
  
  pushMatrix();
  if (random(1.0) < 0.01*corruptionLevel) {
    translate(random(-corruptionLevel+1, corruptionLevel+1),
      random(-corruptionLevel+1, corruptionLevel+1)-yOff);
  } else {
    translate(0.0, -yOff);
  }
  for (int i=0; i<letters.size(); i++) {
    letters.get(i).render();
  }
  popMatrix();
  
  // Screen glitches
  if (random(1.0)<0.01*corruptionLevel) {
    pixelateScreen((int) random(2, constrain(corruptionLevel, 4, 64)));
  }
  if (random(1.0)<0.01*corruptionLevel) {
    glitchScreen((int) random(1, corruptionLevel));
  }
  if (random(1.0)<0.025*corruptionLevel) {
    rbGlitch((int) random(1, corruptionLevel));
  }
  //image(mft.fontTexture, 0, 0);
}


void buildText(char[] text) {
  PVector letterPosition = new PVector(leftMargin, 10);
  for (int i=0; i<text.length; i++) {
    char letter = text[i];
    if (letter == ' ') {
      letterPosition.x += spaceWidth;
    } else if (letter == '\n') {
      letterPosition.x = leftMargin;
      letterPosition.y += mft.getFontSize();
    } else {
      letters.add(new GlitchLetter(letterPosition, letter, mft));
      letterPosition.x += mft.getCharWidth(letter)+2;
    }
    if (i<text.length-1) {
      // Check next letter width
      char nextLetter = text[i+1];
      int nextLetterWidth = 0;
      if (nextLetter == ' ' || nextLetter == '\n') {
        nextLetterWidth = spaceWidth;
      } else {
        nextLetterWidth = mft.getCharWidth(nextLetter);
      }
      if (letterPosition.x+nextLetterWidth >= width-10) {
        letterPosition.x = leftMargin;
        letterPosition.y += mft.getFontSize();
      }
    }
  }
}


void glitchScreen(int n) {
  loadPixels();
  for (int i=0; i<n; i++) {
    int x0 = (int) random(width);
    int y0 = (int) random(height);
    int x1 = (int) min(x0+random(4, 100*12*corruptionLevel), width);
    int y1 = (int) min(y0+random(4, 10+4*corruptionLevel), height);
    for (int y=y0; y<y1; y++) {
      for (int x=x0; x<x1; x++) {
        pixels[x + y*width] = ~pixels[x + y*width];
      }
    }
  }
  updatePixels();
}


void pixelateScreen(int n) {
  loadPixels();
  for (int y=0; y<height; y+=n) {
    for (int x=0; x<width; x+=n) {
      for (int yy=0; yy<n; yy+=1) {
        for (int xx=0; xx<n; xx+=1) {
          pixels[min(x+xx + (y+yy)*width, pixels.length-1)] = pixels[x+y*width];
        }
      }
    }
  }
  updatePixels();
}


void rbGlitch(int n) {
  loadPixels();
  PImage buffer = createImage(width, height, RGB);
  buffer.loadPixels();
  for (int i=0; i<pixels.length; i++) {
    buffer.pixels[i] = (pixels[i] & 0xff00ff00) +
      (pixels[min(pixels.length-1, i+n)] & 0xff0000ff) +
      (pixels[max(0, i-n)] & 0x00ff0000);
  }
  buffer.updatePixels();
  image(buffer, 0, 0);
}


void mouseClicked() {
  saveFrame("glitch###.png");
}
