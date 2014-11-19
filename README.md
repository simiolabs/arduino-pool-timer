arduino-pool-timer
==================

This program attemps to control a pool pump using an Arduino, DS1307 Real Time Clock and a relay. The controller checks the start time, when the current time is greater than this, the pump is turned on and the LED will blink. After the current time is greater than the end time both the LED and the pump are turned off.
