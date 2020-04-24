;**************************************************************************
; SBM 2020. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;; Grupo 2301
;; Miembro 1: Rodrigo Lardiés Guillén
;; Miembro 2: Víctor Sánchez de la Roda Núñez
;; Pareja número: 
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
 text_info_dec_to_hex db "El numero decimal a convertir es: ", '$'
 text_info_hex_to_dec db 10,13,"El numero hexadecimal a convertir es: ", '$'
 text_res_dec_to_hex db 10,13,"El numero en hexadecimal es : ", '$'
 text_res_hex_to_dec db 10,13,"El numero en decimal es : ", '$'
 numero_decimal db "255",'$'
 numero_hexadecimal db "FF",'$'
 resultado db 6 dup(0)
 resultado2 db 6 dup(0)
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

MOV DX, OFFSET text_info_dec_to_hex
MOV AH,9H
INT 21H
MOV DX, OFFSET numero_decimal
MOV AH,9H
INT 21H
MOV DX, OFFSET  text_res_dec_to_hex
MOV AH,9H
INT 21H


PUSH DS 
MOV CX, OFFSET resultado
MOV BX, SEG numero_decimal
MOV DS,BX
MOV BX, OFFSET numero_decimal
MOV AH,12H
INT 60H
POP DS
MOV DX, CX
MOV AH,9H
INT 21H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOV DX, OFFSET text_info_hex_to_dec
MOV AH,9H
INT 21H
MOV DX, OFFSET numero_hexadecimal
MOV AH,9H
INT 21H
MOV DX, OFFSET  text_res_hex_to_dec
MOV AH,9H
INT 21H


PUSH DS 
MOV CX, OFFSET resultado2
MOV BX, SEG numero_hexadecimal
MOV DS,BX
MOV BX, OFFSET numero_hexadecimal
MOV AH,13H
INT 60H
POP DS
MOV DX, CX
MOV AH,9H
INT 21H




TERMINAR:
    MOV AX, 4C00H
    INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
