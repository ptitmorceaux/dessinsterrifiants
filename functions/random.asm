;===============================================================

extern printf, scanf, rand, srand, time

;===============================================================

section .data
    testmsg:        db  "Nombre = %d", 10, 0
    random_errmsg:  db  "non", 10, 0

;===============================================================

section .bss

;===============================================================

section .text
global main

main:
    push rbp

    ; mov rdi, 15
    ; call random_number
    ; mov rax, rdi

    ; mov rdi, testmsg
    ; mov rsi, 
    ; mov rax, 0
    ; call printf

    mov ecx, 15    ; on save le max (temporaire) dans ebx
    push rcx
    mov rdi, 0
    call time   ; return les secondes depuis le 01/01/1970 dans rax
    mov rdi, rax
    call srand
    call rand   ; mov dans eax un nombre pseudo aleatoire
    ; Calculer rand() % (MAX + 1) -> return un nb entre 0 et MAX
    pop rcx
    inc ecx ; (MAX + 1)
    xor edx, edx    ; réinitialise de maniere efficace edx à 0
    div ecx ; le reste est return dans edx
    mov eax, edx

    mov edi, testmsg
    mov esi, eax    ; Le reste (rand % (x + 1)) est maintenant dans edx
    mov rax, 0
    call printf

    pop rbp

    mov rax, 60        
    mov rdi, 0
    syscall


;===============================================

; Utilité:
;   - Renvoyer un nombre entier positif entre 0 et [nombre max] ou [nombre max] est un entier > 0

; Entrée:
;   - rdi -> [nombre max]

; random_number:
    
;     cmp edi, 0
;     jle non
    
;     mov rbx, rdi    ; on save le max dans rbx

;     call time
;     mov rdi, rax
;     call srand

;     call rand
;     ; Calculer rand() % (x + 1)
;     mov eax, edx
;     add eax, 1
;     mov ebx, eax
;     call rand
;     xor edx, edx
;     div ebx

;     mov [random_number], edx  ; Le reste (rand % (x + 1)) est maintenant dans edx

;     jmp fin

;     non:
;     mov rdi, random_errmsg
;     mov rax, 0
;     call printf

;     fin:
;     mov rsp, rbp
;     pop rbp

;===============================================================