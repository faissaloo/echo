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
    push `\n`     ;The newline character
    pop eax
    pop	ebx	        ; Get the number of arguments

    dec ebx      ; If there are no arguments just exit instantly
    jz _noArgsExit

    pop	ecx	        ; Pop the program name, we don't need this so we'll just overwrite it

    pop	edi		; Get first argument
    ;compare edx with '-n' to see if they're the same
    mov edx, [edi]
    bswap edx
    xor dl, dl          ; Mask the bits we don't need
    sub edx,`\0\0n-`;Check for '-n'
    jne _main
_removenl:
    xchg edx, eax       ; Removes the newline character from memory
    push edi
    dec ebx
    jz _exit
    pop edi
    pop edi
_main:
    ;strlen(edi)
    push edi
    ;Get the string length for string edi and put it in edi
    db 0x3c             ;Mask scasd on first pass
_s:
    scasd               ;Move to the next 'double word'
_sit:
    mov edx,[edi]
    ; Wooo magical numbers!
    and edx, 0x7F7F7F7F
    sub edx, 0x01010101
    and edx, 0x80808080
    jz _s ;If none of them were zeros loops back to s

    mov edx,[edi] ;restore edx so we can check if it was actually 0 or if we've
                  ;misfired (which happens only with character 128)
    test dl, dl
    jz _cont

    test dh, dh
    jz _cont1

    bswap edx ;swap the bytes around so we can use segment registers to check
              ;the value
    test dh, dh
    jz _cont2

    test dl, dl
    jnz _sit

_cont3:
    inc edi

_cont2:
    inc edi

_cont1:
    inc edi

_cont:
    mov byte [edi], 32 ; Put a space in between each argument to replace the string terminator
    dec ebx          ; Decrease arg count
    jnz _sit         ; If this is the last argument exit


_exit:
    ;Append a newline to the end if we have a newline
    stosb   ;and increase the length by one
    ; Print the string
    pop ecx          ; String
    mov edx, edi
    sub edx, ecx     ; String length
    inc ebx          ; stdout
    mov al,4         ; sys_write
    push _sysentercont
    push ecx
    push edx
    push ebp
    mov ebp, esp
    sysenter        ; Kernel interrupt
_sysentercont:
    ;Exit with code 0
    dec ebx
_noArgsExit:
    mov al, 1
    mov ebp, esp
    sysenter

filesize      equ     $ - $$
