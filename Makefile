GDB=gdb

.PHONY: all

all: floppy.bin

clean:
	rm -f floppy.bin
	rm -f bootsector/*.o bootsector/*.bin

run: floppy.bin
	qemu-system-i386 -drive format=raw,index=0,if=floppy,file=$<

debug: floppy.bin
	qemu-system-i386 -S -s \
			-drive format=raw,index=0,if=floppy,file=$< &	
	$(GDB) -ex "target remote localhost:1234" \
			-ex "set disassembly-flavor intel"

floppy.bin: bootsector/bootsector.bin
	cat $^ > $@

bootsector/bootsector.bin: bootsector/*.asm
	nasm -i bootsector/ -f bin -o $@ bootsector/bootsector.asm
