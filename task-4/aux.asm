section .bss
        answer resd 1

section .text

global expression
global term
global factor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
factor:
        push    ebp
        mov     ebp, esp
        pusha

        mov esi, [ebp + 8]
        mov edi, [ebp + 12]
        mov ebx, [edi]

        mov cl, [esi + ebx]
        cmp cl, 0x28
        je new_expression

new_number:
        xor eax, eax

loop_digit:
        mov cl, [esi + ebx]
        cmp cl, 0x30
        jl loop_digit_end

        cmp cl, 0x39
        jg loop_digit_end

        mov edx, eax
        shl edx, 1
        mov eax, edx
        shl edx, 2
        add eax, edx

        xor edx, edx
        mov dl, cl
        and dl, 15
        add eax, edx

        inc ebx
        jmp loop_digit

loop_digit_end:
        mov [edi], ebx
        jmp factor_end

new_expression:
        inc ebx
        mov [edi], ebx

        push edi
        push esi
        call expression
        add esp, 8

        mov edi, [ebp + 12]
        mov ebx, [edi]
        inc ebx
        mov [edi], ebx

factor_end:
        mov [answer], eax
        popa
        mov eax, [answer]
        
        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term:
        push    ebp
        mov     ebp, esp
        pusha

first_factor:
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]

        push edi
        push esi
        call factor
        add esp, 8

term_operation:
        mov esi, [ebp + 8]      
        mov edi, [ebp + 12]
        mov ebx, [edi]

        mov cl, [esi + ebx]     
        cmp cl, 0x2a
        je multiplication
        cmp cl, 0x2f
        je division
        jmp term_end

multiplication:
        push eax
        inc ebx
        mov [edi], ebx

        push edi
        push esi
        call factor
        add esp, 8

        pop ebx
        xchg eax, ebx
        xor edx, edx
        imul ebx
        jmp term_operation

division:
        push eax
        inc ebx
        mov [edi], ebx

        push edi
        push esi
        call factor
        add esp, 8

        pop ebx
        xchg eax, ebx
        xor edx, edx
        cdq
        idiv ebx
        jmp term_operation
        
term_end:
        mov [answer], eax
        popa
        mov eax, [answer]

        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
expression:
        push    ebp
        mov     ebp, esp
        pusha

first_term:
        mov esi, [ebp + 8]      
        mov edi, [ebp + 12]

        push edi
        push esi
        call term
        add esp, 8

expression_operation:
        mov esi, [ebp + 8]      
        mov edi, [ebp + 12]
        mov ebx, [edi]

        mov cl, [esi + ebx]     
        cmp cl, 0x2b
        je plus
        cmp cl, 0x2d
        je minus
        jmp expression_end

minus:
        push eax
        inc ebx
        mov [edi], ebx

        push edi
        push esi
        call term
        add esp, 8

        pop ebx
        xchg eax, ebx
        sub eax, ebx
        jmp expression_operation

plus:
        push eax
        inc ebx
        mov [edi], ebx

        push edi
        push esi
        call term
        add esp, 8

        pop ebx
        xchg eax, ebx
        add eax, ebx
        jmp expression_operation
        
expression_end:
        mov [answer], eax
        popa
        mov eax, [answer]

        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	pop eax
	pop ecx
	pop esi
	push esi
	push ecx
	push eax
	
	xor eax, eax

iterate_string:
	push [esi]
	pop ebx
	cmp bl, 0x28
	jne closing_bracket

opening_bracket:
	inc eax
	jmp check_bracket_end

closing_bracket:
	cmp eax, 0
	jz fail
	dec eax

check_bracket_end:
	inc esi
	loop iterate_string

iterate_string_end:
	cmp eax, 0
	jg fail

success:
	xor eax, eax
	inc eax
	jmp par_end

fail:
	xor eax, eax

par_end:
	ret
