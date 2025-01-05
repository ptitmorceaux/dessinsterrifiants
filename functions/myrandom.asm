;===============================================================

                    ; Fonction random_number ;

;===============================================================

    ; Utilité :

;   - Renvoyer un nombre entier positif entre 0 et [nombre max] avec [nombre max] un entier > 0 à partir d'une seed donnée [seed]

;===============================================

    ; Prend en entrée 2 arguments :

;   - edi -> [nombre max]
;   - esi -> [seed]         ; Si = 0 : la seed est generée a partir de time

;===============================================

    ; Renvoie:

;   - eax -> nb aleatoire en 0 et MAX et 0 si (edi <= 0)
;   - edx -> le nombre pseudo aleatoire généré par la seed

;===============================================

    ; Exemple d'appel :

; mov edi, 15
; call random_number

;===============================================================

extern printf, scanf, rand, srand, time

;===============================================================

section .bss
    seed:       resd    1
    max:        resd    1
    rand_num:   resd    1

;===============================================================

section .data
    nb_printf:      db  "Nombre = %d", 10, 0
    random_errmsg:  db  "non", 10, 0

;===============================================================

section .text
global random_number
random_number:
    ; Debut de la fonction
    push rbp
    mov rbp, rsp

    ;=====================================

    ; Maximum (esi)

    cmp edi, 0
    jle random_number__error

    ; On save le maximum indiqué
    mov dword[max], edi

    ;=====================================

    ; Génération d'une graine si besoin (edi)

    cmp esi, 0
    jne seed_fixed

    mov rdi, 0
    call time   ; return les secondes depuis le 01/01/1970 dans rax
    mov rsi, rax
    
    seed_fixed:
    
    mov edi, esi
    call srand
    call rand   ; return dans eax un nombre pseudo aleatoire

    ; On save le nombre pseudo aleatoire
    mov dword[rand_num], eax

    ;=====================================

    ; Calculer rand() % (MAX + 1) -> return un nb entre 0 et MAX
    mov eax, dword[rand_num]    ; Charger rand_num dans eax
    mov ebx, dword[max]         ; Charger MAX dans ebx
    inc ebx                     ; Incrementer eax pour obtenir (MAX + 1)
    xor edx, edx                ; Réinitialiser edx à 0 avant la division
    div ebx         ; Diviser eax (le nombre aléatoire) par (MAX + 1), résultat dans eax, reste dans edx

    ; On met le nb aleatoire dans eax
    mov eax, edx

    jmp pseudo_alea

    ;=====================================

    random_number__error:
    mov rdi, random_errmsg
    mov rax, 0
    call printf
    mov eax, 0  ; on renvoie 0 en cas d'erreur

    ;=====================================

    ; On return le nombre pseudo aleatoire généré par la seed dans edx

    pseudo_alea:

    mov edx, dword[rand_num]

    ;=====================================

    ; Fin de la fonction
    mov rsp, rbp
    pop rbp
    ret

;===============================================================