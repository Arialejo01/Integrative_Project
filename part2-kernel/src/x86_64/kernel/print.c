#include "print.h"
#include <stdint.h>

#define VGA_COLS 80
#define VGA_ROWS 25

static volatile uint16_t *const VGA = (uint16_t *)0xb8000;

static int col   = 0;
static int row   = 0;
static uint8_t color = (COLOR_WHITE) | (COLOR_BLACK << 4);

void set_color(uint8_t fg, uint8_t bg)
{
    color = fg | (uint8_t)(bg << 4);
}

void clear(void)
{
    uint16_t blank = (uint16_t)((uint16_t)color << 8) | ' ';
    for (int i = 0; i < VGA_COLS * VGA_ROWS; i++)
        VGA[i] = blank;
    col = 0;
    row = 0;
}

void print_char(char c)
{
    if (c == '\n') {
        col = 0;
        row++;
    } else {
        VGA[row * VGA_COLS + col] = (uint16_t)((uint16_t)color << 8) | (uint8_t)c;
        col++;
    }

    if (col >= VGA_COLS) {
        col = 0;
        row++;
    }
    if (row >= VGA_ROWS)
        row = 0;
}

void print_str(const char *str)
{
    for (int i = 0; str[i] != '\0'; i++)
        print_char(str[i]);
}
