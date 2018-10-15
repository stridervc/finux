GDB=gdb

.PHONY: all

all: floppy.bin

clean:
	rm -f floppy.bin
	rm -f bootsector/*.o bootsector/*.bin
	rm -f kernel/*.o kernel/*.bin

run: floppy.bin
	qemu-system-i386 -drive format=raw,index=0,if=floppy,file=$<

# see .gdbinit for gdb settings
debug: floppy.bin
	qemu-system-i386 -S -s \
			-drive format=raw,index=0,if=floppy,file=$< &	
	$(GDB)

floppy.bin: bootsector/bootsector.bin kernel/kernel.bin
	cat $^ > $@

bootsector/bootsector.bin: bootsector/*.asm
	nasm -i bootsector/ -f bin -o $@ bootsector/bootsector.asm

kernel/kernel.bin: kernel/*.asm
	nasm -i kernel/ -f bin -o $@ kernel/kernel.asm
