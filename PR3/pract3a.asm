;**************************************************************************
;* BASIC ASSEMBLY PROGRAM STRUCTURE EXAMPLE to use with C code link
;* SBM / MBS 2020
;*
;**************************************************************************


; CODE SEGMENT DEFINITION
_TEXT SEGMENT BYTE PUBLIC 'CODE'
ASSUME CS: _TEXT, 


PUBLIC _calculaMediana  ; example for the first function
_calculaMediana PROC FAR 

PUSH BP
MOV BP, SP
; Push the registered used 

; Recover the data from stack , BP+6, etc (integers, pointers, etc)

; fill in with the required instructions

; return the result in AX if needed.

; pop the used registers

POP BP	;BP restored
RET

_calculaMediana ENDP



_TEXT ENDS

END
