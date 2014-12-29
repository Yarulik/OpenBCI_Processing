
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
//package fr.inria.openvibelink.write;


import processing.net.*;
import java.nio.ByteBuffer;
import processing.core.PApplet;
import static processing.core.PApplet.arrayCopy;

// send a raw stream of float in TCP.

// NB: Measures elapsed time between 2 calls in order to keep up with asked sample rate (oversampling by repeating values). This mechasism is analogous to (and doesn't interfere with) the drift correction feature of the openvibe acquisition server. 

// In openvibe acquisiton server: generic raw telnet reader, big endian, 32 bits float

// TODO: maybe use a queue to push data from main program and *then* send values (will need interpolation though)

public class WriteAnalog {

  // buffer for sending data (1 point per channel)
  private byte[] buffer;
  // for readability, how many bytes make one float
  private final int nbBytesPerFloat = 4;

  // TCP server
  private Server s;

  // How many elements we should expect
  private int nbChans;

  // Which pace we have to keep up with to sync with client
  private int sampleRate;

  // Last time we sent data (in nanoseconds since sample rate can get *really* high)
  private long tick;
  // We may have sent a little bit less or a little bit more to keep up with samplerate, record this to avoid offset
  private double leftoverDuplications = 0;

  public WriteAnalog(PApplet caller, int port, int nbChans, int sampleRate) {
    this.nbChans = nbChans;
    this.sampleRate = sampleRate;
    // 4 bytes per float values for the buffer
    buffer = new byte[nbChans*nbBytesPerFloat];
    // init network
    s = new Server(caller, port);
    // init clock
    tick = caller.millis();
  }

  // convert from float to bytes
  // http://stackoverflow.com/a/14619742
  private byte [] float2ByteArray (float value)
  {  
    return ByteBuffer.allocate(nbBytesPerFloat).putFloat(value).array();
  }

  // sends floats values to client
  // if array size is too big compared to nbChans sends only first elements, if too small fills with 0
  // WARNING: in this method no buffer is used, will try to comply with sample rate by repeating values. easy but not efficient.
  public void write(float[] data) {

    // fill float buffer and then pass it to TCPWriteAnalog to send over network
    for (int i = 0; i < nbChans; i++) {
      // fetch float value
      float chan = 0;
      if (i < data.length) {
        chan  = data[i];
      }
      // copy byte value to the correct place of the buffer buffer
      arrayCopy(float2ByteArray(chan), 0, buffer, i*nbBytesPerFloat, nbBytesPerFloat);
    }

    // elapsed time since last call, update tick
    long now = System.nanoTime() ;
    long elapsedTime = now - tick;
    tick = now;

    // now we have to compute how many times we should send data to keep up with sample rate (oversampling)
    // NB: could be 0 if framerate is very high
    double neededDuplications = sampleRate * (elapsedTime / 1000000000.0) + leftoverDuplications;
    // since we can't send only a fraction to be perfect, at the moment we're ok with an approximation
    long nbDuplications = Math.round(neededDuplications);
    // nbDuplications could be 0 if framerate is very high, remember offset for next time
    leftoverDuplications = neededDuplications - nbDuplications;

    // write as many times data as we need to sync with openvibe 
    for (int i = 0; i < nbDuplications; i++) {
      s.write(buffer);
    }
  }

  // this method, on the other hand, pipe buffered data but do not care about sample rate
  // data[nbChans][nbPoints]
  // TODO: interpolation
  // TODO: check number of channels
  public void write(float[][] data) {

    // if no data, pass
    if (data.length < 1) {
      return;
    }

    int nbPoints = data[0].length;

    // maybe not very efficient, but acquisition server expects data points for each channels in turns, so invert i and j
    for (int j = 0; j < nbPoints; j++) {
      // fill float buffer and then pass it to TCPWriteAnalog to send over network
      for (int i = 0; i < nbChans; i++) {

        // fill float buffer and then pass it to TCPWriteAnalog to send over network
        // fetch float value
        float chan = 0;
        if (i < data.length) {
          chan  = data[i][j];
        }
        // copy byte value to the correct place of the buffer buffer
        arrayCopy(float2ByteArray(chan), 0, buffer, i*nbBytesPerFloat, nbBytesPerFloat);
      }
      // send channels values for this chunk
      s.write(buffer);
    }
  }
}
