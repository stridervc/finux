GDB=gdb
LODEVICE := $(shell sudo losetup -f)

.PHONY: all

#all: floppy.bin
all: disk.img

clean:
	rm -f floppy.bin
	rm -f bootsector/*.o bootsector/*.bin
	rm -f kernel/*.o kernel/*.bin kernel/*.elf
	rm -f disk.img

#run: floppy.bin
#	qemu-system-i386 -drive format=raw,index=0,if=floppy,file=$<

run: disk.img
	qemu-system-i386 -drive format=raw,index=0,file=$<

disk.img: grubdisk.img grub.cfg finux.bin
	cp -f $< $@
	mkdir mnt
	sudo losetup $(LODEVICE) $@ -o 1048576
	sudo mount $(LODEVICE) mnt
	sudo cp grub.cfg mnt/boot/grub/
	sudo cp finux.bin mnt/boot/
	sudo umount mnt
	rmdir mnt
	sudo losetup -d $(LODEVICE)

finux.bin: kernel/kernel.elf linker.ld
	#ld -n -o $@ -T linker.ld -m elf_i386 -Ttext 0x1000 kernel/kernel.elf
	ld -n -o $@ -T linker.ld -m elf_i386 kernel/kernel.elf

kernel/kernel.elf: kernel/*.asm kernel/*/*.asm lib/*.asm
	nasm -i kernel/ -f elf -o $@ kernel/kernel.asm

# see .gdbinit for gdb settings
debug: disk.img
	qemu-system-i386 -S -s \
			-drive format=raw,index=0,file=$< &	
	$(GDB)
