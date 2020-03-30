;**************************************************************************
; PRACTICA 2 SBM 2020. Ejercicio B
;**************************************************************************
; Autores: Rodrigo Lardiés Guillén         NIA 382246 Gr 2301
;          Víctor Sánchez de la Roda Núñez NIA 380451 Gr 2301
;**************************************************************************

;DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT
  ;Variables declaradas
  tabla db 8000 dup(0); Tabla de 8000 bytes de la onda inicializada todo a 0
  nombrefichero db 0, 0 ;Auxiliar para el nombre del fichero
  fichero db 30, 33 dup(0),13, 10, '$' ;Variable que almacena el nombre del fichero
  textonombre db "Introduzca el nombre del archivo: ",13,10,'$';Mensaje que pide el nombre del archivo que aparecerá por pantalla 
  textofrec db "Frecuencia (Hz) deseada: ",13,10,'$'; Mensaje que pide la frecuencia en Hz que aparecerá por pantalla
  salida db "Hasta luego!",'$' ;Mensaje que aparecerá por pantalla en caso de introducir "quit"
  salidanoquit db "Archivo creado correctamente.",13,10,'$' ;Mensaje que aparecerá si se crea el archivo correctamente
  frecuencia db 4 dup(0), 13, 10, '$' ;Variable donde se almacena la frecuencia
  error_open db "Error abriendo el fichero (fopen) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del open
  error_close db "Error cerrando el fichero (fclose) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del close
  error_write db "Error escribiendo el fichero (Write_WAV) con codigo de error: ",'$' ;Mensaje de error que aparecerá por pantalla en el caso del write
  codigo_error db 2 dup(0),13,10,'$' ;Palabra donde almacenaremos el código de error correspondiente en ASCII para imprimirlo
  cont_elem db 1 dup(0) ; Contador que se utilizará para saber cuántos elementos metemos/sacamos de la pila
  frec_hex db 2 dup(0),13,10,'$' ;Variable que utilizaremos para transformar lo introducido por teclado
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
  textoquit db "quit",0 ;Palabra que indica el fin del bucle
                      ;Es necesaria en este segmento por el uso de REPE CMPSB
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

  CALL FUNC_PRINCIPAL ;LLama al bucle que pide continuamente nombres de archivos
 

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


TERMINA: ;Rutina que termina el programa si has introducido quit como nombre de fichero
    ;Imprime el texto de salida del programa
    MOV DX, OFFSET salida ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H
    JMP FIN 

