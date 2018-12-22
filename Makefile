GDB=gdb
GRUBTMP=/tmp/grubdisk
DISKTMP=$(GRUBTMP)/disk.img
DOCKER=docker
DOCKERARGS=-v $(GRUBTMP):$(GRUBTMP):rw --device=$(LODEVICE1):$(LODEVICE1) --device=$(LODEVICE2):$(LODEVICE2)
DOCKERCONTAINER=redshift/grub-pc
DOCKERRUN=$(DOCKER) run $(DOCKERARGS) $(DOCKERCONTAINER)
LODEVICE1=/dev/loop0
LODEVICE2=/dev/loop1

.PHONY: all

all: disk.img

clean:
	rm -f floppy.bin
	rm -f bootsector/*.o bootsector/*.bin
	rm -f kernel/*.o kernel/*.bin kernel/*.elf
	rm -f disk.img grubdisk.img
	rm -rf finux.initrd

run: disk.img
	qemu-system-i386 -drive format=raw,index=0,file=$<

grubdisk.img:
	mkdir -p $(GRUBTMP)
	dd if=/dev/zero of=$(DISKTMP) bs=1M count=32
	echo "- - L *" | sudo sfdisk $(DISKTMP)
	sudo losetup $(LODEVICE1) $(DISKTMP)
	sudo losetup $(LODEVICE2) $(DISKTMP) -o 1048576
	sudo mke2fs $(LODEVICE2)
	mkdir $(GRUBTMP)/finux
	sudo mount $(LODEVICE2) $(GRUBTMP)/finux
	$(DOCKERRUN) grub-install --root-directory=$(GRUBTMP)/finux --no-floppy --modules="normal part_msdos ext2 multiboot" $(LODEVICE1)
	sudo umount $(LODEVICE2)
	sudo losetup -d $(LODEVICE2)
	sudo losetup -d $(LODEVICE1)
	cp $(DISKTMP) $@
	rm -rf $(GRUBTMP)

disk.img: grubdisk.img grub.cfg finux.bin finux.initrd
	$(eval LODEVICE := $(shell sudo losetup -f))
	cp -f $< $@
	mkdir mnt
	sudo losetup $(LODEVICE) $@ -o 1048576
	sudo mount $(LODEVICE) mnt
	sudo cp grub.cfg mnt/boot/grub/
	sudo cp finux.bin mnt/boot/
	sudo cp finux.initrd mnt/boot/
	sudo umount mnt
	rmdir mnt
	sudo losetup -d $(LODEVICE)

finux.bin: kernel/kernel.elf linker.ld
	ld -n -o $@ -T linker.ld -m elf_i386 kernel/kernel.elf

kernel/kernel.elf: kernel/*.asm kernel/*/*.asm lib/*.asm
	nasm -i kernel/ -f elf -o $@ kernel/kernel.asm

# see .gdbinit for gdb settings
debug: disk.img
	qemu-system-i386 -S -s \
			-drive format=raw,index=0,file=$< &	
	$(GDB)

finux.initrd: initrd/*
	tar cf $@ $<

