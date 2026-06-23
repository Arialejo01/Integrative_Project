#include "print.h"

void kernel_main(void)
{
    clear();

    set_color(COLOR_LIGHT_GREEN, COLOR_BLACK);
    print_str("  *** UIDE - Integrative Project 2026 ***\n");

    set_color(COLOR_WHITE, COLOR_BLACK);
    print_str("\n");
    print_str("  64-bit kernel running in long mode\n");
    print_str("  Build, Boot and Attack\n");
    print_str("\n");

    set_color(COLOR_CYAN, COLOR_BLACK);
    print_str("  [OK] Multiboot2 verified\n");
    print_str("  [OK] CPUID supported\n");
    print_str("  [OK] Long mode enabled\n");
    print_str("  [OK] Paging active (1 GB identity-mapped)\n");
    print_str("  [OK] 64-bit GDT loaded\n");
    print_str("  [OK] C kernel running in long mode\n");

    set_color(COLOR_YELLOW, COLOR_BLACK);
    print_str("\n  Gorila Tremendo Yo Soy, Bienvenido a GorillaOS\n");
}
