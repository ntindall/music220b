Machine.add("kb-alt.ck");

.5::second => dur T;
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

Kick k;
k.output => dac;

fun void kick() {
  <<< "kick" >>>;
  k.hit(1);

  T => now;
}

fun void hihat() {
  <<< "hihat" >>>;

  Noise n => JCRev j => HPF h => ADSR a => dac;
  j.mix(1);
  a.set (1::ms, 5::ms, .5, 10::ms);

  for (int i; i < 4; i++) {
    if (i % 2 == 0) {
      Math.random2f(0.6,0.8) => n.gain;
    } else {
      Math.random2f(0.4, 0.6) => n.gain;
    } 

    if (Math.random2f(0,1) >= 0.6) {
      1.6 => n.gain;
    }

    a.keyOn();
    h.freq(6000);


    10::ms => now;
    a.keyOff();
    T/4 - 10::ms => now;
  }
}

fun void sizzle() {
  <<< "sizzle" >>>;
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


fun void loop() {
  while (true) {
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