public class Globals
{
  static int buttonIsDown;
  static float delay;
  static int separation;

  fun static int buttonDown() {
    return buttonIsDown;
  }

  fun static float getDelay() {
    return delay;
  }
}

0.8 => Globals.delay;
5 => Globals.separation;

<<< "--------- [TRACEROUTE] INITIALIZING GLOBALS --------- " >>>;

1::day => now;