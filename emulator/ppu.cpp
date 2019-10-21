#include "ppu.hpp"
#define dhex(x) cout << #x << " = " << hex << int(x) << endl

uint8_t pattern_table[2][16][16][2][8]; // 2 tables of 16x16 tiles, each one using 2 planes of 8 bytes
uint8_t palettes[32];
uint8_t nametable[2][30][32];
uint8_t attribute_table[8][8];

struct color
{
    uint8_t R, G, B;
} colors[64];

ctrl PPUCTRL;
status PPUSTATUS;
mask PPUMASK;

cv::Mat screen = cv::Mat::zeros( 240, 256, CV_8UC3 );
char window[] = "ONESSENO - OneNESSystemNotOfficial";

uint16_t cycle, scanline;
bool address_latch;
uint16_t vram_addr;

color get_pixel_color(int pattern_tbl_idx, int palette_idx, int tile_y, int tile_x, int pixel_y, int pixel_x)
{
    uint8_t pattern_lo = (pattern_table[pattern_tbl_idx][tile_y][tile_x][0][pixel_y] & (1 << (7 - pixel_x))) >> (7 - pixel_x);
    uint8_t pattern_hi = (pattern_table[pattern_tbl_idx][tile_y][tile_x][1][pixel_y] & (1 << (7 - pixel_x))) >> (7 - pixel_x);

    uint8_t color_idx = (pattern_hi << 1) | pattern_lo;
    return colors[palettes[4 * palette_idx + color_idx]];
}

color get_pixel_from_nametable(int palette_idx)
{
    uint8_t tile_x = nametable[0][(scanline / 8)][(cycle / 8)] % 16;
    uint8_t tile_y = nametable[0][(scanline / 8)][(cycle / 8)] / 16;
    uint8_t pixel_x = cycle % 8;
    uint8_t pixel_y = scanline % 8;

    return get_pixel_color(1, palette_idx, tile_y, tile_x, pixel_y, pixel_x);
}

int get_palette_idx_from_attr_tbl()
{
    uint8_t area_y = (scanline / 8) / 4;
    uint8_t area_x = (cycle / 8) / 4;
    uint8_t attribute = attribute_table[area_y][area_x];
    uint8_t tile_y = (scanline / 16) % 2;
    uint8_t tile_x = (cycle / 16) % 2;

    if (tile_x == 0 && tile_y == 0)
        return attribute & 0x3;
    if (tile_x == 1 && tile_y == 0)
        return (attribute >> 2) & 0x3;
    if (tile_x == 0 && tile_y == 1)
        return (attribute >> 4) & 0x3;
    if (tile_x == 1 && tile_y == 1)
        return (attribute >> 6) & 0x3;
}

void print_pixel()
{    
    int palette_idx = get_palette_idx_from_attr_tbl();
    color pixel_color = get_pixel_from_nametable(palette_idx);

    screen.at<cv::Vec3b>(scanline % 240, cycle % 256) = cv::Vec3b(pixel_color.B, pixel_color.G, pixel_color.R);
}

void print_pattern_table()
{
    auto print_pattern = [&] (int table_idx)
    {
        cv::Mat table = cv::Mat::zeros( 128, 128, CV_8UC3 );
        string window = "Pattern " + to_string(table_idx);
        for (int pos_y = 0; pos_y < 128; pos_y++)
        {
            for (int pos_x = 0; pos_x < 128; pos_x++)
            {
                uint8_t tile_x = pos_x / 8;  // relative to screen
                uint8_t tile_y = pos_y / 8;  // relative to screen
                uint8_t pixel_x = pos_x % 8; // relative to tile
                uint8_t pixel_y = pos_y % 8; // relative to tile
                color pixel_color = get_pixel_color(table_idx, 0, tile_y, tile_x, pixel_y, pixel_x);
                table.at<cv::Vec3b>(pos_y, pos_x) = cv::Vec3b(pixel_color.R, pixel_color.G, pixel_color.B);
            }
        }
        auto scaled_table = table;
        cv::resize(table, scaled_table, cv::Size(), 2, 2);
        imshow(window, scaled_table);
    };

    print_pattern(0);
    print_pattern(1);
}

void init_test_palettes()
{
    palettes[0] = 0x30;
    for (uint8_t i = 1; i < 32; i++)
    {
        palettes[i] = uint8_t(pow(2, i)) % 0x30;
    }
}

