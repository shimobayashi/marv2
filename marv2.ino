#include <Wire.h>
#include <Adafruit_BMP085.h>

Adafruit_BMP085 bmp;
  
void setup() {
  Serial.begin(9600, SERIAL_8E1);
  if (!bmp.begin()) {
	Serial.println("Could not find a valid BMP085 sensor, check wiring!");
	while (1) {}
  }
}
  
void loop() {
    Serial.print("Temperature\t");
    Serial.print(bmp.readTemperature());
    
    Serial.print("\tPressure\t");
    Serial.print(bmp.readPressure());
    
    int humidity = (int)((analogRead(A0) / (1024 / 5.0)) / 1.0 * 100);
    Serial.print("\tHumidity\t");
    Serial.print(humidity);
    
    Serial.println("");
    
    delay(1000);
}
