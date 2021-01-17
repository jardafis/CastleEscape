        extern	_screenTab
        public  _cls
		public	clearAttr
		public	clearChar
        section code_user

        include "defs.asm"

        ;
        ; Clear the screen bitmap and attr data.
        ;
        ; On entry, l contains the attribute to fill the attr memory.
        ;
_cls:
        push	af
        push    bc
        push    hl

		ld		a,l
		ld		(clsAttrib),a

        halt    

        di      
        ld      (clsTempSP),sp

        ld      sp,SCREEN_ATTR_END
        ld      h,l                     ; attr input parameter in l
        ; If we divide the attr length by 4 it will
        ; fit in 8 bits and we can use djnz
        ld      b,SCREEN_ATTR_LENGTH/4
.loop2
        ; Push 4 bytes into screen attr memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        djnz    loop2

        ld      hl,0                    ; data to fill
        ; If we divide the screen length by 32 it will
        ; fit in 8 bits and we can use djnz
        ld      b,SCREEN_LENGTH/32
.loop
        ; Push 32 bytes of 0 into the screen memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        djnz    loop
.clsTempSP = $+1
        ld      sp,0x0000
        ei      

        pop     hl
        pop     bc
        pop		af
        ret     

		;
		; Set the screen attribute position specified by 'bc' to
		; the attribute used to clear the screen.
		;
		; Entry:
		;		b - Attrib Y location
		;		c - Attrib X location
		;
		; Corrupts:
		;		af, bc, hl
		;
clearAttr:
		ld		l,b
		ld		h,0
		hlx		32
		ld		b,0
		add		hl,bc
		ld		bc,SCREEN_ATTR_START
		add		hl,bc
		ld		a,(clsAttrib)
		ld		(hl),a
		ret

		;
		; Clear the character position specified by 'bc'
		;
		; Entry:
		;		b - Char Y location
		;		c - Char X location
		;
		; Corrupts:
		;		af, bc, hl
		;
clearChar:
		ld		l,b
		ld		h,0
		hlx		16

		di
		ld		(clearCharSP),sp
		ld		sp,_screenTab
		add		hl,sp
		ld		sp,hl
		pop		hl
		ld		a,l
		add		c
		ld		l,a
		xor		a
		ld		b,8
.clearCharLoop
		ld		(hl),a
		inc		h
		djnz	clearCharLoop

.clearCharSP = $ + 1
		ld		sp,0x0000
		ei

		ret

		section bss_user
clsAttrib:
		ds		1
