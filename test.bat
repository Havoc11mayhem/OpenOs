x86_64-elf-g++ -ffreestanding -m64 -c "src/kernal.cpp" -o "compiled/kernal.o"
nasm "src/kernal_entry.asm" -f elf64 -o "compiled/kernal_entry.o"
x86_64-elf-ld -o compiled/full_kernal.bin -Ttext 0x1000 compiled/kernal_entry.o compiled/kernal.o  --oformat binary
nasm "src/boot.asm" -f bin -o "compiled/boot.bin"
cat "compiled/boot.bin" "compiled/full_kernal.bin" > "compiled/openosI.bin"