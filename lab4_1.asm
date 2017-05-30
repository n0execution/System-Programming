SSEG SEGMENT PARA PUBLIC "STACK"
DB  64  DUP("2")
SSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
MAS_LENGTH_MES DB "Enter size of array from 2 to 50: $"
MAS_LENGTH_ERR DB "ERROR! Size of array must be from 2 to 50.",10,13,'$'
AGAIN_MES DB 10,13,"Reload program? Yes - press Enter, else - press anything else.",10,13,'$'
EROR_NO_NUMBER DB 10,13,"ERROR! Input something",10,13,"Try again $"
EROR_NUMBER DB 10,13,"To much symbols. You can input only 4 symbols, except '-'",10,13,"Try again: $" 
INPUT_TEXT DB 10,13,"Enter element from -9999 to 9999: $"
OUTPUT_MAS DB 10,13,"This is our array: $"
OUTPUT_MAS_S DB 10,13,"Sorted array: $"
mas dw 100 dup(0)
SUMMA_MSG DB 10,13,"The sum of array is: $"
SPACE db 10,13,'$'
SPACEMSG DB " $"
OVERFLOWMSG DB 10,13,"ERROR! Overflow in sum",10,13,'$'
MAX_MSG DB 10,13,"Maximum of our array is: $"
MAX DW 0
FLAG DB 0
SUM DW 0
X DW 0
I DW 0
N DW 0
DSEG ENDS

CSEG SEGMENT
ASSUME CS:CSEG, DS:DSEG , SS:SSEG
;===============================================================================
;===============================================================================
;===============================================================================
;OUTPUT DIG
INPUTINT PROC FAR
    XOR AX,AX
    XOR CX,CX
	XOR DX,DX
    OR BX, BX
    JNS m1
    MOV AL, '-'
    int 29h
    NEG BX
m1:
    MOV AX, BX
    XOR CX, CX
    MOV BX, 10
m2:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ m2
m3:
    POP AX
    int 29h
    LOOP m3
    RET
INPUTINT ENDP
;===============================================================================
;===============================================================================
;===============================================================================
;MAIN
MAIN PROC FAR
PUSH DS
MOV AX,DSEG
MOV DS,AX
BEGIN:
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
  
;=========NUMBER OF ELENENT INPUT==============
    MOV AH,09H
    LEA DX,MAS_LENGTH_MES
    INT 21H
    CALL INPUT 
    MOV CX,X
    CMP CX,1
    JG GO
    JMP ERROR_LENGTH_SIGN
    GO:
    CMP CX,51
    JL GO1
    JMP ERROR_LENGTH_SIGN
  
ERROR_LENGTH_SIGN:
    MOV AH,09H  
    LEA DX,MAS_LENGTH_ERR  
    INT 21H
    JMP BEGIN
;====================MASIVE INPUT================  
GO1:
    MOV I,0
    MOV N,CX
VVOD:

    MOV AH,09H
    LEA DX,INPUT_TEXT
    INT 21H

    PUSH CX
    CALL INPUT
    POP CX

    MOV SI,I
    MOV AX,X
    MOV MAS[SI],AX
    INC I 
    INC I
    LOOP VVOD

    JMP OUT1

;====================OVERFLOW MSG================
BEGINPR:
    JMP BEGIN

    ERR_OVERFLOW:
    mov ah,09h
    LEA DX, OVERFLOWMSG
    INT 21H
    JMP REPEATJ

OUT1:
;====================MASIVE OUTPUT================
    mov si,0
    mov i,si
    mov cx,n

    MOV AH,09H
    LEA DX,OUTPUT_MAS
    INT 21H

OUTPUT:

    PUSH CX
    MOV BX,MAS[SI]
    CALL INPUTINT
    POP CX

    INC I 
    INC I
    MOV SI,I


    MOV AH,09H
    LEA DX,SPACEMSG
    INT 21H

    MOV SI,I
    LOOP OUTPUT
;=================================SUM==================================
    mov si,0
    mov i,si
    MOV SUM,SI
    mov cx,n
    XOR AX,AX
    XOR BX,BX
    JMP SUMMA

BEGINPR1:
    JMP BEGINPR

SUMMA:
    MOV BX,MAS[SI]
    ADD SUM,BX
    JO ERR_OVERFLOW
    INC I
    INC I
    MOV SI,I
    LOOP SUMMA

    MOV AH, 09H
    LEA DX,SUMMA_MSG
    INT 21H

    MOV BX,SUM
    CALL INPUTINT
;=========SEARCH MAX==========================================================
    mov si,0
    mov i,si
    MOV max,-9999
    mov cx,n
    XOR AX,AX
    XOR BX,BX

