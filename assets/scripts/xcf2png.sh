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
        (file-png-save2 RUN-NONINTERACTIVE image drawable outpath outpath 0 9 0 0 0 0 0 0 0)
        (gimp-image-delete image)
    )
)

(gimp-message-set-handler 1) ; Messages to standard output
EOF

echo "(convert-xcf \"$1\" \"$2\")"

echo "(gimp-quit 0)"

} | gimp -i -b -
