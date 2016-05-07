BITS 32
              org     0x08048000
;Mini LEGAL ELF header
;http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html
ehdr:                                                 ; Elf32_Ehdr
              db      0x7F, "ELF", 1, 1, 1, 0         ;   e_ident
      times 8 db      0
              dw      2                               ;   e_type
              dw      3                               ;   e_machine
              dd      1                               ;   e_version
              dd      _start                          ;   e_entry
              dd      phdr - $$                       ;   e_phoff
              dd      0                               ;   e_shoff
              dd      0                               ;   e_flags
              dw      ehdrsize                        ;   e_ehsize
              dw      phdrsize                        ;   e_phentsize
              dw      1                               ;   e_phnum
              dw      0                               ;   e_shentsize
              dw      0                               ;   e_shnum
              dw      0                               ;   e_shstrndx

ehdrsize      equ     $ - ehdr

phdr:                                                 ; Elf32_Phdr
              dd      1                               ;   p_type
              dd      0                               ;   p_offset
              dd      $$                              ;   p_vaddr
              dd      $$                              ;   p_paddr
              dd      filesize                        ;   p_filesz
              dd      filesize                        ;   p_memsz
              dd      5                               ;   p_flags
              dd      0x1000                          ;   p_align

phdrsize      equ     $ - phdr

_start:
    pop	esi	        ; Get the number of arguments

    dec esi      ; If there are no arguments just exit instantly
    jz _noArgsExit

    pop	ecx	        ; Pop the program name, we don't need this so we'll just overwrite it

    pop	ecx		      ; Get first argument
    mov ebx, 0x80808080 ;Store the himagic in ebx so we can speed things up a little
    ;Listen: I don't give a damn if you don't like the fact that I'm using a non
    ;general purpose register for this, it doesn't get used and it's much faster
    mov ebp, 0x7F7F7F7F
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
    ;Get the string length for string edx and put it in eax
_s:
    mov edi,[edx]
    add edx,4     ;Move to the next 'double word' (because we'll be decreasing from it)
    ; Wooo magical numbers!
    and edi, ebp
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
_sysentercont:
    ;Exit with code 0
    xor ebx, ebx
_noArgsExit:
    mov eax, 1
    mov ebp, esp
    sysenter

filesize      equ     $ - $$
