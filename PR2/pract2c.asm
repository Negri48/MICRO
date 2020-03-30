;**************************************************************************
; PRACTICA 2 SBM 2020. Ejercicio C
;**************************************************************************
; Autores: Rodrigo Lardiés Guillén         NIA 382246 Gr 2301
;          Víctor Sánchez de la Roda Núñez NIA 380451 Gr 2301
;**************************************************************************
;DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT
  ;Variables declaradas
  nombrefichero db 0, 0;nombre
  fichero db 30, 33 dup(0),13, 10, '$' ;nombre del fichero
  tipo db 8 dup(0), 13, 10, '$';Varibale donde guardaremos el tipo
  sample_rate db 4 dup(0),13, 10,'$' ;Variable donde guardaremos el Sample_Rate
  numeromuestras db 4 dup(0), 13, 10, '$' ;Variable donde guardaremos el número de muestras
  totalbytes db 4 dup(0), 13, 10, '$' ;Varible donde guardaremos el nº total de Bytes
  bytesmuestra db 2 dup(0), 13, 10, '$';Variable donde guardaremos los bytes por muestra
  
  canales db 2 dup(0), 13, 10, '$'; Variable donde guardaremos el número de canales
  bytes db 4 dup(0), 13, 10, '$';Variable donde guardaremos el número de bytes
  buffer db 44 dup(0),13, 10, '$' ; buffer en el que leeremos del archivo

  textonombre db "Introduzca el nombre del archivo:",13, 10,'$';Mensaje que pide el nombre del archivo que aparecerá por pantalla
  textofilename db "Filename: ", '$'; Mensaje que aparece por pantalla
  textotipo db "Tipo de Archivo: ", '$' ; Mensaje que aparece por pantalla
  textofrecuencia db "Sample-rate: ",'$'; Mensaje que aparece por pantalla
  textomuestras db "Numero de muestras: ", '$' ; Mensaje que aparece por pantalla
  textocanales db "Numero de canales: ", '$' ; Mensaje que aparece por pantalla
  textobytes db "Bytes por segundo: ", '$' ; Mensaje que aparece por pantalla
  error_open db "Error abriendo el fichero (fopen) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del open
  error_close db "Error cerrando el fichero (fclose) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del close
  error_write db "Error escribiendo el fichero (Write_WAV) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del write
  cab_incompleta db "Error al leer la cabecera (fread). La cabecera es incompleta.",'$'; Mensaje de error que aparecerá por pantalla en el caso que fread devuelva más de 0 y menos de 44 bytes
  cab_vacia db "Error al leer la cabecera (fread). La cabecera es vacía.",'$'; Mensaje de error que aparecerá por pantalla en el caso que fread devuelva 0 bytes
  cab_erronea db "Error al leer la cabecera (fread). La cabecera es errónea.",'$' ; Mensaje de error que aparecerá por pantalla en el caso que la cabecera no contenga las palabras de estado.
  ascii_conv db 10 dup(0),13,10,'$' ; Variable donde guardaremos los hexadecimales convertidos en ASCII para imprimirlos por pantalla
  cont_elem db 1 dup(0) ; Contador que se utilizará para saber cuántos elementos metemos/sacamos de la pila
  codigo_error db 2 dup(0),13,10,'$' ;Palabra donde almacenaremos el código de error correspondiente en ASCII para imprimirlo

  ;Referencias a funciones dee módulos externos
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
  textoRIFF db "RIFF" ;Variable que usamos para comparar
  textoWAVEfmt db "WAVEfmt";Variable que usamos para comparar
  textodata db "data" ;Varible que usamos para comparar
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
  MOV DX, OFFSET nombrefichero ;DX : offset al inicio de la variable
  MOV nombrefichero[0], 30
  INT 21H 
  ;Al leer debemos quitar los dos primeros bytes que los utiliza el SO
  MOV BL, nombrefichero[1]
  MOV BH, 0
  ADD BX, 2
  MOV nombrefichero[BX], 0

  ;Abrimos un fichero en el disco, almacenando en AX el descriptor o en caso de error el código correspondiente además de CF = 1
  MOV DX, OFFSET fichero;Guardamos en DX la direccion del nombre del fichero, OFFSET devuelve donde empieza fichero
  CALL fopen
  JNC CONTINUA_OPEN ;Si no hay error (CF = 0) seguimos la ejecución de la rutina
  JMP FIN_OPEN ;Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa

  CONTINUA_OPEN:
  ;Leemos la cabecera del fichero y la guardamos en el buffer
  MOV BX, AX
  MOV CX, 44 ; bytes que se van a leer
  MOV DX, OFFSET buffer ;direccion del buffer
  CALL fread ;fread carga en AX los bytes que de han leido y si hay un error CF=1
  JNC CONTINUA_READ
  JMP FIN_READ ;Si hay error en el fread termina el programa
  CONTINUA_READ:
    JMP COMPROBACIONES_READ ;Comprobamos si la cabecera es correcta.

  CONTINUA_COMPROBACIONES:  
  ;Cerramos el archivo y en BX ya esta el descriptor del fichero 
  CALL fclose
  JNC CONTINUA_CLOSE ;Si no hay error (CF = 0) seguimos la ejecución de la rutina
  JMP FIN_CLOSE ;Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa
  CONTINUA_CLOSE:
    


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
  CALL HEX_to_ASCII ;Como es un número tenemos que transformalo a ASCII para imprimir
 
  ;Imprimimos el valor de sample_rate
  MOV DX, OFFSET ascii_conv
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
  CALL HEX_to_ASCII ;Como es un número tenemos que transformalo a ASCII para imprimir

  ;Imprimimos el valor del numero de muestras
  MOV DX, OFFSET ascii_conv
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
  CALL HEX_to_ASCII ;Como es un número tenemos que transformalo a ASCII para imprimir

  ;Imprimimos el valor del numero de canales
  MOV DX, OFFSET ascii_conv
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
  CALL HEX_to_ASCII ;Como es un número tenemos que transformalo a ASCII para imprimir

  ;Imprimimos el valor del numero de bytes por segundo
  MOV DX, OFFSET ascii_conv
  MOV AH, 9
  INT 21H

 

