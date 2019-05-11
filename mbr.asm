
mov ax,cs
mov ss,ax
mov sp,0x7c00




ghalt:
		hlt
		
		gdt_size		dw 0		   ;Global description table size
		gdt_base		dd 0x00007e00  ;GDT 物理地址，是我随便定义的，只要时一块空闲的内存空间就可以

	
times 0x200-($-$$) -2 db 0
                  db 0x55,0xaa	