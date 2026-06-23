; Multiboot2 header — must appear within the first 32 KB of the kernel image.
; GRUB reads this to identify and load the kernel.

section .multiboot_header
header_start:
    dd 0xe85250d6                               ; Multiboot2 magic number
    dd 0                                         ; Architecture: i386 protected mode
    dd header_end - header_start                ; Header length in bytes
    ; Checksum: magic + arch + length + checksum must equal 0 mod 2^32
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; Required end tag (type=0, flags=0, size=8)
    dw 0
    dw 0
    dd 8
header_end:
