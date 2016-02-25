import oscP5.*;
import netPS.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int firstValue;
int secondValue;

void setup() {
  size(400,400)
  frameRate(60);
  
  osc = new OscP5(this, 12000);
  
  myRemoteLocation = new NetAddress("127.0.0.1", 12000)
}

void draw() {
  background (firstValue);
}

void draw() {
 background(firstValue); 
}

void mousePressed() {
  /* Create a message and send it to yourself */
  OscMessage myMessage = new OscMessage ("/foo/notes i f");
  
  myMessage.add(123);
  
  oscP5.send(myMessage, myRemoteLocation);
}

void oscEvent(OscMessage msg) {
  print ("### recevied an osc message.");
  print ("addrpattern: " + msg.addrPattern());
  println(msg.typetag());
  
  if (msg.checkAddrPattern("/foo/notes") == true) {
    if (theOscMessage.checkTypeTag("if") {
       firstValue = theOscMessage.get(0).intValue();
       secondValue = theOscMessage.get(1).floatValue;
       println("value " + firstValue + ", " + secondValue);
    }
  }
  
}