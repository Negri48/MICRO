;**************************************************************************
;* BASIC ASSEMBLY PROGRAM STRUCTURE EXAMPLE to use with C code link
;* SBM / MBS 2020
;* Autores: Rodrigo Lardiés Guillén
;           Víctor Sánchez de la Roda Núñez
;**************************************************************************
 

; CODE SEGMENT DEFINITION
_TEXT SEGMENT BYTE PUBLIC 'CODE'
ASSUME CS: _TEXT,


;********************************************************************************************************************************************************************
;; Look Up Tables para el tercer apartado
tabla db 84,82,87,65,71,77,89,70,80,68,88,66,78,74,90,83,81,86,72,76,67,75,69 ;Tabla que contiene valores ASCII de las letras de los DNI
coef_mod_23 db 14,6,19,18,11,8,10,1 ;Tabla que contiene los coeficientes que acompañan a cada cifra en el algoritmo modular del apartado 3 (explicado después)
;*********************************************************************************************************************************************************************





;*********************************************************************************************************************************************************************
; funcion1: _calculaMediana
;
PUBLIC _calculaMediana 
_calculaMediana PROC FAR 
;Guardamos el puntero a la pila
PUSH BP
MOV BP, SP

;Hacemos push a la pila los registros utilizados
PUSH BX CX DX

;Recuperamos las variables necesarias para el ejercicio
MOV AX,[BP + 6] ;; int a
MOV BX,[BP + 8] ;; int b
MOV CX, [BP + 10] ;; int c
MOV DX, [BP + 12] ;; int d

;Funcionamiento de la subrutina
;   Realizamos 6 comparaciones para ordenar los elementos de menor a mayor
;   A B C D --> ¿ D > C ? ---> SI Comparamos con el siguiente
;                         ---> NO Intercambiamos los valores de los registros
;   Cuando comparamos todos con D, tenemos en D el valor más alto, se realiza los mismo para las anteriores posiciones

;   COMPARACION DE DX
CMP DX,CX ; ¿ D > C?
JNS SALTO1; Si no hay bandera de signo (D > C) comparamos los siguientes
XCHG DX,CX ; Si la hay (C > D) intercambiamos los valores de los registros
SALTO1: CMP DX,BX ;Se repite lo explicado anteriormente para todos los registros
JNS SALTO2
XCHG DX,BX
SALTO2: CMP DX,AX
JNS SALTO3
XCHG DX,AX

;   COMPARACION DE CX
SALTO3: CMP CX,BX
JNS SALTO4
XCHG CX,BX
SALTO4:CMP CX,AX
JNS SALTO5
XCHG CX,AX

;   COMPARACION DE BX
SALTO5:CMP BX,AX
JNS SALTO6
XCHG BX,AX

;   En este punto tenemos: A < B < C < D. La mediana entonces será la media de B + C
SALTO6: ADD BX,CX ;Suma de registros
SAR BX,1 ;División por 2

;   Tenemos que volcar el resultado (la mediana a AX) para retornar correctamente
MOV AX,BX 

;Termina la funcionalidad

;Devolvemos los valores de los registros utilizados (AX no ya que hay un retorno)
POP DX CX BX BP
RET

_calculaMediana ENDP
;*********************************************************************************************************************************************************************




;*********************************************************************************************************************************************************************
; funcion2: _enteroACadenaHexa
;
PUBLIC _enteroACadenaHexa
_enteroACadenaHexa PROC FAR 
;Guardamos el puntero a la pila
PUSH BP
MOV BP, SP

;Hacemos push a la pila los registros utilizados
PUSH AX CX DX DI ES

;Recuperamos las variables necesarias para el ejercicio
MOV AX,[BP + 6] ;; int num 
LES DI,[BP + 8] ;; char* outStr

