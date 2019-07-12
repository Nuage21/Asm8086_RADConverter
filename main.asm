
; RADConverter is an asm8086 written program which converts Roman & Arab expressed numbers into each other
; works on 16bit integer
; written: July 2019 
; Assembly TP (Travaux Pratiques) at Higher National School of Computer Science
; by: > Hakim Beldjoudi (ih_beldjoudi@esi.dz)
;     > + Binome

org 100h

.data

welcomeStr      db "Welcome to the RADConverter __ completely written with asm8086$"
esiStr          db "HIGHER NATIONAL SCHOOL OF COMPUTER SCIENCE ESI -ex-INI ALGIERS$"
hzStr           db "______________________________________________________________$"
enterStr        db "Please enter a number to be convert: $"
romanToArabStr  db "Arab digits equivalent = $"
arabToRomanStr  db "Roman digits equivalent = $"
anotherTryStr   db "Another Try ? (y/n): $"
invalidStr      db "Invalid entry !$"
endlStr         db 0ah, 0dh, '$'

; ROMAN DIGTS

CROMAN_DIGITS db 'I', 'V', 'X', 'L', 'C', 'D', 'M' ; Capital 7 chars
LROMAN_DIGITS db 'i', 'v', 'x', 'l', 'c', 'd', 'm' ; little chars  


input           db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" ; read stream
output          db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" ; by default string proc return

ends

; defines some macros

macro print_str msg ; print a string
    push ax
    push dx
    mov ah, 09h
    mov dx, offset msg
    int 21h
    pop dx
    pop ax
endm 

macro endl 
    print_str endlStr
endm

.code ;---------------------------------------main_begin

mov ax, @data
mov ds, ax

print_str esiStr  
endl
print_str hzStr 
endl
print_str welcomeStr

prog_begin: 
; reset i/o strings
lea di, input
push di
call resetStr
pop di
lea di, output
push di
call resetStr
pop di

; ---> start
endl
print_str hzStr
endl 
print_str enterStr 
lea di, input

call get_str
call isRAI
cmp al, 00h
jne invalid
cmp ah, 00h
je  toArabCnvrt
push ax
call STR_TO_INT
push ax 
call TO_ROMAN
pop ax
pop ax
endl
print_str arabToRomanStr
print_str output
jmp retry

toArabCnvrt:
endl
print_str romanToArabStr
;
call ROMAN_TO_INT
push ax
call INT_TO_STR
pop ax
print_str output
jmp retry
 
invalid:
endl
print_str invalidStr

retry:
endl 
print_str anotherTryStr

mov ah, 1
int 21h ; reads answer
cmp al, 'y'
je prog_begin  
 
mov ah, 4ch
int 21h

;--------------------------------main_end
get_str proc near   
                    ; Reads and stores a string.                            
                    ; input: DI offset of string                            
                    ; output: DI offset of string                           
                    ; bx number of characters read                     
    push ax
    push di 
    cld             ; process from left ->
    xor bx, bx      ; bx <-- 00h
    mov ah, 1       ; input char function code
    int 21h
    
    while1:
    
    cmp al, 0dh     ; is it a carriage return ?
    je end_while1
    cmp al, 8h      ; backspace ?
    jne else1
    dec di          ; move str ptr back 
    dec bx          ; charCounter--
    jmp read        ;read another char
    else1:
    stosb           ; store char in string
    inc bx
    read:
    int 21h         ; read a char into al
    jmp while1      ; loop again
    end_while1:
    pop di   
    pop ax
    ret                                               

get_str endp

;-------------------------------------------------------

isRomanDigit proc near  ; insensitive_case
    ; enter a char through pile 
    ; return ax, 00h means it's a roman 
    push bp
    mov bp, sp
    mov dx, [bp+4]
    push bx ;save it 
    mov ax, 1
    lea bx, LROMAN_DIGITS
    lea si, CROMAN_DIGITS
    mov cx, 7  
    while2:
    push ax
    mov dh,[bx]
    mov al,[si]
    cmp dl, dh
    je yesRoman 
    cmp dl, al
    je yesRoman
    pop ax
    inc bx
    inc si
    loop while2
    pop bx
    pop bp 
    ret
    yesRoman:
    pop ax
    mov ax, 00h 
    pop bx
    pop bp
    ret
isRomanDigit endp  

;-------------------------------------------------------

