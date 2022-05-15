section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;; calculate least common multiple fow 2 numbers, a and b
cmmmc:
	pop edx                         ; extrag a si b din parametrii functiei
	pop eax
	pop ebx
	
	push ebx                        ; apoi pun la loc pe stiva 
	push eax                        ; valorile
	push edx

while_not_equal:
	cmp eax, ebx                    ; compar a cu b
	jl swap_numbers                 ; daca a < b, le interschimb
	je while_not_equal_end          ; daca a = b, am obtinut cmmdc-ul

	sub eax, ebx                    ; altfel, scad din a pe b
	jmp while_not_equal             ; si repet

swap_numbers:
	push eax                        ; interschimb a cu b cu ajutorul stive
	push ebx
	pop eax
	pop ebx
	jmp while_not_equal             ; si continui algoritmul

while_not_equal_end:
	push eax                        ; mut cmmdc-ul din eax in ecx
	pop ecx

	pop edx                         ; obtin iar valorile a si b din parametrii
	pop eax
	pop ebx
	push ebx
	push eax
	push edx

	mul ebx                         ; le inmultesc

	xor edx, edx                    ; si impart la cmmdc, obtinand astfel cmmmc-ul
	div ecx

	ret
