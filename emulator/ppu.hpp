#pragma once
#include "utils.hpp"
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include "cpu.hpp"
#include "colors.hpp"

union ctrl
{
    // $2000
    struct ctrl_f 
    {
        uint8_t nametable_lo_addr  : 1;
        uint8_t nametable_hi_addr  : 1;
        uint8_t increment_mode     : 1;
        uint8_t fg_patt_table_addr : 1;
        uint8_t bg_patt_table_addr : 1;
        uint8_t sprite_size        : 1;
        uint8_t master_slave       : 1;
        uint8_t enable_nmi         : 1;
    } flags;
    uint8_t byte;
};

union mask
{
    // $2001
    struct mask_f 
    {
        uint8_t greyscale       : 1;
        uint8_t show_8_left_bg  : 1;
        uint8_t show_8_left_fg  : 1;
        uint8_t show_bg         : 1;
        uint8_t show_fg         : 1;
        uint8_t emphasize_red   : 1;
        uint8_t emphasize_green : 1;
        uint8_t enable_blue     : 1;
    } flags;
    uint8_t byte;
};

union status
{
    // $2002
    struct status_f 
    {
        uint8_t TODO       : 7; //TODO
	    uint8_t vblank     : 1;
    } flags;
	uint8_t byte;
};


struct sprite_info
{
    uint8_t y, tile_index, attributes, x;
};

// Initialize ppu power up state
void ppu_init();

// Execute whatever the ppu should do within one clock cycle
void ppu_clock();

uint8_t read_register(uint16_t address);

void write_register(uint16_t address, uint8_t data);
