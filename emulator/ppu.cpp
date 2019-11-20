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

color get_pixel_color_from_patt_tbl(uint8_t pattern_tbl_idx,
                                    uint8_t patt_tbl_tile_y, uint8_t patt_tbl_tile_x)
{
    int palette_idx = get_palette_idx_from_attr_tbl();

    uint8_t patt_bit_0 = pattern_table[pattern_tbl_idx]
                                      [patt_tbl_tile_y]
                                      [patt_tbl_tile_x]
                                      [0]
                                      [pixel_y()];

    // MSB corresponds to the most left pixel
    patt_bit_0 = get_bit_range(patt_bit_0, 7 - pixel_x(), 7 - pixel_x());

    uint8_t patt_bit_1 = pattern_table[pattern_tbl_idx]
                                      [patt_tbl_tile_y]
                                      [patt_tbl_tile_x]
                                      [1]
                                      [pixel_y()];

    // MSB corresponds to the most left pixel
    patt_bit_1 = get_bit_range(patt_bit_1, 7 - pixel_x(), 7 - pixel_x());

    // Building the two bits color_idx
    uint8_t color_idx = (patt_bit_1 << 1) | patt_bit_0;

    return colors[palettes[4 * palette_idx + color_idx]];
}

color get_pixel_color_from_nametable(uint8_t nametable_idx, uint8_t patt_tbl_idx)
{
    assert(nametable_idx == current_nametable());
    
    // Using division to get indices of the pattern table because it's 16x16 tiles
    uint8_t patt_tbl_tile_x = nametable[nametable_idx][tile_y()][tile_x()] % 16;
    uint8_t patt_tbl_tile_y = nametable[nametable_idx][tile_y()][tile_x()] / 16;

    return get_pixel_color_from_patt_tbl(patt_tbl_idx, patt_tbl_tile_y, patt_tbl_tile_x);
}

void print_pixel(uint8_t nametable_idx, uint8_t patt_tbl_idx)
{
    assert(nametable_idx == current_nametable());
    color pixel_color = get_pixel_color_from_nametable(nametable_idx, patt_tbl_idx);

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

    return {color_idx != 0, colors[palettes[4 * palette_idx + color_idx]]};
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
    if (cycle != 0 || scanline != 0)
    {
        cout << "print_pattern_table function should be called before the first ppu_clock()." << endl;
        cout << "because it uses scanline/cycle variables." << endl;
        exit(1);
    }

    auto print_pattern = [&](int table_idx) {
        cv::Mat table = cv::Mat::zeros(128, 128, CV_8UC3);
        string windows_title = "Pattern " + to_string(table_idx);
        for (scanline = 0; scanline < 128; scanline++)
        {
            for (cycle = 0; cycle < 128; cycle++)
            {
                color pixel_color = get_pixel_color_from_patt_tbl(table_idx, tile_y(), tile_x());
                table.at<cv::Vec3b>(scanline, cycle) = cv::Vec3b(pixel_color.R, pixel_color.G, pixel_color.B);
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

    for (int side = 0; side < 2; side++)
    {
        for (int row = 0; row < 16; row++)
        {
            for (int col = 0; col < 16; col++)
            {
                for (int plane = 0; plane < 2; plane++)
                {
                    for (int byte_row = 0; byte_row < 8; byte_row++)
                    {
                        pattern_table[side][row][col][plane][byte_row] = chr[chr_it++];
                    }
                }
            }
        }
    }
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
        cout << (60 / fps_timer.seconds()) << " fps" << endl;
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
            scanline = 0;
        }
    }
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
        break;
    default:
        break;
    }
    return data;
}

void ppu_write(uint16_t address, uint8_t data)
{
    if (address >= 0x3F00)
    {
        // palettes
        address %= 0x3F00;
        address %= 0x0020;
        palettes[uint8_t(address)] = data;
        for (uint8_t i = 0; i < 32; i += 4)
        {
            palettes[i] = palettes[0];
        }
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
    else
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

void exec_dma(uint8_t address_high)
{
    for (uint16_t i = 0; i < 256; i++)
        ((uint8_t *)oam)[oam_address++] = mcu.load_absolute(build_dword(address_high, (uint8_t)i)).second;
    // TODO: count cpu cycles.
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
			address_latch = 1;
		}
		else
		{
            fine_y = data & 0x07;
            coarse_y = data >> 3;
			address_latch = 0;
		} 
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
