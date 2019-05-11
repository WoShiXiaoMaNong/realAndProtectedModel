
		mov ax,cs
		mov ss,ax
		mov sp,0x7c00
		
		;计算GDT的逻辑地址 ： 从物理地址转换成  段地址：偏移量 的形式
		;物理地址 / 16   商 为 段地址 ，余数为偏移量
		;使用32位除法
		;ax -> 低16位   dx -> 高16位
		mov ax,[cs:gdt_base + 0x7c00]
		mov dx,[cs:gdt_base + 0x7c00 + 0x02]
		mov bx,16
		div bx
		mov ds,ax
		mov bx,dx
		
		
		;0#描述符 null描述符，处理器规范的要求
		mov dword [bx + 0x00],0x00
		mov dword [bx + 0x04],0x00
		
		;1# 保护模式下的代码段描述符，即 本代码的段描述符
		;参考描述符的格式规范
		mov dword [bx + 0x08],0x7c0001ff 
		mov dword [bx + 0x0c],0x00409800
		
		;2# 保护模式下的数据段（文本显示的显存缓冲 0xb800:0）
		mov dword [bx + 0x10],0x8000ffff
		mov dword [bx + 0x14],0x0040920b
		
		;创建#3描述符，保护模式下的堆栈段描述符
		mov dword [bx + 0x18],0x00007a00
		mov dword [bx + 0x1c],0x00409600
		
		;init gdtr
		;描述符界限，gdr_size = size - 1
		;lgdt : 注册gdt  后面接 40位的参数
		;	前16位 为gdt界限  后32位 为 gdt 基地址
		mov word [cs:gdt_size + 0x7c00], 4 * 8 - 1
		lgdt [cs:gdt_size + 0x7c00]
		
		;由于历史原因，需要手动开启A20 即第21根地址线
		;固定设置
		in al,0x92
		or al,0000_0010b
		out 0x92,al
		
		;中断还没有安装，暂时先屏蔽中断
		cli
		
		;通过设置 寄存器CR0的 PE位，开启保护模式
		mov eax,cr0
		or eax,0000_0001b
		mov cr0,eax
		
		;jmp dword 段选择子:偏移量  可以起到清理流水线，串行化处理器以及刷新CS的功能
		;高13位为描述符index，第三位为TI，TI =1 时，描述符在LDT，否则在GDT
		;低2位 为RPL，请求等级，这里设置为0x00
		;当前代码所在的段描述符以及 设置在 GDT 的1#位置
		jmp dword 0000_0000_0000_1000b:flush
		[bits 32]
flush:
		;开始屏幕打印字符
		mov ax,0000_0000_0001_0000b
		mov ds,ax
		 mov byte [0x00],'P'  
         mov byte [0x02],'r'
         mov byte [0x04],'o'
         mov byte [0x06],'t'
         mov byte [0x08],'e'
         mov byte [0x0a],'c'
         mov byte [0x0c],'t'
         mov byte [0x0e],' '
         mov byte [0x10],'m'
         mov byte [0x12],'o'
         mov byte [0x14],'d'
         mov byte [0x16],'e'
         mov byte [0x18],' '
         mov byte [0x1a],'O'
         mov byte [0x1c],'K'
		
		;初始化stack
		mov ax,0000_0000_0001_1000b
		mov ss,ax
		mov esp,0x7c00
		
		mov ebp,esp
		push byte '!'
		
		sub ebp,0x04
		cmp ebp,esp
		jnz ghalt
		;实际上，肯定会进入这里，32位模式下，push的是双字，push byte '!'的时候，会进行符号位填充
		pop eax
		mov [0x1e],al
		
ghalt:
		hlt
		
		gdt_size		dw 0		   ;Global description table size
		gdt_base		dd 0x00007e00  ;GDT 物理地址，是我随便定义的，只要时一块空闲的内存空间就可以

	
times 0x200-($-$$) -2 db 0
                  db 0x55,0xaa	