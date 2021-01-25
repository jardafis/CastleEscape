        public  rand

        section code_user

		; Fast RND
		;
		; An 8-bit pseudo-random number generator,
		; using a similar method to the Spectrum ROM,
		; - without the overhead of the Spectrum ROM.
		;
		; R = random number seed
		; an integer in the range [1, 256]
		;
		; R -> (33*R) mod 257
		;
		; S = R - 1
		; an 8-bit unsigned integer
		; http://www.z80.info/pseudo-random.txt
rand:
        ld      a, 1
        ld      b, a

        rrca                            ; multiply by 32
        rrca    
        rrca    
        xor     0x1f

        add     a, b
        sbc     a, 255                  ; carry

        ld      (rand+1), a
        and     %01111111               ; Ensure its positive

        ret     
