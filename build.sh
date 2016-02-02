#!/bin/bash
nasm -f elf echo.asm
ld -o echo echo.o -melf_i386
rm echo.o
strip echo
echo "Done building, the file 'echo' is your executable"
