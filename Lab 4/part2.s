  
		  .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R2, #TEST_NUM   // load the data word ...
MAIN_LOOP:
          LDR     R1, [R2]        // into R1
		  CMP     R1, #0          // R1 will hold the result
          BEQ     END
		  BL 	  ONES
          ADD     R2, #4
          B       MAIN_LOOP
END:      B       END

ONES:     MOV     R0, #0          // R0 will return the result
ONES_LOOP:CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     ONES_END
          LSR     R3, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R3
          ADD     R0, #1          // count the string length so far
          B       ONES_LOOP            
ONES_END: MOV     PC, LR
            

TEST_NUM: .word   0x103fe00f, 0x103f000f, 0x100000ff, 0x0800f000, 0x1000ffff
		  .word	  0x3ffe0001, 0x11111111, 0x00030001, 0x00007000, 0xfffff000, 0x00000000

          .end  
