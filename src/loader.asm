;
; This loader will be contained within a REM statement in
; a BASIC program created using bin2rem. It is expected the
; crt0 code is appended to the end of the binary image created
; when this file is assembled.
;
; When executed this loader will copy the crt0 to is runtime
; location and jump to it.
;
        EXTERN  crt0
        EXTERN  crt0_end
        SECTION LOADER
        org     23766                   ; Start address used by bin2rem
        di
        ld      hl, data                ; crt0 binary image address
        ld      de, crt0                ; crt0 destimation address
        ld      bc, crt0_end-crt0       ; crt0 length
        ldir                            ; copy
        jp      crt0
data:
