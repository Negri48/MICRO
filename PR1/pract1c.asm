;**************************************************************************
; SBM 2020. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;; Grupo 2301
;; Miembro 1: Rodrigo Lardiés Guillén
;; Miembro 2: Víctor Sánchez de la Roda Núñez
;; Pareja número:
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;;No necesitamos declarar variables
DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC NEAR
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
MOV AX, DATOS
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
; FIN DE LAS INICIALIZACIONES
; COMIENZO DEL PROGRAMA
;;Cargamos los datos
MOV AX, 051H
MOV DS, AX
MOV AX, 073H
MOV ES, AX
MOV BX, 0222H
MOV AX, 1111H
MOV DI, AX

;MOV AL,DS:[3412H] ;;Guarda en AL, el contenido de la posicion 510H + 3412H = 3922H --> Guarda 4E en AL
;MOV AX, [BX] ;; Guarda en AX, el contenido de la posicion 0222H + 510H = 0732H --> Guarda 0000 en AX
;MOV [DI], AL ;; Guarda AL, en la direccion de memoria 1621H --> Guarda 00 en la direccion 1621H

;;Apartado a)
MOV AL, ES:[31F2H]

;;Apartado b)
MOV SI,002H
MOV AX,ES:[SI]

;;Apartado c)
MOV ES:[0EF1H],AL

; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
