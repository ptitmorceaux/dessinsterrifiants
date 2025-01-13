;##################################################
;###########       Etape 1       ##################
;##################################################

; my external functions from ./functions/
extern random_number
extern draw_circle
extern distance_points

;##################################################

%include "etapes/common.asm"

%define NB_CERCLES 300
%define COLUMN_CIRCLES 3 ; { r , x , y }
%define MAX_RAYON (WIDTH / 2)

;##################################################

section .bss
    display_name:	resq	1
    screen:			resd	1
    depth:         	resd	1
    connection:    	resd	1
    window:         resq	1
    gc:             resq	1

    i:              resw    1
    j:              resw    1
    circles_rxy:    resw    NB_CERCLES * COLUMN_CIRCLES   ; nb de cercles * { r , x , y }
    tmp_circle_rxy: resw    COLUMN_CIRCLES

;##################################################

section .data
    event:		times	24 dq 0

    msg_start:  db  "--- DEBUT ---", 10, 10, 0
    msg_end:    db  "--- FIN ---", 10, 10, 0
    int_msg:    db  "%d : %d // %d", 10, 10, 0
    coord_msg:  db  "x:%d y:%d // %d", 10, 10, 0
    msg_aled:   db  "ALED", 10, 10, 0
    test_msg:   db  "TEST MSG : %d", 10, 0

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

mov word[i], 0
boucle_cercle:

    ; mul utilise rdx:rax
    movzx rax, word[i]
    mov rbx, COLUMN_CIRCLES
    mul rbx
    ; rax = i * COLUMN_CIRCLES
    mov rbx, rax
    ; rbx = i * COLUMN_CIRCLES

    ;=====================================

    ; Calcul d'un cercle aléatoire

    ;=====================================

    cercle_est_en_collision:

    mov word[j], 0
    boucle_random:

        ; Si on défini le rayon -> tmp[0] : le max est different de x et y
        cmp word[j], 0
        jne boucle_rand__xy

        mov di, MAX_RAYON   ; Maximum du rayon
        jmp boucle_rand_calcul

        boucle_rand__xy:
        mov di, WIDTH  ; Maximum pour x et y

        boucle_rand_calcul:
        call random_number
        ; ax = random_number

        movzx rcx, word[j] ; rcx = j

        mov word[tmp_circle_rxy + WORD * (rcx)], ax ; tmp[j] (word)

    inc word[j]
    cmp word[j], COLUMN_CIRCLES
    jne boucle_random

    ;=====================================

    ; On vérifie si [tmp_circle_rxy] ne rentre pas en collision avec un des cercles déjà calculés
    ; Sinon on renvoie vers boucle_rand__tmp_cricle

    ;=====================================

    ; Si on est au premier cercle dessiner, on ne regarde pas
    cmp word[i], 0
    je fin_boucle_collision

    mov word[j], 0
    boucle_collision:

        movzx r8, word[j]
        mov rax, COLUMN_CIRCLES
        mul r8      ; r8 *= rax
        mov r8, rax ; r8 = j * COLUMN_CIRCLES

        movzx rdi, word[circles_rxy + WORD * (r8 + 1)]  ; x1 -> cercle[j][1]
        movzx rsi, word[circles_rxy + WORD * (r8 + 2)]  ; y1 -> cercle[j][2]
        movzx rdx, word[tmp_circle_rxy + WORD * (1)]    ; x2 -> tmp[1]
        movzx rcx, word[tmp_circle_rxy + WORD * (2)]    ; y2 -> tmp[2]
        call distance_points
        ; rax = la ditance entre les deux points

        ; Somme des rayons
        movzx rdx, word[tmp_circle_rxy]             ; tmp_cercle[0]
        movzx rsi, word[circles_rxy + WORD * (r8)]  ; cercles[j][0]
        add rdx, rsi
        ; rdx = (somme des rayons) = (rayon_tmp + rayon_cerlce[j])

        ; Si distance <= sum(rayons):
        cmp rax, rdx
        jbe cercle_est_en_collision
    
    inc word[j]
    ; Si j == i alors on a déjà parcouru tout les cercles exsitants, on arrete la boucle
    mov ax, word[i]
    cmp word[j], ax
    jne boucle_collision
    
    fin_boucle_collision:

    ;=====================================

    ; On ajoute le tmp_cricle dans le tableau des cercles

    ;=====================================

    mov word[j], 0 
    boucle_init_cercle:

        movzx r8, word[j]   ; r8  = j
        mov rax, rbx        ; rax = COLUMN_CIRCLES * i
        add rax, r8         ; rax = j + COLUMN_CIRCLES * i

        mov cx, word[tmp_circle_rxy + WORD * (r8)]

        mov word[circles_rxy + WORD * (rax)], cx  ; circles_rxy[i][j] (word)
    
    inc word[j]
    cmp word[j], COLUMN_CIRCLES
    jne boucle_init_cercle

    ;=====================================

inc word[i]
cmp word[i], NB_CERCLES
jne boucle_cercle


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

mov word[i], 0
boucle_dessin:

    ; mul utilise rdx:rax
    movzx rax, word[i]
    mov rbx, COLUMN_CIRCLES
    mul rbx
    ; rax = i * COLUMN_CIRCLES

    mov rdi, qword[display_name]
    mov rsi, qword[window]
    mov rdx, qword[gc]

    mov cx,  word[circles_rxy + WORD * (rax + 0)]   ; circles_rxy[i][0] : RAYON du CERCLE (word)
    mov r8w, word[circles_rxy + WORD * (rax + 1)]   ; circles_rxy[i][1] : COORDONNEE en X DU CERCLE (word)
    mov r9w, word[circles_rxy + WORD * (rax + 2)]   ; circles_rxy[i][2] : COORDONNEE en Y DU CERCLE (word)

    push 0xFFFFFF   ; COULEUR du crayon en hexa (dword mais en vrai -> 3 octets : 0xRRGGBB)
    
    call draw_circle

    pop rdi ; Pour nettoyer la pile (-> 0xFFFFFF)

inc word[i]
cmp word[i], NB_CERCLES
jne boucle_dessin


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