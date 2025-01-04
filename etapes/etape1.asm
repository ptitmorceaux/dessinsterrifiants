;##################################################
;###########       Etape 1       ##################
;##################################################

%include "etapes/common.asm"

section .bss
    display_name:	resq	1
    screen:			resd	1
    depth:         	resd	1
    connection:    	resd	1
    width:         	resd	1
    height:        	resd	1
    window:		resq	1
    gc:		resq	1

    my_rayon:   resw    1

section .data
    event:		times	24 dq 0


section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################
global main
main:
;###########################################################
; Mettez ici votre code qui devra s'exécuter avant le dessin
;###########################################################





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
push 0xFFFFFF	; background  0xRRGGBB
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

;couleur du cercle 1
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0xFF00FF	; Couleur du crayon en hexa ; rouge
call XSetForeground

mov word[my_rayon], 50

; Dessin du cercle 1
mov rdi,qword[display_name]
mov rsi,qword[window]		
mov rdx,qword[gc]			

mov bx, HEIGHT / 2	; COORDONNEE en Y DU CERCLE

mov cx,word[my_rayon]	; RAYON DU CERCLE
sub bx,cx
movzx rcx,bx			

mov bx, WIDTH / 2	; COORDONNEE en X DU CERCLE

mov r15w,word[my_rayon]	; RAYON DU CERCLE
sub bx,r15w
movzx r8,bx		
mov r9w,word[my_rayon]	; RAYON DU CERCLE
shl r9,1
mov rax,23040
push rax
push 0
push r9
call XDrawArc

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
	
