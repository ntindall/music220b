VoicForm v=>JCRev r=>dac;r.mix(0.2);spork~c();while(1){for(0=>int i;i<32;i++){
v.phonemeNum(i);v.freq(Std.rand2(800,1000));500::ms=>now;}}fun void c(){Shakers 
s=>r=>dac;s.which(18);while(1){s.noteOn(1);Std.rand2(400,1200)::ms=>now;}}

//Whining and Clanging
//Nathan Tindall
//Music 220Btouch