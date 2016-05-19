public class DelayArray extends Chubgraph {

    8 => int ARRAY_SIZE;
    8  => int MAX_CHANS;

    Gain in_array[MAX_CHANS];

    KS backing_array[ARRAY_SIZE];
    Gain gain_array[ARRAY_SIZE];
    0 => int logical_size;

    Gain out_array[MAX_CHANS];

    // sample rate
    second / samp => float SRATE;

    <<< "INSTANTIATING ARRAY WITH " + MAX_CHANS + " CHANNELS!" >>>;

    // connect to inlet and outlet of chubgraph
    for( int i; i < backing_array.size(); i++ ) {
        in_array[i % MAX_CHANS] => backing_array[i] => gain_array[i] => out_array[i % MAX_CHANS];
        0 => gain_array[i].gain;
    }

    fun UGen chan(int i) {
        return in_array[i % MAX_CHANS];
    }

    fun int size() {
        return Math.max(logical_size, 1) $ int;
    }

    fun int channels() {
        return MAX_CHANS;
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
        0 => logical_size; //wraparound
      }

      <<< "DelayArray allocating at position: " + logical_size + 
          " with frequency " + delay * SCALAR / SRATE             >>>;
      backing_array[logical_size].tune(Std.ftom(delay * SCALAR / SRATE));
      1 => gain_array[logical_size].gain;


      logical_size + 1 => logical_size;

    }

    fun void chuck_out(UGen out) {
        out.channels() => int n_chans;
        <<< "CHUCKING ARRAY TO " + n_chans + " CHANNELS!" >>>;
        for (int i; i < MAX_CHANS; i++) {
            out_array[i] => out.chan(i % n_chans);
        }
    }
}

while (true) 1::day => now;