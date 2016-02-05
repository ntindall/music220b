//chuck globals.ck drum-machine.ck soundscape.ck

Machine.add("kb-alt.ck");

.2::second => dur T;
T - (now % T) => now; //wait until the next period


//http://electro-music.com/forum/topic-21382.html
class Kick
{
  Impulse i; // the attack 
  i => Gain g1 => Gain g1_fb => g1 => LPF g1_f => Gain BDFreq; // BD pitch envelope 
  i => Gain g2 => Gain g2_fb => g2 => LPF g2_f; // BD amp envelope 
    
  // drum sound oscillator to amp envelope to overdrive to LPF to output 
  BDFreq => SinOsc s => Gain ampenv => SinOsc s_ws => LPF s_f => Gain output; 
  g2_f => ampenv; // amp envelope of the drum sound 
  3 => ampenv.op; // set ampenv a multiplier 
  1 => s_ws.sync; // prepare the SinOsc to be used as a waveshaper for overdrive 
  
  // set default 
  80.0 => BDFreq.gain; // BD initial pitch: 80 hz 
  1.0 - 1.0 / 2000 => g1_fb.gain; // BD pitch decay 
  g1_f.set(100, 1); // set BD pitch attack 
  1.0 - 1.0 / 4000 => g2_fb.gain; // BD amp decay 
  g2_f.set(50, 1); // set BD amp attack 
  .75 => ampenv.gain; // overdrive gain 
  s_f.set(600, 1); // set BD lowpass filter 

  fun void hit(float v) 
  { 
    v => i.next; 
  } 
}

//http://electro-music.com/forum/topic-21382.html
// easy white noise snare 
class kjzSnare101 { 
    // note: connect output to external sources to connect 
    Noise s => Gain s_env => LPF s_f => Gain output; // white noise source 
    Impulse i => Gain g => Gain g_fb => g => LPF g_f => s_env; 
    
    3 => s_env.op; // make s envelope a multiplier 
    s_f.set(3000, 4); // set default drum filter 
    g_fb.gain(1.0 - 1.0/3000); // set default drum decay 
    g_f.set(200, 1); // set default drum attack 
    
    fun void setFilter(float f, float Q) 
    { 
        s_f.set(f, Q); 
    } 
    fun void setDecay(float decay) 
    { 
        g_fb.gain(1.0 - 1.0 / decay); // decay unit: samples! 
    } 
    fun void setAttack(float attack) 
    { 
        g_f.freq(attack); // attack unit: Hz! 
    } 
    fun void hit(float velocity) 
    { 
        velocity => i.next; 
    } 
} 

kjzSnare101 s;
s.setAttack(10000);
s.setFilter(2000, 1);
s.output => dac;

Kick k;
k.output => dac;

[
 1.0, 0.0,
 1.0, 0.0, 
 1.0, 1.0, 0.5,
 1.0, 0.5, 1.0, 0.5,
 1.0, 0.0, 0.0, 0.5,
 1.0, 1.0, 1.0] @=> float kickDist[];
fun void kick() {
  if (kickDist[Globals.eighth] * Globals.density > Math.random2f(0.2,0.7)) {
    k.hit(kickDist[Globals.eighth]);
  }

  T => now;
}


[1.0, 0.5, 0.8, 0.5,
 1.0, 0.5, 0.5, 0.5,
 0.5, 1.0,
 0.5, 1.0, 
 1.0, 0.8, 0.8,
 1.0, 1.0, 1.0] @=> float hatDist[];
fun void hihat() {

  hatDist[Globals.eighth] => float hat;

  if (hat * Globals.density > 0.25) {

    Noise n => JCRev j => HPF h => ADSR a => Pan2 p => dac;
    j.mix(1);
    a.set (1::ms, 5::ms, .5, 10::ms);

    Math.random2(1,2) => int hits;
    if (Globals.density > 1) {
      2 => hits;
    }

    for (int i; i < hits; i++) {
      if (i % 2 == 0) {
        p.pan(0.3);
        Math.random2f(0.6,0.8) => n.gain;
      } else {
        p.pan(-0.3);
        Math.random2f(0.4, 0.6) => n.gain;
      } 

      if (Math.random2f(0,1) >= 0.6) {
        1.6 => n.gain;
      }

      a.keyOn();
      h.freq(6000);


      10::ms => now;
      a.keyOff();
      T/2 - 10::ms => now;
    }
  }
}


fun void sizzle() {
  Impulse i => JCRev j => Chorus c => HPF z => Gain g => dac;
  g.gain(0.5);
  j.mix(0.1);
  c.modDepth(0.99999);
  c.mix(0);
  z.freq(1000);

  Math.random2(4,8) => int reps;
  for
   (int j; j < reps; j++) {
    1::ms => dur last;
    0.9 => float delta;

    while (last > 0.00001::samp) {
      <<< last >>>;
      1 => i.next;
      last => now;
      last * delta => last;
      if (Math.random2f(0,1) > 0.5) 3::samp => now;
    }

    20::ms => now;
  }

}

[
 0.0, 0.5,
 1.0, 0.0, 
 0.0, 0.5, 1.0,
 0.0, 0.0, 0.0, 0.0,
 1.0, 0.0, 1.0, 0.5,
 1.0, 1.0, 1.0] @=> float snareDist[];
fun void snare() {
  if (snareDist[Globals.eighth] * Globals.density > Math.random2f(0.2,0.7)) {
    s.hit(kickDist[Globals.eighth]);
  } else {
    if (Math.random2f(0,1) > 0.9) {
      for (int i; i < 2; i++) {
        s.hit(Math.random2f(0.5,0.8));
        T/2 => now;
      }
    }
  }
}

0 => int introThread;
fun void intro() {
  1 => introThread;
  while (true) {
    if (Globals.isIntro()) {
      sizzle();

    } else {
      break;
    }
    Math.random2f(200,600)::ms => now;
  }
}


//controllable evolution?
//controllable density... program the density of things.
//map density of repeated sounds to some global parameter!!!! good idea
//converging array, then when values have converged, rerandomize!!!

fun void loop() {
  while (true) {
    Globals.advanceTime();

    if (Globals.isIntro()) {
      if (introThread == 0) {
        spork ~intro();
      }
    }

    if (Globals.getSnare()) {
      spork ~ snare();
    }

    if (Globals.getBass()) {

    }

    if (Globals.getKick()) {
      spork ~ kick();
    }

    if (Globals.getHihat()) {
      spork ~ hihat();
    }

    if (Globals.getSizzle() && Math.random2f(0,1) > 0.8) {
      spork ~ sizzle();
    }

    T => now;
  }

}





loop();