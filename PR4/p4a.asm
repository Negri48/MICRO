CODIGO SEGMENT
	ASSUME CS : CODIGO
	ORG 256

INICIO:
    JMP FUNCIONALIDAD
;Variables globales, utilizadas para imprimir
    text_grupo_nombre db "Grupo 2301. Rodrigo y Victor. Se debe especificar si se quiere instalar (/I) o desinstalar (/D) el driver",10,13,'$'
    text_comp_instalado db "El driver ya esta instalado." ,10,13,'$'
    text_comp_desinstalado db "El driver no esta instalado." ,10,13,'$'
    text_num_params db "El numero de parametros permitidos es 2: [nombre_programa] [arg1]",10,13,'$'
    text_error_params db "El segundo argumento solo puede ser /D o /I",10,13,'$'
    text_instalacion_term db "El driver se ha instalado correctamente.",10,13,'$'
    text_desinstalacion_term db "El driver se ha desinstalado correctamente.",10,13,'$'
    text_no_se_puede_desinstalar db "El driver que se intentar desinstalar no se encuentra instalado.",10,13,'$'
    text_no_se_puede_instalar db "El driver que se intentar instalar, ya se encuentra instalado.",10,13,'$'
    text_pedir_numeros_dec db "Introduce el numero decimal [0 - 65535] a convertir: ",10,13,'$'
    text_pedir_numeros_hex db "Introduce el numero hexadecimal [0 - FFFF] a convertir: ",10,13,'$'
FUNCIONALIDAD:
	CMP BYTE PTR ES:[80H], 0 ; no hay parametros
	JE IMPRIMIR_ESTADO_NOMBRES_GRUPO
	CMP BYTE PTR ES:[80H], 3 ; el numero de parametros es correcto (/D o /I)
	JNE NUMERO_PARAMS_INCORRECTO
	CMP WORD PTR ES:[82H], 'D/'
	JE CASO_DESINSTALAR
	CMP WORD PTR ES:[82H], 'I/'
	JE CASO_INSTALAR
    JMP ERROR_ARGUMENTOS
CASO_INSTALAR:
    MOV AX,0
    MOV ES,AX
    CMP ES:[60H*4], WORD PTR 0
    JNE IMPRIMIR_NO_SE_PUEDE_INSTALAR
    CMP ES:[60H*4+2], WORD PTR 0
    JNE IMPRIMIR_NO_SE_PUEDE_INSTALAR
    CALL INSTALAR
    
CASO_DESINSTALAR:
    MOV AX,0
    MOV ES,AX
    CMP ES:[60H*4], WORD PTR 0
    JE IMPRIMIR_NO_SE_PUEDE_DESINSTALAR
    CMP ES:[60H*4+2], WORD PTR 0
    JE IMPRIMIR_NO_SE_PUEDE_DESINSTALAR
    CALL DESINSTALAR
    MOV AX,0
    MOV DX, OFFSET text_desinstalacion_term
    MOV AH,9H
    INT 21H
    JMP TERMINAR

NUMERO_PARAMS_INCORRECTO:
    MOV AX,0
    MOV DX, OFFSET text_num_params
    MOV AH,9H
    INT 21H

    JMP TERMINAR
IMPRIMIR_ESTADO_NOMBRES_GRUPO:
    MOV AX,0
    MOV ES,AX
    ;Comprobamos Vector de Inicializacion
    CMP ES:[60H*4], WORD PTR 0
    JE IMPRIMIR_NO_ESTA_INSTALADO
    CMP ES:[60H*4+2], WORD PTR 0
    JE IMPRIMIR_NO_ESTA_INSTALADO
    ;Habria que ver firma digital
    ;El driver está instalado imprimimos
    MOV DX, OFFSET text_comp_instalado
    MOV AH,9H
    INT 21H
    MOV DX, OFFSET text_grupo_nombre
    MOV AH,9H
    INT 21H
    JMP TERMINAR
IMPRIMIR_NO_SE_PUEDE_INSTALAR:
    MOV AX,0
    MOV DX, OFFSET text_no_se_puede_instalar
    MOV AH,9H
    INT 21H

    JMP TERMINAR
IMPRIMIR_NO_ESTA_INSTALADO:
    MOV AX,0
    MOV DX, OFFSET text_comp_desinstalado
    MOV AH,9H
    INT 21H
    MOV DX, OFFSET text_grupo_nombre
    MOV AH,9H
    INT 21H
    
    JMP TERMINAR
ERROR_ARGUMENTOS:
    MOV AX,0
    MOV DX, OFFSET text_error_params
    MOV AH,9H
    INT 21H

    JMP TERMINAR

IMPRIMIR_NO_SE_PUEDE_DESINSTALAR:
    MOV AX,0
    MOV DX, OFFSET text_no_se_puede_desinstalar
    MOV AH,9H 
    INT 21H

    JMP TERMINAR





TERMINAR:
    MOV AX, 4C00H
    INT 21H





