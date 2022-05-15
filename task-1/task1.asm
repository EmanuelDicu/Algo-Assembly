section .text
	global sort

; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list

sort:
        enter 0, 0

        mov ecx, [ebp + 8]

construct_list:
        push ecx

        mov edx, [ebp + 12]
        push edx
        push ecx
        call find_position
        add esp, 8

        pop ecx
        cmp ecx, 1
        je construct_list_end

        dec ecx
        push ecx
        push eax
        
        mov edx, [ebp + 12]
        push edx
        push ecx
        call find_position
        add esp, 8

        pop ebx
        pop ecx

        mov edx, [ebp + 12]
        add eax, 4
        mov [eax], ebx 

        jmp construct_list

construct_list_end:

	leave
	ret

find_position:
        enter 0, 0

        mov ebx, [ebp + 8]
        mov eax, [ebp + 12]

loop_for:
        cmp ebx, [eax]
        je end_loop_for
        add eax, 8
        jmp loop_for

end_loop_for:

        leave
        ret