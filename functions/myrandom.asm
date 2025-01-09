;===============================================================

                    ; Fonction random_number ;

;===============================================================

    ; Utilité :

;   - Renvoyer un nombre entier positif entre 0 et [nombre max] avec [nombre max] un entier > 0

;===============================================

    ; Prend en entrée 1 argument :

;   - di -> [nombre max]

;===============================================

    ; Renvoie:

;   - eax -> nb aleatoire en 0 et MAX et 0 si di <= 0

;===============================================

    ; Exemple d'appel :

; mov di, 500  ; max random num
; call random_number

;===============================================================

extern printf, scanf, rand, srand, time

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

    ; Maximum (di)

    cmp di, 0
    jle random_number__error

    ;=====================================

    ; Génération d'un nombre aléatoire dans le registre rax
    rdrand_generate:
        rdrand rax
        jc rdrand_success
        jmp rdrand_generate
    rdrand_success:

    ;=====================================

    ; Calculer rand() % (MAX + 1) -> return un nb entre 0 et MAX
    inc rdi         ; Incrementer rdi pour obtenir (MAX + 1)
    xor rdx, rdx    ; Réinitialiser rdx à 0 avant la division
    div rdi         ; Diviser rax (le nombre aléatoire) par rdi (MAX + 1), résultat dans rax, reste dans rdx

    ; On met le nb aleatoire dans eax
    movzx rax, dx

    jmp fin

    ;=====================================

    random_number__error:
    mov rdi, random_errmsg
    mov rax, 0
    call printf
    mov rax, 0  ; on renvoie 0 en cas d'erreur

    ;=====================================

    fin:

    ; Fin de la fonction
    mov rsp, rbp
    pop rbp
    ret

;===============================================================