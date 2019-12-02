class GlitchLetter {
  PVector position = new PVector();
  Integer[] coords;
  int yOffset;
  
  GlitchLetter(PVector pos, char let, MyFontTexture mft) {
    position.set(pos);
    coords = mft.getCoords(let);
    //yOffset = font.getSize()-coords[3]/2;
    PFont.Glyph glyph = mft.font.getGlyph(let);
    yOffset = (glyph.height/2)-glyph.topExtent;
  }
  
  void render() {
    if (coords == null) return;
    
    boolean glitch = false;
    int r = 0;
    if (random(1.0)<0.0001*corruptionLevel) {
      glitch = true;
      r = (int) random(256);
    }
    
    pushMatrix();
    // glitchy translation
    if (glitch && (r&1) == 1) {
      int t = mft.getFontSize();
      translate(position.x+random(-t, t), position.y+yOffset+random(-t, t));
    } else {
      translate(position.x, position.y+yOffset);
    }
    
    // glitchy mirroring
    float scaleX = 1.0;
    float scaleY = 1.0;
    if (glitch && (r & 2) == 2) {
      float s = 1.5+corruptionLevel*0.1;
      scaleX = random(-s, s);
      scaleY = random(-s, s);
    }
    scale(scaleX*coords[2], scaleY*coords[3]);
    
    if (glitch && (r & 4) == 4) {
      rotate(random(-QUARTER_PI/2, QUARTER_PI/2));
    }
    
    beginShape();
    texture(mft.fontTexture);
    vertex(-0.5, -0.5, coords[0], coords[1]);
    vertex(0.5, -0.5, coords[0]+coords[2], coords[1]);
    vertex(0.5, 0.5, coords[0]+coords[2], coords[1]+coords[3]);
    vertex(-0.5, 0.5, coords[0], coords[1]+coords[3]);
    
    endShape();
    popMatrix();
  }
}
