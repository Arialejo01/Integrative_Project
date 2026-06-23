; =============================================================================
; main.asm — Boot entry point
;
; Episode 1: Multiboot2 entry → print "OK" to VGA (0xb8000) in 32-bit mode.
; Episode 2: Verify Multiboot magic, CPUID, long-mode support → set up page
;            tables (identity-map first GB with 2 MB huge pages) → build 64-bit
;            GDT → far-jump into long_mode_start → call C kernel.
; =============================================================================

global start
extern kernel_main          ; defined in kernel.c

; ─────────────────────────────────────────────────────────────────────────────
; 32-BIT PROTECTED MODE ENTRY (GRUB hands control here)
; ─────────────────────────────────────────────────────────────────────────────
section .text
bits 32
start:
    mov esp, stack_top      ; set up the stack

    ; Episode 1: write "OK" (green on black) to top-left of VGA buffer
    ; 0x2f = attribute byte: white text on green bg; 'O'=0x4f 'K'=0x4b
    mov dword [0xb8000], 0x2f4b2f4f

    ; Episode 2: run safety checks before entering long mode
    call check_multiboot
    call check_cpuid
    call check_long_mode

    call setup_page_tables
    call enable_paging

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start   ; far jump → 64-bit segment

    hlt                     ; unreachable

; ─────────────────────────────────────────────────────────────────────────────
; VERIFICATION ROUTINES (32-bit)
; ─────────────────────────────────────────────────────────────────────────────

; Verify GRUB placed the Multiboot2 magic value in EAX.
check_multiboot:
    cmp eax, 0x36d76289
    jne .fail
    ret
.fail:
    mov al, 'M'
    jmp error

; Verify the CPU supports the CPUID instruction by trying to flip bit 21
; of EFLAGS.  If the bit can be changed, CPUID is available.
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .fail
    ret
.fail:
    mov al, 'C'
    jmp error

; Verify that the CPU supports 64-bit long mode via CPUID leaf 0x80000001.
check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .fail

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29       ; Long Mode bit
    jz .fail
    ret
.fail:
    mov al, 'L'
    jmp error

; ─────────────────────────────────────────────────────────────────────────────
; PAGE TABLE SETUP — identity-map first 1 GB using 2 MB huge pages
; ─────────────────────────────────────────────────────────────────────────────
setup_page_tables:
    ; P4[0] → P3
    mov eax, p3_table
    or  eax, 0b11           ; present + writable
    mov [p4_table], eax

    ; P3[0] → P2
    mov eax, p2_table
    or  eax, 0b11
    mov [p3_table], eax

    ; P2[0..511] → 512 × 2 MB huge pages (covers the first 1 GB)
    mov ecx, 0
.map_p2:
    mov eax, 0x200000       ; 2 MB
    mul ecx
    or  eax, 0b10000011     ; present + writable + huge page
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2

    ret

; ─────────────────────────────────────────────────────────────────────────────
; ENABLE PAGING + LONG MODE
; ─────────────────────────────────────────────────────────────────────────────
enable_paging:
    ; Load PML4 (P4) into CR3
    mov eax, p4_table
    mov cr3, eax

    ; Enable PAE (Physical Address Extension) in CR4.bit5
    mov eax, cr4
    or  eax, 1 << 5
    mov cr4, eax

    ; Set Long Mode Enable (LME) bit in EFER MSR (0xC0000080)
    mov ecx, 0xC0000080
    rdmsr
    or  eax, 1 << 8
    wrmsr

    ; Enable paging in CR0.bit31 (also activates long mode)
    mov eax, cr0
    or  eax, 1 << 31
    mov cr0, eax

    ret

; ─────────────────────────────────────────────────────────────────────────────
; ERROR HANDLER — prints "ERR: X" in red and halts
; al = ASCII error code character
; ─────────────────────────────────────────────────────────────────────────────
error:
    mov dword [0xb8000], 0x4f524f45   ; "ER"
    mov dword [0xb8004], 0x4f3a4f52   ; "R:"
    mov dword [0xb8008], 0x4f204f20   ; "  "
    mov byte  [0xb800a], al
    hlt

; ─────────────────────────────────────────────────────────────────────────────
; 64-BIT GDT
; ─────────────────────────────────────────────────────────────────────────────
section .rodata
gdt64:
    dq 0                                        ; null descriptor
.code_segment: equ $ - gdt64
    ; 64-bit code segment: execute/read, present, 64-bit (L bit)
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
.pointer:
    dw $ - gdt64 - 1        ; limit (size - 1)
    dq gdt64                ; base address

; ─────────────────────────────────────────────────────────────────────────────
; BSS — page tables and stack (must be 4 KB aligned)
; ─────────────────────────────────────────────────────────────────────────────
section .bss
align 4096
p4_table:   resb 4096
p3_table:   resb 4096
p2_table:   resb 4096
stack_bottom:
    resb 4096 * 4           ; 16 KB stack
stack_top:

; ─────────────────────────────────────────────────────────────────────────────
; 64-BIT LONG MODE ENTRY
; ─────────────────────────────────────────────────────────────────────────────
section .text
bits 64
long_mode_start:
    ; Null-out data segment registers (not used in 64-bit flat model)
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call kernel_main        ; hand off to C

    hlt
