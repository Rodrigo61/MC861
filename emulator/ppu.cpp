#include "ppu.hpp"

#define SCREEN_PIXEL_HEIGHT 240
#define SCREEN_PIXEL_WIDTH 256

bool updated_frame;

// 2 tables of 16x16 tiles, each one using 2 planes of 8 bytes
uint8_t pattern_table[2][16][16][2][8];

// 4 BG palettes, 4 FG palettes. palettes[0] is backdrop
uint8_t palettes[32];

// 2 nametables of 30x32 tiles for background
uint8_t nametable[2][30][32];

// 2 of 8x8 attribute table, each byte controls the palette 4×4 tile part of the nametable
// and is divided into four 2-bit areas. Each area covers 2×2 tiles
uint8_t attribute_table[2][8][8];

// Object Attribute Memory, sprite information.
sprite_info oam[64];

// Address used by CPU to write to OAM.
uint8_t oam_address;

// CPU's shared registers
ctrl PPUCTRL;
status PPUSTATUS;
mask PPUMASK;

// OpenCV's stuff to show the game's screen
cv::Mat screen = cv::Mat::zeros(SCREEN_PIXEL_HEIGHT, SCREEN_PIXEL_WIDTH, CV_8UC3);
string windows_title = "ONESSENO - OneNESSystemNotOfficial";

// Below are two variables that use the same nomenclature of original NES systems
// cycle = current column; scanline = current row of the screen
// These variables are not exactly 1 to 1 with row/line, because their range are
// actually bigger than the screen's range
uint16_t cycle, scanline;

// Address used by CPU to write/read using registers $2006/$2007
uint16_t vram_addr;
bool address_latch; // used to switch between low and high address

// Buffer used to transfer data using register 2007
uint8_t data_buffer;

// Variables used at
uint8_t fine_x = 0, fine_y = 0;
uint8_t coarse_x = 0, coarse_y = 0;

// Functions that return the x/y position of the nametable's tile which
// the current scanline/cycle are within
uint8_t tile_y() 
{ 
    return ((scanline + fine_y) / 8 + coarse_y) % 30; 
}
uint8_t tile_x() { return cycle / 8; }

uint8_t current_nametable()
{
    int tile = (scanline + fine_y) / 8 + coarse_y;
    uint8_t base = (PPUCTRL.flags.nametable_hi_addr << 1) | PPUCTRL.flags.nametable_lo_addr;
    if (tile >= 30 && tile < 60)
    {
        // within the second nametable
        return !bool(base);
    }
        
    // // within the base nametable, maybe wrapped up
    return bool(base);
}

// Functions that return the pixel's x/y position relative to the
// current tile which the current scanline/cycle are within
uint8_t pixel_y() { return (scanline + fine_y) % 8; }
uint8_t pixel_x() { return cycle % 8; }

// Get color from palette considering the mirrors
color get_color(uint8_t palette_color_id)
{
    if (palette_color_id % 4 == 0)
        return colors[palettes[0]];
    return colors[palettes[palette_color_id]];
}

uint8_t get_bit_range(uint8_t source, uint8_t lsb, uint8_t msb)
{
    source >>= lsb;
    source &= (1 << (msb - lsb + 1)) - 1;
    return source;
}

int get_palette_idx_from_attr_tbl()
{
    // Retrieves the indices of the attribute that represents the 4x4 tiles area
    // which the current scanline/cycle are within
    uint8_t group_4x4_y = tile_y() / 4;
    uint8_t group_4x4_x = tile_x() / 4;
    uint8_t attribute = attribute_table[current_nametable()][group_4x4_y][group_4x4_x];

    // Retrieves which one of the 4 2x2 subgroups of the previous 4x4 the
    // current scanline/cycle are within
    uint8_t group_2x2_y = (tile_y() / 2) % 2;
    uint8_t group_2x2_x = (tile_x() / 2) % 2;

    // Selecting the 2 bits related to the current 2x2 subgroup.
    // attribute = (bottomright << 6) | (bottomleft << 4) | (topright << 2) | (topleft << 0)
    if (group_2x2_x == 0 && group_2x2_y == 0)
        return get_bit_range(attribute, 0, 1);
    if (group_2x2_x == 1 && group_2x2_y == 0)
        return get_bit_range(attribute, 2, 3);
    if (group_2x2_x == 0 && group_2x2_y == 1)
        return get_bit_range(attribute, 4, 5);
    if (group_2x2_x == 1 && group_2x2_y == 1)
        return get_bit_range(attribute, 6, 7);

    assert(false);
}

