void ReadSCP1000(void) {}


void init_pressure_ground(void)
{
	for(int i = 0; i < 300; i++){		// We take some readings...
		delay(20);
		barometer.Read(); 	// Get initial data from absolute pressure sensor
		ground_pressure 	= (ground_pressure * 9l   + barometer.Press) / 10l;
		ground_temperature 	= (ground_temperature * 9 + barometer.Temp) / 10;
	}
	abs_pressure  = barometer.Press;
}

long
read_barometer(void)
{
 	float x, scaling, temp;

	barometer.Read(); 	// Get new data from absolute pressure sensor

	//abs_pressure 			= (abs_pressure + barometer.Press) >> 1;		// Small filtering
	abs_pressure 			= ((float)abs_pressure * .7) + ((float)barometer.Press * .3);		// large filtering
	scaling 				= (float)ground_pressure / (float)abs_pressure;
	temp 					= ((float)ground_temperature / 10.0f) + 273.15f;
	x 						= log(scaling) * temp * 29271.267f;
	return 	(x / 10);
}

// in M/S * 100
void read_airspeed(void)
{

}

#if BATTERY_EVENT == 1
void read_battery(void)
{
	battery_voltage1 = BATTERY_VOLTAGE(analogRead(BATTERY_PIN1)) * .1 + battery_voltage1 * .9;
	battery_voltage2 = BATTERY_VOLTAGE(analogRead(BATTERY_PIN2)) * .1 + battery_voltage2 * .9;
	battery_voltage3 = BATTERY_VOLTAGE(analogRead(BATTERY_PIN3)) * .1 + battery_voltage3 * .9;
	battery_voltage4 = BATTERY_VOLTAGE(analogRead(BATTERY_PIN4)) * .1 + battery_voltage4 * .9;

	#if BATTERY_TYPE == 0
		if(battery_voltage3 < LOW_VOLTAGE)
			low_battery_event();
		battery_voltage = battery_voltage3; // set total battery voltage, for telemetry stream
	#endif

	#if BATTERY_TYPE == 1
		if(battery_voltage4 < LOW_VOLTAGE)
			low_battery_event();
		battery_voltage = battery_voltage4; // set total battery voltage, for telemetry stream
	#endif
}
#endif


void read_current(void)
{
	current_voltage 	= CURRENT_VOLTAGE(analogRead(VOLTAGE_PIN_0)) * .1 	+ current_voltage * .9; //reads power sensor voltage pin
	current_amps 		= CURRENT_AMPS(analogRead(CURRENT_PIN_1)) * .1 		+ current_amps * .9; //reads power sensor current pin
	current_total		+= (current_amps * 0.27777) / delta_ms_medium_loop;
}


//v: 10.9453, a: 17.4023, mah: 8.2
