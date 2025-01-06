;##################################################
;###########       Etape 1       ##################
;##################################################

; my external functions from ./functions/
extern random_number
extern draw_circle

;##################################################

%include "etapes/common.asm"

;##################################################

section .bss
    display_name:	resq	1
    screen:			resd	1
    depth:         	resd	1
    connection:    	resd	1
    width:         	resd	1
    height:        	resd	1
    window:         resq	1
    gc:             resq	1

    i:              resb    1
    circle_rxy:     resd    3   ; 10 cercles * { r , x , y }
    rand_seed:           resd    1

;##################################################

section .data
    event:		times	24 dq 0

    int_msg:    db    "%d : %d", 10, 10, 0

;##################################################

section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################
global main
main:
;###########################################################
; Mettez ici votre code qui devra s'exécuter avant le dessin
;###########################################################

mov dword[rand_seed], 0

mov byte[i], 0
boucle_rand:
    mov edi, WIDTH - 100  ; Maximum
    mov esi, dword[rand_seed]
    call random_number    ; Résultat return dans eax et la prochaine seed dans edx
    mov dword[rand_seed], edx
    
    mov rbx, circle_rxy
    movzx rcx, byte[i]
    mov dword[rbx + DWORD * rcx], eax

    ; mov rdi, int_msg
    ; movzx esi, byte[i]
    ; mov edx, dword[circle_rxy + DWORD * rcx]
    ; mov rax, 0
    ; call printf
inc byte[i]
cmp byte[i], 3  ; max d'iterations (3 : r, x, y)
jne boucle_rand


;###############################
; Code de création de la fenêtre
;###############################
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,WIDTH	; largeur
mov r9,HEIGHT	; hauteur
push 0x000000	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
;jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################

dessin:

mov rdi, qword[display_name]
mov rsi, qword[window]
mov rdx, qword[gc]
mov ecx, dword[circle_rxy + DWORD * 0]  ; RAYON du CERCLE (dword)
mov r8d, dword[circle_rxy + DWORD * 1]  ; COORDONNEE en X DU CERCLE (dword)
mov r9d, dword[circle_rxy + DWORD * 2]  ; COORDONNEE en Y DU CERCLE (dword)
push 0xFFFFFF   ; COULEUR du crayon en hexa (dword mais en vrai -> 3 octets : 0xRRGGBB)
call draw_circle


; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
;jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit