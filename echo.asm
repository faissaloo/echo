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
    pop ebx             ;Get argument count
    dec ebx             ;If there are no arguments just exit instantly
    jz _noArgsExit
    
    mov al, `\n`        ;Store the newline character

    add esp, 4          ;Remove program name from the stack, we don't need it
    pop	ecx	        ;Get first argument
    
    ;compare edx with '-n' to see if they're the same
    ;If we take 1 away from ecx we'll be assured
    ;that before and after the -n there will be a null terminator
    ;no need for bswap or shift rubbish
    cmp dword [ecx-1],`\0-n\0`;Check for '-n'
    jne _main
_removenl:
    xor eax, eax       ; Removes the newline character from memory
    dec ebx
    jz _noArgsExit
    pop ecx ;prepares the first real argument for echo
_main:
    dec ebx
    jz _final_arg ;check if we're already on the final argument
    _most_args:
        pop edx
        dec ebx
        mov byte [edx-1], ` `
        jnz _most_args

    _final_arg: ;only get strlen for the final argument
	;Remove the null between argv and envp and get the first bit of 
	;envp, basically combining add esp, 4 and pop edx.
	;We can do this because we no longer need to keep track of the 
	;stack after this.
	mov edx, [esp+4]
_exit:
    ;Append a newline to the end if we have a newline
    ; Print the string
    mov [edx], al
    inc ebx          ; stdout
    inc edx
    ;String pointer is already in ecx
    mov al,4         ; sys_write, only need to write to al because only thing in that register is newline, which is 8-bits and no longer needed
    sub edx, ecx     ; String length
    push _sysentercont
    lea ebp, [esp-12] ;esp-12 because we don't care what gets put in those registers after, so just use any stack garbage
    sysenter        ; Kernel interrupt
_sysentercont:
    dec ebx
_noArgsExit:
    mov eax, 1
    mov ebp, esp
    sysenter

filesize      equ     $ - $$
