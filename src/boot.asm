[bits 16]
[org 0x7C00]

LOADER_SEGMENT equ 0x0000
LOADER_OFFSET  equ 0x7E00

mov [BOOT_DISK], dl      ; BIOS drive number

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov bp, 0x8000
mov sp, bp

; Load loader.bin: assume it starts at LBA 1 (CHS: C0/H0/S2), size = 2 sectors
mov bx, LOADER_OFFSET    ; ES:BX = load address (ES=0)
mov ah, 0x02             ; INT 13h - read sectors
mov al, 2                ; number of sectors
mov ch, 0x00             ; cylinder 0
mov dh, 0x00             ; head 0
mov cl, 0x02             ; sector 2 (LBA 1)
mov dl, [BOOT_DISK]      ; drive
int 0x13                 ; no error checking for now

; Optional: set text mode
mov ah, 0x00
mov al, 0x03
int 0x10

; Jump to loader at 0x0000:0x7E00
jmp LOADER_SEGMENT:LOADER_OFFSET

BOOT_DISK: db 0

times 510-($-$$) db 0
dw 0xAA55