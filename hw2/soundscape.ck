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

  c => Gain g => Pan2 p => Globals.globalGain;
  p.pan(Math.random2f(-0.5,0.5));
  g.gain(Math.random2f(0.005,0.01));

  e.set(10::ms, 5::ms, 0.8, 10::ms);


  1000::ms => a.max => b.max => c.max;
  400::ms => a.delay => b.delay => c.delay;
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

  T * Globals.meter * 2=> now;
}

fun void longPhrase() {
  if (Globals.density > 0.1) {
    spork ~bloom();
  }
  T * Globals.meter * 2=> now;
}

[47, 47, 43, 43] @=> int bassPhrase[];
fun void bass() {
  SinOsc f => ADSR e => Echo a => Echo b => Echo c;
  c => Pan2 p => Globals.globalGain;
  p.pan(-.1);

  1000::ms => a.max => b.max => c.max;
  400::ms => a.delay => b.delay => c.delay;

  e.set(50::ms,20::ms, 0.5, 10::ms);

  f.freq(Std.mtof(bassPhrase[phraseCount % 4]));
  e.keyOn(1);
  200::ms => now;
  e.keyOff();

  now => time start;
  5::second => dur decay;
  while (now < start + decay) {
    p.pan() + 0.01 => p.pan;
    100::ms => now;
  }
}

[47, 54, 59,
 47, 54, 59,
 47, 54, 61,
 47, 54, 62,
 47, 54, 61,
 59, 54, 51] @=> int arpPhrase[];
fun void arp() {
  if (Globals.getDensity() > 0.3) {
    spork ~ twiddle();
  }
  if (Globals.getDensity() > 0.8) {
    spork ~ arp2();
  }

  SawOsc o => ADSR e => Gain g => Globals.globalGain;
  e.set (20::ms, 20::ms, 0.8, 5::ms);

  g.gain(0.005);

  int i;
  now => time start;
  while (now < start + Globals.meter * T) {
    o.freq(Std.mtof(arpPhrase[i]));
    e.keyOn(1);

    T - e.releaseTime() => now;
    e.keyOff(1);
    e.releaseTime() => now;
    i++;
  }
}

[[78, 81, 78],
 [78, 81, 78],
 [76, 78, 76],
 [76, 78, 76],
 [76, 78, 76],
 [76, 78, 76],
 [76, 78, 74],
 [74, 78, 74]] @=> int twiddlePhrases[][];
fun void twiddle() {
  SawOsc o => ADSR e => Gain g => Globals.globalGain;
  e.set (20::ms, 20::ms, 0.8, 5::ms);

  Math.random2(0, twiddlePhrases.cap() - 1) => int phraseNum;

  g.gain(0.005);

  T/2 => now;

  (Globals.meter / 3) + 8 => int reps;

  for (int i; i < reps; i++) {
    for (int i; i < 3; i++) {
      o.freq(Std.mtof(twiddlePhrases[phraseNum][i] - 12));
      e.keyOn(1);

      T/2 - e.releaseTime() => now;
      e.keyOff(1);
      e.releaseTime() => now;
    }
  }
}


[71, 90, 76, 73, 76, 74,
 83, 71, 83, 78, 76, 73,
 71, 95, 90, 78, 61, 73,
 73, 76, 71, 90, 83, 62,
 83, 71, 83, 71, 74, 78,
 83, 73, 83, 95] @=> int arpPhrase2[];
fun void arp2() {
  reverse(arpPhrase2) @=> arpPhrase2;
  SawOsc o => ADSR e => Gain g => Globals.globalGain;
  e.set (20::ms, 20::ms, 0.8, 5::ms);

  g.gain(0.005);

  int i;
  now => time start;
  while (now < start + Globals.meter * T) {
    o.freq(Std.mtof(arpPhrase2[i % arpPhrase2.cap() ]));
    e.keyOn(1);

    T/2 - e.releaseTime() => now;
    e.keyOff(1);
    e.releaseTime() => now;
    i++;
  }

}

