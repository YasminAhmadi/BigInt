%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
   
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
     

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
   
     
    sys_exit     equ     60
   
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
 
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
   
    ;access mode
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000

   
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif

;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:

   push   rcx
   push   rdx
   push   rsi
   push   rdi
   push   r11

   push   ax

   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout
   syscall

   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi
   push   r11


   sub    rsp, 1

   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall

   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx
   cmp    bl, 0
   je     sEnd
   neg    rax
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall
   
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
; rsi : zero terminated string start
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx

    pop     rax
    pop     rcx
    pop     rbx
    ret
;-------------------------------------------

section .data
    Msg db 'Hello World', 0

section .bss
   num1 resb 100
   num2 resb 100
   res resb 100

section .text
    global _start

_start:
        xor r14, r14 ; r14: len of array1
        xor r15, r15 ; r15: len of array2
getinput1:
        call getc
        cmp al, 10
        je getinput2
        ;sub al, 97
        ;sub al, 10
        sub al, '0'
        mov [num1+r14], al
        inc r14
        jmp getinput1

getinput2:
        call getc
        cmp al, 10
        je cont
        sub al, '0'
        mov [num2+r15], al
        inc r15
        jmp getinput2
cont: 
        dec r14
        dec r15
        cmp r15, r14 ; rcx --> len(result) or len-1
        cmovbe rcx, r14 
        cmova rcx, r15
        ;mov rax, rcx
        ;call writeNum
        mov r9, rcx
        inc r9
        xor r8, r8  ; carry
        
      
addfunc:
        
        mov al, [num1+r14]
        add al, [num2+r15]
        add al, r8b
        xor r8, r8
        cmp al, 10
        jb contadd
        inc r8
        sub al, 10
        
        contadd:
        mov [res+rcx], al
        ;xor rax, rax
        ;mov al, [res]
        dec r14
        dec r15
        dec rcx


        cmp rcx, -1
        jne addfunc
xor rcx, rcx        
cmp r8, 1
jne print 
mov al, 1
;add al, 97
add al, '0'
call putc    
print:
        
        mov al, [res+rcx]
        ;call writeNum
        add al, '0'
        call putc
        inc rcx
        cmp r9, rcx
        jne print
Exit:
   call newLine
   mov     rax,    sys_exit
   xor     rdi,    rdi
   syscall
