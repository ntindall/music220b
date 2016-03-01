// (launch with s.ck)

// the patch
SinOsc s => JCRev r => dac;
.5 => s.gain;
.1 => r.mix;

// create our OSC receiver
OscRecv recv;
// use port 6449 (or whatever)
6449 => recv.port;
// start listening (launch thread)
recv.listen();

// create an address in the receiver, store in new variable
recv.event( "/data, i i i i i i i i" ) @=> OscEvent @ oe;

// our function
fun void print( int bar[] )
{
    // print it
    for( 0 => int i; i < bar.cap(); i++ )
        <<< bar[i] >>>;
}

// infinite event loop
while( true )
{
    // wait for event to arrive
    oe => now;
    
    // grab the next message from the queue. 
    while( oe.nextMsg() )
    { 
        int array[8];
        array[0] => int waitTime;

        for (1 => int i; i < 8; i++) {
            array[i] % 80 => int midiPitch;
            oe.getInt() => midiPitch => Std.mtof => s.freq;
            5::ms => now;
        }
        // print
        //print(array);
    }
}

// for each traceroute node, create delay line, get dynamic comb filter of
// network data

//multichannel (4/8)