int smearCount;
[90, 88, 91, 93, 85, 71, 65, 79, 81, 83] @=> int smearNotes[];
fun void smear() {
    smearCount++;
    <<< "[!][!][!] smear sporked!!! " + smearCount >>>;
    now => time start;
    (T * Globals.meter) => dur smearTime;
    TriOsc t => ADSR e => Gain g => Chorus j => JCRev r => Pan2 p => Globals.globalGain;
    e.set(5::second, 1::second, 0.9, 1::second);
    g.gain(.01);
    p.pan(Math.random2f(-0.5,0.5));

    j.mix(0.5);
    j.modFreq(0.001);
    j.modDepth(2);


    t.freq(Std.mtof(smearNotes[Math.random2(0, smearNotes.cap() - 1)]));

    e.keyOn();
    while (now < start + smearTime) {
      10::ms => now;
    }
    e.keyOff();

    if (Math.random2(0, 1) > 0.5) {
      spork ~smear();
      smearTime * 4 => now; 
    } else {
      smearTime => now;
    }

    <<< "[!][!][!] smear dying!!! " + smearCount >>>;
    smearCount--;
}

int spawnCount;
fun void smearDriver() {
  spawnCount++;
  <<< "Smeardriver spawned: " + spawnCount >>>;
  int reps;

  if (Globals.getDensity() >= 0) 2 => reps;
  if (Globals.getDensity() >= 0.4) 3 => reps;
  if (Globals.getDensity() >= 0.7) 4 => reps;
  if (Globals.getDensity() >= 0.9) 6 => reps;
  if (Globals.getDensity() >= 1.0) 8 => reps;

  for (int i; i < reps; i++) {
    spork ~smear();
    T * 8 => now;
  }
  T * Globals.meter * (reps / 2)  => now;
  <<< "Smeardriver dying: " + spawnCount >>>;
  spawnCount--;
}

fun void mutateArrays() {
  <<< "[!][!][!] REVERSING ARRAYS [!][!][!]" >>>;
  reverse(arpPhrase) @=> arpPhrase;
  //reverse(bassPhrase) @=> bassPhrase;
  reverse(bloomVals) @=> bloomVals;
}

//fun void print( int bar[] )
//{
//  // print it
//  for( 0 => int i; i < bar.cap(); i++ )
//    <<< bar[i] >>>;
//}

fun int[] reverse(int r[]) {
  int toReturn[r.cap()];
  r.cap() - 1 => int ptr;

  for (int i; i < r.cap(); i++) {
    r[ptr] => toReturn[i];
    ptr--;
  }

  return toReturn;

}

fun void loop() {
  while (true) {
    if (Globals.eighth % Globals.meter == 0) {
        if (phraseCount % 4 == 0) {
          Math.random2(15, 17) => int newMeter;
          <<< "[!][!][!] METER SHIFT [!][!][!]" >>>;
          <<< "[Old: " + Globals.meter + "]" >>>;
          <<< "[New: " + newMeter + "]" >>>; 
          newMeter => Globals.meter;


          if (Globals.getSmear()) {
            spork ~ smearDriver();
          }

          mutateArrays();
        }

      if (Globals.getBass()) {
        spork ~ bass();
      }

      if (Globals.getArp()) {
        spork ~ arp();
      }

      if (Math.random2f(0, Globals.density) > 0.3 &&
          Globals.getBloom()) { //put smear with bloom
        spork ~ longPhrase();
      }

      phraseCount + 1 => phraseCount; //keep track so we can change tonality
    }

    if (Globals.density > 0.5) {
      if ((Globals.eighth % Globals.meter) == 8  &&
          Globals.getBloom()) { //put smear with bloom) {
        spork ~longPhrase();
      } 
    }

    T => now;
  }
}


loop();
