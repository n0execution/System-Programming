STSEG  SEGMENT  PARA  STACK  "STACK"  
DB 64 DUP ("STACK")

STSEG  ENDS

DSEG  SEGMENT  PARA  PUBLIC  "DATA" 

INPUT DB 'Please, enter the number between -9999 and 9999 inclusive : ', 13, 10, '$'
ENDLINE	DB 13,10,'$'
RESULT DB 'This is your number: $'
CONTINUE DB 13, 10, 'Press enter to continue or esc to quit.$'
ERROR DB 'Oops.', 13, 10,  'Something went wrong.', 13, 10, '$'
ERRORTOOMUCH DB 'Error. Your number is incorrect!$'
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

LEA DI,RESULT
CALL PRINT

CALL OUTPUTINT

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
		


INPUTINT ENDP



;PROCEDURE FOR WRITE NUMBER ON SCREEN
OUTPUTINT PROC  
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
	RET
OUTPUTINT ENDP


;PROCEDURE FOR WRITE STRING ON SCREEN

PRINT PROC NEAR
	PUSH AX
    MOV AH,09		    
   	XCHG DX,DI		    
   	INT 21h		    
    
	XCHG DX,DI		    
   	POP AX
   	RET
PRINT ENDP


MAIN ENDP 
CSEG ENDS 
END MAIN
