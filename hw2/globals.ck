public class Globals
{

  static float density;
  static int eighth; //constant sense of time
  static int meter;

  static int bass;
  static int arp;
  static int kick;
  static int smear;

  static int hihat;
  static int snare;
  static int sizzle;

  static int intro;

  static LPF @ globalLPF;
  static HPF @ globalHPF;
  static Gain @ globalGain;

  //initialize class variables if desired non-zero
  fun static void init() {
    0.0 => density;
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

  fun static int getArp() {
    return arp;
  }

  fun static int getSmear() {
    return smear;
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

  fun static void mutateFilters(int dX, int dY) {
    Math.min(Math.max(globalLPF.freq() + dX, 50), 2000) => globalLPF.freq;
    Math.max(globalHPF.freq() - dY, 50) => globalHPF.freq;

    <<< globalLPF.freq(), globalHPF.freq() >>>;
  }

  fun static void advanceTime() {
    (eighth + 1) % meter => eighth;
    <<< eighth >>>;
  }
}

Globals.init();
new LPF @=> Globals.globalLPF;
new HPF @=> Globals.globalHPF;
new Gain @=> Globals.globalGain;

<<< "--------- [GENERATIVE SOUNDSCAPE] INITIALIZING GLOBALS --------- " >>>;

Globals.globalLPF.freq(1000);
Globals.globalHPF.freq(0);
Globals.globalGain.gain(1);

Globals.globalGain => Globals.globalHPF => Globals.globalLPF => dac;

1::day => now;