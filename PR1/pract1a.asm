;**************************************************************************
; SBM 2020. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;; Grupo 2301
;; Miembro 1: Rodrigo Lardiés Guillén
;; Miembro 2: Víctor Sánchez de la Roda Núñez
;; Pareja número: 
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;; En este ejercicio no hace falta declarar ninguna variable
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
; -- rellenar con las instrucciones solicitadas

;;Cargamos los datos
MOV AX, 0099H
MOV BX, 00B2H
MOV CX, 3412H
MOV DX, CX
;;Para alcanzar la posicion 65225H tenemos que
;;guardar en DS la posicion 65000H (ponemos
;;6500H porque se multiplica por 16) + offset
MOV AX, 6500H
MOV DS, AX
MOV BH, DS:[225H]
MOV BL, DS:[226H]
MOV AX, 6000H
MOV DS, AX
;;Los corchetes sirven para acceder a la direccion
;;del contenido
MOV DS:[8H], CH
MOV AX, [SI]
MOV BX,[BP+10]

; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
