import java.util.Arrays;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.IOException;

PImage convertTo32Bit(PImage source) {
  PImage img = createImage(source.width, source.height, ARGB);
  source.loadPixels();
  img.loadPixels();
  for (int i=0; i<source.pixels.length; i++) {
    int val = source.pixels[i];
    int col = (val > 0) ? 255 : 0;
    img.pixels[i] = color(col, col, col, val);
  }  
  return img;
}

char[] readFile(String filename) {
  String[] lines = loadStrings(filename);
  nLines = lines.length;
  String text = String.join("\n", Arrays.asList(lines));
  char[] textArray = new char[text.length()];
  text.getChars(0, text.length(), textArray, 0);
  
  return textArray;
}

void textCorrupt(String infile, String outfile) {
  //println(dataPath("textcorrupt.py"));
  ProcessBuilder pb = new ProcessBuilder("python3", "/home/gdg/Desktop/corrupt/textcorrupt.py", infile, outfile);
  pb.directory(new File(dataPath("")));
  try {
    Process p = pb.start();
    /*
    BufferedReader in = new BufferedReader(new InputStreamReader(p.getErrorStream()));
    String line;
    while ((line = in.readLine()) != null) {
      System.out.println(line);
    }
    */
  } catch (IOException e) {
    println(e);
  }
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}
