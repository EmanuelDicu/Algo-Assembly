section .text
	global intertwine

;; void intertwine(int *v1, int n1, int *v2, int n2, int *v);
;
;  Take the 2 arrays, v1 and v2 with varying lengths, n1 and n2,
;  and intertwine them
;  The resulting array is stored in v
intertwine:
	enter 0, 0                      ; rdi = *v1, esi = n1, 
                                        ; rdx = *v2, ecx = n2, r8 = *v
	
	push r9                         ; salvez cei 2 registrii ca sa ii restaurez
	push r10                        ; inainte de a iesi din metoda

	mov r9d, esi                    ; in r9d voi tine lungimea maxima a celor
	cmp r9d, ecx                    ; 2 siruri
	jge loop_intertwine
	mov r9d, ecx

loop_intertwine:
	cmp esi, 0                      ; verific daca am epuizat toate caracterele
	jz skip_first                   ; din primul sir

	mov r10d, [rdi]                 ; daca nu, adaug la sirul final caracterul
	mov [r8], r10d                  ; curent din primul sir
	
        add rdi, 4                      ; si apoi cresc pointerii la v1 si v
	dec esi
	add r8, 4

skip_first:
	cmp ecx, 0                      ; verific daca am epuizat toate caracterele 
	jz skip_second                  ; din al 2-lea sir
	
        mov r10d, [rdx]                 ; daca nu, adaug la sirul final caracterul
	mov [r8], r10d                  ; curent din primul sir
	
        add rdx, 4                      ; si apoi cresc pointerii la v2 si v
	dec ecx
	add r8, 4

skip_second:
	dec r9d                         ; scad contorul (de cate ori iterez prin
	cmp r9d, 0                      ; siruri si vad daca mai continui loop-ul
	jg loop_intertwine

	pop r10                         ; in final restaurez registrii modificati
	pop r9
	leave
	ret
