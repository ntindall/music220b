Nathan James Tindall
Music 220B
Winter 2016

to run: chuck laundry.ck
note: the file paths for the audio file may be adjusted for your system.

For this composition, I recorded the sounds in the laundry room of a residence
at Stanford. The sound itself is very cyclical and repetitive in nature, which
yields to interesting rhythmic properties when the sound is manipulated.

From a form perspective, I wanted the piece to depict the beginning and end of
a Spin Cycle on a washing machine. The beginning "revs up" through increasingly
intense inharmonic notes before exploring more hamonic material in an
increasingly "washed out" context. The gliss gestures are reminiscent of clothes
slushing about in the wash. The piece ends by returning to the original
unaltered sound.

The process began by experimenting with the parameters passed to a single
massively parameterized function that manipulated the features of the sound
buffer and the KS Chord object. Development and iteration was relatively
straightforward, though I did run into some difficulty with too many open files
(which I solved through a crude "pool" of two buffers that are acquired by
seperate shreds when available).