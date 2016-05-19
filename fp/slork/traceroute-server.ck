/* Traceroute - Network Sonification
 * Nathan James Tindall
 * SLOrk Spring 2016
 */

/***************************************************************** LOCAL DATA */
// create our OSC receiver
OscRecv tracerote_recv;
// use port 6449 (or whatever)
6471 => tracerote_recv.port;
// start listening (launch thread)
tracerote_recv.listen();

/* Wireshark listener */
// create our OSC receiver
OscRecv tshark_recv;
// use port 6449 (or whatever)
6449 => tshark_recv.port;
// start listening (launch thread)
tshark_recv.listen();

// create an address in the receiver, store in new variable
tshark_recv.event( "/data, i i i i i i i i" ) @=> OscEvent @ ts_oe;

/*********************************************** NETWORK TRANSMISSION (HEMIS) */

// send objects
OscSend xmit[16];
// number of targets (initialized by netinit)
int targets;
// port
6450 => int port;

// aim the transmitter at port
fun void netinit() {
  if (me.arg(0) == "local" || me.arg(0) == "l" || me.arg(0) == "localhost")
  {
    1 => targets;
    xmit[0].setHost ( "localhost", port );
  } else 
  {
    //NOTE: REMEMBER TO MODIFY TARGET VALUE OR WILL AOOBE
    1 => targets;
    xmit[0].setHost ( "localhost", port );
   // xmit[1].setHost ( "Nathan.local", port );
    /*
    xmit[2].setHost ( "tikkamasala.local", port );
    xmit[3].setHost ( "transfat.local", port );
    xmit[4].setHost ( "peanutbutter.local", port );
    xmit[5].setHost ( "tofurkey.local", port );
    xmit[6].setHost ( "doubledouble.local", port );
    xmit[7].setHost ( "seventeen.local", port );
    xmit[8].setHost ( "aguachile.local", port );
    xmit[9].setHost ( "snickers.local", port );
    xmit[10].setHost ( "padthai.local", port );
    xmit[11].setHost ( "flavorblasted.local", port );
    xmit[12].setHost ( "dolsotbibimbop.local", port );
    xmit[13].setHost ( "poutine.local", port );
    xmit[14].setHost ( "shabushabu.local", port );
    xmit[15].setHost ( "froyo.local", port );
    */
    //xmit[11].setHost ( "pupuplatter.local", port );
    //xmit[13].setHost ( "xiaolongbao.local", port );
    //xmit[14].setHost ( "turkducken.local", port );
    //xmit[16].setHost ( "oatmealraisin.local", port );
  }
}


fun void traceroute_listen() {
  // create an address in the receiver, store in new variable
  tracerote_recv.event( "/data, f i i i i" ) @=> OscEvent @ tr_oe;

  // infinite event loop
  0 => int z;
  while( true )
  {
    // wait for event to arrive
    tr_oe => now;
    
    // grab the next message from the queue. 
    while( tr_oe.nextMsg() )
    { 
      tr_oe.getFloat() => float node_delay;
      xmit[z].startMsg( "/slork/traceroute/tune", "f");
      node_delay => xmit[z].addFloat;

      (z + 1) % targets => z; //rotate

      <<< "tuning" >>>;
      1::second => now;
    }
  }
}


fun void tshark_listen() {
  // infinite event loop
  while( true )
  {
    // wait for event to arrive
    ts_oe => now;
    0 => int cur_ptr;
    4 => int chan_delta;
    // grab the next message from the queue. 
    while( ts_oe.nextMsg() )
    {   
      int array[8];
      for (0 => int i; i < 8; i++) {
        ts_oe.getInt() => array[i];
        Math.abs((cur_ptr + chan_delta)) % targets => int osc_idx;

        //compute frequency
        array[i] % 100 + 20 => int midiPitch;
        midiPitch => Std.mtof => float freq;

        spork ~trigger(osc_idx, freq);
        spork ~trigger((osc_idx + 4) % targets ,freq/2);

        (Globals.separation)::ms => now;
      }

      cur_ptr + 1 + chan_delta => cur_ptr;

      if (Globals.buttonDown() == 1) {
          <<< "CLEARING QUEUE" >>>;
          while (ts_oe.nextMsg()) {
          }
      }
    }
    
  }
}

fun void trigger(int idx, float freq) {
  <<< idx, freq >>>;
  xmit[idx].startMsg( "/slork/traceroute/trigger", "f");
  freq => xmit[idx].addFloat;
}

fun void update_feedback() {
    while ( true )
    {
      for (int z; z < targets; z++)
      {
        xmit[z].startMsg( "/slork/traceroute/feedback", "f" );
        Globals.getDelay() => xmit[z].addFloat;
      }

      250::ms => now;
    }

}

/******************************************************************** CONTROL */
netinit();

spork ~update_feedback();
spork ~traceroute_listen();
spork ~tshark_listen();

while ( true ) 1::day => now;
