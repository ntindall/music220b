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

64 => int ARRAY_SIZE;
public class DelayArray extends Chubgraph {

    KS backing_array[ARRAY_SIZE];
    Gain gain_array[ARRAY_SIZE];
    0 => int logical_size;

    // sample rate
    second / samp => float SRATE;

    outlet.channels() => int numChannels;
    <<< "INSTANTIATING ARRAY WITH " + numChannels + " CHANNELS!" >>>;

    // connect to inlet and outlet of chubgraph
    for( int i; i < backing_array.size(); i++ ) {
        inlet => backing_array[i] => gain_array[i] => outlet.chan(i % numChannels);
        0 => gain_array[i].gain;
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
        for( int i; i < backing_array.size(); i++ )
        {
            att => backing_array[i].feedback;
        }

        return att;
    }

    fun void allocate( float delay ) {
      2000000 => int SCALAR;

      if (logical_size == backing_array.size()) {
        <<< ARRAY_SIZE + " delays allocated, array full" >>>;
        return;
      }

      <<< "DelayArray allocating at position: " + logical_size + 
          " with frequency " + delay * SCALAR / SRATE             >>>;
      backing_array[logical_size].tune(Std.ftom(delay * SCALAR / SRATE));
      1 => gain_array[logical_size].gain;


      logical_size + 1 => logical_size;

    }
}

//------------------------------------------------------------------------------
// the patch

// create our OSC receiver
OscRecv tracerote_recv;
// use port 6449 (or whatever)
6471 => tracerote_recv.port;
// start listening (launch thread)
tracerote_recv.listen();

// create an address in the receiver, store in new variable
tracerote_recv.event( "/data, f i i i i" ) @=> OscEvent @ tr_oe;


// create our OSC receiver
OscRecv tshark_recv;
// use port 6449 (or whatever)
6449 => tshark_recv.port;
// start listening (launch thread)
tshark_recv.listen();

// create an address in the receiver, store in new variable
tshark_recv.event( "/data, i i i i i i i i" ) @=> OscEvent @ ts_oe;


//Impulse i => DelayArray d => dac;
//d.feedback(0.99);

SinOsc s => DelayArray d => dac;
d.feedback(0.9);


/*
spork ~excite();
fun void excite() {
    while (true) {
        <<< "Exciting" >>>;
        for (int j; j < 100; j++) {
            1 => i.next;
            samp => now; //::second => now;    
        }
        1::second => now;
    }
}*/


fun void traceroute_listen() {
    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        tr_oe => now;
        
        // grab the next message from the queue. 
        while( tr_oe.nextMsg() )
        { 
            tr_oe.getFloat() => float f;
            d.allocate(f);
            5::second => now;
        }
    }
}

fun void tshark_listen() {
    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        ts_oe => now;

        // grab the next message from the queue. 
        while( ts_oe.nextMsg() )
        {   
            /*
            //read it in!
            int array[8];
            for (0 => int i; i < 8; i++) {
                ts_oe.getInt() => array[i]; 
            }
            //what to do with it?
            1 => i.next; //excite!
            */
            s.gain(0.01); //on
            int array[8];
            for (4 => int i; i < 8; i++) {
                ts_oe.getInt() => array[i];
                array[i] % 80 => int midiPitch;

                ts_oe.getInt() => midiPitch => Std.mtof => s.freq;
                2::ms => now;
            }
            s.gain(0); //off
        }
    }
}

spork ~traceroute_listen();
spork ~tshark_listen();


1::day => now;
// for each traceroute node, create delay line, get dynamic comb filter of
// network data

//multichannel (4/8)

//make array of 64 ks chords, map them to different channels