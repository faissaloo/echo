global _start
section .text

_start:
    pop	esi	        ; Get the number of arguments
    pop	ebx	        ; Pop the program name, we don't need this so we'll just overwrite it

    mov edx,0xA     ;The newline character

    cmp esi, 1      ; If there are no arguments just exit
    je _exit
    pop	ebx		      ; Get argument
    ;compare ebx with '-n' to see if they're the same
    mov edi, [ebx]
    and edi, 0xFFFFFF ; Mask the bits we don't need
    cmp edi,0x6e2d ;Check for '-n'
    jne _main
_removenl:
    mov edx,0 ;Removes the newline character from memory
    pop	ebx		      ; Skips to the next argument
    dec esi         ; decrease the number of arguments left

_main:
    cmp esi, 1      ; If there is only one argument do nothing, just skip to the end
    je _exit
    ;strlen(edi)
    dec esi         ; Decrease the number of arguments left
    mov edi, ebx
    ;Get the string length for string edi and put it in eax
    push	edi
  	xor	ecx, ecx
  	mov	edi, [esp]
  	not	ecx
  	xor	al, al
    repne scasb
  	not	ecx
  	pop	edi
  	lea	eax, [ecx-1]
    mov byte [ebx+eax],32 ; Put a space in between each argument to replace the string terminator
    cmp esi,1       ; Here we need to add a conditional to check if we've processed all arguments
    jne _main        ; If this is the last argument exit


_exit:
    ;Append a newline to the end if we have a newline
    mov [ebx+eax],edx
    inc eax ;Increase the length by one
    ; Print the string
    mov edx,eax     ; String length
    mov ecx,ebx     ; String
    mov ebx,1       ; stdout
    mov eax,4       ; sys_write
    int 0x80        ; Kernel interrupt

    ;Exit with code 0
    mov eax, 1
    xor ebx, ebx
    int 0x80
