global _start
section .text

_start:
    pop	eax	        ; Get the number of arguments
    pop	ebx	        ; Pop the program name, we don't need this so we'll just overwrite it
    pop	ebx		      ; Get the first argument

    cmp eax, 1      ;If there is only one argument do nothing, just skip to the end
    je _exit
    cmp eax, 2 ;if there are two arguments skip to the bit of code that checks if the first argument is -n
    jne _twoargs
    jmp _main
_twoargs:
    ;compare ebx with '-n' to see if they're the same
    cld
    mov  ecx,2 ;'-n' will always be 2 characters long
    lea  esi,[nlarg]
    lea  edi, [ebx]
    repe cmpsb
    je _removenl ;If they are equal remove the newline
    jmp _main
_removenl:
    mov dword [newline],0 ;Removes the newline character from memory
    pop	ebx		      ;Skips to the next argument
    jmp _main
_main:
    cmp eax, 1      ;If there is only one argument do nothing, just skip to the end
    je _exit
    ;strlen(edi)
    mov edi, ebx
    call _strlen

    ;Print the string
    mov edx,eax     ;String length
    mov ecx,ebx     ;String
    mov ebx,1       ;stdout
    mov eax,4       ;sys_write
    int 0x80        ;Kernel interrupt
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
    mov ebx, 0
    int 80h

;call strlen
;Takes edi (the starting address of the string)
;Returns eax (the length of the string)
_strlen:
  	push	edi
  	sub	ecx, ecx
  	mov	edi, [esp]
  	not	ecx
  	sub	al, al
  	cld
    repne scasb
  	not	ecx
  	pop	edi
  	lea	eax, [ecx-1]
  	ret

section .data
  newline DB 0xA
  nlarg DB "-n",0