;Funcionamiento de la subrutina
;   Obtenidos los caracteres ASCII del int num, comprobamos si es caso base (= 0).
;   Si no lo es, inicializamos un contador (CX) y la zona de memoria (ES:[DI]) dónde guardaremos el String.
;   Realizamos bucle:  num / 16 --> ¿ Cociente (AX) = 0 ? --> SI: Salimos de bucle
;                                                       --> NO: ¿ Resto (DX) es dígito o letra ? -->DIGITO: Sumamos 30H para obtener su valor ASCII
;                                                                                                 -->LETRA: Sumamos 37H para obtener su valor ASCII
;                       Al terminar cada iteración del bucle, hacemos push del resto modificado e incrementamos el contador (CX) 

;   Contador y zona de memoria
MOV CX, 0 
MOV WORD PTR ES:[DI],0
MOV WORD PTR ES:[DI+2],0

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
        INC CX ;Aumentamos el contador en 1 unidad
JMP BUCLE

;   Realizamos bucle_pila: ¿ Contador (CX) = 0 ? ---> SI: Salimos del bucle
;                                                ---> NO: Hacemos POP de la pila (valor ASCII) y guardamos 1 byte en la zona de memoria designada
;                           Al terminar cada iteración, incrementamos la direción de memoria y decrementamos el contador
;
;   **** ES NECESARIO USAR LA PILA YA QUE: num = 1020 ---> BUCLE introduce en la pila CF3 y necesitamos imprimir 3FC ****
BUCLE_PILA:
    CMP CX,0
    JZ TERMINAR ;Salida del bucle si el cociente es 0
    POP AX ;Sacamos de la pila el valor ASCII del caracter a representar
    MOV ES:[DI],AL ;Lo guardamos en la zona de memoria asignada
    INC DI ;Incrementamos la dirección de memoria (para escribir en la siguiente posición)
    DEC CX ;Decrementamos el contador (CX)
JMP BUCLE_PILA


;   Si estamos en el caso trivial, tan sólo debemos guardar en la zona de memoria un 0 (30H valor ASCII)
CASO_CERO:
    MOV ES:[DI],30H ;Guardamos un 0
    INC DI ;Incrementamos la dirección de memoria (para escribir en la siguiente posición)

;   Debemos escribir al final de la cadena a representar un '/0' en C (00H en ASCII)
TERMINAR:
    MOV ES:[DI], 00H

;Termina la funcionalidad

;Devolvemos los valores de los registros utilizados
POP ES DI DX CX AX BP
RET
_enteroACadenaHexa ENDP
;*********************************************************************************************************************************************************************



;*********************************************************************************************************************************************************************
; funcion3: _calculaLetraDNI
;
PUBLIC _calculaLetraDNI 
_calculaLetraDNI PROC FAR 
;Guardamos el puntero a la pila
PUSH BP 
MOV BP, SP

;Hacemos push a la pila los registros utilizados
PUSH SI DI CX DX AX BX ES DS

;Recuperamos las variables necesarias para el ejercicio
LDS DI,[BP + 6] ;; char* inStr
                ;; char* letra (Lo recuperaré después porque necesito ese registro)

