;##################################################
;###########       Etape 5       ##################
;##################################################

; my external functions from ./functions/
extern random_number
extern draw_circle
extern distance_points

;##################################################

%include "etapes/common.asm"

%define NB_CERCLES 1000
%define NB_CERCLES_INIT 10

%define COLUMN_CIRCLES 3 ; { r , x , y }

%define DISTANCE_FENETRE_EXTERNE 50
%define RAYON_EXTERN (WIDTH - 2 * DISTANCE_FENETRE_EXTERNE) / 2
%define MAX_XY (WIDTH - 2 * DISTANCE_FENETRE_EXTERNE)

%define LEN_PALETTE 10

;##################################################

section .bss
    display_name:	resq	1
    screen:			resd	1
    depth:         	resd	1
    connection:    	resd	1
    window:         resq	1
    gc:             resq	1

    i:                  resw    1
    j:                  resw    1
    circles_rxy:        resw    NB_CERCLES * COLUMN_CIRCLES   ; nb_de_cercles * { r , x , y }
    tmp_circle_rxy:     resw    COLUMN_CIRCLES
    extern_circle_rxy:  resw    COLUMN_CIRCLES

;##################################################

section .data
    event:		times	24 dq 0

    palette:    dd  0xb8ff61, 0xb9e458, 0xbaca4f, 0xbbaf46, 0xbc943d, 0xbe7a33, 0xbf5f2a, 0xc04421, 0xc12a18, 0xc20f0f

    ; msg_start:  db  "--- DEBUT ---", 10, 10, 0
    ; msg_end:    db  "--- FIN ---", 10, 10, 0
    ; int_msg:    db  "%d : %d // %d", 10, 10, 0
    ; coord_msg:  db  "x:%d y:%d // %d", 10, 10, 0
    ; msg_aled:   db  "ALED", 10, 10, 0
    ; test_msg:   db  "TEST MSG : %d", 10, 0

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

