; loader.asm - second stage loader
; nasm loader.asm -f bin -o loader.bin
; Assumptions:
;  - Loaded by boot sector at 0x7E00
;  - DL still contains BIOS boot drive
;  - kernel.bin is at LBA 20, size = KERNEL_SECTORS

BITS 16
ORG 0x7E00

KERNEL_LOAD_SEGMENT equ 0x1000          ; 0x1000:0x0000 = 0x00100000
KERNEL_LOAD_OFFSET  equ 0x0000
KERNEL_SECTORS      equ 32              ; adjust to actual kernel size in sectors
KERNEL_LBA          equ 20              ; where build.bat writes kernel

start_loader:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00                      ; simple stack

; --- enable A20 (naive, works in emulators) ---
enable_a20:
    in   al, 0x92
    or   al, 00000010b
    out  0x92, al

; --- load kernel from disk into 0x00100000 ---
    mov ax, KERNEL_LOAD_SEGMENT
    mov es, ax
    mov bx, KERNEL_LOAD_OFFSET          ; ES:BX = 0x00100000

    mov si, KERNEL_LBA                  ; current LBA
    mov di, KERNEL_SECTORS              ; sectors left to read

load_kernel_loop:
    cmp di, 0
    je kernel_loaded

    ; convert LBA in SI to CHS for int 13h (very naive, assumes 1 head, 63 sectors/track)
    ; C = LBA / 63, S = (LBA % 63) + 1, H = 0
    mov ax, si
    xor dx, dx
    mov cx, 63
    div cx                              ; AX / 63 -> AX=quotient (C), DX=remainder

    mov ch, al                          ; cylinder
    mov cl, dl                          ; sector index
    inc cl                              ; sector = remainder + 1
    mov dh, 0                           ; head = 0

    mov ah, 0x02                        ; int 13h - read sectors
    mov al, 1                           ; read 1 sector at a time
    mov dl, [BOOT_DRIVE]                ; BIOS drive (saved by boot sector or set here)
    int 0x13

    jc disk_error                       ; if carry set, error

    add bx, 512                         ; advance buffer by 1 sector
    inc si                              ; next LBA
    dec di                              ; one less sector to read
    jmp load_kernel_loop

kernel_loaded:

; --- set up GDT and enter protected mode ---
    cli

    lgdt [gdt_descriptor]

    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    jmp CODE_SEL:protected_mode_entry   ; far jump to flush prefetch

disk_error:
    ; simple hang on disk error
    cli
.hang:
    hlt
    jmp .hang

BOOT_DRIVE: db 0    ; optional: you can have boot.asm store DL here before jumping

; ---------------- GDT ----------------
ALIGN 8
gdt_start:
gdt_null:           dq 0

gdt_code:           ; code segment
    dw 0xFFFF       ; limit
    dw 0x0000       ; base low
    db 0x00         ; base mid
    db 10011010b    ; code, present
    db 11001111b    ; granularity, 4K, 32-bit
    db 0x00         ; base high

gdt_data:           ; data segment
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEL equ gdt_code - gdt_start
DATA_SEL equ gdt_data - gdt_start

; ------------- 32-bit code -------------
BITS 32

protected_mode_entry:
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x9FC00                     ; simple stack

    ; jump to kernel entry at 0x00100000
    jmp 0x00100000

.hang32:
    hlt
    jmp .hang32