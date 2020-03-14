.global _start
_start:		LDR R2, =0xFF200020 // R2 holds address of HEX0
			LDR R3, [R2, #0x30]	// R3 holds value of Keys
			MOV R4, #0			// Current Value to display
			MOV R5, #0
			MOV R0, #0
			MOV R0, #BLANK_BIT
			LDRB R0, [R0]
DISPLAY:	STR R0, [R2]		// Set HEX0 to what the pattern in R0 is
			CMP R3, #0          // Is (R3 - 0) = 0?
			BEQ NO_KEY          // If R3 is 0, that means no key has been pressed
			CMP R3, #1          // Is (R3 - 1) = 0?
			BEQ ZERO            // If R3 is 0, that means key 0 has been pressed
			CMP R3, #2          // Is (R3 - 2) = 0?
			BEQ INCREMENT       // If R3 is 0, that means key 1 has been pressed
			CMP R3, #4          // Is (R3 - 4) = 0?
			BEQ DECREMENT       // If R3 is 0, that means key 2 has been pressed
			CMP R3, #8          // Is (R3 - 8) = 0?
			BEQ BLANK           // If R3 is 0, that means key 3 has been pressed
// When key values <= 1
WAIT: 		LDR R3, [R2, #0x30]	// R5 holds KEY Values
			CMP R3, #0			// Check if any keys pressed
			BNE WAIT			// Wait for key release	
			B DISPLAY
// When key values = 0			
NO_KEY:		LDR R3, [R2, #0x30]	// R3 holds value of Keys
			CMP R3, #0
			BEQ NO_KEY
			B	DISPLAY
ZERO: 		MOV R5, #0
			BL SEG7_CODE
			STR R0, [R2]
			B WAIT
INCREMENT: 	ADDS R5, #1
			CMP R5, #9			// Check if r5 is 9
			MOVGT R5, #0		// Make it 0 if it's greater than 9
			CMP R0, #0			// Check if bit code pattern is for blank
			MOVEQ R5, #0		// If it is blank, show 0 
			BL SEG7_CODE	
			STR R0, [R2]
			B WAIT
DECREMENT: 	SUBS R5, #1
			MOVLT R5, #9		// Make it 9 if R5 is less than 0
			CMP R0, #0			// Check if bit code pattern is for blank
			MOVEQ R5, #0		// If it is blank, show 0 
			BL SEG7_CODE
			STR R0, [R2]
			B WAIT
BLANK: 		MOV R0, #BLANK_BIT
			LDRB R0, [R0]
			MOV R5, #0			// Reset count
			STR R0, [R2]
			B WAIT
	
/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit pattern to be written to the HEX display
 */
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R5         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
			
BLANK_BIT:	.byte   0b00000000
			.skip   3
	
