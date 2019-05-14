		mov ax,cs
		mov ss,ax
		mov sp,0x7c00
		
		;重新计算GDT 地址
		;计算后 DS:BX指向 GDT的开始地址。
		mov ax, [cs:pgdt + 0x7c00 + 2]
		mov dx, [cs:pgdt + 0x7c00 + 4]
		mov bx, 16
		div bx
		mov ds,ax
		mov bx,dx
		
		;0# 描述符，cpu规范规定，定义一个null描述符
		mov dword [bx],0x00
		mov dword [bx + 4],0x00
		
		;创建1#描述符，这是一个数据段，对应0~4GB的线性地址空间
         mov dword [bx+0x08],0x0000ffff    ;基地址为0，段界限为0xfffff
         mov dword [bx+0x0c],0x00cf9200    ;粒度为4KB，存储器段描述符 
		 
		;2# 描述符，本代码段在进入protected模式后的内存地址描述符
		;段基地址 0x7c00，段界限为512字节 
		mov dword [bx + 0x10],0x7c0001ff
		mov dword [bx + 0x14],0x00409800

		;3# 描述符，本代码段在进入protected模式后的内存地址描述符
		;段基地址 0x7c00，段界限为512字节 
		;可写权限，用户字符串排序时的写回操作
		mov dword [bx + 0x18],0x7c0001ff
		mov dword [bx + 0x1c],0x00409200
		
		;4#, stack
		mov dword [bx + 0x20],0x7c00fffe
		mov dword [bx + 0x24],0x00cf9600
		
		mov word [cs:pgdt + 0x7c00], 5 * 8 - 1
		lgdt [cs: pgdt+0x7c00]
           
		   
		in al,0x92                         ;南桥芯片内的端口 
        or al,0000_0010B
        out 0x92,al                        ;打开A20
		cli                                ;中断机制尚未工作

        mov eax,cr0
        or eax,1
        mov cr0,eax                        ;设置PE位
		;从此，以及开启protected模式
		
		jmp dword 0x0010:flush
		[bits 32]
	flush:
		mov eax,0x0018                      
         mov ds,eax
      
         mov eax,0x0008                     ;加载数据段(0..4GB)选择子
         mov es,eax
         mov fs,eax
         mov gs,eax
      
         mov eax,0x0020                     ;0000 0000 0010 0000
         mov ss,eax
         xor esp,esp                        ;ESP <- 0
		
		mov dword [es:0x0b8000],0x072e0750 ;字符'P'、'.'及其显示属性
		mov dword [es:0x0b8004],0x072e074d ;字符'M'、'.'及其显示属性
	
	;冒泡排序
	@1:
		mov ecx,pgdt - string - 1   ;String.size()
		xor bx,bx  ;index
		xor dx,dx  ;flag
	@2:
		mov ax,[string + bx]
		cmp ah,al
		JGE @3
		xchg ah,al
		mov dx,1
  		mov [string + bx],ax
	@3:
		inc bx
		loop @2
		
		cmp dx,1
		je @1
		
		
		mov ecx,pgdt-string
        xor ebx,ebx                        ;偏移地址是32位的情况 
  @@4:                                      ;32位的偏移具有更大的灵活性
        mov ah,0x07
        mov al,[string+ebx]
        mov [es:0xb80a0+ebx*2],ax          ;演示0~4GB寻址。
        inc ebx
        loop @@4
	ghlt:
		hlt
	string:
		db 		'qwertyuioplkjhgfdsazxcvbnmMNBVCXZASDFGHJKLPOIUYTREWQ546213978'
	pgdt:
		dw		0				;GDT size - 1
		dd 		0x00007e00      ;GDT的物理地址
		
	 times 510-($-$$) db 0
                      db 0x55,0xaa	