pair<color, uint8_t> get_pixel_color_from_patt_tbl(uint8_t pattern_tbl_idx,
                                    uint8_t patt_tbl_tile_y, uint8_t patt_tbl_tile_x,
                                    uint8_t patt_tbl_pixel_y, uint8_t patt_tbl_pixel_x)
{
    int palette_idx = get_palette_idx_from_attr_tbl();

    uint8_t patt_bit_0 = pattern_table[pattern_tbl_idx]
                                      [patt_tbl_tile_y]
                                      [patt_tbl_tile_x]
                                      [0]
                                      [patt_tbl_pixel_y];

    // MSB corresponds to the most left pixel
    patt_bit_0 = get_bit_range(patt_bit_0, 7 - patt_tbl_pixel_x, 7 - patt_tbl_pixel_x);

    uint8_t patt_bit_1 = pattern_table[pattern_tbl_idx]
                                      [patt_tbl_tile_y]
                                      [patt_tbl_tile_x]
                                      [1]
                                      [patt_tbl_pixel_y];

    // MSB corresponds to the most left pixel
    patt_bit_1 = get_bit_range(patt_bit_1, 7 - patt_tbl_pixel_x, 7 - patt_tbl_pixel_x);

    // Building the two bits color_idx
    uint8_t color_idx = (patt_bit_1 << 1) | patt_bit_0;

    return {get_color(4 * palette_idx + color_idx), color_idx};
}

pair<color, uint8_t> get_pixel_color_from_nametable(uint8_t nametable_idx, uint8_t patt_tbl_idx)
{
    assert(nametable_idx == current_nametable());
    
    // Using division to get indices of the pattern table because it's 16x16 tiles
    uint8_t patt_tbl_tile_x = nametable[nametable_idx][tile_y()][tile_x()] % 16;
    uint8_t patt_tbl_tile_y = nametable[nametable_idx][tile_y()][tile_x()] / 16;

    return get_pixel_color_from_patt_tbl(patt_tbl_idx, patt_tbl_tile_y, patt_tbl_tile_x, pixel_y(), pixel_x());
}

void print_pixel(uint8_t nametable_idx, uint8_t patt_tbl_idx)
{
    assert(nametable_idx == current_nametable());
    color pixel_color = get_pixel_color_from_nametable(nametable_idx, patt_tbl_idx).first;

    screen.at<cv::Vec3b>(scanline, cycle) = cv::Vec3b(pixel_color.B,
                                                      pixel_color.G,
                                                      pixel_color.R);
}

pair<bool, color> get_sprite_pixel_color_from_patt_tbl(uint8_t pattern_tbl_idx, uint8_t palette_idx,
                                                       uint8_t patt_tbl_tile_y, uint8_t patt_tbl_tile_x, uint8_t y, uint8_t x)
{
    uint8_t patt_bit_0 = pattern_table[pattern_tbl_idx]
                                      [patt_tbl_tile_y]
                                      [patt_tbl_tile_x]
                                      [0]
                                      [y];

    // MSB corresponds to the most left pixel
    patt_bit_0 = get_bit_range(patt_bit_0, 7 - x, 7 - x);

    uint8_t patt_bit_1 = pattern_table[pattern_tbl_idx]
                                      [patt_tbl_tile_y]
                                      [patt_tbl_tile_x]
                                      [1]
                                      [y];

    // MSB corresponds to the most left pixel
    patt_bit_1 = get_bit_range(patt_bit_1, 7 - x, 7 - x);

    // Building the two bits color_idx
    uint8_t color_idx = (patt_bit_1 << 1) | patt_bit_0;

    return {color_idx != 0, get_color(4 * palette_idx + color_idx)};
}

vector<int> scanline_selected_sprites;

