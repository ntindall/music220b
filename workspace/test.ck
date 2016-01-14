
// HID
Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

// patch
BeeThree organ => JCRev r => Echo e => Echo e2 => dac;
r => dac;

// set delays
240::ms => e.max => e.delay;
480::ms => e2.max => e2.delay;
// set gains
.6 => e.gain;
.3 => e2.gain;
.05 => r.mix;
0 => organ.gain;

[48, 50, 52, 55, 57, 60, 62, 64, 67, 69, 72, 74, 79, 81, 84] 
@=> int pitches[];
    0 => int last;
// infinite event loop
while( true )
{
    // wait for event
    hi => now;

    // get message
    while( hi.recv( msg ) )
    {
        // check
        if( msg.isButtonDown() )
        {
            Std.mtof( pitches[last]) => float freq;
            if( freq > 20000 ) continue;

            freq => organ.freq;
            .5 => organ.gain;
            1 => organ.noteOn;
            (last + 1) % 15 => last;

            80::ms => now;
        }
        else
        {
            0 => organ.noteOff;
        }
    }
}