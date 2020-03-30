;**************************************************************************
; PRACTICA 2 SBM 2020. Ejercicio A
;**************************************************************************
; Autores: Rodrigo Lardiés Guillén         NIA 382246 Gr 2301
;          Víctor Sánchez de la Roda Núñez NIA 380451 Gr 2301
;**************************************************************************

;DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT
  ;Variables declaradas
  tabla db 440 dup (9 dup (50), 9 dup (-50)), 80 dup (0) ;Tabla WAV que indica 440 oscilaciones entre 50 y -50 (en bloques de 9) y 80 bytes vacíos ==> 440*18 + 80 = 8000 bytes
  fichero db "gen_la.wav", 0; Almacenamos el nombre del fichero
  error_open db "Error abriendo el fichero (fopen) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del open
  error_close db "Error cerrando el fichero (fclose) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del close
  error_write db "Error escribiendo el fichero (Write_WAV) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del write
  codigo_error db 2 dup(0),13,10,'$' ;Palabra donde almacenaremos el código de error correspondiente en ASCII para imprimirlo
  cont_elem db 1 dup(0) ; Contador que se utilizará para saber cuántos elementos metemos/sacamos de la pila
  ;Referencias a funciones de módulos externos
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

  ;Inicializamos el modulo WAV especificando la frecuencia de muestreo y el número de muestras
  MOV DX, 8000 ;SAMPLE RATE
  MOV CX, 8000 ;NUMBER OF SAMPLES
  CALL Init_WAV_Header

  ;Abrimos un fichero en el disco, almacenando en AX el descriptor o en caso de error el código correspondiente además de CF = 1
  MOV DX, OFFSET fichero;Guardamos en DX la direccion del nombre del fichero, OFFSET devuelve donde empieza fichero
  CALL fopen
  JC FIN_OPEN ;Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa

  ;Escribir en disco la señal de 440 Hz almacenada en la variable tabla
  MOV BX, AX ;Guardamos en BX el descriptor de fichero
  MOV DI, OFFSET tabla ;Guardamos en DI el comienzo de la tabla
  CALL Write_WAV ;Almacena en AX el nº de Bytes escritos si no hay error, sino almacena el codigo de error
  JC FIN_WRITE; Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa
  ;Cerramos el archivo y en AX ya esta el descriptor del fichero 
  CALL fclose
  JC FIN_CLOSE ;Capturamos el error si CF=1


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

INICIO ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HEX_to_ASCII : Subrutina que pasa un elemento en memoria a ASCII
;ARGS_INPUT: AX debe contenter lo que queremos pasar a ASCII
;ARGS_OUTPUT: codigo_error contiene AX escrito en ASCII
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEX_to_ASCII PROC NEAR
	
	MOV WORD PTR codigo_error[0], 0 ;Inicializo la varible a 0 (por si estuviese escrita)
	
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
	MOV DI, OFFSET codigo_error
	JMP BUCLE ;Sacamos elementos de la pila
	
	
	BUCLE:
		POP DX ;Sacamos el primer elemento de la pila
		ADD DI, 1 ;Avanzamos la posición en la variable
		MOV [DI], DX ; Escribimos el elemento sacado de la pila en codigo_error
		DEC cont_elem; Decrementamos el contador de elementos
		CMP cont_elem,0 ;Si no quedan elementos por sacar seguimos
		JNE BUCLE ;Si cont_elem != 0 repetimos el proceso
				
		;Guardamos el segmento y el offset del valor que hemos obtenido
		MOV DX, SEG codigo_error
		MOV AX, OFFSET codigo_error

		; Retorna a la rutina principal
		RET ;Fin de la subrutina	

HEX_to_ASCII ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CODE ENDS
END INICIO