
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.data

welcomeStr      db "Hi welcome to the RADConverter __ completely written with asm8086$"
enterStr        db "Please enter a number to be convert: $"
romanToArabStr  db "Arab digits equivalent = $"
arabToRomanStr  db "Roman digits equivalent = $"
anotherTryStr   db "Another Try ? (y/n): "
endlStr         db 0ah, 0dh, '$'

; ROMAN DIGTS

CROMAN_DIGITS db 'I', 'V', 'X', 'L', 'C', 'D', 'M' ; Capital 7 chars
LROMAN_DIGITS db 'i', 'v', 'x', 'l', 'c', 'd', 'm' ; little chars  


input           db "$$$$$$$$$$$$$$$" ; read stream
output          db "$$$$$$$$$$$$$$$" ; by default string proc return

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

.code

mov ax, @data
mov ds, ax

print_str welcomeStr
prog_begin: endl 
print_str enterStr 
lea di, input

call get_str
call STR_TO_INT
push ax
call TO_ROMAN
endl
print_str arabToRomanStr
print_str output
endl
print_str anotherTryStr
mov ah, 1
int 21h ; reads answer
cmp al, 'y'
je prog_begin  
 
mov ah, 4ch
int 21h

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

isRomanDigit proc near
    ; enter a char through pile 
    ; return ah, 00h means it's a roman 
    push bp
    mov bp, sp
    mov dx, [bp+4] 
    mov ax, 1
    lea bx, LROMAN_DIGITS
    mov cx, 7  
    while2:
    mov dh,[bx]
    cmp dl, dh
    je yesRoman
    inc bx
    loop while2
    pop bp 
    ret
    yesRoman:
    mov al, 00h
    pop bp
    ret
isRomanDigit endp

ROMAN_VALUE proc near
    ; return in ax(al) the ROMAN value 
    ; of a pushed char, (-1) it it's not roman
    
    push bp
    mov bp, sp
    mov ax, [bp+4] ;load pushed
    cmp ax, 'I'
    jne RV_case2
    mov ax, 1
    jmp end 
    
    RV_case2:
    cmp ax, 'V'
    jne RV_case3
    mov ax, 5
    jmp end
    
    RV_case3:
    cmp ax, 'X'
    jne RV_case4
    mov ax, 10
    jmp end
    
    RV_case4:
    cmp ax, 'L'
    jne RV_case5
    mov ax, 50
    jmp end
    
    RV_case5:
    cmp ax, 'C'
    jne RV_case6
    mov ax, 100
    jmp end
    
    RV_case6:
    cmp ax, 'D'
    jne RV_case7
    mov ax, 500
    jmp end
    
    RV_case7:
    cmp ax, 'M'
    jne RV_case8
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

ends



