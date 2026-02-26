; kernel_entry.asm
; 32-bit entry point at 0x00100000

BITS 32
GLOBAL kernel_entry
EXTERN kernel_main

SECTION .text

kernel_entry:
    ; set up a simple stack
    mov esp, 0x9FC00

    ; call C++ kernel
    call kernel_main

.hang:
    hlt
    jmp .hang