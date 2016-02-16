//--------------------------------------------------------------------
// name: budding.ck
// author: nathan james tindall
// date: winter 2016
//
// usage: chuck budding.ck
//
// control elements:
//--------------------------------------------------------------------


// default filename (can be overwritten via input argument)
"piano.wav" => string FILENAME;
// get file name, if one specified as input x0argument
if( me.args() > 0 ) me.arg(0) => FILENAME;

.5 => float GRAIN_RAMP_FACTOR;

// max lisa voices
30 => int LISA_MAX_VOICES;
// load file into a LiSa (use one LiSa per sound)
load( FILENAME ) @=> LiSa @ lisaLEFT;
load( FILENAME ) @=> LiSa @ lisaRIGHT;
load( FILENAME ) @=> LiSa @ lisaLEFT2;
load( FILENAME ) @=> LiSa @ lisaRIGHT2;


// patch it
PoleZero blockerL => LPF lpfL => NRev reverbL => Gain gL => dac.left;
PoleZero blockerR => LPF lpfR => NRev reverbR => Gain gR => dac.right; 
.99 => blockerL.blockZero => blockerR.blockZero;
4000 => lpfL.freq => lpfR.freq; //to block hissing a bit



// connect
lisaLEFT.chan(0) => blockerL;
lisaLEFT2.chan(0) => blockerL;
lisaRIGHT.chan(0) => blockerR;
lisaRIGHT2.chan(0) => blockerR;

//------------------------- LISA HELPERS -------------------------------------

// grain sporkee
fun void grain( LiSa lisa, dur pos, dur grainLen, dur rampUp, dur rampDown, float rate )
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

//------------------------- LISA HELPERS -------------------------------------

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

fun void partFour() {
  0.50 => float pos;

  while (pos < .558) {
    for (int i; i < 100; i++) {
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
              GRAIN_RAMP_FACTOR * 250::ms,
              GRAIN_RAMP_FACTOR * 250::ms,
              2);
      spork ~ grain(lisaRIGHT,
              pos * lisaRIGHT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              1);
      10::ms => now;
    }
    .002 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}


fun void partFive() {
  0.558 => float pos;

  while (pos < .58) {
    for (int i; i < 100; i++) {
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
              GRAIN_RAMP_FACTOR * 250::ms,
              GRAIN_RAMP_FACTOR * 250::ms,
              2);
      spork ~ grain(lisaRIGHT,
              pos * lisaRIGHT.duration(),
              500::ms, 
              GRAIN_RAMP_FACTOR * 500::ms,
              GRAIN_RAMP_FACTOR * 500::ms,
              1);
      10::ms => now;
    }
    0.001 +=> pos;
    <<< "[!][!] pos: " + pos >>>;
  }
}

fun void end() {
  0.58 => float pos;

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
  partOne();
  partTwo();
  partThree();
  partFour();
  partFive();
  end();

}

main();