; Définition du cercle externe -> { r , x , y }
mov word[extern_circle_rxy + WORD * 0], RAYON_EXTERN    ; r
mov word[extern_circle_rxy + WORD * 1], (WIDTH / 2)     ; x
mov word[extern_circle_rxy + WORD * 2], (WIDTH / 2)     ; y

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

        ; Si on défini le rayon d'un cercle init ou non
        cmp word[i], NB_CERCLES_INIT
        jb boucle_rand__rayon_init

        ; rayon d'un cercle pas init : pas de random
        mov ax, 0   ; on initialise à 0
        jmp def_tmp

        ; rayon d'un cercle init
        boucle_rand__rayon_init:
        mov di, RAYON_EXTERN   ; Rayon max CERCLE INIT random = RAYON_EXTERN
        jmp boucle_rand_calcul

        ; Pour x et y (voir calcul etape 3)
        boucle_rand__xy:
        mov di, MAX_XY  ; Maximum pour x et y

        boucle_rand_calcul:
        call random_number
        ; ax = random_number

        ; Si on définie le rayon alors on n'applique aucun changement sur le nombre aleatoire
        cmp word[j], 0
        je def_tmp
        ; Sinon, pour x et y, on rajoute DISTANCE_FENETRE_EXTERNE (voir calcul etape 3)
        add ax, DISTANCE_FENETRE_EXTERNE

        def_tmp:
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

        ;------------------------------------------
        
        ; Pour eviter de recalculer un nouveau cercle si le changement de rayon cause
        ; une collision avec un cercle pas encore calculer dans la boucle [j] :

        ;------------------------------------------
        
        ; On verifie un cercle init la somme est de : tmp[0] + cercles[j][0]
        cmp word[i], NB_CERCLES_INIT
        jb somme_rayons
        ; Sinon le rayon de tmp est de 0, la somme est donc : cercles[j][0]
        movzx rdx, word[circles_rxy + WORD * (r8)]  ; cercles[j][0] 
        jmp distance_inferieure_rayon

        somme_rayons:
        ; Somme des rayons
        movzx rdx, word[tmp_circle_rxy]             ; tmp_cercle[0]
        movzx rsi, word[circles_rxy + WORD * (r8)]  ; cercles[j][0]
        add rdx, rsi
        ; rdx = (somme des rayons) = (rayon_tmp + rayon_cerlce[j])

        distance_inferieure_rayon:
        ; Si distance <= sum(rayons):
        cmp rax, rdx
        jbe cercle_est_en_collision

        ;------------------------------------------

        ; ETAPE 2

        ; On change le rayon pour etre tangent au cercle le plus proche si pas cercle init

        ;------------------------------------------

        ; Si il s'agit d'un cercle init on ne change pas son rayon
        cmp word[i], NB_CERCLES_INIT
        jb init_ou_pas_proche

        ; Si le rayon du cercle n'est pas égal à 0
        ; On calcul le plus proche
        cmp word[tmp_circle_rxy], 0
        jne calc_proche
        ; Sinon on initialise le rayon au max + 1 pour pouvoir calculer le plus proche
        mov word[tmp_circle_rxy], RAYON_EXTERN + 1

        calc_proche:
        ; (distance - cerlces[j][0])
        movzx rdx, word[circles_rxy + WORD * (r8)]  ; rayon -> cerlces[j][0]
        ; rax = distance
        ; rdx = cerlces[j][0] -> rayon
        sub rax, rdx    ; rax = distance - rayon_cercle

        ; Si (distance - rayon_cercle) >= tmp_rayon
        ; Alors tmp_rayon ne change pas
        cmp ax, word[tmp_circle_rxy]
        jae init_ou_pas_proche

        ; On change le rayon si le nouveau est plus petit
        ; rax = nouveau rayon = (distance - rayon_cercle)
        mov word[tmp_circle_rxy], ax

        init_ou_pas_proche:

        ;------------------------------------------

    inc word[j]
    ; Si j == i alors on a déjà parcouru tout les cercles exsitants, on arrete la boucle
    mov ax, word[i]
    cmp word[j], ax
    jne boucle_collision
    
    fin_boucle_collision:

    ;=====================================

    ; Etape 3

    ; On redessine si tmp cercle est dans le cercle externe (normalement c'est optimisé avec le rand de x et y pour dessiner dans la zone)

    ;=====================================

    movzx rdi, word[extern_circle_rxy + WORD * (1)] ; x1 -> extern[1]
    movzx rsi, word[extern_circle_rxy + WORD * (2)] ; y1 -> extern[2]
    movzx rdx, word[tmp_circle_rxy + WORD * (1)]    ; x2 -> tmp[1]
    movzx rcx, word[tmp_circle_rxy + WORD * (2)]    ; y2 -> tmp[2]
    call distance_points
    ; rax = la ditance entre les deux points

    ; Somme de rayon_tmp et de la distance entre extern et tmp (voir schema etape 3)
    movzx rdx, word[tmp_circle_rxy] ; tmp_cercle[0]
    add rax, rdx
    ; rax = (rayon_tmp + distance_tmp_extern)

    ; Si (rayon_tmp + distance_tmp_extern) > rayon_extern:
    movzx rdx, word[extern_circle_rxy]
    cmp rax, rdx
    ja cercle_est_en_collision

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

; ;------------------------------------------
; ;        Afficher le cercle externe
; ;------------------------------------------
;     mov rdi, qword[display_name]
;     mov rsi, qword[window]
;     mov rdx, qword[gc]
;     mov cx,  word[extern_circle_rxy + WORD * 0]
;     mov r8w, word[extern_circle_rxy + WORD * 1]
;     mov r9w, word[extern_circle_rxy + WORD * 2]
;     push 0xFF00FF   ; purpule
;     call draw_circle
; ;------------------------------------------

mov word[i], 0
boucle_dessin:

    ; mul utilise rdx:rax
    movzx rax, word[i]
    mov rbx, COLUMN_CIRCLES
    mul rbx     ; met le resultat dans rax 
    ; rax = i * COLUMN_CIRCLES

    mov cx,  word[circles_rxy + WORD * (rax + 0)]   ; circles_rxy[i][0] : RAYON du CERCLE (word)
    mov word[j], 0

    boucle_cercle_concentrique:
        
        push rcx
        push rax

        mov rdi, qword[display_name]
        mov rsi, qword[window]
        mov rdx, qword[gc]

        mov r8w, word[circles_rxy + WORD * (rax + 1)]   ; circles_rxy[i][1] : COORDONNEE en X DU CERCLE (word)
        mov r9w, word[circles_rxy + WORD * (rax + 2)]   ; circles_rxy[i][2] : COORDONNEE en Y DU CERCLE (word)

        movzx rbx, word[j]
        mov ebx, dword[palette + DWORD * rbx]
        push rbx     ; mettre la couleur du tableau
        call draw_circle

        
        pop rcx     ; enlever 0xFF0000
        pop rax     ; Save rax
        pop rcx     ; recupere le rayon cx

        inc word[j]
        cmp word[j], LEN_PALETTE    
        jb len_palette_unreached 
        mov word[j], 0        
        len_palette_unreached:
    
    sub cx, 1
    cmp cx, 0
    jg boucle_cercle_concentrique

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