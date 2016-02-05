//modified by NT for drum machine / generative soundscape

/*----------------------------------------------------------------------------
    S.M.E.L.T. : Small Musically Expressive Laptop Toolkit

    Copyright (c) 2007 Rebecca Fiebrink and Ge Wang.  All rights reserved.
      http://smelt.cs.princeton.edu/
      http://soundlab.cs.princeton.edu/

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
    U.S.A.
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// name: kb.ck
// desc: this program attempts to open a keyboard and then listens for
//       both key-down and key-up events.
//
// to run (in command line chuck):
//     %> chuck kb.ck
//
// to run (in miniAudicle):
//     (make sure VM is started, add the thing)
//-----------------------------------------------------------------------------

// the device number to open
0 => int deviceNum;

// instantiate a HidIn object
HidIn hi;
// structure to hold HID messages
HidMsg msg;

// open keyboard
if( !hi.openKeyboard( deviceNum ) ) me.exit();
// successful! print name of device
<<< "keyboard '", hi.name(), "' ready" >>>;

// infinite event loop
while( true )
{
    // wait on event
    hi => now;

    // get one or more messages
    while( hi.recv( msg ) )
    {
        // check for action type
        if( msg.isButtonDown() )
        {
            //up arrow
            if (msg.which == 82) {
                Globals.increaseDensity();
            }

            //down arrow
            if (msg.which == 81) {
                Globals.decreaseDensity();
            }

            if (msg.which == 12) {
                <<< "intro" >>>;
                (Globals.isIntro() ^ 1) => Globals.intro;
            }

            if (msg.which == 5) {
                <<< "bass toggled" >>>;
                (Globals.getBass() ^ 1) => Globals.bass;
            }

            if (msg.which == 11) {
                <<< "hihat toggled" >>>;
                (Globals.getHihat() ^ 1) => Globals.hihat;
            }

            if (msg.which == 14) {
                <<< "kick toggled" >>>;
                (Globals.getKick() ^ 1) => Globals.kick;
            }


            if (msg.which == 22) {
                <<< "snare" >>>;
                (Globals.getSnare() ^ 1) => Globals.snare;
            }

            if (msg.which == 29) {
                <<< "sizzle" >>>;
                (Globals.getSizzle() ^ 1) => Globals.sizzle;
            }

            // print
            <<< "down:", msg.which >>>;
        }
        else
        {
            // print
            <<< "up:", msg.which >>>;
        }
    }
}