ROMAN_VALUE proc near
    ; return in ax(al) the ROMAN value 
    ; of a pushed char, (-1) it it's not roman
    
    push bp
    mov bp, sp
    mov ax, [bp+4] ;load pushed
    cmp ax, 'I'
    je RV_case1_ 
    cmp ax, 'i'
    jne RV_case2
    RV_case1_:
    mov ax, 1
    jmp end 
    
    RV_case2:
    cmp ax, 'V'
    je RV_case2_ 
    cmp ax, 'v'
    jne RV_case3
    RV_case2_:
    mov ax, 5
    jmp end
    
    RV_case3:
    cmp ax, 'X'
    je RV_case3_
    cmp ax, 'x'
    jne RV_case4
    RV_case3_:
    mov ax, 10
    jmp end
    
    RV_case4:
    cmp ax, 'L'
    je RV_case4_
    cmp ax, 'l'
    jne RV_case5
    RV_case4_:
    mov ax, 50
    jmp end
    
    RV_case5:
    cmp ax, 'C'
    je RV_case5_
    cmp ax, 'c'
    jne RV_case6 
    RV_case5_:
    mov ax, 100
    jmp end
    
    RV_case6:
    cmp ax, 'D'
    je RV_case6_  
    cmp ax, 'd'
    jne RV_case7
    RV_case6_:
    mov ax, 500
    jmp end
    
    RV_case7:
    cmp ax, 'M'
    je RV_case7_
    cmp ax, 'm'
    jne RV_case8
    RV_case7_:
    mov ax, 1000
    jmp end  
    
    RV_case8:
    cmp ax, 0
    jne RV_default
    mov ax, 0
    jmp end
    
    RV_default:
    mov ax, -1
    end:
    pop bp
    ret
    ROMAN_VALUE endp                                   
;-------------------------------------------------------

TO_ROMAN proc near
    ; convert to roman_expressed
    ; return: in output buffer 
    ; the pushed item [2 bytes] from stack
    push bp
    mov bp, sp
    mov ax, [bp+4] 
    lea bx, output
    
    TR_while:
    cmp ax, 0
    je TR_end
    cmp ax, 1000
    jl TR_elif1
    mov [bx], 'M'
    inc bx
    sub ax, 1000
    jmp TR_while 
    TR_elif1:
    cmp ax, 500
    jl TR_elif2
    cmp ax, 900
    jl TR_elif1_else
    mov [bx], 'C'
    mov [bx+1], 'M'
    add bx, 2
    sub ax, 900
    jmp TR_while
    TR_elif1_else:
    mov [bx], 'C'
    inc bx
    sub ax, 500
    jmp TR_while
    TR_elif2:
    cmp ax, 100
    jl TR_elif3
    cmp ax, 400
    jl TR_elif2_else
    mov [bx], 'C'
    mov [bx+1], 'D'
    add bx, 2
    sub ax, 400
    jmp TR_while
    TR_elif2_else:
    mov [bx], 'C'
    inc bx
    sub ax, 100
    jmp TR_while
    TR_elif3:
    
    cmp ax, 50
    jl TR_elif4
    cmp ax, 90
    jl TR_elif3_else
    mov [bx], 'X'
    mov [bx+1], 'C'
    add bx, 2
    sub ax, 90
    jmp TR_while
    TR_elif3_else:
    mov [bx], 'L'
    inc bx
    sub ax, 50
    jmp TR_while
    TR_elif4:
    
    cmp ax, 9
    jl TR_elif5
    cmp ax, 40
    jl TR_elif4_elif
    mov [bx], 'X'
    mov [bx+1], 'L'
    add bx, 2
    sub ax, 40
    jmp TR_while
    TR_elif4_elif:
    cmp ax, 9
    jne TR_elif4_else
    mov [bx], 'I'
    mov [bx+1], 'X'
    add bx, 2
    sub ax, 9
    jmp TR_while
    TR_elif4_else:
    mov [bx], 'X'
    inc bx
    sub ax, 10
    jmp TR_while
    
    TR_elif5:
    cmp ax, 4
    jl TR_else
    cmp ax, 5
    jl TR_elif5_else
    mov [bx], 'V'
    inc bx
    sub ax, 5
    jmp TR_while
    TR_elif5_else:
    mov [bx], 'I'
    mov [bx+1], 'V'
    add bx, 2
    sub ax, 4
    jmp TR_while
    
    TR_else:
    mov [bx], 'I'
    inc bx
    dec ax
    jmp TR_while
    TR_end:
    pop bp
    ret 
    TO_ROMAN endp 
;------------------------------------------------------- 
    
