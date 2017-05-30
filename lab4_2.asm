SSEG SEGMENT PARA PUBLIC "STACK"
DB  64  DUP("2")
SSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
ARRAY_LENGTH_MES DB "Enter number of columns from 2 to 10: $"
ARRAY_LENGTH_MESrad DB "Enter number of rows from 2 to 10: $"
ARRAY_LENGTH_ERR DB "ERROR! Size of array must be from 2 to 10",10,13,'$'
AGAIN_MES DB 10,13,"Reload program? Yes - press Enter, else - enter anything else.",10,13,'$'
EROR_NO_NUMBER DB 10,13,"ERROR! Input something",10,13,"Try again. $"
EROR_NUMBER DB 10,13,"Too much symbols. You can input only 4 symbols, except '-'",10,13,"Try again  $" 
INPUT_TEXT DB 10,13,"Print element from -9999 to 9999: $"
OUTPUT_ARRAY DB 10,13,"This is our array: ",10,13,'$'
NOSEARCHMSG DB 10,13,"This element is not in our array!",10,13,'$'
ARRAY dw 100 dup(0)
SPACE db 10,13,'$'
OUTFINDMSG DB 10,13,"Our element is ARRAY$"
SPACEMSG DB " $"
FLAG DB 0
FLAG1 DB 0
SEARCHMSG DB 10,13,"Print element to find:  $"
SEARCH DW 0
X DW 0
I DW 0
N DW 0
row DW 0
COLUMN DW 0
DSEG ENDS

CSEG SEGMENT
ASSUME CS:CSEG, DS:DSEG , SS:SSEG
;===============================================================================
;===============================================================================
;===============================================================================
;OUTPUT DIG
OUTPUTINT PROC FAR
    xor ax,ax
    xor cx,cx
	xor dx,dx
    or bx, bx
    jns m1
    mov al, '-'
    int 29h
    neg bx
m1:
    mov ax, bx
    xor cx, cx
    mov bx, 10
m2:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz m2
m3:
    pop ax
    int 29h
    loop m3
    ret
OUTPUTINT ENDP
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
;ENTER
SPACEmSG_F PROC FAR
    PUSH AX
    PUSH DX
    mov ah,09h
    lea dx,SPACEMSG
    int 21h
    POP AX   
    POP DX 
    RET
SPACEmSG_F ENDP
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
  
;=========NUMBER OF COLUMNS==============
    MOV AH,09H
    LEA DX,ARRAY_LENGTH_MES
    INT 21H
    CALL INPUT 
    MOV BX,X
    MOV COLUMN,BX
    CMP COLUMN,1
    JG GO11
    JMP ERROR_LENGTH_SIGN
GO11:
    CMP COLUMN,11
    JL RADOK1
    JMP ERROR_LENGTH_SIGN
  
ERROR_LENGTH_SIGN:
    MOV AH,09H  
    LEA DX,ARRAY_LENGTH_ERR  
    INT 21H
    JMP BEGIN
  
;=========NUMBER OF row==============  
radok1:
    MOV AH,09H
    LEA DX,ARRAY_LENGTH_MESRAD
    INT 21H
    CALL INPUT 
    MOV BX,X
    MOV row,BX
    CMP row,1
    JG GO
    JMP ERROR_LENGTH_SIGN
GO:
    CMP row,11
    JL GO1
    JMP ERROR_LENGTH_SIGN

;====================ARRAY INPUT================  
GO1:
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR SI,SI
    MOV I,SI

    MOV CX,row
INPUT1:
    PUSH CX
    MOV CX,COLUMN
    XOR SI,SI
    MOV I,SI

INPUT2:
    MOV AH,09H
    LEA DX,INPUT_TEXT
    INT 21H

    PUSH CX
    PUSH BX
    CALL INPUT
    MOV AX,X
    POP BX
    POP CX
    MOV ARRAY[BX+SI],AX

    INC I
    INC I
    MOV SI,I
    LOOP INPUT2

    ADD BX,10
    POP CX
    LOOP INPUT1
    JMP OUT1
  ;========
BEGINPR:
    JMP BEGIN
  ;========
;====================ARRAY OUTPUT================  
OUT1:
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR SI,SI
    MOV I,SI

    MOV AH,09H
    LEA DX,OUTPUT_ARRAY
    INT 21H

    MOV CX,row
OUTPUT1:
    PUSH CX
    MOV CX,COLUMN
    XOR SI,SI
    MOV I,SI

OUTPUT2:

    MOV AX,ARRAY [BX+SI]
    PUSH BX
    PUSH CX
    MOV BX,AX
    CALL OUTPUTINT
    POP CX
    POP BX
    CALL SPACEmSG_F
    INC I
    INC I
    MOV SI,I
    LOOP OUTPUT2

    CALL SPACEMES
    ADD BX,10
    POP CX
    LOOP OUTPUT1
;================SEARCH==========================================
    MOV AH,09H
    LEA DX,SEARCHMSG
    INT 21H
    CALL INPUT
    MOV AX,X
    MOV SEARCH,AX
    MOV FLAG1,0
;===========
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR SI,SI
    MOV I,SI

    MOV CX,row
SEARCH1:
    PUSH CX
    MOV CX,COLUMN
    XOR SI,SI
    MOV I,SI

SEARCH2:
    MOV AX,ARRAY [BX+SI]
    CMP SEARCH,AX
    JE OUTFIND
    JMP LOL
;=========
BEGINPR1:
    JMP BEGINPR
;==========
OUTFIND:
    MOV FLAG1,1
    MOV AH,09H
    LEA DX,OUTFINDMSG
    INT 21H



    MOV AL,"["
    INT 29H

;=======row
    MOV AX,BX
    PUSH BX
    PUSH CX
    XOR DX,DX
    MOV BX,10
    DIV BX
    MOV BX,AX
    INC BX
    CALL OUTPUTINT
    POP CX 
    POP BX
    CALL SPACEMSG_F

    MOV AL,"]"
    INT 29H


    MOV AL,"["
    INT 29H

;=====COLUMN
    PUSH CX
    PUSH BX
    MOV BX,SI
    SHR BX,1
    INC BX
    CALL OUTPUTINT
    POP BX
    POP CX

    MOV AL,"]"
    INT 29H
    LOL:
    INC I
    INC I
    MOV SI,I
    LOOP SEARCH2

    ADD BX,10
    POP CX
    LOOP SEARCH1
;==========
    CMP FLAG1,0
    JZ NOSEARCH
    JMP REPEATJ

NOSEARCH:
    MOV AH,09H
    LEA DX,NOSEARCHMSG
    INT 21H
;=========MAIN REPEAT================================================================ 
REPEATJ: 
    MOV AH,09H
    LEA DX,AGAIN_MES
    INT 21H
    MOV AH, 08H
    INT 21H
    CMP AL,0DH
    JZ BEGINPR1
    mov ax,4c00h
    int 21h
MAIN ENDP

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
ret
INPUT ENDP

CSEG ENDS
END MAIN
