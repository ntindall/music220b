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
recv.event( "/data, s" ) @=> OscEvent @ oe;

// infinite event loop
while( true )
{
    // wait for event to arrive
    oe => now;
    <<< "recvd" >>>;
    // grab the next message from the queue. 
    while( oe.nextMsg() )
    { 
        string s;

        // getFloat fetches the expected float (as indicated by "i f")
        oe.getString() => s; //=> Std.mtof => s.freq;

        // print
        <<< "got (via OSC):", s >>>;
    }
}