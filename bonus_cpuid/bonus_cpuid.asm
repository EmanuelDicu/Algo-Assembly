section .text
	global cpu_manufact_id
	global features
	global l2_cache_info

;; void cpu_manufact_id(char *id_string);
;
;  reads the manufacturer id string from cpuid and stores it in id_string
cpu_manufact_id:
	enter 	0, 0
	pusha 

	mov eax, 0                      ; conform documentatiei, cand eax = 0,                     
	cpuid                           ; vendorID = [ebx:edx:eax]

	mov edi, [ebp + 8]              ; pe care le mut in solutie
	mov [edi], ebx
	mov [edi + 4], edx
	mov [edi + 8], ecx
	
	popa
	leave
	ret

;; void features(char *vmx, char *rdrand, char *avx)
;
;  checks whether vmx, rdrand and avx are supported by the cpu
;  if a feature is supported, 1 is written in the corresponding variable
;  0 is written otherwise
features:
	enter 	0, 0
	pusha

	mov eax, 1                      ; conform documentatiei, cand eax = 1
	cpuid                           

; vmx
	mov edi, [ebp + 8]              ; vmx este al 5-lea cel mai nesemnificativ
	mov ebx, ecx                    ; bit din ecx. Copiez in ebx ca sa nu 
	shr ebx, 5                      ; alterez ecx
	and ebx, 1
	mov [edi], ebx

; rdrand
	mov edi, [ebp + 12]             ; similar, rdrand este al 30-lea bit din ecx
	mov ebx, ecx
	shr ebx, 30
	and ebx, 1
	mov [edi], ebx

; avx
	mov edi, [ebp + 16]             ; si avx este al 28-lea bit
	mov ebx, ecx
	shr ebx, 28
	and ebx, 1
	mov [edi], ebx

	popa
	leave
	ret

;; void l2_cache_info(int *line_size, int *cache_size)
;
;  reads from cpuid the cache line size, and total cache size for the current
;  cpu, and stores them in the corresponding parameters
l2_cache_info:
	enter 	0, 0
	pusha
	
	mov eax, 0x80000006             ; conform documentatiei, cand apelez cpuid
	cpuid                           ; cu valoarea asta, obtin cache-info

	mov edi, [ebp + 8]              ; L2 cache line-size va fi in octetul
	xor ebx, ebx                    ; cel mai nesemnificativ din ecx
	mov bl, cl
	mov [edi], ebx

	mov edi, [ebp + 12]             ; si L2 cache size va fi in word-ul (16 biti)
	xor ebx, ebx                    ; cel mai semnificativ al lui ecx
	mov ebx, ecx
	shr ebx, 16
	mov [edi], ebx

	popa
	leave
	ret
