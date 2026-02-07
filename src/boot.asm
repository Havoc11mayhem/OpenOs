jmp $ ;jump to start of code
times 510-($-$$) db 0 ;adds padding to make the file 512 bytes long
db 0x55, 0xaa ; tells bios this is a boot sector
