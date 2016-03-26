0.6::second => dur BEAT;

Gain rhythmR => LPF lR => dac.right;
Gain rhythmL => LPF lL => dac.left;

lR.freq(500);
lL.freq(500);

fun void bass() {
  SndBuf bass => PitShift shifter;

  shifter.mix(0.8);
  shifter.shift(0.25);

  shifter => rhythmR;
  shifter => rhythmL;
  bass.read(me.sourceDir() + "audio/bass.wav");
  bass.rate(Math.random2f(0.999,1.001));


  bass.length() => now;
}

fun void mid(float rate, int shouldPan) {
  SndBuf mid;
  if (shouldPan == 1) {
      if (Math.random2f(0,1) > 0.5) {
          mid => rhythmR;
      } else {
          mid => rhythmL;
      }
  } else {
      mid => rhythmR;
  }

  mid.read(me.sourceDir() +"audio/mid.wav");
  mid.rate(rate * Math.random2f(.99,1.01));

  mid.length() => now;
}

fun void high(float rate, int shouldPan) {
  SndBuf high;
  if (shouldPan == 1) {
      if (Math.random2f(0,1) > 0.5) {
          high => rhythmR;
      } else {
          high => rhythmL;
      }
  } else {
      high => rhythmL;
  }

  high.read(me.sourceDir() + "audio/high.wav");
  high.rate(rate * Math.random2f(.99,1.01));

  high.length() => now;
}

fun void breakyMid() {
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.4, 1);
  BEAT/5 => now;

  spork ~mid(1.3, 0);
  BEAT/6 => now;
  spork ~mid(1.2, 0);
  BEAT/7 => now;
  spork ~mid(1.1, 0);
  BEAT/8 => now;
  spork ~mid(1.0, 0);
  BEAT/9 => now;
}

fun void breakyHigh() {
  spork ~high(1.5, 1);
  BEAT/4 => now;
  spork ~high(1.4, 1);
  BEAT/5 => now;

  spork ~high(1.3, 0);
  BEAT/6 => now;
  spork ~high(1.2, 0);
  BEAT/7 => now;
  spork ~high(1.1, 0);
  BEAT/8 => now;
  spork ~high(1.0, 0);
  BEAT/9 => now;
}

fun void groove() {
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(1, 1);
  BEAT/2 => now;

  spork ~bass();
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/2 => now;
  spork ~bass();
  //spork ~breaky();
  BEAT => now;

  spork ~bass();
  BEAT/2 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(1, 1);
  BEAT/2 => now;

  spork ~bass();
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/2 => now;
  spork ~bass();
  spork ~breakyMid();
  BEAT => now;
}

