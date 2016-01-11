Saxofony s=>PitShift p=>p=>Pan2 q=>dac; Saxofony d=>PitShift o=>o=>Pan2 w=>dac;
p.shift(0.999); s.freq(15); d.freq(16); o.shift(1.001);1=>s.noteOn;1=>d.noteOn;
0=>float x;while(100::ms=>now){Math.cos(x)=>w.pan;-w.pan()=>q.pan; x + 0.2=>x;}

//cars racing
//Nathan James Tindall
//Music 220B