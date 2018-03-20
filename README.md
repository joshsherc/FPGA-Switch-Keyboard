# FPGA-Switch-Keyboard

A simple FPGA keyboard, developed in VHDL. The current program automatically plays a variation of the "Hot Cross Buns" song, but can easily be modified to play songs via the keyboard.

Each note is developed manually, defining the high and low points of the signal. This is done by setting a signal to be high for a certain amount of time, with an equivelant amount of time setting that signal to being low. This way, each individual note can be developed with a custom frequency, based on the length of time being high and low.
