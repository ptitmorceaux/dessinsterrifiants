;===============================================================

extern printf, scanf, rand, srand, time

;===============================================================

section .data
    nb_printf:      db  "Nombre = %d", 10, 0
    random_errmsg:  db  "non", 10, 0

;===============================================================

section .bss
    rand_num:   resd    1

;===============================================================

section .text
global main

main:
    push rbp

    mov edi, 15
    call random_number
    mov dword[rand_num], eax

    mov rdi, nb_printf
    mov esi, dword[rand_num]
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

; Renvoie:
;   - eax -> nb aleatoire en 0 et MAX et 0 si (edi <= 0)

random_number:
    push rbp
    mov rbp, rsp 
    
    cmp edi, 0
    jle random_number__error
    
    mov ecx, edi    ; on save le max (temporaire) dans ecx
    push rcx
    
    mov rdi, 0
    call time   ; return les secondes depuis le 01/01/1970 dans rax
    mov ecx, eax
    
    ; PID dans RAX
    mov rax, 39 ; getpid syscall number
    syscall
    
    mul ecx   ; eax = partie inferieur de : ecx (time) * PID (ancien eax)

    mov edi, eax
    call srand
    call rand   ; mov dans eax un nombre pseudo aleatoire
    
    ; Calculer rand() % (MAX + 1) -> return un nb entre 0 et MAX
    pop rcx
    inc ecx ; (MAX + 1)
    xor edx, edx    ; réinitialise de maniere efficace edx à 0
    mov rdx, 0
    div ecx ; le reste est return dans edx

    ; On met le nb aleatoire dans eax
    mov eax, edx

    jmp fin

    random_number__error:
    mov rdi, random_errmsg
    mov rax, 0
    call printf
    mov eax, 0  ; on renvoie 0 en cas d'erreur

    fin:
    mov rsp, rbp
    pop rbp
    ret

;===============================================================