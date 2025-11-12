;===============================================================

                    ; Fonction draw_circle ;

;===============================================================

    ; Utilité :

;   - Dessine un cercle de rayon [rayon] aux coordonéess ( [coord_x] ; [coord_y] ) avec une couleur de trait [line_color]

;===============================================

    ; Prend en entrée 7 arguments :

;   - rdi -> [display_name]
;   - rsi -> [window]
;   - rdx -> [gc]
;   - cx -> [rayon]
;   - r8w  -> [coord_x]
;   - r9w  -> [coord_y]
;   - Dans la pile : [rbp + QWORD * 2] -> line_color (dword)

;===============================================

; Ne renvoie rien

;===============================================

;   Exemple d'appel :

; mov rdi, qword[display_name]
; mov rsi, qword[window]
; mov rdx, qword[gc]
; mov cx, 50           ; RAYON du CERCLE (dword)
; mov r8w, WIDTH / 2    ; COORDONNEE en X DU CERCLE (dword)
; mov r9w, HEIGHT / 2   ; COORDONNEE en Y DU CERCLE (dword)
; push 0x00FF00         ; COULEUR du crayon en hexa (dword mais en vrai -> 3 octets : 0xRRGGBB)
; call draw_circle

;===============================================

%include "etapes/common.asm"

;===============================================================

section .bss
    display_name:	resq	1
    window:         resq	1
    gc:		        resq	1

    coord_x:        resw    1
    coord_y:        resw    1
    rayon:          resw    1
    line_color:     resd    1

;===============================================================

section .text
global draw_circle
draw_circle:
    ; Début de la fonction
    push rbp
    mov rbp, rsp
    sub rsp, 16  ; Aligner la pile sur 16 octets et réserver de l'espace

    ;=====================================

    ; Sauvegarde des  arguments
    mov qword[display_name], rdi
    mov qword[window], rsi
    mov qword[gc], rdx
    mov word[rayon], cx
    mov word[coord_x], r8w
    mov word[coord_y], r9w
    mov rdi, qword[rbp + QWORD * 2] ; arg 7 -> voir page 5 cours fonctions
    mov dword[line_color], edi

    ;=====================================

    ; Couleur du cercle
    mov rdi, qword[display_name]
    mov rsi, qword[gc]
    mov edx, dword[line_color]    ; Couleur du crayon en hexa ; rouge
    call XSetForeground

    ; Dessin du cercle
    mov rdi, qword[display_name]
    mov rsi, qword[window]		
    mov rdx, qword[gc]			

    mov bx, word[coord_x]   ; COORDONNEE en X DU CERCLE

    mov cx, word[rayon]     ; RAYON DU CERCLE
    sub bx, cx
    movzx rcx, bx			

    mov bx, word[coord_y]	; COORDONNEE en Y DU CERCLE

    mov r10w, word[rayon]	; RAYON DU CERCLE
    sub bx, r10w
    movzx r8, bx		
    mov r9w, word[rayon]	; RAYON DU CERCLE
    shl r9, 1
    mov rax, 23040
    push rax
    push 0
    push r9
    call XDrawArc
    add rsp, 24     ; Nettoyer la pile (3 push x 8 octets)

    ;=====================================

    ; Fin de la fonction
    leave  ; Équivalent à: mov rsp, rbp; pop rbp
    ret

;===============================================================