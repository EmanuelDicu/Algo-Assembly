global get_words
global compare_func
global sort
extern qsort, strtok, strlen

section .data
    delim db " ,.",10,0                 ; string cu delimitatorii din enunt

section .text

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0

    push compare_func                   ; tot ce fac aici este sa apelez qsort
    mov eax, [ebp + 16]                 ; pun parametrii pe stiva
    push eax
    mov eax, [ebp + 12]
    push eax
    mov eax, [ebp + 8]
    push eax
    call qsort                          ; si apoi apelez
    add esp, 16                         ; la final, restaurez stack pointer-ul

    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    push delim                          ; apelez strtok(str, delim) prima data
    mov ebx, [ebp + 8]
    push ebx
    call strtok
    add esp, 8                          ; aici restaurez stack pointer-ul

    mov ecx, 0
    mov edi, [ebp + 12]

loop_while_str:
;    PRINTF32 `%s\n\x0`, eax

    mov [edi], eax                      ; mai intai mut cuvantul obtinut in lista
    add edi, 4                          ; de cuvinte rezultate
    inc ecx

    push ecx                            ; imi salvez registrii pentru ca e posibil
    push edi                            ; ca apelul la strtok sa ii strice
    
    push delim                          ; apoi apelez strtok(NULL, delim)
    push 0
    call strtok
    add esp, 8                          ; aici restaurez stack pointer-ul

    pop edi                             ; imi restaurez registrii de dina
    pop ecx
    
    cmp ecx, [ebp + 16]                 ; verific sa vad daca mai am cuvinte de 
    jl loop_while_str                   ; pus in lista

loop_while_str_end:
    leave                               
    ret

compare_func:
    enter 0, 0                          ; functia de comparare pentru qsort
    pusha 

    mov esi, [ebp + 8]                  ; obtin pointerul la pointerul la sirul de
    mov esi, [esi]                      ; caractere (pe care il dereferentiez o data)
    
    push esi                            ; apoi apelez strlen ca sa aflu lungimea sirului
    call strlen                         
    add esp, 4
    push eax                            ; pun lungimea pe stiva

    mov edi, [ebp + 12]                 ; similar pentru al 2-lea sir, aflu pointerul
    mov edi, [edi]                      ; la sir dereferentiand de 2 ori
    
    push edi                            ; apoi apelez strlen ca sa aflu lungimea lui
    call strlen
    add esp, 4
    push eax                            ; pun lungimea pe stiva

    pop edx                             ; imi restaurez lungimile celor 2 siruri
    pop ebx
    cmp ebx, edx                        ; pe care le compar sa vad daca sunt diferite
    jl first_less                       ; primul sir e mai mic 
    jg first_greater                    ; al 2-lea sir e mai mic

    mov esi, [ebp + 8]                  ; daca nu, in esi si edi imi setez pointeri
    mov esi, [esi]                      ; cu care o sa iterez prin cele 2 siruri
    mov edi, [ebp + 12]                 ; in paralel
    mov edi, [edi]
    mov ecx, ebx                        ; in ecx tin lungimea sirurilor (care acum e =)

loop_string:
    mov al, [esi]                       ; compar s1[i] cu s2[i]
    cmp al, [edi]
    jl first_less                       ; primul sir este mai mic
    jg first_greater                    ; al 2-lea sir este mai mic

    inc esi                             ; cresc pointerii la cele 2 siruri
    inc edi
    loop loop_string                    ; si continui loop-ul

equal_strings:                          ; siruri egale, returenz 0
    popa
    xor eax, eax                        
    jmp compare_func_end

first_less:                             ; primul e mai mic, returnez -1
    popa 
    mov eax, -1                 
    jmp compare_func_end

first_greater:                          ; primul e mai mare, returnez 1
    popa
    mov eax, 1

compare_func_end:
    leave
    ret