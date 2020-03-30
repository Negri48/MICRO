;**************************************************************************
; SBM 2018. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
;DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT
  nombrefichero db 0, 0;nombre
  fichero db 30, 33 dup(0),13, 10, '$' ;nombre del fichero
  tipo db 8 dup(0), 13, 10, '$';
  sample_rate db 4 dup(0),13, 10,'$' ;
  numeromuestras db 4 dup(0), 13, 10, '$'
  totalbytes db 4 dup(0), 13, 10, '$'
  bytesmuestra db 2 dup(0), 13, 10, '$'
  
  canales db 2 dup(0), 13, 10, '$'; 
  bytes db 4 dup(0), 13, 10, '$';
  buffer db 44 dup(0),13, 10, '$' ; buffer en el que leeremos del archivo

  textonombre db "Introduzca el nombre del archivo:",13, 10,'$'; Texto que se mostrara por pantalla
  textofilename db "Filename: ", '$'; 
  textotipo db "Tipo de Archivo: ", '$'
  textofrecuencia db "Sample-rate: ",'$';
  textomuestras db "Numero de muestras: ", '$'
  textocanales db "Numero de canales: ", '$'
  textobytes db "Bytes por segundo: ", '$'
  
  ASCII_CONV db 10 dup(0),13,10,'$'
  CONT_ELEM db 1 dup(0)


EXTRN fopen:FAR
EXTRN fread:FAR
EXTRN fclose:FAR
DATOS ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE PILA 
PILA SEGMENT STACK "STACK" 
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

  ;Imprime el texto que solicita un nombre
  MOV DX, OFFSET textonombre ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  ;Leemos el nombre del archivo escrito por teclado
  MOV AH, 0AH ;Función captura de teclado
  MOV DX, OFFSET nombrefichero 
  MOV nombrefichero[0], 30
  INT 21H 

  MOV BL, nombrefichero[1]
  MOV BH, 0
  ADD BX, 2
  MOV nombrefichero[BX], 0
  ;nombrefichero = nombrefichero + 2, Asi nos quitamos los dos primeros bytes y nombrefichero apunta a la cadena del nombre directamente

  ;Abrimos el fichero
  MOV DX, OFFSET fichero ;Cargamos en DX la posicion donde empieza el nombre del fichero
  CALL fopen  ;fopen carga en AX el descriptor del fichero que abre y si hay un error CF=1

  ;leemos la cabecera del fichero y la guardamos en el buffer
  MOV BX, AX
  MOV CX, 44 ; bytes que se van a leer
  MOV DX, OFFSET buffer ;direccion del buffer
  CALL fread ;fread carga en AX los bytes que de han leido y si hay un error CF=1


  ;Cerramos el archivo y en AX ya esta el descriptor del fichero 
  CALL fclose



  ;Mostramos el texto filename
  MOV DX, OFFSET textofilename ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  ;Escribimos el nombre del fichero
  MOV AH, 9 ; Número de función = 9 (imprimir string)
  MOV DX, OFFSET fichero ; DX : offset al inicio del texto a imprimir
  INT 21h 

  ;Mostramos el texto tipo de archivo
  MOV DX, OFFSET textotipo ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  MOV BX, OFFSET buffer ; cargamos la direccion donde empieza el buffer
  ADD BX, 8 ; nos movemos 8 posiciones para obtener el valor que nos interesa
  MOV DI, OFFSET tipo ; guardamos en DI la dieccion de la variable tipo
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX ; copiamos en DI los dos primeros bytes
  ADD BX, 2 ; Avanzamos los punteros dos posiciones para cargar los dos siguientes bytes
  ADD DI, 2
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX ; copiamos los dos siguientes bytes en la variable
  ADD BX, 2 ; Repetimos el proceso hasta completar a los 8 bytes de la variable
  ADD DI, 2
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX
  ADD BX, 2
  ADD DI, 2
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX

  ;Imprimimos el tipo de archivo guardado en la variable tipo
  MOV DX, OFFSET tipo
  MOV AH, 9
  INT 21H


  ;Mostramos el texto sample-rate
  MOV DX, OFFSET textofrecuencia ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  ;Le asignamos a simple_rate su valor correspondiente
  MOV BX , OFFSET buffer ; guardamos la direccion donde comienza el buffer en AX
  ADD BX, 24 ;; vamos hasta la posicion 24 del buffer
  MOV DI, OFFSET sample_rate  ; guardamos la direccion de la viriable simple_rate
  MOV AX, WORD PTR [BX] ; Cogemos los dos primeros bytes de la frecuencia
  MOV WORD PTR [DI], AX  ; Copiamos los dos primeros bytes en la variable simple_rate
  ADD BX, 2; ; Avanzamos el puntero dos posiciones 
  ADD DI, 2 ; ; Avanzamos el puntero dos posiciones
  MOV AX, WORD PTR [BX] ; ; Cogemos los dos siguientes bytes de la frecuencia
  MOV WORD PTR [DI], AX ; Copiamos los dos siguientes bytes en la variable simple_rate

  MOV DI, OFFSET sample_rate
  CALL ASCII_to_DEC
 
  ;Imprimimos el valor de sample_rate
  MOV DX, OFFSET ASCII_CONV
  MOV AH, 9
  INT 21H

  ;Mostramos el texto numero de muestras
  MOV DX, OFFSET textomuestras ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  ;hallamos el numero de muestras: bytes totales / bytes por muestra
  ;hallamos el numero total de bytes
  MOV BX, 0
  MOV DI, OFFSET buffer
  MOV BX, OFFSET totalbytes
  MOV AX, WORD PTR [DI+40]
  MOV WORD PTR [BX], AX
  ADD BX, 2
  MOV AX, WORD PTR [DI+42]
  MOV WORD PTR [BX], AX

  ;Hallamos el numero de bytes por muestra,
  MOV BX, OFFSET buffer
  ADD BX, 34
  MOV DI, OFFSET bytesmuestra
  MOV AX, WORD PTR [BX] ; Nos queda en AX el numero de bits por muestra
  MOV BL, 08H
  DIV BL ; dividimos entre 8 para obtener el numero de bytes 
  MOV CX, 0
  MOV CL, AL
  MOV WORD PTR [DI], CX ; lo guardamos en la variable bytesmuestra

  ;hallamos el numero de muestras: totalbytes / bytes por muestra
  MOV DI, OFFSET bytesmuestra
  MOV BX, WORD PTR [DI]
  MOV DI, OFFSET totalbytes
  MOV AX, WORD PTR [DI]
  MOV DX, 0
  DIV BX
  MOV DI, OFFSET numeromuestras
  MOV WORD PTR [DI], AX

  MOV DI, OFFSET numeromuestras
  CALL ASCII_to_DEC

  ;Imprimimos el valor del numero de muestras
  MOV DX, OFFSET ASCII_CONV
  MOV AH, 9
  INT 21H

  ;Mostramos el texto numero de canales
  MOV DX, OFFSET textocanales ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  ;Asignamos el numero de canales a la variable canales
  MOV BX, OFFSET buffer
  ADD BX, 22
  MOV DI, OFFSET canales
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX


  ;Conversion a numero decimal de la variable canales
  MOV DI, OFFSET canales
  CALL ASCII_to_DEC

  ;Imprimimos el valor del numero de canales
  MOV DX, OFFSET ASCII_CONV
  MOV AH, 9
  INT 21H

  ;Mostramos el texto bytes por segundo
  MOV DX, OFFSET textobytes ; DX : offset al inicio del texto a imprimir
  MOV AH, 9
  INT 21H

  ;Asignamos el numero de bytes por segundo a la variable bytes
  MOV BX, OFFSET buffer
  ADD BX, 28
  MOV DI, OFFSET bytes
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX
  ADD BX, 2
  ADD DI, 2
  MOV AX, WORD PTR [BX]
  MOV WORD PTR [DI], AX

  ;Conversiona numero decimal
  MOV DI, OFFSET bytes
  CALL ASCII_to_DEC

  ;Imprimimos el valor del numero de bytes por segundo
  MOV DX, OFFSET ASCII_CONV
  MOV AH, 9
  INT 21H

 

