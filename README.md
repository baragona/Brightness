# Brightness
Sync macbook screen brightness to non-Apple external display.
It has no UI whatsoever. Just a menu item that allows quitting.

UPDATE: it still works on Mojave. It also seems to not conflict with Night Shift.

# Installation
Download the precompiled app here: https://github.com/ojotoxy/Brightness/releases

(Debug build from high sierra xcode 9)

Unzip and run the app. A "sun" icon appears in the menu bar, that is the only UI for now, and it only allows quitting.

# Other Thoughts
Pull requests welcome!

How it works:
  * Periodically sync brightness. Explained below.
  * Listen for these events: NSWorkspaceSessionDidBecomeActiveNotification, NSWorkspaceScreensDidWakeNotification, NSWorkspaceDidWakeNotification
  * When this event happens, recheck the displays configuration and decide what mode to be in.
  * Pick a 'driving display'. This is the monitor whose brightness should be copied to the others.
  * A driving display is the first display found whose real backlight brightness can be read. (Macbook internal display for example)
  * Periodically, copy the brightness to all other monitors.
  * Two methods are available for setting brightness, which I call Real and Fake.
  * Real is supported on apple monitors. There turns out to be a semi-documented api for doing setting brightness. This stuff is sort of on the fringes of what is offically supported by Apple!
  * Fake is supported on all monitors. This is done using the graphics card Gamma Table. Which basically maps RGB values to new RGB values. It is meant for color correction, but brightness correction is a subset of that. The original gamma table is read, and then scaled downward. (It does this the easy way now, but what might be better is to stretch the gamma table rightward, using interpolation. This could preserve color better while dimming? I thought I did this, but apparently it's doing it the dumb way...)
  * Because OSX will auto control the brightness of an apple external monitor, there is not much point to syncing it with this app. And it sort of does odd stuff sometimes when you do that.

Some ideas for improvements:
  * Rewrite it in Swift, Duh.
  * Make it compatible with apple thunderbolt displays. (Basically, detect when the display can already control its own brightness and turn off the syncing.)
  * Add a Menu Bar widget for controlling brightness. I haven't needed this, because the keyboard (including USB keyboards) have buttons for controlling internal brightness, which is then synced to the external.
  * Incorporate pretty much all the good ideas from F.lux, but open source! Why not?
  * Debug the occasional crashes. Clean up the code.
  * Rewrite the code in swift. Maybe rewrite the code, period. I don't pretend that it's very good as it is.
  * Find a robust way to control a non-apple monitors actual backlight brightess. There have been attempts at this before, but they are seem kind of hacky and have actually crashed my computer before! This is highly dependent on the GPU of the computer, and the external monitor itself. Most monitors seem to support this via https://en.wikipedia.org/wiki/Display_Data_Channel which should be present on all of  Displayport(thunderbolt), DVI, HDMI, VGA. Doing this well would have the effect of Much Better contrast at low brightness levels, which is the lame part of doing the brightness this way.
  * Perhaps a USB dongle could act as a middle man for the DDC control, using a microcontroller to send instructions to the monitor. This would be a Displayport passthru device, basically, that can inject additional DDC commands. Read starting pg 89 here, if you don't immediately think this is a terrible idea: http://ftp.cis.nctu.edu.tw/csie/Software/X11/private/VeSaSpEcS/VESA_Document_Center_Video_Interface/DportV1.1.pdf

License: Artistic License 2.0, thanks Larry.