void print_sprite_pixel(uint8_t patt_tbl_idx)
{
    color pixel_color;
    bool any_color = false;
    for (int i : scanline_selected_sprites)
    {
        if (oam[i].x <= cycle && cycle < oam[i].x + 8)
        {
            int tile_pos_y = scanline - oam[i].y - 1; // PPU draws sprites one below.
            int tile_pos_x = cycle - oam[i].x;

            if (oam[i].attributes.flags.flip_hor)
                tile_pos_y = 7 - tile_pos_y;

            if (oam[i].attributes.flags.flip_ver)
                tile_pos_x = 7 - tile_pos_x;

            if (oam[i].attributes.flags.priority == 1)
                continue;

            auto res = get_sprite_pixel_color_from_patt_tbl(patt_tbl_idx, 4 + oam[i].attributes.flags.palette, oam[i].tile_index / 16, oam[i].tile_index % 16, tile_pos_y, tile_pos_x);
            pixel_color = res.second;

            if (res.first)
            {
                uint8_t bg_color_idx = get_pixel_color_from_nametable(current_nametable(), PPUCTRL.flags.bg_patt_table_addr).second;
                if (i == 0 /*&& bg_color_idx != 0*/)
                {
                    PPUSTATUS.flags.sprite_0hit = 1;
                }
                any_color = true;
                break;
            }
        }
    }

    // TODO: set flags.

    if (any_color)
        screen.at<cv::Vec3b>(scanline, cycle) = cv::Vec3b(pixel_color.B,
                                                          pixel_color.G,
                                                          pixel_color.R);
}

void print_pattern_table()
{
    auto print_pattern = [&](int table_idx) {
        cv::Mat table = cv::Mat::zeros(128, 128, CV_8UC3);
        string windows_title = "Pattern " + to_string(table_idx);
        for (int i = 0; i < 128; i++)
        {
            for (int j = 0; j < 128; j++)
            {
                color pixel_color = get_pixel_color_from_patt_tbl(table_idx, i / 8, j / 8, i % 8, j % 8).first;
                table.at<cv::Vec3b>(i, j) = cv::Vec3b(pixel_color.R, pixel_color.G, pixel_color.B);
            }
        }
        auto scaled_table = table;
        cv::resize(table, scaled_table, cv::Size(), 2, 2);
        imshow(windows_title, scaled_table);
    };

    print_pattern(0);
    print_pattern(1);
}

void init_debug_palettes()
{
    palettes[0] = 0x30;
    for (uint8_t i = 1; i < 32; i++)
    {
        // this is a random function that I came up with,
        // dont lose your time understanding or even reading this
        palettes[i] = uint8_t(pow(2, i)) % 0x30;
    }
}

void load_chr_from_mcu()
{
    auto chr = mcu.get_chr();
    int chr_it = 0;

    memcpy(pattern_table, chr, sizeof(pattern_table));
}

void ppu_init()
{
    address_latch = false;

    load_chr_from_mcu();

    init_debug_palettes();

    load_colors();

    print_pattern_table();
}

long long frame_counter = 0;
code_timer fps_timer;

void print_screen()
{
    frame_counter++;
    if (frame_counter % 60 == 0)
    {
        //cout << (60 / fps_timer.seconds()) << " fps" << endl;
        fps_timer = code_timer();
    }

    auto scaled_screen = screen;
    cv::resize(screen, scaled_screen, cv::Size(), 2, 2);
    imshow(windows_title, scaled_screen);
    updated_frame = true;
}

void select_scanline_sprites()
{
    scanline_selected_sprites.clear();

    for (int i = 0; scanline_selected_sprites.size() < 8 && i < 64; i++)
        if (oam[i].y != 0 && oam[i].y < scanline && scanline <= oam[i].y + 8)
            scanline_selected_sprites.push_back(i);
}

void ppu_clock()
{
    if (cycle < SCREEN_PIXEL_WIDTH && scanline < SCREEN_PIXEL_HEIGHT)
    {
        // Only prints pixels that are within the visible area of screen
        print_pixel(current_nametable(), PPUCTRL.flags.bg_patt_table_addr);

        if (PPUMASK.flags.show_fg)
        {
            if (cycle == 0)
                select_scanline_sprites();

            print_sprite_pixel(PPUCTRL.flags.fg_patt_table_addr);
        }
    }

    // Checks for VBlank range
    if (scanline == 241 && cycle == 1)
    {
        PPUSTATUS.flags.vblank = 1;
        print_screen();
        print_pattern_table();
        if (PPUCTRL.flags.enable_nmi)
            set_nmi();
    }

    cycle++;

    // Checks for the end of current frame
    if (cycle >= 341)
    {
        cycle = 0;
        scanline++;
        if (scanline >= 261)
        {
            PPUSTATUS.flags.vblank = 0;
            PPUSTATUS.flags.sprite_0hit = 0;
            scanline = 0;
        }
    }
}


