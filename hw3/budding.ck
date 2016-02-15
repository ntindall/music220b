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


// patch it
PoleZero blockerL => NRev reverbL => Gain lG => dac.left;
PoleZero blockerR => NRev reverbR => Gain rG => dac.right; 
.99 => blockerL.blockZero;
.99 => blockerR.blockZero;

// connect
lisaLEFT.chan(0) => blockerL;
lisaRIGHT.chan(0) => blockerR;

//------------------------- LISA HELPERS -------------------------------------

  fun void stereopan(float panvalue)
  {  //panvalue can be between [-1,1]
     panvalue/2.0+.5 => float left;
     1.0-left => float right;
     Math.sqrt(left*left + right*right) => float power;
     right/power => lG.gain;
     left/power => rG.gain;
  }


// grain sporkee
fun void grain( LiSa @ lisa, dur pos, dur grainLen, dur rampUp, dur rampDown, float rate )
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

fun void main() {
  0 => float pos;
  while (pos < 1) {
    //spork ~ stereopan(Math.random2f(-0.2, 0.2));

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

main();
