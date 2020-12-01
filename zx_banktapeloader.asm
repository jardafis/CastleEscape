     EXTERN __BANK_0_head
     EXTERN __BANK_1_head
     EXTERN __BANK_2_head
     EXTERN __BANK_3_head
     EXTERN __BANK_4_head
     EXTERN __BANK_5_head
     EXTERN __BANK_6_head
     EXTERN __BANK_7_head
     EXTERN __BANK_0_tail
     EXTERN __BANK_1_tail
     EXTERN __BANK_2_tail
     EXTERN __BANK_3_tail
     EXTERN __BANK_4_tail
     EXTERN __BANK_5_tail
     EXTERN __BANK_6_tail
     EXTERN __BANK_7_tail

	SECTION code_crt_init
	call _bankedtapeloader

     SECTION code_driver

     defc ZX_BANK_IOPORT = 0x7ffd
     INCLUDE "target/zx/def/sysvar.def"


     PUBLIC _bankedtapeloader
_bankedtapeloader:
     ld   ix,__BANK_0_head
     ld   de,__BANK_0_tail - __BANK_0_head
     ld   c,0x10 ;Bank 0
     call load_block
     ret  c
     ld   ix,__BANK_1_head
     ld   de,__BANK_1_tail - __BANK_1_head
     ld   c,0x11 ;Bank 1
     call load_block
     ret  c
     ld   ix,__BANK_2_head
     ld   de,__BANK_2_tail - __BANK_2_head
     ld   c,0x12 ;Bank 2
     call load_block
     ret  c
     ld   ix,__BANK_3_head
     ld   de,__BANK_3_tail - __BANK_3_head
     ld   c,0x13 ;Bank 3
     call load_block
     ret  c
     ld   ix,__BANK_4_head
     ld   de,__BANK_4_tail - __BANK_4_head
     ld   c,0x14 ;Bank 4
     call load_block
     ret  c
     ld   ix,__BANK_5_head
     ld   de,__BANK_5_tail - __BANK_5_head
     ld   c,0x15 ;Bank 5
     call load_block
     ret  c
     ld   ix,__BANK_6_head
     ld   de,__BANK_6_tail - __BANK_6_head
     ld   c,0x16 ;Bank 6
     call load_block
     ret  c
     ld   ix,__BANK_7_head
     ld   de,__BANK_7_tail - __BANK_7_head
     ld   c,0x17 ;Bank 7
     call load_block
     di
     ld   a,0x10
     ld   (SV_BANKM),a
     ld   bc,ZX_BANK_IOPORT
     out  (c),a
     ei
     ret

load_block:
     ld   a,d
     or   e
     ret  z     ;Nothing to load
     ld   a,c
     di
     ld   (SV_BANKM),a
     ld   bc,ZX_BANK_IOPORT
     out  (c),a
     ei
     ld   hl,(23613)
     push hl
     ld   hl,load_block1
     push hl
     ld   (23613),sp
     ld   a,255  ;Data block
     scf         ;Load
     call 0x556	 ; call the tape loader in ROM
load_block1:
     pop  hl
     pop  hl
     ld   (23613),hl
     and  a
     ret

