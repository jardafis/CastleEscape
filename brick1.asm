	SECTION code_user


	EXTERN _screenTab
	EXTERN _MagickImage

	PUBLIC _brick1
_brick1:
	push af
	push bc		; Pointer to image
	push de
	push hl		; Pointer to screen

	ld a,32
.l_2
	push	af

	ld hl,(_screenTab)		; Get the first pixel row
	add	a,l					; add the x offset
	ld l,a
	dec l					; need 0 based offset so subtract 1
	ld bc,_MagickImage+7	; point to the image

	ld d,8
.l_1
	ld a,(bc)
	ld (hl), a

	inc bc
	inc h					; add hl,0x100

	dec d
	jr nz,l_1

	pop af
	dec a
	jr nz,l_2



	ld bc,32
.l_3
	push	bc

	ld hl,(_screenTab+(23*8*2))
	add hl,bc
	dec hl
	ld bc,_MagickImage+7

	ld d,8
.l_4
	ld a,(bc)
	ld (hl), a
	inc bc
	inc	h
	dec d
	jr nz,l_4

	pop bc
	dec c
	jr nz,l_3


	pop hl
	pop de
	pop bc
	pop af
	ret