fun void groove2() {
  spork ~bass();
  BEAT/2 => now;
  spork ~high(2, 1);
  BEAT/4 => now;
  spork ~high(2, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~high(1, 1);
  BEAT/2 => now;


  spork ~bass();
  spork ~high(1.5, 1);
  BEAT/4 => now;
  spork ~high(1.5, 1);
  BEAT/4 => now;
  spork ~high(1.5, 1);
  BEAT/2 => now;
  spork ~bass();
  //spork ~breaky();
  BEAT/2 => now;
  spork ~high(1, 1);
  BEAT/4 => now;
  spork ~high(1, 1);
  BEAT/4 => now;

  spork ~bass();
  BEAT/2 => now;
  spork ~high(2, 1);
  BEAT/4 => now;
  spork ~high(2, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~high(1, 1);
  spork ~high(1, 1);
  BEAT/4 => now;
  spork ~high(1, 1);
  BEAT/4 => now;

  spork ~bass();
  spork ~high(1.5, 1);
  BEAT/4 => now;
  spork ~high(1.5, 1);
  BEAT/4 => now;
  spork ~high(1.5, 1);
  BEAT/2 => now;
  spork ~bass();
  spork ~breakyHigh();
  BEAT => now;
}

fun void groove3() {
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~bass();
  spork ~breakyHigh();
  BEAT => now;

  spork ~bass();
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~high(1.5, 1);
  BEAT/2 => now;
  spork ~bass();
  spork ~breakyMid();
  //spork ~breaky();

  BEAT/2 => now;
  spork ~high(1, 1);
  BEAT/4 => now;
  spork ~high(1, 1);
  BEAT/4 => now;

  spork ~bass();
  BEAT/2 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~breakyHigh();
  BEAT/2 => now;
 // spork ~mid(1);
  BEAT/4 => now;
//  spork ~mid(1);
  BEAT/4 => now;

  spork ~bass();
  //spork ~mid(1.5);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/2 => now;
  spork ~breakyHigh();
  BEAT/2 => now;
  spork ~bass();
  BEAT/2 => now;
}

fun void groove4() {
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~mid(2, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(1, 1);
  BEAT/2 => now;

  spork ~bass();
  BEAT/2 => now;
 // spork ~mid(2);
  BEAT/4 => now;
  spork ~mid(0.8, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(1, 1);
  BEAT/2 => now;

    spork ~bass();
  BEAT/2 => now;
 // spork ~mid(2);
  BEAT/4 => now;
  spork ~mid(0.8, 1);
  BEAT/4 => now;
  spork ~bass();
  BEAT/2 => now;
  spork ~mid(1, 1);
  BEAT/2 => now;

  spork ~bass();
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/4 => now;
  spork ~mid(1.5, 1);
  BEAT/2 => now;
  spork ~bass();
  spork ~breakyMid();
  BEAT => now;

}

/************** ARP1 *************************/
SinOsc arp1T => Chorus arp1C;
arp1C.modFreq(100);
arp1C.modDepth(0.02);

arp1C => LPF arp1LPF => Gain arp1Gain => ADSR arp1ADSR => dac;
arp1LPF.freq(100);
arp1Gain.gain(0.1);

[79, 67, 74, 77,
 79, 67, 74, 67,
 79, 67, 74, 77,
 79, 67, 74, 67
] @=> int arpNotes[];
fun void arp(float gain) {
  arp1Gain.gain(gain);
  arp1ADSR.keyOn();
  for (int i; i < 16; i++) {
    arpNotes[i] + 12 => Std.mtof => arp1T.freq;
    BEAT/4 => now;
  }
  arp1ADSR.keyOff();
}

/*******************************************/

fun void playChord(float midi1, float midi2, float midi3, dur playTime, float shift, float gain, float cutoff) {
  SawOsc chord1 => PitShift chordP;
  SawOsc chord2 => chordP;
  SawOsc chord3 => chordP;

  chordP => Gain chordG => ADSR chordA => LPF l => NRev r => dac;

  l.freq(cutoff);

  chordG.gain(gain);

  chordP.mix(0.5);
  chordP.shift(1);

  chordA.set(playTime / 2,playTime / 4, 0.8, playTime/8);

  //patch
  chord1.freq(Std.mtof(midi1));
  chord2.freq(Std.mtof(midi2));
  chord3.freq(Std.mtof(midi3));

  //on
  chordA.keyOn();


  playTime - chordA.releaseTime() => now;
  //off
  chordA.keyOff();

  chordA.releaseTime() => now;
  1::second => now;
}

fun void jitter(int midiNote, float gain, float cutoff) {
  SawOsc s => LPF l => Gain sG => ADSR env => NRev r => dac;
  l.freq(cutoff);
  r.mix(0.05);

  sG.gain(gain);

  50::ms => dur jitterDur;

  s.freq(Std.mtof(midiNote));

  env.set(3::ms, 0::ms, 1, 3::ms);

  for (int i; i < 16; i++) {
    env.keyOn();
    jitterDur => now;
    env.keyOff();
    jitterDur / (i + 1) => now;
  }
  1::second => now;
}

fun void rampLPF(LPF @ l, float end, dur rampTime) {

  100 => int numSteps;
  (end - l.freq()) / numSteps => float delta;

  while (l.freq() < end) {
    l.freq() + delta => l.freq;
    <<< l.freq() >>>;
    rampTime / numSteps => now;
  }
}

/*** IT BEGINS ***/

spork ~ rampLPF (arp1LPF, 400, BEAT * 4 * 6);
for (int i; i < 4; i++) {
  arp(0.1);
}
spork ~groove();
for (int i; i < 2; i++) {
  arp(0.1);
}

spork ~ rampLPF (arp1LPF, 4000, BEAT * 4 * 4);
spork ~groove();
for (int i; i < 2; i++) {
  arp(0.1);
}
spork ~groove();
for (int i; i < 2; i++) {
  arp(0.1);
}

for (int i; i < 2; i++) {
  spork ~playChord(55,62,71, BEAT * 4 * 3, 0, 0.05, 400);
  arp1C.modFreq(0);
  spork ~groove();
  for (int i; i < 2; i++) {
    arp(0.02);
  }

  spork ~playChord(55,64,72, BEAT * 4 * 3, 0, 0.05, 400);
  spork ~groove();
  for (int i; i < 2; i++) {
    arp(0.02);
  }
  spork ~playChord(55,67,74, BEAT * 4 * 4, 0, 0.05, 400);
  spork ~playChord(71,71,71, BEAT * 4 * 4, 0, 0.03, 400);
  spork ~groove2();
  for (int i; i < 2; i++) {
    spork ~jitter(43, 0.1, 400);
    arp(0.02);
  }
  spork ~groove2();
  for (int i; i < 2; i++) {
    spork ~jitter(43, 0.1, 400);
    arp(0.02);
  }
}

spork ~playChord(55,62,69, BEAT * 4 * 3, 0, 0.1, 400);
spork ~playChord(71,69,69, BEAT * 4 * 3, 0, 0.1, 400);
arp1C.modFreq(0);
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 400);
  arp(0.02);
}

spork ~playChord(55,64,72, BEAT * 4 * 3, 0, 0.1, 400);
spork ~playChord(76,74,79, BEAT * 4 * 3, 0, 0.1, 400);
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 400);
  arp(0.02);
}
spork ~playChord(55,67,74, BEAT * 4 * 4, 0, 0.1, 400);
spork ~playChord(71,72,79, BEAT * 4 * 4, 0, 0.1, 400);
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 400);
  arp(0.02);
}
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 400);
  arp(0.01);
}


