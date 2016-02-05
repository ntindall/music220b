public class Globals
{

  static float density;
  static int eighth; //constant sense of time
  static int meter;

  static int bass;
  static int kick;

  static int hihat;
  static int snare;
  static int sizzle;

  static int intro;

  //initialize class variables if desired non-zero
  fun static void init() {
    0.5 => density;
    15 => meter; //number of eighths in phrases
  }

  fun static int isIntro() {
    return intro;
  }

  fun static int getKick() {
    return kick;
  }

  fun static int getBass() {
    return bass;
  }

  fun static int getHihat() {
    return hihat;
  }

  fun static int getSnare() {
    return snare;
  }

  fun static int getSizzle() {
    return sizzle;
  }

  fun static float getDensity() {
    return density;
  }

  fun static void increaseDensity() {
    density + 0.1 => density;
    printDensity();
  }

  fun static void decreaseDensity() {
    density - 0.1 => density;
    printDensity();
  }

  fun static void printDensity() {
    <<< "density: " + density >>>;
  }

  fun static void advanceTime() {
    (eighth + 1) % meter => eighth;
    <<< eighth >>>;
  }
}

Globals.init();