void ppu_write(uint16_t address, uint8_t data)
{
    if (address <= 0x1FFF)
    {
        cout << "Writting in pattern table is not allowed yet. address = " << hex << int(address) << endl;
        exit(1);
    }
    if (address >= 0x3F00)
    {
        // palettes
        address %= 0x3F00;
        address %= 0x0020;
        palettes[uint8_t(address)] = data;

        if (uint8_t(address) % 4 == 0)
            palettes[0] = palettes[uint8_t(address)];
    }
    // Nametables
    else if (address >= 0x2000 && address < 0x2400)
    {
        if (address < 0x23C0)
        {
            address %= 0x2000;
            nametable[0][address / 32][address % 32] = data;
        }
        else
        {
            address %= 0x23C0;
            attribute_table[0][address / 8][address % 8] = data;
        }
    }
    else if (address >= 0x2400 && address < 0x2800)
    {
        if (address < 0x27C0)
        {
            address %= 0x2400;
            nametable[0][address / 32][address % 32] = data;
        }
        else
        {
            address %= 0x27C0;
            attribute_table[0][address / 8][address % 8] = data;
        }
    }
    else if (address >= 0x2800 && address < 0x2C00)
    {
        if (address < 0x2BC0)
        {
            address %= 0x2800;
            nametable[1][address / 32][address % 32] = data;
        }
        else
        {
            address %= 0x2BC0;
            attribute_table[1][address / 8][address % 8] = data;
        }
    }
    else if (address >= 0x2C00 && address < 0x3000)
    {
        if (address < 0x2FC0)
        {
            address %= 0x2C00;
            nametable[1][address / 32][address % 32] = data;
        }
        else
        {
            address %= 0x2FC0;
            attribute_table[1][address / 8][address % 8] = data;
        }
    }
}

uint8_t ppu_read(uint16_t address)
{
    if (address <= 0x1FFF)
    {
        return ((uint8_t *)pattern_table) [address];
    }
    else
    {
        cout << "Reading from this area is not implemented yet." << endl;
        exit(1);
    }
}

void exec_dma(uint8_t address_high)
{
    for (uint16_t i = 0; i < 256; i++)
        ((uint8_t *)oam)[oam_address++] = mcu.load_absolute(build_dword(address_high, (uint8_t)i)).second;
    // TODO: count cpu cycles.
}

uint8_t read_register(uint16_t address)
{
    uint8_t data = 0x0;
    switch (address)
    {
    case 0x2002:
        // STATUS
        address_latch = false;
        data = PPUSTATUS.byte;
        break;
    case 0x2004:
        break;
    case 0x2007:
        data = data_buffer;
        data_buffer = ppu_read(vram_addr);
        vram_addr += PPUCTRL.flags.increment_mode ? 32 : 1;
        break;
    default:
        break;
    }
   // cout << "address = " << hex << int(address) << endl;
   // cout << "data = " << hex << int(data) << endl;
    return data;
}

void write_register(uint16_t address, uint8_t data)
{
    switch (address)
    {
    case 0x2000:
        // CONTROL
        PPUCTRL.byte = data;
        break;
    case 0x2001:
        PPUMASK.byte = data;
        break;
    case 0x2003:
        oam_address = data;
        break;
    case 0x2004:
        break;
    case 0x2005:
        if (address_latch == 0)
		{
            fine_x = data & 0x07;
            coarse_x = data >> 3;
		}
		else
		{
            fine_y = data & 0x07;
            coarse_y = data >> 3;
		} 
        address_latch = !address_latch;
		break;
    case 0x2006:
        if (address_latch)
        {
            vram_addr = uint16_t((vram_addr & 0xFF00) | data);
        }
        else
        {
            vram_addr = uint16_t((vram_addr & 0x00FF) | (data << 8));
        }
        address_latch = !address_latch;
        break;
    case 0x2007:
        ppu_write(vram_addr, data);
        vram_addr += PPUCTRL.flags.increment_mode ? 32 : 1;
        break;
    case 0x4014:
        exec_dma(data);
        break;
    default:
        break;
    }
}
