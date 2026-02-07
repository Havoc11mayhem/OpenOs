cd C:\Users\Computer\AppData\Local\bin\NASM
nasm c:/openos/src/boot.asm -f bin -o c:/openos/boot.bin
qemu-system-x86_64 -drive file=c:/openos/boot.bin,format=raw