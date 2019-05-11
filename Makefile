NASM	= nasm.exe -f bin
DEL		= del
MAKE	= make

default:
	$(MAKE) mbr.bin
	$(MAKE) user.bin
	
mbr.bin: mbr.asm Makefile
	$(NASM) mbr.asm -o mbr.bin
	
user.bin: User.asm Makefile
	$(NASM) User.asm -o user.bin

clean:
	-$(DEL) *.bin
	-$(DEL) *.lock