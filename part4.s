.text                   // executable code follows
.global _start                  
_start:   	LDR 	R3, =0xFF200020		//R3 holds HEX address
		  	LDR 	R4, =0xFF200050 	//R4 holds key address
			LDR 	R4, =0xFF20005C		// EC of keys
			LDR 	R11, =0xFFFEC600	// A9 Private Timer Address
			LDR 	R12, =2000000		// Will give 0.01 seconds for counter
			STR 	R12, [R11]
			MOV 	R12, #0b011
			STR 	R12, [R11, #8] 		// Set A = 1 (auto load), E = 1 (start timer)
			MOV 	R6, #0b111
			STR 	R6, [R4]			// Clear EC
			MOV 	R10, #0xffffffff 	//BOOLEAN - count if 1, stop if 0
		  	MOV 	R5, #0 				// HEX1-0 Counter          // 2 counters: tens and ones place
			MOV		R7, #0				// HEX3-2 Counter
DISPLAY:	LDR 	R6, [R4]
			CMP 	R6, #0b0000
			BLNE 	RESET				// If EC detects a 1, need to reset 
			CMP 	R5, #99				// If HEX1-0 hits 99, go back to 0
			MOVGT	R5, #0				
			ADDGT	R7, #1				// Also, add one to R7 if 99 hit
			CMP		R7, #59				// If HEX3-2 hit 59, go back to 0
			MOVGT	R7, #0				// Basically reset the clock
			// Finds bit codes for HEX1-0
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
            ORR     R6, R0			// R6 holds current bit code			
			MOV		R8, R6 			// save code for first two
			// Finds bit codes for HEX3-2
			MOV     R0, R7          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R6, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R6, #16
            ORR     R8, R6
			LSL     R0, #24
            ORR     R8, R0
            STR     R8, [R3]        // display the numbers on HEX3-0
			BL 		DO_DELAY		// delay before incrementing
			ADD		R5, #1			// increment
			B 		DISPLAY

/* Subroutine to perform a delay so numbers can increment
 * at a visible speed.
 */
DO_DELAY:  	LDR 	R12, =0xFFFEC60C	// read timer status
			LDR		R12, [R12]
			CMP 	R12, #0				// check if done counting (when = 1)
			BEQ 	DO_DELAY
			STR 	R12, [R11, #12]		// Reset status by writing a 1
			MOV 	PC, LR

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
RESET: 			MOV 	R6, #0b1111   // REASSERT EC
				STR 	R6, [R4]	  // Write 1's to EC to reset
				MVN 	R10, R10	  // Complement current value of R10
				CMP 	R10, #0
				BEQ 	DO_NOTHING
				B 		DISPLAY
				
DO_NOTHING: 	LDR 	R6, [R4]
				CMP 	R6, #0b0000
				BNE 	DISPLAY
				B 		DO_NOTHING
				
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