void ppu_init()
{
    address_latch = false;

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

    init_test_palettes();

    colors[0x01] = {0, 30, 116};
    colors[0x02] = {8, 16, 144};
    colors[0x03] = {48, 0, 136};
    colors[0x04] = {68, 0, 100};
    colors[0x05] = {92, 0, 48};
    colors[0x06] = {84, 4, 0};
    colors[0x07] = {60, 24, 0};
    colors[0x08] = {32, 42, 0};
    colors[0x09] = {8, 58, 0};
    colors[0x0A] = {0, 64, 0};
    colors[0x0B] = {0, 60, 0};
    colors[0x0C] = {0, 50, 60};
    colors[0x0D] = {0, 0, 0};
    colors[0x0E] = {0, 0, 0};
    colors[0x0F] = {0, 0, 0};

    colors[0x10] = {152, 150, 152};
    colors[0x11] = {8, 76, 196};
    colors[0x12] = {48, 50, 236};
    colors[0x13] = {92, 30, 228};
    colors[0x14] = {136, 20, 176};
    colors[0x15] = {160, 20, 100};
    colors[0x16] = {152, 34, 32};
    colors[0x17] = {120, 60, 0};
    colors[0x18] = {84, 90, 0};
    colors[0x19] = {40, 114, 0};
    colors[0x1A] = {8, 124, 0};
    colors[0x1B] = {0, 118, 40};
    colors[0x1C] = {0, 102, 120};
    colors[0x1D] = {0, 0, 0};
    colors[0x1E] = {0, 0, 0};
    colors[0x1F] = {0, 0, 0};

    colors[0x20] = {236, 238, 236};
    colors[0x21] = {76, 154, 236};
    colors[0x22] = {120, 124, 236};
    colors[0x23] = {176, 98, 236};
    colors[0x24] = {228, 84, 236};
    colors[0x25] = {236, 88, 180};
    colors[0x26] = {236, 106, 100};
    colors[0x27] = {212, 136, 32};
    colors[0x28] = {160, 170, 0};
    colors[0x29] = {116, 196, 0};
    colors[0x2A] = {76, 208, 32};
    colors[0x2B] = {56, 204, 108};
    colors[0x2C] = {56, 180, 204};
    colors[0x2D] = {60, 60, 60};
    colors[0x2E] = {0, 0, 0};
    colors[0x2F] = {0, 0, 0};

    colors[0x30] = {236, 238, 236};
    colors[0x31] = {168, 204, 236};
    colors[0x32] = {188, 188, 236};
    colors[0x33] = {212, 178, 236};
    colors[0x34] = {236, 174, 236};
    colors[0x35] = {236, 174, 212};
    colors[0x36] = {236, 180, 176};
    colors[0x37] = {228, 196, 144};
    colors[0x38] = {204, 210, 120};
    colors[0x39] = {180, 222, 120};
    colors[0x3A] = {168, 226, 144};
    colors[0x3B] = {152, 226, 180};
    colors[0x3C] = {160, 214, 228};
    colors[0x3D] = {160, 162, 160};
    colors[0x3E] = {0, 0, 0};
    colors[0x3F] = {0, 0, 0};

    print_pattern_table();

}

void print_screen()
{
    auto scaled_screen = screen;
    cv::resize(screen, scaled_screen, cv::Size(), 2, 2);
    imshow(window, scaled_screen);
    cv::waitKey(1);
}

void ppu_clock()
{
    if (cycle < 256 && scanline < 240)
        print_pixel();

    if (scanline >= 241 && cycle == 1)
        PPUSTATUS.flags.vblank = 1;
    
    cycle++;

    if (cycle >= 341)
    {
        cycle = 0;
        scanline++;
        if (scanline >= 261)
        {
            PPUSTATUS.flags.vblank = 0;
            scanline = 0;
            print_screen();
            //imshow( window, screen );
            //cv::waitKey(1);
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
    cout << "address = " << hex << int(address) << "  data = " << int(data) << endl;
    if (address >= 0x3F00)
    {
        // palettes
        address %= 0x3F00;
        palettes[uint8_t(address)] = data;
        for (uint8_t i = 0; i < 32; i += 4)
        {
            palettes[i] = palettes[0];
        }
        
    }
    else if (address >= 0x2000 && address < 0x23C0)
    {
        // background
        address %= 0x2000;
        nametable[0][address / 32][address % 32] = data;
    }
    else
    {
        // attribute table
        address %= 0x23C0;
        attribute_table[address / 8][address % 8] = data;
    }
}

void write_register(uint16_t address, uint8_t data)
{
    switch (address)
    {
    case 0x2000:
        // CONTROL
        PPUCTRL.byte = data;
        break;
    case 0x2003:
        break;
    case 0x2004:
        break;
    case 0x2005:
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
        break;
    default:
        break;
    }
}
