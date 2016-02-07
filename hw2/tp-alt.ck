//modified by NJT for 220B generative soundscape

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
// name: tp.ck
// desc: this program attempts to open a mouse/trackpad device, listens for
//       motion, mousedown, mouseup, and wheel events.
//
// authors: Rebecca Fiebrink and Ge Wang
//
// to run (in command line chuck):
//     %> chuck tp.ck
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

// open mouse 0, exit on fail
if( !hi.openMouse( deviceNum ) ) me.exit();
// successful! print name of device
<<< "mouse '", hi.name(), "' ready" >>>;

// infinite event loop
while( true )
{
    // wait on HidIn as event
    hi => now;

    // messages received
    while( hi.recv( msg ) )
    {
        // mouse motion
        if( msg.isMouseMotion() )
        {
            Globals.mutateFilters(msg.deltaX, msg.deltaY);
            // axis of motion
            //if( msg.deltaX )
            //{
            //    <<< "mouse motion:", msg.deltaX, "on x-axis" >>>;
            //}
            //else if( msg.deltaY )
            //{
            //    <<< "mouse motion:", msg.deltaY, "on y-axis" >>>;
            //}
        }
        
        // mouse button down
        else if( msg.isButtonDown() )
        {
            <<< "mouse button", msg.which, "down" >>>;
        }
        
        // mouse button up
        else if( msg.isButtonUp() )
        {
            <<< "mouse button", msg.which, "up" >>>;
        }

        // mouse wheel motion (requires chuck 1.2.0.8 or higher)
        else if( msg.isWheelMotion() )
        {
            // axis of motion
            if( msg.deltaX )
            {
                <<< "mouse wheel:", msg.deltaX, "on x-axis" >>>;
            }            
            else if( msg.deltaY )
            {
                <<< "mouse wheel:", msg.deltaY, "on y-axis" >>>;
            }
        }
    }
}