FIN: ;Rutina que termina el programa
   MOV AX, 4C00H
  INT 21H

FIN_OPEN: ;Rutina que termina el programa si hay error en fopen
  CALL HEX_to_ASCII ;Transformamos el codigo de error (almacenado en AX) a ASCII para imprimir
  MOV DX, OFFSET error_open ;Imprimimos el mensaje de error de fopen
  MOV AH, 9
  INT 21H
  MOV DX, OFFSET codigo_error ;Imprimimos el codigo de error provocado
  MOV AH, 9
  INT 21H
  JMP FIN

FIN_CLOSE: ;Rutina que termina el programa si hay error en fclose
  CALL HEX_to_ASCII ;Transformamos el código de error (almacenado en AX) a ASCII para imprimir
  MOV DX, OFFSET error_close ;Imprimimos el mensaje de error de fopen
  MOV AH, 9
  INT 21H
  MOV DX, OFFSET codigo_error ;Imprimimos el codigo de error provocado
  MOV AH, 9
  INT 21H
  JMP FIN

FIN_WRITE: ;Rutina que termina el programa si hay error en Write_WAW
  CALL HEX_to_ASCII ;Transformamos el código de error (almacenado en AX) a ASCII para imprimir
  MOV DX, OFFSET error_write ;Imprimimos el mensaje de error de Write_WAV
  MOV AH, 9
  INT 21H
  MOV DX, OFFSET codigo_error ;Imprimimos el codigo de error provocado
  MOV AH, 9
  INT 21H
  CALL fclose ;Cerramos el descriptor de fichero que sigue estando contenido en BX
  JMP FIN

FIN_READ: ;Rutina que termina el programa si hay error en fread
  CALL HEX_to_ASCII ;Transformamos el código de error (almacenado en AX) a ASCII para imprimir
  MOV DX, OFFSET error_write ;Imprimimos el mensaje de error de fread
  MOV AH, 9
  INT 21H
  MOV DX, OFFSET codigo_error ;Imprimimos el codigo de error provocado
  MOV AH, 9
  INT 21H
  CALL fclose ;Cerramos el descriptor de fichero que sigue estando contenido en BX
  JMP FIN
