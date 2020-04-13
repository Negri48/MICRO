;**************************************************************************
;* BASIC ASSEMBLY PROGRAM STRUCTURE EXAMPLE to use with C code link
;* SBM / MBS 2020
;* Autores: Rodrigo Lardiés Guillén
;           Víctor Sánchez de la Roda Núñez
;**************************************************************************
 

; CODE SEGMENT DEFINITION
_TEXT SEGMENT BYTE PUBLIC 'CODE'
ASSUME CS: _TEXT,


;********************************************************************************************************************************************************************
;; Look Up Tables para el tercer apartado
tabla db 84,82,87,65,71,77,89,70,80,68,88,66,78,74,90,83,81,86,72,76,67,75,69 ;Tabla que contiene valores ASCII de las letras de los DNI
coef_mod_23 db 14,6,19,18,11,8,10,1 ;Tabla que contiene los coeficientes que acompañan a cada cifra en el algoritmo modular del apartado 3 (explicado después)
;*********************************************************************************************************************************************************************





;*********************************************************************************************************************************************************************
; funcion1: _calculaMediana

PUBLIC _calculaMediana 
_calculaMediana PROC FAR 
;Guardamos el puntero a la pila
PUSH BP
MOV BP, SP
;Hacemos push a la pila los registros utilizados
PUSH BX DX CX DI
;Recuperamos las variables necesarias para el ejercicio
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
POP DI CX DX BX BP	;BP restored
RET

_calculaMediana ENDP
;*************************************************************************************************************




;*************************************************************************************************************
; funcion2: _enteroACadenaHexa
PUBLIC _enteroACadenaHexa  ; example for the first function
_enteroACadenaHexa PROC FAR 
PUSH BP
MOV BP, SP

PUSH AX
PUSH DI
PUSH CX
PUSH DX



LES DI,[BP + 8]
MOV AX,[BP + 6]
MOV CX, 0 ;;Contador
MOV WORD PTR ES:[DI],0
MOV WORD PTR ES:[DI+2],0


CMP AX,0
JZ CASO_CERO

BUCLE: 
    CMP AX, 0
    JZ BUCLE_PILA
    MOV DX,0
    MOV BX, 10H
    IDIV BX
    CMP DX,0AH
    JS NUMERO
    ADD DX,37H
    JMP LETRA
    NUMERO: 
        ADD DX,30H
    LETRA:
        PUSH DX
    INC CX
JMP BUCLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



CASO_CERO:
    MOV ES:[DI],30H
    INC DI 
    JMP TERMINAR


BUCLE_PILA:
    CMP CX,0
    JZ TERMINAR
    POP AX
    MOV ES:[DI],AL
    INC DI
    DEC CX
    JMP BUCLE_PILA

TERMINAR:


MOV ES:[DI], 00H
POP CX
POP DX
POP DI
POP AX
POP BP	;BP restored
RET
_enteroACadenaHexa ENDP
;*************************************************************************************************************



;*************************************************************************************************************
; funcion3: _calculaLetraDNI
PUBLIC _calculaLetraDNI  ; example for the first function
_calculaLetraDNI PROC FAR 


PUSH BP 
MOV BP, SP

PUSH SI DI CX DX AX BX ES DS

LDS DI,[BP + 6] ;;Nº DNI


MOV CX, 8 ;;CONTADOR

;;AX = BYTE DE DNI / RESULTADO
;; SI = OFFSET
;;  CX  = CONTADOR
;;DX = 
;; BX = SUMA
MOV SI, OFFSET coef_mod_23
MOV DX,0 
MOV BX,0
BUCLE_DNI:
    MOV AX,0
    CMP CX,0
    JZ TERMINAR_DNI
    MOV DL, byte ptr CS:[SI]
    MOV AL, byte ptr DS:[DI]
    SUB AX,30H
    MUL DL
    ADD BX,AX
    INC SI
    INC DI
    DEC CX
JMP BUCLE_DNI


TERMINAR_DNI:
;;En BX tenemos el resultado de la aritmética modular del nº del DNI
;;Queremos ahora dividirlo por 23 y quedarnos con el resto
MOV AX,BX
MOV BX,0
MOV BX,23
DIV BL

;;El resto está en AH, queremos mirar en LUT
MOV DX,0
MOV DL,AH
MOV BX,0
;;Obtenemos la dirección donde almacenaremos la letra
LES SI,[BP + 10]
MOV BX, OFFSET tabla 
ADD BX, DX

MOV DL, byte ptr CS:[BX]
MOV byte ptr ES:[SI], DL
POP DS ES BX AX DX CX DI SI BP	;BP restored
RET
_calculaLetraDNI ENDP
;*************************************************************************************************************
_TEXT ENDS
END
