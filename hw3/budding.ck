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
"twilight-source.aiff" => string FILENAME;
// get file name, if one specified as input x0argument
if( me.args() > 0 ) me.arg(0) => FILENAME;

.5 => float GRAIN_RAMP_FACTOR;

// max lisa voices
30 => int LISA_MAX_VOICES;
// load file into a LiSa (use one LiSa per sound)
load( FILENAME ) @=> LiSa @ lisa;

// patch it
PoleZero blocker => NRev reverb => dac;
// connect
lisa.chan(0) => blocker;

//------------------------- LISA HELPERS -------------------------------------

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
  while (true) {
    grain(lisa,
          pos * lisa.duration(), 
          1000::ms, 
          GRAIN_RAMP_FACTOR * 1000::ms,
          GRAIN_RAMP_FACTOR * 1000::ms,
          1);
    .001 +=> pos;
  }
}

main();