FIN: MOV AX, 4C00H
  INT 21H

INICIO ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SUBRUTINA PASAR ELEMENTO A ASCII
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_to_DEC PROC NEAR
	;CODIGO SUBRUTINA

	MOV WORD PTR ASCII_CONV[0], 0
	MOV WORD PTR ASCII_CONV[2], 0
	MOV WORD PTR ASCII_CONV[4], 0
	MOV WORD PTR ASCII_CONV[6], 0
	MOV WORD PTR ASCII_CONV[8], 0
	
	MOV AX, WORD PTR [DI] ; Carga en AX el elemento que queremos convertir a ASCII para poder realizar la operacion DIV
	
 	RESTO_DIV:
		MOV DX, 0
		MOV CX, 10
		DIV CX ; Divide DX:AX entre el operando DIEZ, cargando en AX el cociente de la division y en DX el resto
		ADD DX, 48 ;Sumamos 30 al resto de la division para convertirlo a ascii
		PUSH DX ;Añadimos el resto en ascii a la pila
		INC CONT_ELEM ;Incrementamos el contador, para llevar la cuenta de los elementos de la pila
		CMP AX, 0 ;Comparamos AX (cociente de la division) con 0.
		JNE RESTO_DIV ;Si AX no es cero volvemos a dividir, hasta que este sea 0
	
	; Si el cociente es 0, continuamos
	MOV DI, OFFSET ASCII_CONV
	JMP BUCLE ; pasamos a sacar el primer elemento de la pila
	
	
	BUCLE:
		POP DX ;Sacamos el primer elemento de la pila
		ADD DI, 1
		MOV [DI], DX ; Escribimos el elemento sacado de la pila en ASCII_CONV
		INC CX ;Incrementamos el contador de las posiciones del resutado ascii
		DEC CONT_ELEM; Decrementamos el contador de elementos de la pila (hemos sacado uno (pop))
		CMP CONT_ELEM,0 
		JNE BUCLE ;Si el contador no es cero, es decir, si quedan elementos en la pila, continuamos en el bucle
		
		; Si ya hemos sacado todos los elementos de la pila y los hemos guardado en las correspondientes posiciones del resultado ASCII
		ADD DI, 1
		MOV ASCII_CONV[DI], '$' ; Y añadimos un $ al final de la cadena para imprimir con la funcion 9H
		
		;Guardamos el segmento y el offset del valor que hemos obtenido
		MOV DX, SEG ASCII_CONV
		MOV AX, OFFSET ASCII_CONV

		
		; Retorna a la rutina principal
		RET ;Fin de la subrutina	

ASCII_to_DEC ENDP


; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
END INICIO