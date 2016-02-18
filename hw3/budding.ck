//------------------------------------------------------------------------------
// name: budding.ck
// author: nathan james tindall
// date: winter 2016
//
// usage: chuck budding.ck
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

  while (pos < 0.5) {
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

//TODO ADJUST GAIN TO PREVENT CLIPPING!!!!

fun void partFour() {
  0.50 => float pos;
  0.1 => leftG1.gain => leftG2.gain => rightG1.gain => rightG2.gain;

  //0 => reverbR.mix => reverbL.mix;


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
  0.1 => leftG1.gain => leftG2.gain => rightG1.gain => rightG2.gain;
  0.5 => leftG2.gain;
  0.8 => rightG2.gain;
  0.4 => leftG3.gain;

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
  0.1 => leftG1.gain => leftG2.gain => rightG1.gain => rightG2.gain;
  0.5 => leftG2.gain;
  0.8 => rightG2.gain;
  0.4 => leftG3.gain => rightG3.gain;

  while (pos < .58) {
    spork ~ grain(lisaLEFT3,
            pos * lisaLEFT3.duration(),
            2000::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            4);
    
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
    /*
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

    */
    500::ms => now;
    0.001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}


fun void end() {
  0.58 => float pos;
  1 => leftG1.gain => leftG2.gain => rightG1.gain => rightG2.gain;

  while (pos < .67) {
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
            0.125);

    spork ~ grain(lisaLEFT,
            pos * lisaLEFT.duration(),
            500::ms, 
            GRAIN_RAMP_FACTOR * 500::ms,
            GRAIN_RAMP_FACTOR * 500::ms,
            0.5);
    spork ~ grain(lisaRIGHT,
            pos * lisaRIGHT.duration(),
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
  //partOne();
  <<< "-----[!][!][!] PART 2 [!][!][!]-----" >>>;
  //partTwo();
  <<< "-----[!][!][!] PART 3 [!][!][!]-----" >>>;  
  //partThree();
  //something different needed around 0.40
  <<< "-----[!][!][!] PART 4 [!][!][!]-----" >>>;  
  //partFour();
  <<< "-----[!][!][!] PART 5 [!][!][!]-----" >>>;  
  //partFive();
  partSix();
  <<< "-----[!][!][!] PART 6 [!][!][!]-----" >>>;  
  end();

}

main();
