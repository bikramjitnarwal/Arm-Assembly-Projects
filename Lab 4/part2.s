  
		  .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R2, #TEST_NUM   
		  MOV	  R5, #0
MAIN:     LDR     R1, [R2]        // 
		  CMP	  R1, #0
		  BEQ     END
		  BL	  ONES
		  CMP	  R5, R0
		  MOVLT   R5, R0
		  ADD	  R2, #4
		  B		  MAIN


ONES:     MOV     R0, #0          // R0 will hold the result
ONES_LOOP:CMP     R1, #0          // loop until the data contains no more 1's
          MOVEQ   PC, LR            
          LSR     R3, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R3      
          ADD     R0, #1          // count the string length so far
          B       ONES_LOOP            

END:      B       END             

TEST_NUM: .word   0x103fe00f, 0x103f000f, 0x100000ff, 0x0800f000, 0x1000ffff
		  .word	  0x3ffe0001, 0x11111111, 0x00030001, 0x00007000, 0xfffff000, 0x00000000

          .end  