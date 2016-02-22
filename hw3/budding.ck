//------------------------------------------------------------------------------
// name: budding.ck
// author: nathan james tindall
// date: winter 2016
//
// usage: chuck budding.ck
// this really stretches time out
//
// control elements:
//------------------------------------------------------------------------------
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// default filename (can be overwritten via input argument)
"audio/piano.wav" => string FILENAME;
// get file name, if one specified as input x0argument
if( me.args() > 0 ) me.arg(0) => FILENAME;

.5 => float GRAIN_RAMP_FACTOR;

// max lisa voices



//check notes from fFEB 16


//TODO::: EXPERIMENT WITH THIS VALUE!!!!
30 => int LISA_MAX_VOICES;







// load file into a LiSa (use one LiSa per sound)
load( FILENAME ) @=> LiSa @ lisaLEFT;
load( FILENAME ) @=> LiSa @ lisaRIGHT;
load( FILENAME ) @=> LiSa @ lisaLEFT2;
load( FILENAME ) @=> LiSa @ lisaRIGHT2;
load( FILENAME ) @=> LiSa @ lisaLEFT3;
load( FILENAME ) @=> LiSa @ lisaRIGHT3;



// patch it
PoleZero blockerL => LPF lpfL => NRev reverbL => Gain gL => dac.left;
PoleZero blockerR => LPF lpfR => NRev reverbR => Gain gR => dac.right; 
.99 => blockerL.blockZero => blockerR.blockZero;
4000 => lpfL.freq => lpfR.freq; //to block hissing a bit

// connect
lisaLEFT.chan(0)   => Gain leftG1  => blockerL;
lisaLEFT2.chan(0)  => Gain leftG2  => blockerL;
lisaLEFT3.chan(0)  => Gain leftG3  => blockerL;

lisaRIGHT.chan(0)  => Gain rightG1 => blockerR;
lisaRIGHT2.chan(0) => Gain rightG2 => blockerR;
lisaRIGHT3.chan(0) => Gain rightG3 => blockerR;

1 => leftG1.gain => leftG2.gain => leftG3.gain => rightG1.gain => rightG2.gain => rightG3.gain;

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------------- LISA HELPERS ---------------------------------------
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

// grain sporkee
fun void grain(LiSa @ lisa,    //UGen       
               dur pos,        //position in buffer
               dur grainLen,   //length of grain
               dur rampUp,     //triangle envelope rampUp
               dur rampDown,   //triangle envelope rampDown
               float rate )    //sample playback rate
{
    // get a voice to use
    lisa.getVoice() => int voice;

    // if available
    if( voice > -1 )
    {
        // set rate
        lisa.rate( voice, rate );
        // set playhead
        lisa.playPos( voice, pos );
        // ramp up
        lisa.rampUp( voice, rampUp );
        // wait
        (grainLen - rampUp) => now;
        // ramp down
        lisa.rampDown( voice, rampDown );
        // wait
        rampDown => now;
    }
    500::ms => now; //decay
}

