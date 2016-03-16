public class Globals
{
  static int buttonIsDown;
  static float delay;

  fun static int buttonDown() {
    return buttonIsDown;
  }

  fun static float getDelay() {
    return delay;
  }
}

0.5 => Globals.delay;

<<< "--------- [TRACEROUTE] INITIALIZING GLOBALS --------- " >>>;

1::day => now;