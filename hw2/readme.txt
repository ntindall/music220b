Nathan James Tindall
Generative Drum Machine & Soundscape
Music 220B - Winter 2016

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

There are 5 files that are involved in the generative soundscape:

globals.ck:       Global state data, shared between all modules. Each other file
                  interfaces with the Globals object in order to coordinate.

                  Important state data include the globalGain, which all 
                  soundscape sounds output to (in order to be put through
                  global low-pass and high-pass filters).

                  Additionally, there is the notion of global density, which
                  all sounds are infuenced by in some way

kb-alt.ck:        Module for keyboard input.

                  [k] - toggles kick
                  [s] - toggles snare
                  [h] - toggles hihat

                  [b] - toggles bass
                  [m] - toggles smear
                  [l] - toggles bloom
                  [a] - toggles arp
                  [z] - toggles sizzle

                  [^] - (up arrow) increase density by 0.1
                  [v] - (down arrow) decrease density by 0.1


tp-alt.ck:        Module for mouse input

                  X direction controls low pass filter frequency
                  Y direction controls high pass filter frequency

drum-machine.ck:  Module for drum machine input (operates at eighth-note tick,
                  with sounds shredding from the main loop every tick).

                  The high level organization of the sound generation (as
                  a function of density) is described below.

soundscape.ck:    Modules for soundscape generation (operates at eigth-note
                  tick, but sounds shredding from the main loop at the
                  beginning of every phrase or at certain ticks within the
                  meter. 

                  The high level organization of the sound generation (as
                  a function of density) is described below.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

From a form perspective, I wanted the piece to begin in confusion of rhythm.
Where is it? What is it? (Complicated by the fact that it is changing).
Eventually this settles into an unpredictable groove with increasingly
complex layers. As the texture densifies, elements fade out and the "smear"
texture becomes more apparent.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Within each 