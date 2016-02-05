//chuck globals.ck drum-machine.ck soundscape.ck

.2::second => dur T;
T - (now % T) => now; //wait until the next period