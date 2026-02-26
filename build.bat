@echo off
echo ============================================
echo        OpenOS Build Script (Windows)
echo ============================================

REM --- Create output folder ---
if not exist compiled mkdir compiled

echo.
echo [1] Assembling boot.asm (boot sector)...
nasm src\boot.asm -f bin -o compiled\boot.bin
if errorlevel 1 goto :error

echo [2] Assembling loader.asm (stage 2)...
nasm src\loader.asm -f bin -o compiled\loader.bin
if errorlevel 1 goto :error

echo [3] Assembling kernel_entry.asm (ELF64)...
nasm src\kernel_entry.asm -f elf64 -o compiled\kernel_entry.o
if errorlevel 1 goto :error

echo [4] Compiling kernel.cpp (ELF64)...
x86_64-elf-gcc -ffreestanding -m64 -c src\kernel.cpp -o compiled\kernel.o
if errorlevel 1 goto :error

echo [5] Linking kernel.bin...
x86_64-elf-ld -o compiled\kernel.bin -Ttext 0x100000 ^
    compiled\kernel_entry.o compiled\kernel.o ^
    --oformat binary
if errorlevel 1 goto :error

echo.
echo [6] Creating 2MB disk image...
powershell -command ^
  "$size = 2MB; $fs = [System.IO.File]::Create('compiled/disk.img');" ^
  "$fs.SetLength($size);" ^
  "$fs.Close()"

echo [7] Writing boot sector to disk (LBA 0)...
powershell -command ^
  "$boot = [System.IO.File]::ReadAllBytes('compiled/boot.bin');" ^
  "$fs = [System.IO.File]::OpenWrite('compiled/disk.img');" ^
  "$fs.Write($boot, 0, $boot.Length);" ^
  "$fs.Close()"

echo [8] Writing loader to disk (LBA 1)...
powershell -command ^
  "$bin = [System.IO.File]::ReadAllBytes('compiled/loader.bin');" ^
  "$fs = [System.IO.File]::OpenWrite('compiled/disk.img');" ^
  "$fs.Seek(512, 'Begin');" ^
  "$fs.Write($bin, 0, $bin.Length);" ^
  "$fs.Close()"

echo [9] Writing kernel to disk (LBA 20)...
powershell -command ^
  "$bin = [System.IO.File]::ReadAllBytes('compiled/kernel.bin');" ^
  "$fs = [System.IO.File]::OpenWrite('compiled/disk.img');" ^
  "$fs.Seek(512*20, 'Begin');" ^
  "$fs.Write($bin, 0, $bin.Length);" ^
  "$fs.Close()"

echo.
echo ============================================
echo Build complete.
echo Run with:
echo qemu-system-x86_64 -drive format=raw,file=compiled\disk.img
echo ============================================
goto :eof

:error
echo.
echo BUILD FAILED.
pause