COMPROBACIONES_READ: ;Rutina que comprueba que el read ha sido válido
  CMP AX,44 ;Comprobamos que se ha leído la cabecera entera
  JNZ ERROR_CABECERA_INCOMPLETA
  CMP AX,0 ;Comprobamos que no es vacía
  JZ ERROR_CABECERA_VACIA
  ;;Comprobamos que haya leído RIFF
  CLD ;Limpiamos el flag de direccion para incrementar las posiciones de memoria (ir de izq a der)
  MOV CX, 4 ;Inicializamos una cantidad de Bytes (4 valen porque "R I F F" cabe )
  MOV DI, OFFSET textoRIFF ;Almacenamos en ES:DI el texto que hace de escape en la rutina
  MOV SI, OFFSET buffer  ;Almacenamos en DS:SI la cabecera del fichero WAV
  REPE CMPSB ;Realiza la operación de comparación entre ES:DI DS:SI Byte a Byte para los primeros CX Bytes
             ;Poniendo ZF = 0 la primera vez que encuentre mismatch en la comparación
  JNE TERMINA_COMPROBACIONES ;Si ZF = 0 termina el programa
  ;;Comprobamos que haya leído WAVEfmt
  CLD ;Limpiamos el flag de direccion para incrementar las posiciones de memoria (ir de izq a der)
  MOV CX, 7 ;Inicializamos una cantidad de Bytes (7 valen porque "W A V E f m t" cabe )
  MOV DI, OFFSET textoWAVEfmt ;Almacenamos en ES:DI el texto que hace de escape en la rutina
  MOV SI, OFFSET buffer  ;Almacenamos en DS:SI la cabecera del fichero WAV
  ADD SI,8
  REPE CMPSB ;Realiza la operación de comparación entre ES:DI DS:SI Byte a Byte para los primeros CX Bytes
             ;Poniendo ZF = 0 la primera vez que encuentre mismatch en la comparación
  JNE TERMINA_COMPROBACIONES ;Si ZF = 0 termina el programa
  ;;Comprobamos que haya leído data
  CLD ;Limpiamos el flag de direccion para incrementar las posiciones de memoria (ir de izq a der)
  MOV CX, 4 ;Inicializamos una cantidad de Bytes (4 valen porque "d a t a" cabe )
  MOV DI, OFFSET textodata ;Almacenamos en ES:DI el texto que hace de escape en la rutina
  MOV SI, OFFSET buffer  ;Almacenamos en DS:SI la cabecera del fichero WAV
  ADD SI,36
  REPE CMPSB ;Realiza la operación de comparación entre ES:DI DS:SI Byte a Byte para los primeros CX Bytes
             ;Poniendo ZF = 0 la primera vez que encuentre mismatch en la comparación
  JNE TERMINA_COMPROBACIONES ;Si ZF = 0 termina el programa

  JMP CONTINUA_COMPROBACIONES ;Si todo es correcto continuamos con la ejecucion


ERROR_CABECERA_INCOMPLETA: ;Rutina que termina el programa en el caso de que la cabecera sea incompleta
  MOV DX, OFFSET cab_incompleta ;Imprimimos el mensaje de error de cabecera incompleta
  MOV AH, 9
  INT 21H
  CALL fclose
  JMP FIN

ERROR_CABECERA_VACIA: ;Rutina que termina el programa en el caso de que la cabecera sea vacía
  MOV DX, OFFSET cab_vacia ;Imprimimos el mensaje de error de cabecera vacia
  MOV AH, 9
  INT 21H
  CALL fclose
  JMP FIN
TERMINA_COMPROBACIONES: ;Rutina que termina el programa en el caso de que la cabecera sea errónea
  MOV DX, OFFSET cab_erronea ;Imprimimos el mensaje de error de cabecera errorea
  MOV AH, 9
  INT 21H
  CALL fclose
  JMP FIN
INICIO ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HEX_to_ASCII : Subrutina que pasa un elemento en memoria a ASCII
;ARGS_INPUT: AX debe contenter lo que queremos pasar a ASCII
;ARGS_OUTPUT: codigo_error contiene AX escrito en ASCII
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEX_to_ASCII PROC NEAR
	;CODIGO SUBRUTINA

	MOV WORD PTR ascii_conv[0], 0
	MOV WORD PTR ascii_conv[2], 0
	MOV WORD PTR ascii_conv[4], 0
	MOV WORD PTR ascii_conv[6], 0
	MOV WORD PTR ascii_conv[8], 0
	
	MOV AX, WORD PTR [DI] ; Carga en AX el elemento que queremos convertir a ASCII para poder realizar la operacion DIV
	
	
 	RESTO_DIV:
		MOV DX, 0 ;Inicializo DX = 0
		MOV CX, 10 ;Inicializo CX = 10
		DIV CX ; Divide DX:AX entre 10 (CX), cargando en AX el cociente de la division y en DX el resto
		ADD DX, 48 ;Sumamos 48 (30H) al resto de la division para convertirlo a ASCII 
		PUSH DX ;Lo metemos en la pila
		INC cont_elem ;Incrementamos el contador, para llevar la cuenta de los elementos de la pila
		CMP AX, 0 ;Comparamos AX (cociente de la division) con 0.
		JNE RESTO_DIV ;Si AX != 0 repetimos el proceso
	
	; Si el cociente es 0, continuamos
	MOV DI, OFFSET ascii_conv
	JMP BUCLE_2 ;Sacamos elementos de la pila
	
	
	BUCLE_2:
		POP DX ;Sacamos el primer elemento de la pila
		ADD DI, 1 ;Avanzamos la posición en la variable
		MOV [DI], DX ; Escribimos el elemento sacado de la pila en codigo_error
		DEC cont_elem; Decrementamos el contador de elementos
		CMP cont_elem,0 ;Si no quedan elementos por sacar seguimos
		JNE BUCLE_2 ;Si cont_elem != 0 repetimos el proceso
				
		;Guardamos el segmento y el offset del valor que hemos obtenido
		MOV DX, SEG ascii_conv
		MOV AX, OFFSET ascii_conv

		; Retorna a la rutina principal
		RET ;Fin de la subrutina	

HEX_to_ASCII ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
END INICIO