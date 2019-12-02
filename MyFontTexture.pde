import java.util.Map;
import java.awt.Font;

class MyFontTexture {
  PFont font;
  Font nativeFont;
  PImage fontTexture;
  HashMap<Character, Integer[]> charCoords;
  int glyphPosX, glyphPosY;
  int padding;
  
  MyFontTexture(PFont font) {
    fontTexture = createImage(512, 512, ARGB);
    charCoords = new HashMap<Character, Integer[]>();
    nativeFont = (Font) font.findNative();
    glyphPosX = 0;
    glyphPosY = 0;
    padding = 2;
    this.font = font;
  }
  
  void processText(char[] charArray) {
    for (char letter: charArray) {
      if (nativeFont.canDisplay(letter) && !charCoords.containsKey(letter)) {
        // Record new letter
        if (font.getGlyph(letter).image == null) {
          continue;
        }
        PImage glyphImg = convertTo32Bit(font.getGlyph(letter).image);
        Integer[] coords = new Integer[4];
        coords[0] = glyphPosX;
        coords[1] = glyphPosY;
        coords[2] = glyphImg.width;
        coords[3] = glyphImg.height;
        charCoords.put(letter, coords);
        
        fontTexture.loadPixels();
        glyphImg.loadPixels();
        for (int y=0; y<coords[3]; y++) {
          for (int x=0; x<coords[2]; x++) {
            fontTexture.pixels[x+glyphPosX + fontTexture.width*(y+glyphPosY)] =
              glyphImg.pixels[x + y*glyphImg.width];
          }
        }
        fontTexture.updatePixels();
        //fontTexture.set(glyphPosX, glyphPosY, glyphImg);
        glyphPosX += glyphImg.width + padding;
        
        // Check for leakage
        if (glyphPosX > fontTexture.width-font.getSize()) {
          glyphPosY += font.getSize();
          glyphPosX = 0;
        }
      }
    }
}
  
  int getCharWidth(char c) {
    return charCoords.containsKey(c) ? charCoords.get(c)[2] : 0;
  }
  
  int getFontSize() {
    return nativeFont.getSize();
  }
  
  Integer[] getCoords(char c) {
    return charCoords.containsKey(c) ? charCoords.get(c) : null;
  }
}