//arp out
spork ~playChord(55,62,69, BEAT * 4 * 3, 0, 0.1, 600);
spork ~playChord(71,69,69, BEAT * 4 * 3, 0, 0.01, 600);
arp1C.modFreq(0);
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 800);
  BEAT * 4 => now;
}

spork ~playChord(55,64,72, BEAT * 4 * 3, 0, 0.07, 600);
spork ~playChord(76,74,79, BEAT * 4 * 3, 0, 0.07, 600);
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 800);
  BEAT * 4 => now;
}
spork ~playChord(55,67,74, BEAT * 4 * 4, 0, 0.08, 800);
spork ~playChord(71,72,79, BEAT * 4 * 4, 0, 0.08, 800);
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 800);
  BEAT * 4 => now;
}
spork ~groove2();
for (int i; i < 2; i++) {
  spork ~jitter(43, 0.1, 800);
  BEAT * 4 => now;
}

//kick out
spork ~playChord(55,62,69, BEAT * 4 * 3, 0, 0.07, 1200);
spork ~playChord(71,69,69, BEAT * 4 * 3, 0, 0.07, 1200);
BEAT * 8 => now;
spork ~playChord(55,64,72, BEAT * 4 * 3, 0, 0.07, 1600);
spork ~playChord(76,74,79, BEAT * 4 * 3, 0, 0.07, 1600);
BEAT * 8 => now;
spork ~playChord(55,67,74, BEAT * 4 * 6, 0, 0.08, 2000);
spork ~playChord(71,72,79, BEAT * 4 * 6, 0, 0.08, 2000);
BEAT * 16 => now;
spork ~playChord(55,67,74, BEAT * 4 * 5, 0, 0.08, 2000);
spork ~playChord(79,69,71, BEAT * 4 * 5, 0, 0.08, 2000);
for (int i; i < 4; i++) {
  spork ~jitter(43, 0.15, 2000);
  BEAT * 4 => now;
}


spork ~rampLPF(lR, 1000, BEAT*4*8); 
spork ~rampLPF(lL, 1000, BEAT*4*8); 
for (int i; i < 4; i++) {
  spork ~playChord(43,43,43, BEAT * 4 * 2, 0, 0.05, 400);
  spork ~groove3();
  for (int i; i < 2; i++) {
    spork ~jitter(43 - 12, 0.15, 2000);
    BEAT * 4 => now;
  }
}


/*********** CHANGE TO GLOBAL GAIN *****/

rhythmR.gain(0.8);
rhythmL.gain(0.8);
spork ~rampLPF(lR, 2000, BEAT*4*8); 
spork ~rampLPF(lL, 2000, BEAT*4*8);
for (int i; i < 4; i++) {
  spork ~groove4();
  for (int i; i < 2; i++) {
    spork ~jitter(43 - 12, 0.15, 2000);
    BEAT * 4 => now;
  }
}
spork ~ rampLPF (arp1LPF, 4000, BEAT * 4 * 4);
arp1C.modFreq(100);
for (int i; i < 4; i++) {
  spork ~groove4();
  spork ~arp(0.1);
  for (int i; i < 2; i++) {
    spork ~jitter(43 - 12, 0.15, 2000);
    BEAT * 4 => now;
  }
}

//groove();