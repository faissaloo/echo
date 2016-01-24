global _start
section .text

_start:
    pop	ebp	        ; Get the number of arguments
    pop	ebx	        ; Pop the program name, we don't need this so we'll just overwrite it

    dec ebp
    cmp ebp, 0
    je _exit
    jmp _twoargs
_twoargs:
    pop	ebx		      ; Get argument
    ;compare ebx with '-n' to see if they're the same
    cld
    mov  ecx,2 ;'-n' will always be 2 characters long
    lea  esi,[nlarg]
    lea  edi, [ebx]
    repe cmpsb
    je _removenl ;If they are equal remove the newline
    jmp _main
_removenl:
    mov byte [newline],0 ;Removes the newline character from memory
    pop	ebx		      ;Skips to the next argument
    dec ebp         ;decrease the number of arguments left
    jmp _main
_nextarg:
    mov edx,1
    mov ecx,space   ;empty space
    mov ebx,1       ;stdout
    mov eax,4       ;sys_write
    int 0x80        ;Kernel interrupt

    pop	ebx		      ; Get argument
    jmp _main
_main:
    cmp ebp, 0      ;If there is only one argument do nothing, just skip to the end
    je _exit
    ;strlen(edi)
    dec ebp        ;decrease the number of arguments left
    mov edi, ebx
    call _strlen

    ;Print the string
    mov edx,eax     ;String length
    mov ecx,ebx     ;String
    mov ebx,1       ;stdout
    mov eax,4       ;sys_write
    int 0x80        ;Kernel interrupt
    cmp ebp,0;Here we need to add a conditional to check if either the stack is empty or we've processed all arguments
    jne _nextarg
    ;Otherwise exit
    jmp _exit


_exit:
    ;Print new line
    mov edx,1
    mov ecx,newline ;New line
    mov ebx,1       ;stdout
    mov eax,4       ;sys_write
    int 0x80        ;Kernel interrupt

    ;Exit with code 0
    mov eax, 1
    xor ebx, ebx
    int 80h

;call strlen
;Takes edi (the starting address of the string)
;Returns eax (the length of the string)
_strlen:
  	push	edi
  	xor	ecx, ecx
  	mov	edi, [esp]
  	not	ecx
  	xor	al, al
  	cld
    repne scasb
  	not	ecx
  	pop	edi
  	lea	eax, [ecx-1]
  	ret

section .data
  newline DB 0xA
  nlarg DB "-n"
  space DB " "
