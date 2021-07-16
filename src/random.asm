        public  rand

        section CODE_2

        ;
        ; Xorshift PRNG
        ;
        ; https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
        ;
        ; Input:
        ;		None
        ;
        ; Output:
        ; 		hl - PRN
        ;
        ; Corrupts:
        ;		a
        ;
rand:
        ld      hl, 1                   ; seed must not be 0

        ld      a, h
        rra
        ld      a, l
        rra
        xor     h
        ld      h, a
        ld      a, l
        rra
        ld      a, h
        rra
        xor     l
        ld      l, a
        xor     h
        ld      h, a

        ld      (rand+1), hl

        ret
