        public  _initISR
        public  ticks
        section code_user

        include "defs.asm"
        defc    VECTOR_TABLE_HIGH=0x80
        defc    VECTOR_TABLE=(VECTOR_TABLE_HIGH<<8)
        defc    JUMP_ADDR_BYTE=0x81
        defc    JUMP_ADDR=(JUMP_ADDR_BYTE<<8)|JUMP_ADDR_BYTE

_initISR:
        pushall 

        ld      hl, VECTOR_TABLE        ; Get vector table address
        ld      a, JUMP_ADDR_BYTE       ; High order byte of jump adress
        ld      (hl), a                 ; Store JUMP_ADDR in first byte of vector table
        ld      de, hl                  ; Fill the same data
        inc     de                      ; in the next 256
        ld      bc, 0x100               ; bytes of the vector table
        ldir    

        ld      hl, JUMP_ADDR           ; Point to the jump instruction address
        ld      a, JP_OPCODE            ; Store the opcode for JP
        ld      (hl), a
        inc     hl
        ld      de, isr                 ; Store the jump address which is the address of the
        ld      (hl), e                 ; isr routine.
        inc     hl
        ld      (hl), d

        ld      a, VECTOR_TABLE_HIGH    ; Write the address of the vector table
        ld      i, a                    ; to the i register
        im      2                       ; Enable interrupt mode 2
        ei                              ; Enable interrupts

        popall  
        ret     

isr:
        push    hl
        ;
        ; Increment the 16-bit ticks count
        ;
        ld      hl, (ticks)
        inc     hl
        ld      (ticks), hl
        pop     hl                      ; Restore the registers we used
        ei                              ; Enable interrupts
        reti                            ; Acknowledge and return from interrupt

        section bss_user
ticks:
        dw      0
