;**************************************************************************
; SBM 2018. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
;DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT
  tabla db 8000 dup(0); Tabla de 8000 bytes de la onda ya inicializada
;9 bytes arriba (50), despues 9 bytes abajo (-50), y asi sucesivamente.
  nombrefichero db 0, 0;nombre
  fichero db 30, 33 dup(0),13, 10, '$' ;nombre del fichero
  textonombre db "Introduzca el nombre del archivo: ",13,10,'$'; Texto que se mostrara por pantalla 
  textofrec db "Frecuencia (Hz) deseada: ",13,10,'$'; Texto que se mostrara por pantalla
  
  salida db "Hasta luego!",'$' ;Palabra que indica el fin del bucle
  salidanoquit db "Archivo creado correctamente.",13,10,'$' ;Palabra que indica el fin del bucle
  frecuencia db 4 dup(0), 13, 10, '$'

  frec_hex db 2 dup(0),13,10,'$'

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
  textoquit db "quit" ;Palabra que indica el fin del bucle
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

  CALL FUNC_PRINCIPAL
 

FIN: MOV AX, 4C00H
  INT 21H

INICIO ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SUBRUTINA QUE PIDE UN ARCHIVO Y UNA FRECUENCIA Y GENERA UN ARCHIVO.WAV
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNC_PRINCIPAL PROC NEAR

  FUNCION:
    ;Imprime el texto que solicita un nombre
    MOV DX, OFFSET textonombre ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H

    ;Leemos el nombre del archivo escrito por teclado
    MOV AH, 0AH ;Función captura de teclado
    MOV DX, OFFSET nombrefichero 
    MOV nombrefichero[0], 30
    INT 21H 
    ;Al leer debemos quitar los dos primeros bytes que los utiliza el SO
    MOV BL, nombrefichero[1]
    MOV BH, 0
    ADD BX, 2
    MOV nombrefichero[BX], 0
    ;;Si lo que hemos introducido es "quit" tenemos que terminar el programa
    CLD
    MOV CX, 5 ;;Inicializamos una cantidad de Bytes (4 valen porque "quit cabe")
    MOV DI, OFFSET textoquit
    MOV SI, OFFSET fichero 
    REPE CMPSB 
    JE TERMINA

    ;;Si no es quit, tenemos que pedir ya almacenar una frecuencia en HzS
    ;Imprime el texto que solicita una frecuencia
    MOV DX, OFFSET textofrec ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H

    ;;Hay que leer del teclado la frecuencia.
    ;Leemos el nombre del archivo escrito por teclado
    MOV AH, 0AH ;Función captura de teclado
    MOV DX, OFFSET frecuencia 
    MOV frecuencia[0], 5
    INT 21H
    

    MOV DI, OFFSET frecuencia
    CALL ASCII_to_DEC

    ;Modificar la tabla para que oscile tantas veces como la frecuenca que se pasa como argumento
    MOV DI, OFFSET frec_hex
    CALL CREA_TABLA

    ;Escribir en disco la señal creada
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

    ;Guardamos en BX el descriptor y en DI el comienzo de la tabla
    MOV BX, AX
     MOV DI, OFFSET tabla
    ;Llamamos a Write_WAV que carga en AX el numero total de bytes escritos
    CALL Write_WAV

  

    ;Cerramos el archivo y en AX ya esta el descriptor del fichero 
    CALL fclose
    



    ;Imprime el texto de salida del programa
    MOV DX, OFFSET salidanoquit ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H

    JMP FUNCION


  TERMINA:
    ;Imprime el texto de salida del programa
    MOV DX, OFFSET salida ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H

  RET 

FUNC_PRINCIPAL ENDP

ASCII_to_DEC PROC NEAR

  MOV BX, 0
  MOV BL, BYTE PTR[DI+1]
  ADD DI, 2
  DEC BX
  ADD DI, BX
  INC BX
  MOV DX,0
  MOV CX, 0
  MOV SI, 1

  BUCLE:

    MOV DL, BYTE PTR[DI]
    SUB DX, 48
    MOV AX, SI
    MUL DX
    ADD CX, AX
    DEC BX
    DEC DI
    MOV AX, 10
    MUL SI
    MOV SI, AX

    CMP BX, 0
    JNZ BUCLE

  MOV DI, OFFSET frec_hex
  MOV WORD PTR[DI], CX

  RET

ASCII_to_DEC ENDP

CREA_TABLA PROC NEAR
  ;;Cargamos en BX el valor de la frecuencia en Hz
  MOV BX,0
  MOV BX, WORD PTR [DI]
  ;;Dividimos Sample_Rate (8000) entre la frecuencia. Cociente guardado en AX, resto en DX
  MOV DX,0
  MOV AX, 8000
  DIV BX
  ;;Comprobamos si el cociente es par (debe tener el mismo nº de picos que de "valles")
  MOV DX,0
  MOV CX,2
  DIV CX ;;AX tam oscilacion, DX si es par (0) o impar (1)

;;Usamos CX para contador
  MOV CX, 0
  MOV DI, OFFSET tabla
   
  RELLENA_TABLA:
    MOV CX, AX
    BUCLE_50:
      MOV BYTE PTR [DI], 50
      ADD DI, 1
      LOOP BUCLE_50
    MOV CX, AX
    BUCLE_MEN50:
      MOV BYTE PTR[DI], -50
      ADD DI,1
      LOOP BUCLE_MEN50
    DEC BX
    CMP BX,0
    JNE RELLENA_TABLA

  RET

CREA_TABLA ENDP


CODE ENDS
END INICIO


