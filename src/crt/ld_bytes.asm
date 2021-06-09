        DEFC    INIT_BORDER=0x00

LD_BYTES:
        INC     D                       ; This resets the zero flag. (D cannot hold +FF.)
        EX      AF, AF'                 ; The A register holds +00 for a header and +FF for a block of data. The carry flag is reset for verifying and set for loading.
        DEC     D                       ; Restore D to its original value.
        LD      A, INIT_BORDER          ; The border is made white.
        OUT     (IO_BORDER), A
        IN      A, (IO_BORDER)          ; Make an initial read of port '254'.
        RRA                             ; Rotate the byte obtained but keep only the EAR bit.
        AND     $20
        OR      $02                     ; Signal red border.
        LD      C, A                    ; Store the value in the C register (+22 for 'off' and +02 for 'on' - the present EAR state).
        CP      A                       ; Set the zero flag.

; The first stage of reading a tape involves showing that a pulsing signal actually exists (i.e. 'on/off' or 'off/on' edges).
LD_BREAK:
        RET     NZ                      ; Return if the BREAK key is being pressed.
LD_START:
        CALL    LD_EDGE_1               ; Return with the carry flag reset if there is no 'edge' within approx.
        JR      NC, LD_BREAK            ; 14,000 T states. But if an 'edge' is found the border will go cyan.

; The next stage involves waiting a while and then showing that the signal is still pulsing.
        LD      HL, $0415               ; The length of this waiting period will be almost one second in duration.
LD_WAIT:
        DJNZ    LD_WAIT
        DEC     HL
        LD      A, H
        OR      L
        JR      NZ, LD_WAIT
        CALL    LD_EDGE_2               ; Continue only if two edges are found within the allowed time period.
        JR      NC, LD_BREAK

; Now accept only a 'leader signal'.
LD_LEADER:
        LD      B, $9C                  ; The timing constant.
        CALL    LD_EDGE_2               ; Continue only if two edges are found within the allowed time period.
        JR      NC, LD_BREAK
        LD      A, $C6                  ; However the edges must have been found within about 3,000 T states of each other.
        CP      B
        JR      NC, LD_START
        INC     H                       ; Count the pair of edges in the H register until '256' pairs have been found.
        JR      NZ, LD_LEADER

; After the leader come the 'off' and 'on' parts of the sync pulse.
LD_SYNC:
        LD      B, $C9                  ; The timing constant.
        CALL    LD_EDGE_1               ; Every edge is considered until two edges are found close together - these will be the start and finishing edges of the 'off' sync pulse.
        JR      NC, LD_BREAK
        LD      A, B
        CP      $D4
        JR      NC, LD_SYNC
        CALL    LD_EDGE_1               ; The finishing edge of the 'on' pulse must exist. (Return carry flag reset.)
        RET     NC

; The bytes of the header or the program/data block can now be loaded or verified. But the first byte is the type flag.
        LD      A, C                    ; The border colours from now on will be blue and yellow.
        XOR     $03
        LD      C, A
        LD      H, $00                  ; Initialise the 'parity matching' byte to zero.
        LD      B, $B0                  ; Set the timing constant for the flag byte.
        JR      LD_MARKER               ; Jump forward into the byte loading loop.

; The byte loading loop is used to fetch the bytes one at a time. The flag byte is first. This is followed by the data bytes and the last byte is the 'parity' byte.
LD_LOOP:
        EX      AF, AF'                 ; Fetch the flags.
        JR      NZ, LD_FLAG             ; Jump forward only when handling the first byte.
        LD      (IX+$00), L             ; Make the actual load when required.

; A new byte can now be collected from the tape.
LD_NEXT:
        INC     IX                      ; Increase the 'destination'.
LD_DEC:
        DEC     DE                      ; Decrease the 'counter'.
        EX      AF, AF'                 ; Save the flags.
        LD      B, $B2                  ; Set the timing constant.
LD_MARKER:
        LD      L, $01                  ; Clear the 'object' register apart from a 'marker' bit.

; The following loop is used to build up a byte in the L register.
LD_8_BITS:
        CALL    LD_EDGE_2               ; Find the length of the 'off' and 'on' pulses of the next bit.
        RET     NC                      ; Return if the time period is exceeded. (Carry flag reset.)
        LD      A, $CB                  ; Compare the length against approx. 2,400 T states, resetting the carry flag for a '0' and setting it for a '1'.
        CP      B
        RL      L                       ; Include the new bit in the L register.
        LD      B, $B0                  ; Set the timing constant for the next bit.
        JP      NC, LD_8_BITS           ; Jump back whilst there are still bits to be fetched.

; The 'parity matching' byte has to be updated with each new byte.
        LD      A, H                    ; Fetch the 'parity matching' byte and include the new byte.
        XOR     L
        LD      H, A                    ; Save it once again.

; Passes round the loop are made until the 'counter' reaches zero. At that point the 'parity matching' byte should be holding zero.
        LD      A, D                    ; Make a further pass if the DE register pair does not hold zero.
        OR      E
        JR      NZ, LD_LOOP
        LD      A, H                    ; Fetch the 'parity matching' byte.
        CP      $01                     ; Return with the carry flag set if the value is zero. (Carry flag reset if in error.)
        RET

LD_FLAG:
        CP      A                       ; Set zero flag
        INC     DE                      ; Increase the counter to compensate for its 'decrease' after the jump.
        JR      LD_DEC

LD_EDGE_2:
        CALL    LD_EDGE_1               ; In effect call LD_EDGE_1 twice, returning in between if there is an error.
        RET     NC

; This entry point is used by the routine at LD_BYTES.
LD_EDGE_1:
        LD      A, $16                  ; Wait 358 T states before entering the sampling loop.
LD_DELAY:
        DEC     A
        JR      NZ, LD_DELAY
        AND     A

; The sampling loop is now entered. The value in the B register is incremented for each pass;  'time-up' is given when B reaches zero.
LD_SAMPLE:
        INC     B                       ; Count each pass.
        RET     Z                       ; Return carry reset and zero set if 'time-up'.
        LD      A, 0x7F                 ; Trigger for emulators to let them know we are a loader.
        IN      A, (IO_BORDER)
        RRA                             ; Shift the byte.
        XOR     C                       ; Now test the byte against the 'last edge-type';  jump back unless it has changed.
        AND     $20
        JR      Z, LD_SAMPLE

; A new 'edge' has been found within the time period allowed for the search. So change the border colour and set the carry flag.
        LD      A, C                    ; Change the 'last edge-type' and border colour.
        CPL
        LD      C, A
        AND     $07                     ; Keep only the border colour.
        OR      $08                     ; Signal 'MIC off'.
        OUT     (IO_BORDER), A          ; Change the border colour (red/cyan or blue/yellow).

        SCF                             ; Signal the successful search before returning.
        RET
