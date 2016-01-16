#!/bin/bash
nasm -f elf echo.asm
ld -o echo echo.o -melf_i386
rm echo.o
echo "Done building, the file 'echo' is your executable"
