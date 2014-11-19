/**************************************************************************/
/*! 
    @file     pool_timer.pde
    @author   Simio Labs
    @license  BSD (see license.txt)
    
    This program attemps to control a pool pump using an Arduino, DS1307
    Real Time Clock and a relay.
    The controller checks the start time, when the current time is greater 
    than this, the pump is turned on and the LED will blink. After the 
    current time is greater than the end time both the LED and the pump are
    turned off.
*/
/**************************************************************************/

#include <SimpleTimer.h>
#include "Wire.h"
#define DS1307_ADDRESS 0x68

#define LED   13
#define RELAY 12

//define your schedule
const int startHour =   19; //24h
const int startMin =    53;
const int endHour =     19; //24h
const int endMin =      55;

// the timer object
SimpleTimer ledTimer;
int buffer[7];
int startMinutes;
int endMinutes;

void setup() {
  Serial.begin(115200);
  Wire.begin();
  
  // initialize the digital pin as an output.
  pinMode(LED, OUTPUT);
  pinMode(RELAY, OUTPUT);
  digitalWrite(LED, LOW);
  digitalWrite(RELAY, LOW);
  ledTimer.setInterval(1000, blinkLed);
  
  startMinutes = startHour * 60 + startMin;
  endMinutes = endHour * 60 + endMin;
}

void loop() {
  readDate(buffer);
  printDate(buffer);
  int currentMinutes = buffer[2] * 60 + buffer[1];
  
  //check if pump should be turned on
  if(currentMinutes >= startMinutes && currentMinutes < endMinutes) {
    Serial.println("Start pump");
    digitalWrite(RELAY, HIGH);
    //loop while pumping water
    while(currentMinutes < endMinutes) {
      ledTimer.run();
      readDate(buffer);
      currentMinutes = buffer[2] * 60 + buffer[1];
    }
    //turn off pump and LED
    Serial.println("Stop pump");
    digitalWrite(LED, LOW);
    digitalWrite(RELAY, LOW);
  }
  delay(1000);
}

// a function to be executed periodically
void blinkLed() {
  digitalWrite(LED, !digitalRead(LED));
}

byte bcdToDec(byte val) {
// Convert binary coded decimal to normal decimal numbers
  return ( (val/16*10) + (val%16) );
}

void readDate(int *buffer) {
  // Reset the register pointer
  Wire.beginTransmission(DS1307_ADDRESS);

  byte zero = 0x00;
  Wire.write(zero);
  Wire.endTransmission();

  Wire.requestFrom(DS1307_ADDRESS, 7);

  buffer[0] = bcdToDec(Wire.read()); //seconds
  buffer[1] = bcdToDec(Wire.read()); //minutes
  buffer[2] = bcdToDec(Wire.read() & 0b111111); //24 hour time
  buffer[3] = bcdToDec(Wire.read()); //0-6 -> sunday - saturday
  buffer[4] = bcdToDec(Wire.read()); //day
  buffer[5] = bcdToDec(Wire.read()); //month
  buffer[6] = bcdToDec(Wire.read()); //year
}

void printDate(int *buffer) {
  //print the date EG   3/1/11 23:59:59
  Serial.print(buffer[4]);
  Serial.print("/");
  Serial.print(buffer[5]);
  Serial.print("/");
  Serial.print(buffer[6]);
  Serial.print(" ");
  Serial.print(buffer[2]);
  Serial.print(":");
  Serial.print(buffer[1]);
  Serial.print(":");
  Serial.println(buffer[0]);
}