;;;;
;Input: DS:BX (ASCII + '$')
;Output: DS:CX (ASCII +'$')
RSI PROC FAR
    PUSH AX BX CX DX DI SI DS
    MOV SI,0
    MOV DI,0
    MOV DX,0
    CMP AH, 12H
    JE DEC_to_HEX
    CMP AH, 13H
    JE HEX_to_DEC
    ;;FALTA CONTROL DE ERRORES
    IMPRIMIR_RESULTADO_CONVERSION:

    FIN_RSI:
        POP DS SI DI DS CX BX AX
    IRET

    DEC_to_HEX:
        ;Introducimos un caracter a la pila para parar de hacer pop
        PUSH '$'
        ;Metemos los numeros en decimal a la pila
        MOV CX, 0
        ADD CX,10
        METER_DEC_PILA:
            MOV AX,0
            MOV AX,DS:[BX+DI]
            CMP AX,'$'
            JE FIN_METER_DEC_PILA
            SUB AX,30H
            PUSH AX
            INC DI
            JMP METER_DEC_PILA
        FIN_METER_DEC_PILA:
        POP DX
        BUCLE_SUMA:
            ;;potencia de 10
            POP AX
            CMP AX,'$'
            JE FIN_BUCLE_SUMA
            MUL CX
            ADD DX,AX
            MOV AX,0
            MOV AX,CX
            MOV CX,0
            MOV CX,10
            MUL CX
            MOV CX, 0
            MOV CX,AX
            MOV AX,0
            JMP BUCLE_SUMA
            ;;extraigo y multiplico
        FIN_BUCLE_SUMA:
        MOV AX,0
        MOV AX,DX
        CALL FUNCION_HEX_TO_ASCII
        

    HEX_to_DEC:

RSI ENDP





INSTALAR PROC
	MOV AX, 0
	MOV ES, AX
	MOV AX, OFFSET RSI
    MOV BX, CS
	CLI
	MOV ES:[60h*4], AX
	MOV ES:[60h*4 +2], BX
	STI
	MOV DX, OFFSET INSTALAR
    MOV AX,0
    MOV DX, OFFSET text_instalacion_term
    MOV AH,9H
    INT 21H
	INT 27h ; Acaba y deja residente
					; PSP, variables y rutina rsi. instalador ENDP codigo ENDS END inicio
INSTALAR ENDP

DESINSTALAR PROC
	PUSH AX BX CX DS ES
	MOV CX, 0
	MOV DS, CX 	; segmento de vectores interrupcion
	MOV ES, DS:[60h*4+2]	; lee segmento de RSI
	MOV BX, ES:[2CH] 	; lee el segmento de entorno del PSP de RSI
	MOV AH, 49H
	INT 21H	; libera segmento de RSI (es)
	MOV ES, BX
	INT 21H	; libera segmento de variables de entorno de RSI
	; pone a cero vector de interrupcion 57h
	CLI
	MOV DS:[60h*4], CX	; cx = 0
	MOV DS:[60h*4+2], CX
	STI
	POP ES DS CX BX AX
	RET
DESINSTALAR ENDP

FUNCION_HEX_TO_ASCII PROC NEAR
;   Contador y zona de memoria
        MOV SI, 0 
        MOV DI,CX
        MOV WORD PTR DS:[DI],0
        MOV WORD PTR DS:[DI+2],0

        ;   Comprobamos si es el caso base. Si es así, saltamos el bucle de la división 
        CMP AX,0
        JZ CASO_CERO

        ;   Si no estamos en el caso base, realizamos bucle:
        BUCLE: 
            CMP AX, 0 
            JZ BUCLE_PILA ;Salida del bucle si el cociente es 0
            MOV DX,0 ;Limpiamos el resto
            MOV BX, 10H ; BX = 16  (Divisor)
            IDIV BX ; Realizamos división de AX/BX con signo, guardando cociente en AX y resto en DX
            CMP DX,0AH ;Si DX < 10, estamos en el caso DIGITO
            JS DIGITO
            ADD DX,37H ;Si DX >= 10, estamos en el caso LETRA, tenemos que sumar 37H para obtener el valor ASCII de la letra 
            JMP LETRA
            DIGITO: 
                ADD DX,30H ;Si es un DIGITO, tenemos que sumar 30H para obtener el valor ASCII del digito
            LETRA:
                PUSH DX ;Introducimos en la pila el resto en su valor ASCII adecuado
                INC SI ;Aumentamos el contador en 1 unidad
        JMP BUCLE

        ;   Realizamos bucle_pila: ¿ Contador (CX) = 0 ? ---> SI: Salimos del bucle
        ;                                                ---> NO: Hacemos POP de la pila (valor ASCII) y guardamos 1 byte en la zona de memoria designada
        ;                           Al terminar cada iteración, incrementamos la direción de memoria y decrementamos el contador
        ;
        ;   **** ES NECESARIO USAR LA PILA YA QUE: num = 1020 ---> BUCLE introduce en la pila CF3 y necesitamos imprimir 3FC ****
        BUCLE_PILA:
            CMP SI,0
            JZ TERMINAR_FUNCION ;Salida del bucle si el cociente es 0
            POP AX ;Sacamos de la pila el valor ASCII del caracter a representar
            MOV DS:[DI],AL ;Lo guardamos en la zona de memoria asignada
            INC DI ;Incrementamos la dirección de memoria (para escribir en la siguiente posición)
            DEC SI ;Decrementamos el contador (CX)
        JMP BUCLE_PILA


        ;   Si estamos en el caso trivial, tan sólo debemos guardar en la zona de memoria un 0 (30H valor ASCII)
        CASO_CERO:
            MOV DS:[DI],30H ;Guardamos un 0
            INC DI ;Incrementamos la dirección de memoria (para escribir en la siguiente posición)

        ;   Debemos escribir al final de la cadena a representar un '/0' en C (00H en ASCII)
        TERMINAR_FUNCION:
            MOV DS:[DI], '$'

        ;Termina la funcionalidad
        RET
FUNCION_HEX_TO_ASCII ENDP



CODIGO ENDS
END INICIO