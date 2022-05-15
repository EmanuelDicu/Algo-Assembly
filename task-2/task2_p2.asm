section .text
	global par

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
par:
	pop eax                         ; obtin lungimea si pointerul la sir
	pop ecx                         ; din parametrii functiei
	pop esi
	push esi                        ; pe care ii pun dupa la loc
	push ecx
	push eax
	
	xor eax, eax                    ; in eax tin cate paranteze deschise am

iterate_string:
	push dword [esi]                ; obtin un nou caracter din sir
	pop ebx
	cmp bl, 0x28                    ; si il compar cu paranteza 
	jne closing_bracket             ; deschisa (28H = '(')

opening_bracket:                        ; caracterul curent e paranteza deschisa
	inc eax                         ; deci cresc contorul (eax)
	jmp check_bracket_end   

closing_bracket:                        ; caracterul curent e paranteza inchisa
	cmp eax, 0                      ; scad contorul si ma asigur sa
	jz fail                         ; nu devina negativ, altfel nu e bine
	dec eax                         ; parantezat

check_bracket_end:
	inc esi                         ; trec la urmatorul caracter din sir
	loop iterate_string

iterate_string_end:
	cmp eax, 0                      ; daca nr de paranteze deschise e diferit
	jg fail                         ; de nr de paranteze inchise, nu am solutie

success:                
	xor eax, eax                    ; pun 1 in eax
	inc eax
	jmp par_end

fail:
	xor eax, eax                    ; pun 0 in eax

par_end:
	ret
