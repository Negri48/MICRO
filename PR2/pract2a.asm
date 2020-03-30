;**************************************************************************
; SBM 2018. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
;DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT
tabla db 444 dup (9 dup (50), 9 dup (-50)), 8 dup (50); Tabla de 8000 bytes de la onda ya inicializada, 444*18 + 8 = 8000
;9 bytes arriba (50), despues 9 bytes abajo (-50), y asi sucesivamente.
fichero db "gen_la.wav", 0; Guardamos el nombre del fichero en datos 
EXTRN Init_WAV_header:FAR
EXTRN fopen:FAR
EXTRN Write_WAV:FAR
EXTRN fclose:FAR
DATOS ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE PILA 
PILA SEGMENT STACK "STACK" 
  DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO EXTRA 
EXTRA SEGMENT 
EXTRA ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE CODIGO 
CODE SEGMENT 
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL 
INICIO PROC 
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
  MOV AX, DATOS
  MOV DS, AX
  MOV AX, PILA
  MOV SS, AX
  MOV AX, EXTRA
  MOV ES, AX
  MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

  ;Inicializar el modulo WAV especificando la frecuencia de muestreo
  ;SAMPLE RATE
  MOV DX, 8000
  ;NUMBER OF SAMPLES
  MOV CX, 8000
  ;Llamada a la funcion
  CALL Init_WAV_Header

  ;Abrimos un fichero en el disco
  ;Guardamos en DX la direccion del nombre del fichero, OFFSET devuelve donde empieza fichero
  MOV DX, OFFSET fichero
  CALL fopen
  ;fopen carga en AX el descriptor del ficheroque abrey si hay un error CF=1

  JC FIN; Capturamos el error si CF=1 y acaba el programa

  ;Escribir en disco la señal de 440 Hz 
  ;Guardamos en BX el descriptor y en DI el comienzo de la tabla
  MOV BX, AX
  MOV DI, OFFSET tabla
  ;Llamamos a Write_WAV que carga en AX el numero total de bytes escritos
  CALL Write_WAV

  JC FIN; Capturamos el error si CF=1 otra vez

  ;Cerramos el archivo y en AX ya esta el descriptor del fichero 
  CALL fclose

FIN:  ;;HA HABIDO UN ERROR 
  MOV AX, 4C00H
  INT 21H 

INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
END INICIO