  
		  .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     SP, #0x1000
          MOV     R2, #TEST_NUM   // load the data word ...
          MOV     R5, #0    // FOR ONES
          MOV     R6, #0    // FOR ZEROS
          MOV     R7, #0    // FOR ALTERNATING 1 AND 0
MAIN_LOOP:
          LDR     R1, [R2]        // into R1
		  CMP     R1, #0          // R1 will hold the result
          BEQ     END

          PUSH   {R1}     // (Save)
		  BL 	  ONES
          POP    {R1}     // we want to use original value (restore)
          CMP     R5, R0
          MOVLT   R5, R0  // IF R5 IS LESS THAN R0 MOV INTO R5
          
          PUSH    {R1}
          BL      ZEROS
          POP     {R1}
          CMP     R6, R0
          MOVLT   R6, R0

          PUSH   {R1}
          BL     ALTERNATE
          POP    {R1}
          CMP    R7, R0
          MOVLT  R7, R0

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
            
ZEROS:
          PUSH    {LR}
          MOV     R3, #NUM_ONES
          LDR     R3, [R3]
          EOR     R1, R3
          BL      ONES
          POP     {LR}
          MOV     PC, LR
          

ALTERNATE:
         PUSH     {LR}
         MOV      R3, #INVERTED_NUM
         LDR      R3, [R3]
         EOR      R1, R3

         PUSH     {R1}
         BL       ONES
         POP      {R1}

        MOV      R3, #INVERTED_NUM
        LDR      R3, [R3, #4]
        EOR      R1, R3

            PUSH     {R1}
            BL       ONES
            POP      {R1}

// TAKE MAX AND PUT INTO R0

         POP      {LR}
         MOV      PC, LR

//TEST_NUM: .word   0x103fe00f, 0x103f000f, 0x100000ff, 0x0800f000, 0x1000ffff
//		  .word	  0x3ffe0001, 0x11111111, 0x00030001, 0x00007000, 0xfffff000, 0x00000000

TEST_NUM: .word 0x0000000A, 0

NUM_ONES: .word 0xffffffff

INVERTED_NUM: .word 0x55555555, 0xaaaaaaaa

          .end  
