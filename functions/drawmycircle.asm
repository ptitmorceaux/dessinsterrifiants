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
;   - rcx -> [rayon]
;   - r8  -> [coord_x]
;   - r9  -> [coord_y]
;   - Dans la pile : [rbp + QWORD * 2] -> line_color

;===============================================

; Ne renvoie rien

;===============================================

;   Exemple d'appel :

; mov rdi, qword[display_name]
; mov rsi, qword[window]
; mov rdx, qword[gc]
; mov ecx, 50           ; RAYON du CERCLE (dword)
; mov r8d, WIDTH / 2    ; COORDONNEE en X DU CERCLE (dword)
; mov r9d, HEIGHT / 2   ; COORDONNEE en Y DU CERCLE (dword)
; push 0x00FF00         ; COULEUR du crayon en hexa (dword mais en vrai -> 3 octets : 0xRRGGBB)
; call draw_circle

;===============================================

%include "etapes/common.asm"

;===============================================================

section .bss
    display_name:	resq	1
    window:         resq	1
    gc:		        resq	1

    coord_x: resd    1
    coord_y: resd    1
    rayon:   resd    1
    line_color:   resd    1

;===============================================================

section .text
global draw_circle

draw_circle:
    ; Début de la fonction
    push rbp
    mov rbp, rsp

    ; Sauvegarde des  arguments
    mov qword[display_name], rdi
    mov qword[window], rsi
    mov qword[gc], rdx
    mov dword[rayon], ecx
    mov dword[coord_x], r8d
    mov dword[coord_y], r9d
    mov rdi, qword[rbp + QWORD * 2] ; arg 7 -> voir page 5 cours fonctions
    mov dword[line_color], edi

    ; Couleur du cercle
    mov rdi, qword[display_name]
    mov rsi, qword[gc]
    mov edx, dword[line_color]    ; Couleur du crayon en hexa ; rouge
    call XSetForeground

    ; Dessin du cercle
    mov rdi, qword[display_name]
    mov rsi, qword[window]		
    mov rdx, qword[gc]			

    mov bx, word[coord_y]   ; COORDONNEE en Y DU CERCLE

    mov cx, word[rayon]     ; RAYON DU CERCLE
    sub bx, cx
    movzx rcx, bx			

    mov bx, word[coord_x]	; COORDONNEE en X DU CERCLE

    mov r15w, word[rayon]	; RAYON DU CERCLE
    sub bx, r15w
    movzx r8, bx		
    mov r9w, word[rayon]	; RAYON DU CERCLE
    shl r9, 1
    mov rax, 23040
    push rax
    push 0
    push r9
    call XDrawArc

    ; Fin de la fonction
    mov rsp, rbp
    pop rbp
    ret