
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.data

welcomeStr      db "Hi welcome to the RANUM_CONVERTER __ completely written with asm8086$"
enterStr        db "Please enter a number to be convert: $"
romanToArabStr  db "Conversion from roman to arab digits...$"
arabToRomanStr  db "Conversion from arab to roman digits...$"
endlStr         db 0ah, 0dh, '$'

; ROMAN DIGTS

CROMAN_DIGITS db 'I', 'V', 'X', 'L', 'C', 'D', 'M' ; Capital 7 chars
LROMAN_DIGITS db 'i', 'v', 'x', 'l', 'c', 'd', 'm' ; little chars  


input      db "$$$$$$$$$$" ; read stream

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
endl 
print_str enterStr
endl

mov ax, 'C'
push ax
call isRomanDigit
cmp al, 00h
jne cmp1
print_str romanToArabStr
cmp1:
print_str arabToRomanStr  

;mov bx, 09h
;lea di, input   

;call get_str
;endl
;print_str input
 
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
    cmp al, 9h      ; backspace ?
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

ends



