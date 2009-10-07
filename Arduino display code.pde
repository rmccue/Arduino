/*
Personal Project - Arduino display code
By: Ryan McCue
*/

#include <LCD4Bit.h>
#include <stdio.h>

LCD4Bit lcd = LCD4Bit(2);
int incomingByte = 0;
int mode = 0;
char high_buffer[4];
char low_buffer[4];
int condition;

int fine_led = 4;
int cloudy_led = 5;
int stormy_led = 6;

/**
 * Setup the serial port, LCD and LEDs
 */
void setup() {
	Serial.begin(9600);

	lcd.init();
	pinMode(fine_led, OUTPUT);
	pinMode(cloudy_led, OUTPUT);
	pinMode(stormy_led, OUTPUT);

	lcd.clear();
	lcd.printIn("Waiting for data");

	flash();
	flash();
	digitalWrite(fine_led, HIGH);
	digitalWrite(cloudy_led, HIGH);
	digitalWrite(stormy_led, HIGH);
}

/**
 * Wait for serial input
 */
void loop() {
	while(Serial.available()) {
		incomingByte = Serial.read();
		// 'H' = High temperature
		if(incomingByte == 72) {
			Serial.println("Ready for high");
			mode = 1;
			return;
		}
		// 'L' = Low temperature
		if(incomingByte == 76) {
			Serial.println("Ready for low");
			mode = 2;
			return;
		}
		// F, C, S = conditions (fine, cloudy, stormy)
		if(incomingByte == 70 || incomingByte == 67 || incomingByte == 83) {
			Serial.println("Changing condition...");
			setCondition(incomingByte);
			return;
		}

		switch (mode) {
			case 2:
				if(strlen(low_buffer) >= 2) {
					Serial.println("Too many digits!");
					return;
				}
				sprintf(strchr(low_buffer, 0), "%c", incomingByte);
				break;
			case 1:
				if(strlen(high_buffer) >= 2) {
					Serial.println("Too many digits!");
					return;
				}
				sprintf(strchr(high_buffer, 0), "%c", incomingByte);
				break;
		}

		if(strlen(high_buffer) >= 2 && strlen(low_buffer) >= 2) {
			outputData();

			sprintf(high_buffer, "");
			sprintf(low_buffer, "");
			mode = 0;
		}
	}
}

/**
 * Flash the LEDs
 */
void flash() {
	digitalWrite(fine_led, HIGH);
	digitalWrite(cloudy_led, LOW);
	digitalWrite(stormy_led, LOW);
	delay(1000);
	digitalWrite(fine_led, LOW);
	digitalWrite(cloudy_led, HIGH);
	digitalWrite(stormy_led, LOW);
	delay(1000);
	digitalWrite(fine_led, LOW);
	digitalWrite(cloudy_led, LOW);
	digitalWrite(stormy_led, HIGH);
	delay(1000);
}

/**
 * Display the data on the LCD
 */
void outputData() {
	lcd.clear();

	lcd.printIn("L: ");
	lcd.printIn(low_buffer);
	lcd.print(0xDF);
	lcd.printIn("C");

	lcd.printIn("  H: ");
	lcd.printIn(high_buffer);
	lcd.print(0xDF);
	lcd.printIn("C");

	lcd.cursorTo(2, 0);  //line=2, x=0.
	Serial.println(condition);
	switch (condition) {
		case 70:
			lcd.printIn("     Fine");
			break;
		case 67:
			lcd.printIn("     Cloudy");
			break;
		case 83:
			lcd.printIn("     Stormy");
			break;
		default:
			lcd.printIn("Invalid condition!");
			break;
	}

}

/**
 * Set the LED according to the data
 *
 * @param int Either of the 70 (F), 67 (C) or 83 (S) characters
 */
void setCondition(int byte) {
	digitalWrite(fine_led, LOW);
	digitalWrite(cloudy_led, LOW);
	digitalWrite(stormy_led, LOW);

	condition = byte;
	switch (byte) {
		case 70:
			digitalWrite(fine_led, HIGH);
			break;
		case 67:
			digitalWrite(cloudy_led, HIGH);
			break;
		case 83:
			digitalWrite(stormy_led, HIGH);
			break;
		default:
			Serial.print("Bad condition: ");
			Serial.println(byte);
	}
}
