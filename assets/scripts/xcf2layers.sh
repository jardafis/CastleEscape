#!/bin/bash
# xcf2png.sh
# Invoke The GIMP with Script-Fu convert-xcf-png
# No error checking.
{
cat <<EOF
(define (convert-xcf filename outpath)
    (let* (
            (image (car (gimp-xcf-load RUN-NONINTERACTIVE filename filename )))
            (drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
            )
        (begin (display "Exporting ")(display filename)(display " -> ")(display outpath)(newline))
        (gimp-image-convert-indexed image 0 0 16 0 0 "null")
        (file-gif-save RUN-NONINTERACTIVE image drawable outpath outpath 0 1 1000 2)
        (gimp-image-delete image)
    )
)

(gimp-message-set-handler 1) ; Messages to standard output
EOF

echo "(convert-xcf \"$1\" \"$2\")"

echo "(gimp-quit 0)"

} | gimp -i -b -
