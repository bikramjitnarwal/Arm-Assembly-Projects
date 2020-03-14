		  .text                   // executable code follows
          .global _start                  
_start:   	LDR R3, =0xFF200020		//R3 holds HEX address
		  	LDR R4, =0xFF200050 	//R4 holds key address
			LDR R4, =0xFF20005C		// EC of keys
			MOV R6, #0b111
			STR R6, [R4]			// Clear EC by putting 1 into it
			MOV R10, #0xffffffff 	// BOOLEAN - count if 1, stop if 0
		  	MOV R5, #0 				// HEX Counter
DISPLAY:	LDR R6, [R4]
			CMP R6, #0b0000
			BLNE RESET				// If EC detects a 1, need to reset 
			CMP 	R5, #99			// If HEX hits 99, go back to 0
			MOVGT	R5, #0
			MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R6, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R6, R0
            STR     R6, [R3]        // display the numbers on HEX
			BL 		DO_DELAY
			ADD		R5, #1			// Increment
			B DISPLAY

/* Subroutine to perform a delay so numbers can increment
 * at a visible speed.
 */
DO_DELAY: 	PUSH {R7}
			LDR R7, =400100 		// delay counter
LOOP: 		SUBS R7, R7, #1
			BNE LOOP
			POP {R7}
			MOV PC, LR

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0
 */
DIVIDE:			MOV    R2, #0
  CONT:			CMP    R0, #10
  				BLT    DIVIDE_END
				SUB    R0, #10
				ADD    R2, #1
				B      CONT
DIVIDE_END:		MOV    R1, R2     // quotient in R1 (remainder in R0)
				MOV    PC, LR

/* Subroutine to reset Edge Capture register for Keys. Also 
 * complements whatever is in r10 which dictates whether counter
 * is paused or counting.
 */
RESET: 			MOV R6, #0b1111
				STR R6, [R4]	  // Write 1's to EC to reset
				MVN R10, R10	  // Complement current value of R10
				CMP R10, #0
				BEQ DO_NOTHING
				B DISPLAY
				
DO_NOTHING: 			LDR R6, [R4]
				CMP R6, #0b0000
				BNE DISPLAY
				B DO_NOTHING
/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit pattern to be written to the HEX display
 */
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment   
	
	
		
