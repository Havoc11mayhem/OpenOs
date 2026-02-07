cd c:\msys64\mingw64\bin\
i386-elf-gcc -ffreestanding -c -m32 -g -c c:\openos\bootloader\src\kernal.cpp -o c:\openos\compiled\kernal.o
nasm kernal_entry.asm -f elf32 -o c:\openos\compiled\kernal_entry.o
ld -o kernal.bin -Ttext 0x10000 kernal_entry.o kernal.o --oformat binary
nasm boot.asm -f bin -o c:\openos\compiled\boot.bin
cat c:\openos\compiled\boot.bin c:\openos\compiled\kernal.bin > c:\openos\compiled\fullos.bin