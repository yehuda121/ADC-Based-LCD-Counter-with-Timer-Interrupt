# ADC-Based LCD Counter with Timer1 Interrupt

## Overview
This project implements a counter using the PIC16F877 microcontroller. The counter value is displayed on an LCD and is incremented or decremented based on the input from an analog sensor via the ADC module. The program uses Timer1 for timing and interrupts to manage tasks effectively.

## Features
- **Analog-to-Digital Conversion (ADC):** Reads analog input to determine whether to increment or decrement the counter.
- **LCD Display:** Displays the current counter value.
- **Timer1 Interrupt:** Ensures precise timing for ADC reading and counter updates.
- **Error Handling:** Detects and displays errors if the ADC input is out of range.

## Hardware Requirements
- PIC16F877 Microcontroller
- LCD Display (16x2 or similar)
- Analog sensor (e.g., potentiometer)
- Supporting components (resistors, capacitors, etc.)

## Software Configuration
### Configuration Bits
- **_CP_OFF:** Code protection off
- **_WDT_OFF:** Watchdog Timer off
- **_BODEN_OFF:** Brown-out Detect off
- **_PWRTE_OFF:** Power-up Timer off
- **_HS_OSC:** High-Speed Oscillator
- **_WRT_ENABLE_ON:** Write Protection on
- **_LVP_OFF:** Low-Voltage Programming off
- **_DEBUG_OFF:** In-Circuit Debugger off
- **_CPD_OFF:** Data Code Protection off

### Initialization
- **Ports Configuration:**
  - PORTA: Configured for ADC input
  - PORTD and PORTE: Configured for LCD interface
- **ADC Initialization:**
  - ADCON0: Set for Fosc/32, ADC enabled
  - ADCON1: Configured for analog and digital channels
- **Timer1 Initialization:**
  - T1CON: Set with 1:8 prescaler, timer enabled

## Program Structure
### Main Loop
- Initializes peripherals (ADC, LCD, Timer1)
- Starts the main loop to handle ADC readings and counter updates
- Updates the LCD display based on ADC input

### Interrupt Service Routine
- Handles Timer1 overflow
- Processes ADC conversion completion

### Subroutines
- **init:** Initializes the LCD
- **write_inst:** Writes instructions to the LCD
- **write_data:** Writes data to the LCD
- **set_cursor:** Sets the cursor position on the LCD
- **d_20:** Provides a 20ms delay
- **d_5:** Provides a 5ms delay

## Usage
1. Connect the hardware components as per the requirements.
2. Load the program onto the PIC16F877 microcontroller.
3. Power on the system.
4. The counter value will be displayed on the LCD.
5. Adjust the analog sensor to increment or decrement the counter value.
