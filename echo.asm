global _start
section .text

_start:
    pop	esi	        ; Get the number of arguments
    pop	ecx	        ; Pop the program name, we don't need this so we'll just overwrite it

    dec esi      ; If there are no arguments just exit
    jz _exit

    pop	ecx		      ; Get argument
    ;compare ecx with '-n' to see if they're the same
    mov ah,`\n`     ;The newline character
    mov edx, [ecx]
    and edx, 0xFFFFFF ; Mask the bits we don't need
    cmp edx,`-n\0`;Check for '-n'
    jne _main
_removenl:
    xor ah,ah ;Removes the newline character from memory
    xor edx,edx ;Set edx back to zero from before to prevent segfaults
    dec esi
    jz _exit
    pop ecx
_main:
    ;strlen(edx)
    ;Here we have an assembly implementation of glibc's strlen.c
    ;Yes, that's right, I'm using *that* method because it's REALLY fast
    mov edx, ecx
    mov ebx, 0x80808080 ;Store the himagic in ebx so we can speed things up a little
    ;Get the string length for string edx and put it in eax
_s:
    mov edi,[edx]
    add edx,4     ;Move to the next 'double word' (because we'll be decreasing from it)
    ; Wooo magical numbers!
    and edi, 0x7F7F7F7F
    sub edi, 0x01010101
    and edi, ebx
    xor edi, 0  ;compare edi with 0
    jz _s ;If none of them were zeros loops back to s
    ;otherwise let's track down the one that was zero which will be represented a 0x80
    sub edx, 4      ;Remove the 'add edx, 2' that we did before
    ; mov edx again, so that we can test the actual value, since our cool magic
    ; number stuff that we did before destroys edx, which means that character
    ; 128 will cause misfires
    mov edi,[edx]
    test edi, 0xFF
    jz _cont


    inc edx
    test edi, 0xFF00
    jz _cont


    inc edx
    test edi, 0xFF0000
    jz _cont

    inc edx
    test edi, 0xFF000000
    jnz _s ;If it was a misfire, go back and continue

_cont:
    mov edi,ecx ;Save the original starting point in edi, we don't want to modify ecx
    sub edx, edi  ;Get the difference
    mov byte [ecx+edx],32 ; Put a space in between each argument to replace the string terminator
    dec esi          ; Decrease arg count
    jnz _main        ; If this is the last argument exit


_exit:
    ;Append a newline to the end if we have a newline
    mov [ecx+edx],ah
    inc edx ;Increase the length by one
    ; Print the string
    ;String length should already be in edx
    ;String should already be in ecx
    ;mov edx,edx     ; String length
    ;mov ecx,ecx     ; String
    mov ebx,1       ; stdout
    mov eax,4       ; sys_write
    push _sysentercont
    push ecx
    push edx
    push ebp
    mov ebp, esp
    sysenter        ; Kernel interrupt
_sysentercont: ;To continue after sysenter
    ;Exit with code 0
    mov eax, 1
    xor ebx, ebx
    push _sysentercont
    push ecx
    push edx
    push ebp
    mov ebp, esp
    sysenter
