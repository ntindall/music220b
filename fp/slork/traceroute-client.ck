/* Traceroute - Network Sonification
 * Nathan James Tindall
 * SLOrk Spring 2016
 */


//------------------------------------------------------------------------------
// the patch
second / samp => float SRATE;
2000000 => int SCALAR;

// create our OSC receiver
OscRecv recv;
// use port 6450 (or whatever)
6450 => recv.port;
// start listening (launch thread)
recv.listen();

SqrOsc osc => LPF lpf => ADSR adsr => Gain g => KS d => dac;
g.gain(0.05); //turn it down!
adsr.set(0.5::ms, 0.5::ms, 1, 0.5::ms);


lpf.freq(10000);
d.feedback(0.90); //init


fun void tune_listen() 
{
  recv.event( "/slork/traceroute/tune, f") @=> OscEvent @ t_oe;
  
  // infinite event loop
  while( true )
  {
    // wait for event to arrive
    t_oe => now;
    
    // grab the next message from the queue. 
    while( t_oe.nextMsg() )
    { 
      t_oe.getFloat() => float node_delay;
      d.tune(Std.ftom(node_delay * SCALAR / SRATE));
      <<< "TUNING: ", Std.ftom(node_delay * SCALAR / SRATE) >>>;
    }
  }
}

fun void feedback_listen() 
{

  recv.event( "/slork/traceroute/feedback, f") @=> OscEvent @ f_oe;
  // infinite event loop
  while( true )
  {
    // wait for event to arrive
    f_oe => now;
    
    // grab the next message from the queue. 
    while( f_oe.nextMsg() )
    { 
      f_oe.getFloat() => float f;
      d.feedback(f);
      <<< "FREQ: ", f >>>;
    }
  }
}

fun void trigger_listen() 
{
  while ( true )
  {
    // create an address in the receiver, store in new variable
    recv.event( "/slork/traceroute/trigger, f" ) @=> OscEvent @ trig_oe;

    while( true )
    {
      // wait for event to arrive
      trig_oe => now;
      
      // grab the next message from the queue. 
      while( trig_oe.nextMsg() )
      { 
        trig_oe.getFloat() => float f;
        <<< f >>>;
        osc.freq(f);
        spork ~trigger();

      }
    }

  }
}

fun void trigger()
{
  adsr.keyOn(); //turn on patch
  100::ms => now;
  adsr.keyOff(); //on
}

spork ~feedback_listen();
spork ~trigger_listen();
spork ~tune_listen();


while ( true ) 1::day => now;