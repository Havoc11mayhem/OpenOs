// kernel.cpp
// Very simple "kernel" that writes text to VGA text mode

#include <stdint.h>

extern "C" void kernel_main() {
    volatile uint16_t* vga = (uint16_t*)0xB8000;
    const char* msg = "OpenOS kernel";
    uint8_t color = 0x0F; // white on black

    for (int i = 0; msg[i] != '\0'; i++) {
        vga[i] = (uint16_t)msg[i] | ((uint16_t)color << 8);
    }

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
