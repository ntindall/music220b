//


//-----------------------------------------------------------------------------
// name: ks-chord.ck
// desc: karplus strong comb filter bank
//
// authors: Madeline Huberth (mhuberth@ccrma.stanford.edu)
//          Ge Wang (ge@ccrma.stanford.edu)
// date: summer 2014
//       Stanford Center @ Peking University
//-----------------------------------------------------------------------------

// single voice Karplus Strong chubgraph
class KS extends Chubgraph
{
    // sample rate
    second / samp => float SRATE;
    
    // ugens!
    DelayA delay;
    OneZero lowpass;
    
    // noise, only for internal use
    Noise n => delay;
    // silence so it doesn't play
    0 => n.gain;
    
    // the feedback
    inlet => delay => lowpass => delay => outlet;
    // max delay
    1::second => delay.max;
    // set lowpass
    -1 => lowpass.zero;
    // set feedback attenuation
    .9 => lowpass.gain;

    // mostly for testing
    fun void play( float pitch, dur T )
    {
        tune( pitch ) => float length;
        // turn on noise
        1 => n.gain;
        // fill delay with length samples
        length::samp => now;
        // silence
        0 => n.gain;
        // let it play
        T-length::samp => now;
    }
    
    // tune the fundamental resonance
    fun float tune( float pitch )
    {
        // computes further pitch tuning for higher pitches
        pitch - 43 => float diff;
        0 => float adjust;
        if( diff > 0 ) diff * .0125 => adjust;
        // compute length
        computeDelay( Std.mtof(pitch+adjust) ) => float length;
        // set the delay
        length::samp => delay.delay;
        //return
        return length;
    }
    
    // set feedback attenuation
    fun float feedback( float att )
    {
        // sanity check
        if( att >= 1 || att < 0 )
        {
            <<< "set feedback value between 0 and 1 (non-inclusive)" >>>;
            return lowpass.gain();
        }

        // set it        
        att => lowpass.gain;
        // return
        return att;
    }
    
    // compute delay from frequency
    fun float computeDelay( float freq )
    {
        // compute delay length from srate and desired freq
        return SRATE / freq;
    }
}

// chord class for KS
class KSChord extends Chubgraph
{
    // array of KS objects    
    KS chordArray[4];
    
    // connect to inlet and outlet of chubgraph
    for( int i; i < chordArray.size(); i++ ) {
        inlet => chordArray[i] => outlet;
    }

    // set feedback    
    fun float feedback( float att )
    {
        // sanith check
        if( att >= 1 || att < 0 )
        {
            <<< "set feedback value between 0 and 1 (non-inclusive)" >>>;
            return att;
        }
        
        // set feedback on each element
        for( int i; i < chordArray.size(); i++ )
        {
            att => chordArray[i].feedback;
        }

        return att;
    }
    
    // tune 4 objects
    fun float tune( float pitch1, float pitch2, float pitch3, float pitch4 )
    {
        pitch1 => chordArray[0].tune;
        pitch2 => chordArray[1].tune;
        pitch3 => chordArray[2].tune;
        pitch4 => chordArray[3].tune;
    }
}

/******************************************************************************/

/* CONTROL FLOW */

fun int coinFlip() {
  if (Math.random2f(0,1) > 0.5) {
    return 1;
  } else {
    return -1;
  }
}

fun float uniform1() {
  return Math.random2f(-1,1);
}

//cool
fun void gliss(float s_note, float e_note, float gain, dur hold) {
  SndBuf buffy => Gain g => KSChord object => JCRev r;
  "../audio/laundry.wav" => buffy.read;
  (e_note - s_note) / 100 => float delta;
  g.gain(gain);
  buffy.rate(.1);
  object.feedback(0.98);
  r.mix(1);
  r => HPF h => dac;
  h.freq(400);
  <<< s_note, e_note >>>;
  
  0 => buffy.pos;
  0 => float shift;
  object.tune(s_note + shift, s_note + shift, s_note+12 + shift, s_note+12 + shift);
  0.1::second => now;
  for (int i; i < 100; i++) {

    object.tune(s_note + shift, s_note + shift, s_note+12 + shift, s_note+12 + shift);
    shift + delta => shift;
    10::ms => now;
  }
  hold => now;
  0 => g.gain;
  2::second => now;
}

fun void oneChord(int x, 
                  int pos,
                  float rate,
                  int multiplier,
                  dur duration,
                  float feedback,
                  int note1,
                  int note2,
                  int note3,
                  int note4,
                  float pan,
                  float gain) {
  // sound to chord to dac
  SndBuf buffy => Gain g => KSChord object => JCRev r => Pan2 p => dac;
  p.pan(pan);
  g.gain(gain);
  // load a sound
  "../audio/laundry.wav" => buffy.read;
  // set feedback
  object.feedback(feedback);
  r.mix(0.2);

  // tune
  object.tune(note1, note2, note3, note4);

  // set playhead to beginning
  pos => buffy.pos;
  // set rate
  rate * multiplier => buffy.rate;

  // advance time
  duration => now;
  g.gain(0);
  1::second => now;
}