STR_TO_INT proc near 
    ; @input to int stored in AX
    lea bx, input
    xor ax, ax ; zero-it
    mov cx, 10 ; to power
    STI_loop:
    push ax
    mov ax, [bx] 
    xor ah, ah
    cmp ax, '$'
    je STI_end
    mov dx, ax
    pop ax
    push dx
    mul cx 
    pop dx
    sub dx, 48 ; ascii to int
    add ax, dx
    inc bx ; next digit of input
    jmp STI_loop
    STI_end:
    pop ax
    ret
    STR_TO_INT endp 
;-------------------------------------------------------

isDigit proc near
    ; return ax = 0 when pushed 
    ; item assci is a digit
    push bp
    mov bp, sp
    mov ax, [bp+4]
    sub ax, 48
    cmp ax, 10
    jl isDig_
    isDig_not: mov ax, -1 
    jmp isDig_end
    isDig_:
    cmp ax, 0
    jl isDig_not
    mov ax, 0000h 
    isDig_end:
    pop bp
    ret
    isDigit endp
;-------------------------------------------------------

isRAI proc near
    ; string treated is @input (implicitly)
    ; ret: (al == ff) => Invalid (not arab nor Roman) 
    ; (ah == 00) => isRoman =true
    ; (ah == ff) => isArab = true
    
    lea bx, input
    mov ax, 0ff00h ; ah -> isRoman
                    ; al -> isValid
    prg_lp:
    mov dx, [bx]
    xor dh, dh 
    cmp dl, '$'
    je prd_lp_end
    push ax
    push dx
    call isRomanDigit
    cmp ax, 00h
    pop dx
    pop ax 
    jne prg_elif
    mov ah, 00h ; isRoman <- true
    jmp prdlp
    prg_elif:
    push ax ; save return value
    push dx
    call isDigit 
    cmp ax, 0 ;isDigit
    pop dx
    pop ax
    je prdlp ; if an arab digit
    mov al, 0ffh ; isValid <- false 
    prdlp: 
    inc bx
    jmp prg_lp
    prd_lp_end:
    ret
;-------------------------------------------------------
    
resetStr proc near
    ; reset to $$$$ given @str pushed
    push bp
    mov bp, sp
    mov di, [bp+4]
    RS_lp:
    cmp [di], '$'
    je RS_end
    mov [di], '$'
    inc di
    jmp RS_lp
    RS_end:
    pop bp
    ret    
ends
;-------------------------------------------------------

ROMAN_TO_INT proc near
    ; get the equivalen integer through AX to the roman-expressed
    ; -- number @input 
    lea bx, input ; load input into bx  
    xor ax, ax ; hold the result
    STI_lp:
    mov dh, [bx]
    mov dl, [bx+1]
    cmp dh, '$'
    je STI_lp_end ; last digit reached
    cmp dl, '$'
    jne STI_ct ; go if not before-last digit
    push ax
    xor ax, ax
    mov al, dh
    push ax
    call ROMAN_VALUE
    mov di, ax
    pop ax
    pop ax
    add ax, di ; add current value
    inc bx
    jmp STI_lp
    STI_ct:
    push ax
    xor ax, ax
    mov al, dh
    push ax
    call ROMAN_VALUE
    mov cx, ax
    pop ax
    xor ax, ax
    mov al, dl
    push ax
    call ROMAN_VALUE
    mov di, ax
    pop ax
    pop ax ; retrieve current acumulated sum
    cmp cx, di
    jl STI_sub
    add ax, cx
    inc bx
    jmp STI_lp
    STI_sub:
    sub ax, cx
    inc bx
    jmp STI_lp 
    STI_lp_end:
    ret
ROMAN_TO_INT endp 
;-------------------------------------------------------

INT_TO_STR proc
    ; converts pushed integer into a str
    ; stored @output
    push bp
    mov bp, sp
    mov ax, [bp+4]    
    mov dx, '$'
    push dx ;identify string end        
    ; di holds number to convert
    ITS_lp:
    mov cl, 10
    div cl    ; al holds quotient
              ; ah holds rest
    cmp al, 0
    je ITS_endlp 
    xor cx, cx
    mov cl, ah
    push cx    ; save digit
    xor ah, ah ; AX holds quetient now
               ; AX prepared to next iteration
    jmp ITS_lp
    ITS_endlp:
    cmp ah, 0
    je ITS_pop
    xor cx, cx
    mov cl, ah
    push cx 
    lea bx, output ; load output stream
    ITS_pop:
    pop ax
    cmp ax, '$'
    je ITS_end
    add ax, 48 ; to digit eq ascci code
    mov [bx], ax
    inc bx ; next stock
    jmp ITS_pop
    ITS_end:
    pop bp
    ret
INT_TO_STR endp

;-----------------------------------code_seg_end--------