maxj:
    mov bx,mas[SI]
    cmp max,bx
    JL SWAP
    JMP MAXGO

SWAP:
    MOV MAX,BX

MAXGO:
    INC I
    INC I
    MOV SI,I
    loop maxj

    MOV AH, 09H
    LEA DX,MAX_MSG
    INT 21H

    MOV BX,MAX
    CALL INPUTINT
;=========SORTING================================================================ 

    mov si,0
    mov i,si
    mov cx,n
    xor bx,bx
    xor ax,ax

SORTPR:

    PUSH CX
    MOV CX,N
    DEC CX

    MOV SI,0
    MOV I, SI

sort:
    MOV AX,MAS[SI]
    MOV BX,MAS[SI+2]
    CMP AX,BX
    JG SWAP_SORT
    JMP SORT1

BEGINPR2:
    JMP BEGINPR1

SWAP_SORT:
    PUSH AX
    MOV AX,BX
    POP BX
    MOV MAS[SI],AX
    MOV MAS[SI+2],BX

SORT1:

    INC I
    INC I
    MOV SI,I
    LOOP SORT
    POP CX
    LOOP SORTPR
;=========OUTPUT SORTED MASIVE================================================================ 
    mov si,0
    mov i,si
    mov cx,n

    MOV AH,09H
    LEA DX,OUTPUT_MAS_S
    INT 21H

OUTPUTS:

    PUSH CX
    MOV BX,MAS[SI]
    CALL INPUTINT
    POP CX

    INC I 
    INC I
    MOV SI,I


    MOV AH,09H
    LEA DX,SPACEMSG
    INT 21H

    MOV SI,I
    LOOP OUTPUTS
;=========MAIN REPEAT================================================================ 
REPEATJ: 
    MOV AH,09H
    LEA DX,AGAIN_MES
    INT 21H
    MOV AH, 08H
    INT 21H
    CMP AL,0DH
    JZ BEGINPR2
    mov ax,4c00h
    int 21h
MAIN ENDP
;===============================================================================
;===============================================================================
;===============================================================================
;ENTER
SPACEmes PROC FAR
    PUSH AX
    PUSH DX
    mov ah,09h
    lea dx,SPACE
    int 21h
    POP AX   
    POP DX 
    RET
SPACEmes ENDP
;===============================================================================
;===============================================================================
;===============================================================================
;INPUT
INPUT PROC
X_START:
    xor ax,ax
    xor cx,cx
    XOR BX,BX
;===========================1ST SYMBOL INPUT====================
START_INPUT:	
	MOV AH,08H
	INT 21H
	cmp al,'-'
    jz is_minus
	cmp al,0dh
    jz MES_NO_DIGIT
    CMP AL,'0'
    JL START_INPUT
	CMP AL,'9'
	JG START_INPUT
    CMP AL,'-'
	JNZ IS_PLUS
;===========================FLAG "-"====================
IS_MINUS:
    INT 29H
    MOV FLAG,1
    JMP IS_PLUS

;===========================NUMBER INPUT====================	
PLUS:
	XOR AX,AX
	MOV AH,08H
	INT 21H
IS_PLUS:
	CMP AL,0DH
	JZ END_PROM_PLUS
	CMP AL,'0'
	JL PLUS
	CMP AL,'9'
	JG PLUS
	INT 29H
	SUB AL,30H
	XOR AH,AH
	PUSH AX
	MOV Dx,10
	MOV Ax,Bx
	MUL Dx
	MOV Bx,Ax
	POP AX
	ADD Bx,Ax
	INC CL
	CMP CL,4
    JG EROR_NUMBER_OF_DIGIT
    JMP PLUS
;===========================NUMBER OF DIGIT CHECK====================
END_PROM_PLUS:
    CMP CL,0
    JZ MES_NO_DIGIT
    JMP END_PLUS  
;===========================NO DIGIT MESSAGE====================
MES_NO_DIGIT:
	MOV AH,09H
	LEA DX,EROR_NO_NUMBER
	INT 21H
	JMP X_START
;===========================TOO MUCH SYMBOLS MESSAGE====================	
EROR_NUMBER_OF_DIGIT:
	MOV AH,09H
	LEA DX,EROR_NUMBER
	INT 21H
	JMP X_START
;===========================CHECK "-" FLAG================================
END_PLUS:
    CMP FLAG,1
    JZ NEG_JMP
    JMP NEG_JMP0
NEG_JMP: 
    NEG BX
NEG_JMP0:
	CALL SPACEmes
	MOV X,BX
	MOV FLAG,0
RET
INPUT ENDP

CSEG ENDS
END MAIN

