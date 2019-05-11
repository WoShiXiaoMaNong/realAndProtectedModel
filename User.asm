section header vstart=0
	program_length	dd program_end
	code_entry		dw start
					dd section.code_1.start
    realloc_tbl_len dw (header_end-code_1_segment)/4							
	code_1_segment	dd section.code_1.start
	timmer_segment	dd section.timmer.start
	msg_segment		dd section.msg.start
	stack_segment	dd section.stack.start
	header_end:
	
section code_1 align=16 vstart=0
start:
	mov ax,ds
	mov es,ax
	
	mov ax,[msg_segment]
	mov ds,ax
	mov ax,[es:stack_segment]
	mov ss,ax
	mov sp,stack_point

	mov bx,msg_start
	mov si,10
	mov di,2
	call put_str
	mov bx,msg_isntall
	mov si,10
	mov di,3
	call put_str
	mov bx,msg_install_end
	mov si,10
	mov di,4
	call put_str
	mov bx,msg_welcome
	mov si,10
	mov di,5
	call put_str
s:
	hlt
	jmp s

;input string addr  ds:bx
;input di row number
;input si column number	 
;The string must end with 0x00

put_str:
	push ax
	push bx
	push si
do_put:	
	mov al,[bx]
	cmp al,0x00
	jz put_str_ret
	call put_char
	add bx,1
	add si,2
	jmp do_put
put_str_ret	:
	pop si
	pop bx
	pop ax
	ret
	

;input di row number
;input si column number	
;input al target char
put_char:	
	push es
	push ax
	push dx
	push bx
	
	mov dl,al
	mov ax,0xb800
	mov es,ax
	mov ax,di
	mov bl,80 * 2
	mul bl
	add ax,si
	mov bx,ax
	mov [es:bx],dl
	
	pop bx
	pop dx
	pop ax
	pop es
	ret

	
section timmer align=16 vstart=0



section msg align=16 vstart=0
	msg_start 			db 'Init timer'
						db  0x00
	msg_isntall 		db 'Install interrupt...'
						db  0x00
	msg_install_end		db 'Install finished..'
						db  0x00
	msg_welcome			db 'Welcome to ZM OS!!!'
						db  0x00
	
	
section stack align=16 vstart=0
	resb 256
	stack_point:	
;===============================================================================
SECTION trail align=16	
times 0x200-($-$$) db 0
                  db 0x55,0xaa	
program_end	: