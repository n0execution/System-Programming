STSEG  SEGMENT  PARA  STACK  "STACK"  
	DB 64 DUP ("STACK")	
STSEG  ENDS

DSEG  SEGMENT  PARA  PUBLIC  "DATA" 

INPUT DB 'Please, enter the number between -9999 and 9999 inclusive : ', 13, 10, '$'
ENDLINE	DB 13,10,'$'
RESULT DB 'This is your number: $'
EQUATION1 DB 'Your equation is 35 * x / (1 - x^2)$'
EQUATION2 DB 'Your equation is x^3 - 75$'
EQUATION3 DB 'Your equation is x^2$'
CONTINUE DB 13, 10, 'Press enter to continue or esc to quit.$'
ERROR DB 'Oops.', 13, 10,  'Something went wrong.', 13, 10, '$'
ERRORTOOMUCH DB 'Error. Your number is incorrect!$'
OVER DB 'Error. Overflow in calculations.$'

DSEG  ENDS



CSEG  SEGMENT PARA PUBLIC  "CODE" 
MAIN  PROC  FAR 
ASSUME  CS: CSEG, DS: DSEG, SS: STSEG   
 
	PUSH DS 
	MOV AX, 0   
	PUSH AX  
	MOV AX, DSEG 
	MOV DS, AX 
	
	
	LEA DI,INPUT
	CALL PRINT

	CALL INPUTINT
	
	LEA DI,ENDLINE
	CALL PRINT
	
	CALL EQUATION

	LEA DI,ENDLINE
	CALL PRINT

	CMP CX, 5
	JE ML1
	LEA DI,RESULT
	CALL PRINT
	
	CALL OUTPUTINT

	CMP DX, 0
	JE ML1
	
	
	MOV AL, ' '
	INT 29h
	
	MOV AX, DX
	CALL OUTPUTINT
	MOV AL, '/'
	INT 29h
	MOV AX, BX
	CALL OUTPUTINT
	
ML1:
	
	LEA DI,ENDLINE
	CALL PRINT
	LEA DI,CONTINUE
	CALL PRINT
	LEA DI,ENDLINE
	CALL PRINT

;PROCEDURE FOR READ NUMBER FROM SCREEN
INPUTINT PROC   
        PUSH CX
        PUSH DX
        PUSH BX
        PUSH SI

; SI - SIGN MARK, BX - NUMBER
        XOR SI, SI ;SI=0
        XOR BX, BX ;BX=0
        XOR CX, CX ;CX=0

; ENTER FIRST NUMBER
        MOV AH, 01h
        INT 21h
		TEST AL,AL ;IF STRING HAS 0 LENGTH
			JZ some_error

; CHECK FOR '-' IF NOT GO TO NORMAL INIT OF SYMBOL
        CMP AL, '-'
			JNE input_next_symbol
		
; ELSE INPUT SIGN MARK
        INC SI
; INPUT NEXT SYMBOL

input_symbol:     
		MOV AH, 01h
        INT 21h
		
;IF SYMBOL GRATER THAN '9', BREAK
input_next_symbol:     
CMP AL, 39h
		JG some_error

;TRANSLATE SYMBOL INTO NUMBER

        CMP AL, 0dh
			JE check_size
		CMP AL, 01bh
			JE the_end
		SUB AL, 30h
			JB some_error
		
; AL HAS NUMBER THAT WE MUST ADD TO BX NUMBER        
	MOV     CL, AL
	
; MULTIPLY RESULT ON 10.
	MOV	AX, BX
	MOV	DX, 10
	MUL	DX
	MOV BX, AX
		;IF RESULT GRATER THAN 16 BIT ERROR
		JC wrong_number	    
       
	ADD BX, CX  ; BX = 10 * bx + al
		JC	wrong_number
	
       
; LOOP WHILE NUMBERS ENTER.
     JMP input_symbol
	 
; TEST ON SIGN


check_size:   	
;CHECK FOR INPUT NUMBER SIZE
	CMP BX,9999	    
		JA wrong_number 
	TEST SI, SI 
		JZ write_result
;CHECK FOR INPUT NUMBER SIZE
	CMP BX,9999	    
		JA wrong_number 
    NEG BX
		
write_result:     
; WRITE RESULT TO AX
	
	MOV AX,BX
    POP SI
    POP BX
    POP DX
    POP CX
    RET

some_error:	
	LEA	DI,ENDLINE
	CALL PRINT
	LEA DI,ERROR
	CALL PRINT
	LEA	DI,ENDLINE
	CALL PRINT
	RET

wrong_number:	
	LEA	DI,ENDLINE
	CALL PRINT
	LEA DI,ERRORTOOMUCH
	CALL PRINT
	LEA	DI,ENDLINE
	CALL PRINT
	RET
	
the_end:
	MOV AX, 4c00h
	int 21h
INPUTINT   ENDP



;PROCEDURE FOR WRITE NUMBER ON SCREEN

OUTPUTINT PROC
	PUSH DX
	PUSH BX
	MOV BX,AX      
	OR BX, BX     
		JNS  prepare1     
	MOV AL, '-'     
	INT	29h     
	NEG BX   
prepare1:     
	MOV AX, BX     
	XOR CX, CX     
	MOV BX, 10   
prepare2:     
	XOR DX, DX     
	DIV BX     
	ADD DL, '0'     
	PUSH DX     
	INC CX     
	TEST AX, AX     
		JNZ prepare2   
output_symbol:     
	POP AX     
	INT 29h     
	LOOP output_symbol
	POP BX
	POP DX
	RET
OUTPUTINT ENDP


EQUATION PROC

	mov cx, 0
	
	MOV BX, AX
	MOV DX, 0

	CMP AX, 6
	JG eq2
	JE eq1
	
	CMP AX, 1
	JG eq1
	JE cont
	NEG AX
	
cont:
	LEA DI, EQUATION3
	CALL PRINT
	
	MUL AX
	CMP AX, 32767
	JAE overflow
	
	CMP DX, 0
	JNE overflow
	
	MOV DX, 0
	JMP calculate
	
eq1:
	eq1:
	LEA DI, EQUATION1
	CALL PRINT

	PUSH BX
	MOV BX, 35
	MUL BX
	POP BX
	CMP DX, 0
	JNE overflow
	
	PUSH AX
	MOV AX,BX
	MUL AX
	DEC AX
	MOV CX, AX
	MOV BX, CX
	
	POP AX
	DIV CX
	NEG AX
	
	JMP calculate
eq2:
	LEA DI, EQUATION2
	CALL PRINT

	MOV DX, 0
	MUL BX
	MUL BX
	
	CMP DX, 0
	JNE overflow
	
	CMP AX, 32767
	JAE overflow
	
	MOV BX, 75
	SUB AX, BX		
	JMP calculate

	

overflow:
	LEA		DI, ENDLINE
	CALL	PRINT
	LEA		DI, OVER
	CALL	PRINT
	LEA		DI, ENDLINE
	CALL	PRINT
	MOV CX, 5
	
calculate:
	RET
	

EQUATION ENDP




;PROCEDURE FOR WRITE STRING ON SCREEN

PRINT PROC NEAR
	PUSH AX
    MOV AH,9		    
   	XCHG DX,DI		    
   	INT 21h		    
    
	XCHG DX,DI		    
   	POP AX
   	RET
PRINT ENDP


MAIN ENDP 
CSEG ENDS 
END MAIN