;Funcionalidad de la subrutina 
;   Inicializamos un contador (CX), guardamos la dirección de la tabla coef_mod_23 (SI), en DX tendré el valor de la dirección de SI
;                                 , BX lo utilizaré para almacenar una suma y AX valdrá ASCII de cada Byte de char* inStr
;
;   El algoritmo que hemos usado para obtener el valor mod 23 del nº de DNI introducido es el siguiente:
;   DNI = ABCDEFGH = A * 10^7 + B * 10^6 + ... + G * 10 + H * 1
;   Queremos tomar mod 23 de eso:              ( A * 10^7 + B * 10^6 + ... + G * 10 + H * 1) mod 23 
;   (x + y) mod 23 = x mod 23 + y mod 23 ----> (A * 10^7) mod 23 + (B * 10^6) mod 23 + ... + (G * 10) mod 23 + (H * 1) mod 23 
;   (x * y) mod 23 = x mod 23 * y mod 23 ----> (A) mod 23 * (10^7) mod 23 + (B) mod 23 * (10^6) mod 23 + ... + (G) mod 23 * (10) mod 23 + (H) mod 23 * (1) mod 23
;   ABCDEFGH, 10 y 1 son menores que 23  ----> A * (10^7) mod 23 + B * (10^6) mod 23 + ... + G * 10 + H * 1
;   Computando con calculadora:          ----> | (10^7) mod 23 = 14 | | (10^6) mod 23 = 6 | | (10^5) mod 23 = 19 | | (10^4) mod 23 = 18 | | (10^3) mod 23 = 11 | | (10^2) mod 23 = 8 |  (COEF_MOD_23)
;   Entonces: DNI mod 23 = (A*14 + B*6 + C*19 + D*18 + E*11 + F*8 + G*10 + H) mod 23
;   La diferencia es que el segundo numero cabe en un registro, el valor más grande que podria tomar en decimal es (dig_mas_alto * coef_mas_alto * nº sumas) = 9*19*8 = 1368

;Inicializamos contador, dirección tabla de coeficientes, valor de la dirección anterior y el resultado de la suma
MOV CX, 8 
MOV SI, OFFSET coef_mod_23
MOV DX,0 
MOV BX,0

;   En este bucle realizamos el algoritmo mencionado antes
BUCLE_DNI:
    MOV AX,0 ;Limpiamos AX
    CMP CX,0 
    JZ TERMINAR_DNI ;Si hemos realizado 8 iteraciones, salimos del bucle
    MOV DL, byte ptr CS:[SI] ;Guardamos en DX el valor del coeficiente correspondiente a la iteración
    MOV AL, byte ptr DS:[DI] ;Guardamos en AX el valor ASCII del dígito del DNI correspondiente a la iteración
    SUB AX,30H ;Obtenemos el valor decimal de dicho dígito
    MUL DL ;Multiplicamos el valor decimal del dígito por el coeficiente de la tabla 
    ADD BX,AX ;Añadimos el resultado de la mult anterior a BX
    INC SI ;Incrementamos la posición de la tabla
    INC DI ;Incrementamos la posición en la cadena del DNI
    DEC CX ;Decrementamos el contador
JMP BUCLE_DNI

;   Una vez tenemos el resultado de DNI * coef, tenemos que hacer mod 23
;   Para ello, dividiremos este número (guardado en BX) entre 23 y nos quedaremos con el resto (que guarderemos en AH)
TERMINAR_DNI:
MOV AX,BX ;Guardamos el resultado del algoritmo en AX
MOV BX,0 ;Limpiamos BX
MOV BX,23 ;Guardamos el divisor (23) en BX
DIV BL ;Division de 8 bits (es suficiente) . Resto en AH (que debemos mirar ahora en LUT tabla)

;   Guardamos el resto en DX, en BX tendremos la dirección de la LUT
MOV DX,0
MOV DL,AH
MOV BX,0 ;Limpiamos BX

;   RECUPERAMOS char* letra de la pila, memoria dónde debemos guardar la letra correspondiente en la LUT al contenido de DX
LES SI,[BP + 10]
MOV BX, OFFSET tabla ;Guardamos en BX el inicio de la tabla
ADD BX, DX ;Avanzamos a la posición correspondiente en la tabla
MOV DL, byte ptr CS:[BX] ;Guardamos el byte correspondiente de la LUT en DL
MOV byte ptr ES:[SI], DL ;Volcamos la letra a la posición de memoria especificada

;Termina la funcionalidad pedida

;Devolvemos los valores de los registros utilizados
POP DS ES BX AX DX CX DI SI BP
RET
_calculaLetraDNI ENDP
;*********************************************************************************************************************************************************************
_TEXT ENDS
END