/* Intro */

for (int i; i < 2; i++) {
  oneChord(0, 
           Math.random2(100, 100000), 
           1,
           1,
           10::second,
           0.5,
           57, 69, 72, 79,
           uniform1(),
           0.05); //A A C G
  1::second => now;
  spork ~gliss(43,45, 0.05, 14::second);
}


//Slowly ramp up harmonicity
now + 10::second => time end;
0.5 => float feedback;
0.95 => float feedback_goal;
(feedback_goal - feedback) / 10 => float delta;
while (now < end) {

  Math.random2(-1,2) => int octave;

  if (Math.random2f(0,1) < 0.5) {
    spork ~oneChord(12 * octave, 
                   Math.random2(50000, 100000), 
                   Math.random2f(0.25,0.75),
                   coinFlip(),
                   1::second,
                   feedback,
                   57, 69, 72, 79,
                   uniform1(),
                   feedback / 2); //A A C G
  } else {
    spork ~oneChord(24 * octave,
                    Math.random2(50000, 100000),
                    Math.random2f(0.25,0.75),
                    coinFlip(),
                    1::second,
                    feedback,
                    57, 71, 72, 76,
                    uniform1(),
                    feedback / 2); //A B C E
  }

  1::second => now;
  feedback + delta => feedback;
  <<< feedback >>>;
}

for (int i; i < 2; i++) {
  spork ~gliss(43,45, 0.1, 10::second);
  spork ~gliss(55,57, 0.1, 10::second);

  //Let the chords be heard!!
  now + 10::second => end;
  0.95 => feedback;
  0.95 => feedback_goal;
  (feedback_goal - feedback) / 10 => delta;
  while (now < end) {

    Math.random2(-1,2) => int octave;

    if (i >= 1) {
      if (Math.random2f(0,1) > 0.5) {
        spork ~gliss(57,59,0.2, 1::second);
        spork ~gliss(59,61,0.2, 1::second);
      }
    }

    if (Math.random2f(0,1) < 0.5) {
      spork ~oneChord(12 * octave, 
                     Math.random2(50000, 100000), 
                     Math.random2f(0.25,0.75),
                     coinFlip(),
                     1::second,
                     feedback,
                     60, 57, 64, 74,
                     uniform1(),
                     feedback / 4);
    } else {
      spork ~oneChord(24 * octave,
                      Math.random2(50000, 100000),
                      Math.random2f(0.25,0.75),
                      coinFlip(),
                      1::second,
                      feedback,
                      60, 57, 64, 74,
                      uniform1(),
                      feedback / 4);
    }

    1::second => now;
    feedback + delta => feedback;
    <<< feedback >>>;
  }
}

spork ~gliss(43,45, 0.2, 10::second);
spork ~gliss(55,57, 0.2, 10::second);

for (int i; i< 4; i++) {
  spork ~gliss(50,62,0.2, 4::second);
  spork ~gliss(59,61,0.2, 4::second);
  4::second => now;
}


//move to G
spork ~gliss(45,43, 0.15, 16::second);
spork ~gliss(57,55, 0.15, 16::second);
for (int i; i < 16; i++) {
  Math.random2(-1,1) => int octave;

  if ((i % 4) - 1 == 0) {
    spork ~gliss(81, 79, 0.4, 4::second);
    <<<"sporking !!!">>>;
  }

  spork ~oneChord(12 * octave,
                Math.random2(50000, 100000),
                Math.random2f(0.25,0.75),
                1,
                1::second,
                0.95,
                55, 62, 71, 69,
                uniform1(),
                0.4);
  1::second => now;
}

//F C E B
//move to F
spork ~gliss(43,41, 0.05, 16::second);
spork ~gliss(55,53, 0.05, 16::second);

for (int i; i < 16; i++) {
  Math.random2(-1,1) => int octave;

  if ((i % 2) - 1 == 0) {
    if ((i % 4) - 1 == 0) {
        spork ~gliss(76, 77, 0.4, 2::second);
      } else {
        spork ~gliss(83, 84, 0.4, 2::second);

      }
    <<<"sporking !!!">>>;
  }

  spork ~oneChord(12 * octave,
                Math.random2(50000, 100000),
                Math.random2f(0.25,0.75),
                1,
                1::second,
                0.95,
                53, 60, 64, 71,
                uniform1(),
                0.2);

  if (i == 15) {
    spork ~gliss(53,57, 0.05, 10::second);
    spork ~gliss(41,45, 0.05, 10::second);

  }

  1::second => now;
  if (i == 15) {}
}
1::second => now;
spork ~gliss(71, 72, 0.2, 10::second);
4::second => now;
spork ~gliss(72, 76, 0.2, 10::second);
4::second => now;
spork ~gliss(76, 79, 0.2, 10::second);
4::second => now;
spork ~gliss(79, 81, 0.4, 10::second);
4::second => now;
spork ~gliss(55,57, 0.1, 10::second);
spork ~gliss(43,45, 0.1, 10::second);

1::day => now;
