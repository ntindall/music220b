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
recv.event( "/data, f i i i i" ) @=> OscEvent @ oe;

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
        oe.getFloat() => float f;
       <<< f >>>;
    }
}

// for each traceroute node, create delay line, get dynamic comb filter of
// network data

//multichannel (4/8)

//make array of 64 ks chords, map them to different channels