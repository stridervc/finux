Finux is my toy OS. So far it's written in only assembly, although in future some more advanced
stuff might be done in other languages like C.

At the moment it:
* Boots via GRUB and reads info passed from GRUB
* Has very basic keyboard support for some keys
* Has a basic shell that understands a few hard coded commands (hello, regs, pci)

I'm currently working on accessing the PCI IDE controller so that I can start
work on mounting a filesystem.
