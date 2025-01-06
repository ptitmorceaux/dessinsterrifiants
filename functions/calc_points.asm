;===============================================================

                    ; Fonction calc_points ;

;===============================================================

    ; Utilité :

;   - Calculer la distance entre deux points

;===============================================

    ; Prend en entrée 4 arguments :

;   - rdi -> [x1]
;   - rsi -> [y1]
;   - rdx -> [x2]
;   - rcx -> [y2]

;===============================================

; Renvoie la distance entre les deux points sous formes d'un entier 

;===============================================

;   Exemple d'appel :

;calc:

;mov rdi, 1 ;(x1)
;mov rsi, 3 ;(y1)

;mov rdx, 5 ;(x2)
;mov rcx, 6 ;(x3)

;call calc_points

;(Renvoie la ditance entre ces deux points dans rax (2))
;===============================================


extern sqrt
section .text
global calc_points

calc_points:
mov rax, rdi
sub rax, rsi
imul rax, rax

mov r8, rax ; (x1-y1)²

mov rax, rdx
sub rax, rcx
imul rax, rax

add rax, r8 ; (x1-y1)² + (x2-y2)²

cvtsi2sd xxm0, rax ; convertire l'entier en double car sqrt attend un float

call sqrt ; sqrt((x1-y1)² + (x2-y2)²)

cvttsd2si rax, xmm0 ; convertie le résultat en entier arrondi

ret