// load file into a LiSa
fun LiSa load( string filename )
{
    // sound buffer
    SndBuf buffy;
    // load it
    filename => buffy.read;
    
    // new LiSa
    LiSa lisa;
    // set duration
    buffy.samples()::samp => lisa.duration;
    
    // transfer values from SndBuf to LiSa
    for( 0 => int i; i < buffy.samples(); i++ )
    {
        // args are sample value and sample index
        // (dur must be integral in samples)
        lisa.valueAt( buffy.valueAt(i), i::samp );        
    }
    
    // set LiSa parameters
    lisa.play( false );
    lisa.loop( false );
    lisa.maxVoices( LISA_MAX_VOICES );
    
    return lisa;
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fun void rampGain(Gain @ g, float goal) {

  500 => int NUM_STEPS;
  g.gain() => float start;

  (goal - start) / NUM_STEPS => float delta; 

  for (int i; i < NUM_STEPS; i++) {
    g.gain() + delta => g.gain;
    10::ms => now;
  }
}


fun void partOne() {
  0 => float pos;

  while (pos < 0.15) {
    spork ~ grain(lisaLEFT,
            pos * lisaLEFT.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            1);
    spork ~ grain(lisaRIGHT,
            pos * lisaRIGHT.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 1000::ms,
            GRAIN_RAMP_FACTOR * 1000::ms,
            1);
    500::ms => now;
    .001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}

fun void partTwo() {
  0.15 => float pos;

  while (pos < 0.30) {
    spork ~ grain(lisaRIGHT2,
            pos * lisaRIGHT2.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.5);
    spork ~ grain(lisaLEFT2,
            pos * lisaRIGHT2.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 1000::ms,
            GRAIN_RAMP_FACTOR * 1000::ms,
            0.25);

    spork ~ grain(lisaLEFT,
            pos * lisaLEFT.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            1);
    spork ~ grain(lisaRIGHT,
            pos * lisaRIGHT.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 1000::ms,
            GRAIN_RAMP_FACTOR * 1000::ms,
            1);
    500::ms => now;
    .001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}

fun void partThree() {
  0.30 => float pos;

  spork ~rampGain(leftG1, 0.7);
  spork ~rampGain(leftG2, 0.7);
  spork ~rampGain(leftG3, 0.7);
  spork ~rampGain(rightG1, 0.7);
  spork ~rampGain(rightG2, 0.7);
  spork ~rampGain(rightG2, 0.7);


  while (pos < 0.4) {
    for (int i; i < 2; i++) {
      spork ~ grain(lisaRIGHT2,
              pos * lisaRIGHT2.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.5);
      spork ~ grain(lisaLEFT2,
              pos * lisaRIGHT2.duration(),
              1000::ms, 
              GRAIN_RAMP_FACTOR * 1000::ms,
              GRAIN_RAMP_FACTOR * 1000::ms,
              0.25);

      spork ~ grain(lisaLEFT,
              pos * lisaLEFT.duration(),
              250::ms, 
              GRAIN_RAMP_FACTOR * 250::ms,
              GRAIN_RAMP_FACTOR * 250::ms,
              2);
      spork ~ grain(lisaRIGHT,
              pos * lisaRIGHT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              1);
      250::ms => now;
    }
    .002 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}

fun void aSlowDown() {
  0.40 => float pos;

  0.3 => leftG1.gain => leftG2.gain => rightG1.gain => rightG2.gain;

  spork ~rampGain(leftG1, 0.15);
  spork ~rampGain(leftG2, 0.15);
  spork ~rampGain(leftG3, 0.05);
  spork ~rampGain(rightG1, 0.15);
  spork ~rampGain(rightG2, 0.15);
  spork ~rampGain(rightG2, 0.05);


  while (pos < 0.5) {
    spork ~ grain(lisaRIGHT3,
          (pos + Math.random2f(-0.001,0.001)) * lisaRIGHT3.duration(),
          5000::ms, 
          GRAIN_RAMP_FACTOR * 5000::ms,
          GRAIN_RAMP_FACTOR * 5000::ms,
          0.250);

    spork ~ grain(lisaLEFT3,
        (pos + Math.random2f(-0.001,0.001)) * lisaRIGHT3.duration(),
        2000::ms, 
        GRAIN_RAMP_FACTOR * 2000::ms,
        GRAIN_RAMP_FACTOR * 2000::ms,
        0.500);

    0::ms => dur total; 
    while (total < 500::ms) {
      Math.random2(30,60)::ms => dur waitTime;

      if (waitTime + total >= 500::ms) {
        500::ms - total => waitTime;
      }

      waitTime + total => total;

      spork ~ grain(lisaRIGHT,
              (pos + Math.random2f(-0.001,0.001)) * lisaRIGHT.duration(),
              50::ms, 
              GRAIN_RAMP_FACTOR * 50::ms,
              GRAIN_RAMP_FACTOR * 50::ms,
              4);
      spork ~ grain(lisaRIGHT2,
              (pos * Math.random2f(-0.001,0.001))  * lisaRIGHT2.duration(),
              25::ms, 
              GRAIN_RAMP_FACTOR * 25::ms,
              GRAIN_RAMP_FACTOR * 25::ms,
              2);
      spork ~ grain(lisaLEFT2,
              (pos * Math.random2f(-0.001,0.001))  * lisaRIGHT2.duration(),
              50::ms, 
              GRAIN_RAMP_FACTOR * 50::ms,
              GRAIN_RAMP_FACTOR * 50::ms,
              5);

      spork ~ grain(lisaLEFT,
              (pos * Math.random2f(-0.001,0.001)) * lisaLEFT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 100::ms,
              GRAIN_RAMP_FACTOR * 100::ms,
              4);
      waitTime => now;
    }
  .001 +=> pos;
  <<< "[!][!] pos: " + pos >>>;
  }
}

//TODO ADJUST GAIN TO PREVENT CLIPPING!!!!

fun void partFour() {
  0.50 => float pos;
  spork ~rampGain(leftG1, 0.15);
  spork ~rampGain(leftG2, 0.15);
  spork ~rampGain(rightG1, 0.15);
  spork ~rampGain(rightG2, 0.15);

  while (pos < .558) {
    for (int i; i < 100; i++) {
      spork ~ grain(lisaRIGHT2,
              pos * lisaRIGHT2.duration(),
              250::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.5);
      spork ~ grain(lisaLEFT2,
              pos * lisaRIGHT2.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.25);

      spork ~ grain(lisaLEFT,
              pos * lisaLEFT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              2);
      spork ~ grain(lisaRIGHT,
              pos * lisaRIGHT.duration(),
              1000::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              1);
      10::ms => now; //plus some increasing amount of randomness
    }

    .002 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}


fun void partFive() {
  0.558 => float pos;

  spork ~rampGain(leftG1, 0.1);
  spork ~rampGain(leftG2, 0.5);
  spork ~rampGain(leftG3, 0.4);
  spork ~rampGain(rightG1, 0.1);
  spork ~rampGain(rightG2, 0.8);


  while (pos < .58) {
    if (pos > 0.564) {
      //use third lisa LEFT
      spork ~ grain(lisaLEFT3,
              pos * lisaLEFT3.duration(),
              2000::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              4);
    }
    spork ~ grain(lisaRIGHT2,
            pos * lisaRIGHT2.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            1);
    spork ~ grain(lisaLEFT2,
            pos * lisaRIGHT2.duration(),
            2000::ms, 
            GRAIN_RAMP_FACTOR * 1000::ms,
            GRAIN_RAMP_FACTOR * 1000::ms,
            2);
    for (int i; i < 100; i++) { //experiment with this section
      spork ~ grain(lisaRIGHT,
              pos * lisaRIGHT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.25);
      spork ~ grain(lisaLEFT,
              pos * lisaLEFT.duration(),
              250::ms, 
              GRAIN_RAMP_FACTOR * 250::ms,
              GRAIN_RAMP_FACTOR * 250::ms,
              0.5);
      10::ms => now;
    }
    0.001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}

fun void partSix() {
  0.56 => float pos;

  spork ~rampGain(leftG1, 1);
  spork ~rampGain(leftG2, 0.3);
  spork ~rampGain(leftG3, 0.3);
  spork ~rampGain(rightG1, 1.0);
  spork ~rampGain(rightG2, 0.4);
  spork ~rampGain(rightG3, 0.3);

  while (pos < .58) {
    spork ~ grain(lisaLEFT3,
            pos * lisaLEFT3.duration(),
            2000::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            4);

    spork ~ grain(lisaRIGHT3,
          pos * lisaRIGHT3.duration(),
          2000::ms, 
          GRAIN_RAMP_FACTOR * 500::ms,
          GRAIN_RAMP_FACTOR * 500::ms,
          8);
    
    spork ~ grain(lisaRIGHT2,
            pos * lisaRIGHT2.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 250::ms,
            GRAIN_RAMP_FACTOR * 250::ms,
            1);
    spork ~ grain(lisaLEFT2,
            pos * lisaRIGHT2.duration(),
            2000::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            2);

    if (pos < .57) {
      spork ~ grain(lisaLEFT,
        pos * lisaLEFT.duration(),
        5000::ms, 
        GRAIN_RAMP_FACTOR * 5000::ms,
        GRAIN_RAMP_FACTOR * 5000::ms,
        0.25);
    }

    500::ms => now;
    0.001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}


fun void end() {
  0.58 => float pos;

  spork ~rampGain(leftG1, 1);
  spork ~rampGain(leftG2, 1);
  spork ~rampGain(leftG3, 0.1);
  spork ~rampGain(rightG1, 1);
  spork ~rampGain(rightG2, 1);
  spork ~rampGain(rightG3, 0.1);


  while (pos < .67) {
    if (pos < 0.59) {
      spork ~ grain(lisaLEFT3,
              (pos + Math.random2f(-0.004, 0.004)) * lisaLEFT3.duration(),
              2000::ms, 
              GRAIN_RAMP_FACTOR * 2000::ms,
              GRAIN_RAMP_FACTOR * 2000::ms,
              4);

      spork ~ grain(lisaRIGHT3,
            (pos + Math.random2f(-0.004, 0.004)) * lisaRIGHT3.duration(),
            8000::ms, 
            GRAIN_RAMP_FACTOR * 8000::ms,
            GRAIN_RAMP_FACTOR * 8000::ms,
            8);
    }

    spork ~ grain(lisaRIGHT2,
            (pos + Math.random2f(-0.001, 0.001)) * lisaRIGHT2.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.5);
    spork ~ grain(lisaLEFT2,
            (pos + Math.random2f(-0.001, 0.001)) * lisaRIGHT2.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 1000::ms,
            GRAIN_RAMP_FACTOR * 1000::ms,
            0.125);

    spork ~ grain(lisaLEFT,
            (pos + Math.random2f(-0.001, 0.001)) * lisaLEFT.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.5);
    spork ~ grain(lisaRIGHT,
            (pos + Math.random2f(-0.001, 0.001)) * lisaRIGHT.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.25);
    500::ms => now;
  
    0.001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }

  while (pos < .97) {
    spork ~ grain(lisaRIGHT2,
            pos * lisaRIGHT2.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.25);
    spork ~ grain(lisaLEFT2,
            pos * lisaRIGHT2.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 1000::ms,
            GRAIN_RAMP_FACTOR * 1000::ms,
            0.125);

    spork ~ grain(lisaLEFT,
            pos * lisaLEFT.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.25);
    spork ~ grain(lisaRIGHT,
            pos * lisaRIGHT.duration(),
            1000::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.125);
    500::ms => now;
  
    0.01 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }

  //let tick echo
  while (pos < 1) {
    if (pos < 1) {
      spork ~ grain(lisaRIGHT2,
              pos * lisaRIGHT2.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.5);
    }
    if (pos < 0.996) {
      spork ~ grain(lisaLEFT2,
              pos * lisaRIGHT2.duration(),
              1000::ms, 
              GRAIN_RAMP_FACTOR * 1000::ms,
              GRAIN_RAMP_FACTOR * 1000::ms,
              0.125);
    }
    if (pos < 0.99) {
      spork ~ grain(lisaLEFT,
              pos * lisaLEFT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.5);
    }
    if (pos < 0.9925) {
      spork ~ grain(lisaRIGHT,
              pos * lisaRIGHT.duration(),
              1000::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              0.25);
    }
    500::ms => now;
  
    0.001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}



fun void main() {
  <<< "-----[!][!][!] PART 1 [!][!][!]-----" >>>;
  partOne();
  <<< "-----[!][!][!] PART 2 [!][!][!]-----" >>>;
  partTwo();
  <<< "-----[!][!][!] PART 3 [!][!][!]-----" >>>;  
  partThree();
  aSlowDown();
  //something different needed around 0.40
  <<< "-----[!][!][!] PART 4 [!][!][!]-----" >>>;  
  partFour();
  <<< "-----[!][!][!] PART 5 [!][!][!]-----" >>>;  
  partFive();
  <<< "-----[!][!][!] PART 6 [!][!][!]-----" >>>;  
  partSix();
  end();

}

main();
