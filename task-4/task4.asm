section .bss

section .text

global expression
global term
global factor

; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
factor:
        push    ebp
        mov     ebp, esp
        ; pusha
        push ebx

        mov esi, [ebp + 8]      ; imi pun in ebx pozitia curenta
        mov edi, [ebp + 12]
        mov ebx, [edi]

        mov cl, [esi + ebx]     ; ma uit la caracterul de pe pozitia curenta
        cmp cl, 0x28            ; daca este egal cu 0x28 (egal cu '(')
        je new_expression       ; atunci avem un factor de forma "(expresie)"

new_number:
        xor eax, eax            ; daca nu, atunci avem un numar

loop_digit:
        mov cl, [esi + ebx]     ; daca pe pozitia curenta caracterul e < '0'
        cmp cl, 0x30            ; 0x30 = '0', 0x39 = '9'
        jl loop_digit_end       ; atunci am terminat de procesat numarul

        cmp cl, 0x39            ; daca pe pozitia curenta caracterul e > '9'
        jg loop_digit_end       ; atunci iar am terminat numarul

        mov edx, eax            ; aici inmultesc eax cu 10 folosind operatii
        shl edx, 1              ; pe biti (eax = (eax << 3) + (eax << 1))
        mov eax, edx
        shl edx, 2
        add eax, edx

        xor edx, edx            ; aici fac eax = eax + caracterul curent
        mov dl, cl      
        and dl, 15              ; il convertesc din char in valoare (-= '0')
        add eax, edx

        inc ebx                 ; si trec la urmatoarea pozitie in sir
        jmp loop_digit

loop_digit_end:
        mov [edi], ebx          ; aici am terminat de procesat un numar
        jmp factor_end

new_expression:
        inc ebx                 ; sar peste paranteza deschisa
        mov [edi], ebx

        push edi                ; apelez iar expression
        push esi
        call expression         
        add esp, 8

        mov edi, [ebp + 12]     ; sar peste paranteza inchisa
        mov ebx, [edi]
        inc ebx
        mov [edi], ebx

factor_end:
        ; mov [answer], eax       ; mut raspunsul intr-o variabila globala
        ; popa                    ; restaurez toti registrii 
        ; mov eax, [answer]       ; si apoi pun in eax raspunsul
        pop ebx

        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
term:
        push    ebp
        mov     ebp, esp
        ; pusha
        push ebx

first_factor:
        mov esi, [ebp + 8]      ; prima data calculez primul factor din termen
        mov edi, [ebp + 12]

        push edi                ; apelez functia factor
        push esi
        call factor
        add esp, 8

term_operation:
        mov esi, [ebp + 8]      ; apoi ma uit la caracterul curent sa vad daca
        mov edi, [ebp + 12]     ; este o operatie (* sau /)
        mov ebx, [edi]

        mov cl, [esi + ebx]     ; daca da, trebuie sa obtin urmatorul factor
        cmp cl, 0x2a            ; 0x2a = '*'
        je next_factors
        cmp cl, 0x2f            ; 0x2f = '/'
        je next_factors
        jmp term_end            ; daca nu, aici se termina termenul

next_factors:
        push eax                ; imi salvez rezultatul curent si operatia
        push ecx                ; pe stiva
        inc ebx                 ; si apoi cresc pozitia curenta
        mov [edi], ebx

        push edi                ; apoi apelez functia factor
        push esi
        call factor
        add esp, 8

        pop ecx                 ; imi restaurez registrii
        pop ebx
        xchg eax, ebx           ; interschimb registrii a.i o sa am eax *// ebx

        cmp cl, 0x2a            ; 0x2a = '*'
        je multiplication
        cmp cl, 0x2f            ; 0x2f = '/'
        je division
        
multiplication:
        imul ebx                ; il inmultesc pe eax cu ebx
        jmp term_operation

division:
        cdq                     ; mai intai extind de la dword la qword
        idiv ebx                ; apoi il inmultesc pe eax cu ebx
        jmp term_operation
        
term_end:
        ; mov [answer], eax       ; mut raspunsul intr-o variabila globala
        ; popa                    ; restaurez toti registrii
        ; mov eax, [answer]       ; si apoi pun in eax raspunsul
        pop ebx

        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
expression:
        push    ebp             
        mov     ebp, esp
        ;pusha                   
        push ebx
        
first_term:
        mov esi, [ebp + 8]      ; prima data calculez primul termen din expresie
        mov edi, [ebp + 12]

        push edi                ; apelez functia term
        push esi
        call term
        add esp, 8

expression_operation:
        mov esi, [ebp + 8]      ; apoi ma uit la caracterul curent sa vad daca
        mov edi, [ebp + 12]     ; este o operatie (+ sau -)
        mov ebx, [edi]

        mov cl, [esi + ebx]     ; daca da, trebuie sa obtin urmatorul termen
        cmp cl, 0x2b            ; 0x2b = '+'
        je next_terms           
        cmp cl, 0x2d            ; 0x2d = '-'
        je next_terms
        jmp expression_end      ; daca nu, aici se termina expresia

next_terms:
        push eax                ; imi salvez rezultatul curent si operatia
        push ecx                ; pe stiva
        inc ebx                 ; si apoi cresc pozitia curenta
        mov [edi], ebx

        push edi                ; apoi apelez functia term
        push esi
        call term
        add esp, 8

        pop ecx                 ; imi restaurez registrii
        pop ebx
        xchg eax, ebx           ; interschimb registrii a.i o sa am eax +/- ebx

        cmp cl, 0x2b            ; 0x2b = '+'
        je plus                 
        cmp cl, 0x2d            ; 0x2d = '-'
        je minus

minus:
        sub eax, ebx            ; scad din eax pe ebx
        jmp expression_operation

plus:
        add eax, ebx            ; adun la eax pe ebx
        jmp expression_operation
        
expression_end:
        ; mov [answer], eax       ; mut raspunsul intr-o variabila globala
        ; popa                    ; restaurez toti registrii
        ; mov eax, [answer]       ; si apoi pun in eax raspunsul
        pop ebx

        leave
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;