INICIO ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SUBRUTINA QUE PIDE UN ARCHIVO Y UNA FRECUENCIA Y GENERA UN ARCHIVO.WAV
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNC_PRINCIPAL PROC NEAR

  FUNCION: ;Rutina que ejecuta lo pedido por el ejercicio
    
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

    ;;Si lo que hemos introducido es "quit" tenemos que terminar el programa
    CLD ;Limpiamos el flag de direccion para incrementar las posiciones de memoria (ir de izq a der)
    MOV CX, 5 ;Inicializamos una cantidad de Bytes (5 valen porque "q u i t 0" necesito comparar el último porque si no palabras que empezasen por quit se detectarian iguales )
    MOV DI, OFFSET textoquit ;Almacenamos en ES:DI el texto que hace de escape en la rutina
    MOV SI, OFFSET fichero  ;Almacenamos en DS:SI el nombre del fichero que hemos introducido por teclado
    REPE CMPSB ;Realiza la operación de comparación entre ES:DI DS:SI Byte a Byte para los primeros CX Bytes
               ;Poniendo ZF = 0 la primera vez que encuentre mismatch en la comparación
    JE TERMINA ;Si ZF = 1 termina el programa

    ;;Si no es quit, tenemos que pedir ya almacenar una frecuencia en HzS
    ;Imprime el texto que solicita una frecuencia
    MOV DX, OFFSET textofrec ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H

    
    ;Leemos la frecuencia escrita por teclado
    MOV AH, 0AH ;Función captura de teclado
    MOV DX, OFFSET frecuencia 
    MOV frecuencia[0], 5
    INT 21H
    
    ;Convierte a decimal la frecuencia introducida por teclado
    MOV DI, OFFSET frecuencia
    CALL ASCII_to_DEC

    ;Debemos dar valores a los Bytes de la tabla WAV en función de la frecuencia obtenida por teclado
    MOV DI, OFFSET frec_hex
    CALL CREA_TABLA

    ;Inicializamos el modulo WAV especificando la frecuencia de muestreo y el número de muestras
    MOV DX, 8000 ;SAMPLE RATE
    MOV CX, 8000 ;NUMBER OF SAMPLES
    CALL Init_WAV_Header

    ;Abrimos un fichero en el disco, almacenando en AX el descriptor o en caso de error el código correspondiente además de CF = 1
    MOV DX, OFFSET fichero;Guardamos en DX la direccion del nombre del fichero, OFFSET devuelve donde empieza fichero
    CALL fopen
    JNC CONTINUA_OPEN ;Si no hay error (CF = 0) seguimos la ejecución de la rutina
    JMP FIN_OPEN ;Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa

  CONTINUA_OPEN:
    MOV BX, AX ;Guardamos en BX el descriptor de fichero
    MOV DI, OFFSET tabla ;Guardamos en DI el comienzo de la tabla
    CALL Write_WAV ;Almacena en AX el nº de Bytes escritos si no hay error, sino almacena el codigo de error
    JNC CONTINUA_WRITE ;Si no hay error (CF = 0) seguimos la ejecución de la rutina
    JMP FIN_WRITE ;Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa

  CONTINUA_WRITE:
    ;Cerramos el archivo y en AX ya esta el descriptor del fichero 
    CALL fclose
    JNC CONTINUA_CLOSE ;Si no hay error (CF = 0) seguimos la ejecución de la rutina
    JMP FIN_CLOSE ;Si hay error (CF = 1) saltamos a la rutina que muestra el error y termina el programa
  CONTINUA_CLOSE:


    ;Imprime el texto que indica que todo ha ido correctamente y vuelve a repetir el proceso
    MOV DX, OFFSET salidanoquit ; DX : offset al inicio del texto a imprimir
    MOV AH, 9
    INT 21H

    JMP FUNCION ;Vuelta al principio


  RET 
FUNC_PRINCIPAL ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ASCII_to_DEC : Subrutina que transforma un carácter ASCII en su valor decimal (para almacenar valores introducidos por teclado)
;ARGS_INPUT : DI debe contener la direccion de memoria de la variable que se ha solicitado por teclado
;ARGS_OUTPUT : freq_hex contiene lo especificado
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_to_DEC PROC NEAR

  MOV BX, 0 ;Inicializo BX a 0 (por si ya estuviese inicializada)
  MOV BL, BYTE PTR[DI+1] ;Carga el nº de Bytes que se han leído por teclado
  ADD DI, 2 ;Avanza a la primera posicionn efectiva de la variable
  DEC BX ;Decremento el contador de Bytes
  ADD DI, BX ;Se coloca en el ultimo Byte leido por teclado (unidades-decenas-centenas... en ese orden)
  INC BX ;Aumento el contador de Bytes
  MOV DX,0 ;Inicializo DX a 0 (por si ya estuviese inicializada)
  MOV CX, 0 ;Inicializo CX a 0 (por si ya estuviese inicializada)
  MOV SI, 1 ;SI contendrá el valor por el que multiplicaremos el Byte que toque pasar a decimal
            ;1432 = 1*1000 + 4*100 + 3*10 + 2*1

  BUCLE: ;Rutina que convierte cada Byte a decimal teniendo en cuenta su posición (unidad,decena..) 
         ;Guarda el resultado en CX

    MOV DL, BYTE PTR[DI] ;Guarda el Byte a cambiar a decimal
    SUB DX, 48 ;Le resta 48 (30H) para pasar a DEC ==> '3' en DEC es '0x33' en HEX
    MOV AX, SI ;Carga el valor por el que multiplicaré el Byte a cambiar
    MUL DX ;Multiplicamos AX*DX
    ADD CX, AX ;Añadimos el resultado a CX
    DEC BX ;Decrementamos el contador de Bytes
    DEC DI ;Retrocedemos una posición en la variable
    MOV AX, 10 ;Guardamos un 10 en AX, que sirve de factor
    MUL SI ;Multiplicamos AX*SI, para tener el nuevo factor de base 10
    MOV SI, AX ;Almacenamos dicho factor en SI

    CMP BX, 0 ;Comprobamos el valor del contador de Bytes
    JNZ BUCLE ; Si BX != 0 repetimos el proceso

  ;Almacenamos el resultado de la transformación en la variable frec_hex
  MOV DI, OFFSET frec_hex
  MOV WORD PTR[DI], CX

  RET

