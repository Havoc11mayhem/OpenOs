bits 16                 ; Tell NASM to generate 16-bit code
org 0x7c00              ; Tell NASM the code will be loaded at address 0x7c00 by the BIOS

boot:
    mov si, hello       ; Point the SI register to the "hello" message
    mov ah, 0x0e        ; 0x0e means 'Write Character in TTY mode' for INT 0x10

.loop:
    lodsb               ; Load byte at address DS:SI into AL and increment SI
    or al, al           ; Check if AL is zero (end of string)
    jz halt             ; If AL is zero, jump to the 'halt' label
    int 0x10            ; Call the BIOS video services interrupt
    jmp .loop           ; Jump back to the start of the loop

halt:
    cli                 ; Clear interrupts flag
    hlt                 ; Halt the CPU execution (infinite loop)

hello:
    db "Hello user, OpenOS is starting...", 0 ; The string to print, terminated by a null byte (0)

; Fill the rest of the 512 bytes with zeros and add the boot signature
times 510 - ($-$$) db 0
dw 0xaa55               ; The boot sector magic number (0x55AA in memory due to little-endian)