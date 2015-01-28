OpenBCI_Processing
==================

Repository containing the latest OpenBCI Processing GUI.

## OpenvibeLink branch

Using the [OpenvibeLink](https://github.com/jfrey-xx/OpenvibeLink) Processing library to stream OpenBCI data to OpenViBE. The GUI will work as usual -- notably regarding channels configuration -- and in the background the raw (?) signals streamed on the network.

Configure the acquisition server to read from Telnet: port 12345, 32 bits float, big endian, 8 channels at 256Hz by default. Look in "scripts" forder for a configuration file + a linux launcher. There is also an OpenViBE scenario for demonstration in there.

## TODO

* restrain the GUI to a simple (and lightweight) control of the channels (bias, N/P, impedance check, gain, etc.). See branch "light_GUI" for a quick (and dirty) simplification of the GUI.