ASCII_to_DEC ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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
	JMP BUCLE_2 ;Sacamos elementos de la pila
	
	
	BUCLE_2:
		POP DX ;Sacamos el primer elemento de la pila
		ADD DI, 1 ;Avanzamos la posición en la variable
		MOV [DI], DX ; Escribimos el elemento sacado de la pila en codigo_error
		DEC cont_elem; Decrementamos el contador de elementos
		CMP cont_elem,0 ;Si no quedan elementos por sacar seguimos
		JNE BUCLE_2 ;Si cont_elem != 0 repetimos el proceso
				
		;Guardamos el segmento y el offset del valor que hemos obtenido
		MOV DX, SEG codigo_error
		MOV AX, OFFSET codigo_error

		; Retorna a la rutina principal
		RET ;Fin de la subrutina	

HEX_to_ASCII ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CREA_TABLA : Subrutina que rellena la tabla WAV con las oscilaciones pertinentes
;ARGS_INPUT : DI debe contener la dirección de memoria de la variable freq_hex
;ARGS_OUTPUT : tabla con sus valores correspondientes 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CREA_TABLA PROC NEAR
 
  MOV BX,0 ;Inicializa BX a o (por si ya estuviese inicializado)
  MOV BX, WORD PTR [DI] ;Guardamos en BX el contenido de la variable freq_hex
  ;;Dividimos Sample_Rate (8000) entre la frecuencia. Cociente guardado en AX, resto en DX
  MOV DX,0 ;Inicializamos DX a o (por si ya estuviese inicializada)
  MOV AX, 8000 ;Guardamos en AX el Sample_Rate
  DIV BX ;Dividimos DX:AX / BX. Obtenemos en AX el tamaño de la oscilación y en DX los Bytes que sobran (hasta rellenar 8000)
  ;;Dividimos para repartir las oscilaciones entre 50 y -50
  MOV DX,0
  MOV CX,2
  DIV CX ;Dividimos DX:AX / CX. Obtenemos en AX el nº de 50 seguidos en la tabla y en DX el resto de la division

  
  MOV CX, 0 ;Usamos CX como contador.
  MOV DI, OFFSET tabla ;Almacenamos en DI la direccion de tabla
   
  ;Vamos a dar valores a la tabla de 8000 bytes.
  ;El método a seguir será repetir AX (tam oscilación) veces poner un 50 y después repetir AX veces poner un -50
  ;Este proceso se repetirá BX (nº total de oscilaciones) veces 
  RELLENA_TABLA: 
    MOV CX, AX ;Inicializo el contador a AX
    BUCLE_50: ;Rutina que pone AX posiciones a 50
      MOV BYTE PTR [DI], 50 ;Almaceno un 50
      ADD DI, 1 ;Avanzo un posición en la tabla
      LOOP BUCLE_50 ;Decrementa el contador en una unidad y vuelve a la etiqueta si no es 0
    
    MOV CX, AX ; Vuelvo a inicializar el contador
    BUCLE_MEN50: ;Rutina que pone AX posiciones a -50
      MOV BYTE PTR[DI], -50 ;Almaceno un -50
      ADD DI,1 ;Avanzo una posición en la tabla
      LOOP BUCLE_MEN50 ;;Decrementa el contador en una unidad y vuelve a la etiqueta si no es 0
    
    DEC BX ;Decremento 1 oscilación
    CMP BX,0 ;Si he terminado de rellenar la tabla salgo, si no repito el proceso
    JNE RELLENA_TABLA

  RET
CREA_TABLA ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE ENDS
END INICIO
