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
LES BX,[BP +14]
MOV DX,[BP + 6]
MOV CX,[BP + 8]
MOV DI, [BP + 10]
MOV AX, [BP + 12]
; fill in with the required instructions
CMP DX,CX
JNS SALTO1
XCHG DX,CX

SALTO1: CMP DX,DI
JNS SALTO2
XCHG DX,DI
SALTO2: CMP DX,AX
JNS SALTO3
XCHG DX,AX

SALTO3: CMP CX,DI
JNS SALTO4
XCHG CX,DI
SALTO4:CMP CX,AX
JNS SALTO5
XCHG CX,AX

SALTO5:CMP DI,AX
JNS SALTO6
XCHG DI,AX

SALTO6: ADD DI,CX

MOV AX,DI
SAR AX,1

; return the result in AX if needed.

; pop the used registers

POP BP	;BP restored
RET

_calculaMediana ENDP



PUBLIC _enteroACadenaHexa  ; example for the first function
_enteroACadenaHexa PROC FAR 
PUSH BP
MOV BP, SP

PUSH AX

PUSH BX

MOV AX,[BP + 6]

MOV BX,[BP + 8]
LES CX,[BP + 10]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BUCLE: CMP AX, 0
JZ FIN
MOV DX,0
MOV DI, 10H

IDIV DI

CMP DX,0AH
JS NUMERO

ADD DX,37H
JMP LETRA
NUMERO: ADD DX,30H
LETRA:
MOV DS:[BX], DL
ADD BX,1
JMP BUCLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FIN:

MOV DS:[BX], 00H

POP BX
POP AX
POP BP	;BP restored
RET
_enteroACadenaHexa ENDP




PUBLIC _calculaLetraDNI  ; example for the first function
_calculaLetraDNI PROC FAR 


PUSH BP
MOV BP, SP

POP BP	;BP restored



RET
_calculaLetraDNI ENDP

_TEXT ENDS

END
