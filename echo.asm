global _start
section .text

_start:
    pop	ebp	        ; Get the number of arguments
    pop	ebx	        ; Pop the program name, we don't need this so we'll just overwrite it

    cmp ebp, 1      ; If there are no arguments just exit
    je _exit
    pop	ebx		      ; Get argument
    ;compare ebx with '-n' to see if they're the same
    cld
    mov  ecx,2      ; '-n' will always be 2 characters long
    lea  esi,[nlarg]
    lea  edi, [ebx]
    repe cmpsb
    je _removenl    ;If they are equal remove the newline
    jmp _main
_removenl:
    mov byte [newline],0 ;Removes the newline character from memory
    pop	ebx		      ; Skips to the next argument
    dec ebp         ; decrease the number of arguments left
    jmp _main
_main:
    cmp ebp, 1      ; If there is only one argument do nothing, just skip to the end
    je _exit
    ;strlen(edi)
    dec ebp         ; Decrease the number of arguments left
    mov edi, ebx
    ;Get the string length for string edi and put it in eax
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

    ;Print the string
    mov edx,eax     ; String length
    mov ecx,ebx     ; String
    mov ebx,1       ; stdout
    mov eax,4       ; sys_write
    int 0x80        ; Kernel interrupt
    cmp ebp,1       ; Here we need to add a conditional to check if either the stack is empty or we've processed all arguments
    je _exit        ; If this is the last argument exit

    mov edx,1
    mov ecx,space   ; Empty space
    mov ebx,1       ; stdout
    mov eax,4       ; sys_write
    int 0x80        ; Kernel interrupt

    pop	ebx		      ; Get argument
    jmp _main


_exit:
    ;Print new line
    mov edx,1
    mov ecx,newline ; New line
    mov ebx,1       ; stdout
    mov eax,4       ; sys_write
    int 0x80        ; Kernel interrupt

    ;Exit with code 0
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data
  newline DB 0xA
  nlarg DB "-n"
  space DB " "
