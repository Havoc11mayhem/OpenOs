jmp $ 
times 510-($-$$) db 0 ;adds padding to make the file 512 bytes long
db 0x55, 0xaa
