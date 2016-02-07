//chuckk globals.ck drum-machine.ck soundscape.ck

.2::second => dur T;
T - (now % T) => now; //wait until the next period
int phraseCount;

Gain left => dac.left;
Gain right => dac.right;

[71, 73, 74, 66, 73, 71, 74, 66] @=> int bloomVals[];
fun void bloom() {
  <<< "blooming" >>>;
  SinOsc f => ADSR e => NRev r => Echo a => Echo b => Echo c;

  <<< Globals.globalGain.gain() >>>;
  c => Globals.globalGain;

  e.set(10::ms, 5::ms, 0.8, 10::ms);


  1000::ms => a.max => b.max => c.max;
  500::ms => a.delay => b.delay => c.delay;
  a.mix(0.5);

  if (Globals.density < 0.3) {
    0::ms => b.delay;
    0::ms => c.delay;
  }

  if (Globals.density < 0.7) {
    0::ms => c.delay;
  }

  Math.random2(0,5) => int reps;
  for(int i; i < 3; i++) {
    f.freq(Std.mtof(bloomVals[reps + i]));
    e.keyOn(1);
    T / 2 => now;
    e.keyOff(1);
  }

  T * Globals.meter => now;
}

fun void longPhrase() {
  if (Globals.density > 0.1) {
    spork ~bloom();
  }
  T * Globals.meter => now;
}

fun void loop() {
  while (true) {
    if (Globals.eighth % 15 == 0) {
      if (Math.random2f(0, Globals.density) > 0.3) {
        spork ~ longPhrase();
        phraseCount + 1 => phraseCount; //keep track so we can change tonality
      }
    }

    if (Globals.density > 0.5) {
      if ((Globals.eighth % 15) == 8) {
        spork ~longPhrase();
      } 
    }






    T => now;
  }
}


loop();
