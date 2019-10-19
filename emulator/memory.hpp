#pragma once

#include <bits/stdc++.h>
using namespace std;

// RAM is in the first 2KB of address space.
#define RAM_SIZE 0x0800

// ROM is interval [0x8000, 0xffff] of address space.
#define ROM_SIZE 0x8000
#define ROM_BASE 0x8000

#define PPU_SIZE 0x08
#define PPU_BASE 0x2000

#define APU_SIZE 0x20
#define APU_BASE 0x4000

// Size of character memory. TODO: set this dynamically based on header.
#define CHR_SIZE 0x2000

// Size of iNES header.
#define NES_HEADER_SIZE 16

class memory_control_unit
{
private:
	// ram byte array.
	uint8_t ram[RAM_SIZE];

	// rom byte array.
	uint8_t rom[ROM_SIZE];

	// PPU memory mapped registers.
	uint8_t ppu_registers[PPU_SIZE];

	// APU memory mapped registers.
	uint8_t apu_registers[APU_SIZE];

	// CHR ROM(RAM)
	uint8_t chr[CHR_SIZE];

public:
	memory_control_unit();

	// Loads rom from assembler output file.
	void load_nes_rom(string rom_path);

	// Instructions using absolute addressing contain a full 16 bit address to identify the target location.
	// Returns a address, data pair.
	pair<uint16_t, uint8_t> load_absolute(uint16_t address);

	// Absolute addressing is computed by taking the 16 bit address from the instruction and adding the contents of the X register.
	pair<uint16_t, uint8_t> load_absolute_x(uint16_t address);

	// Absolute addressing is computed by taking the 16 bit address from the instruction and adding the contents of the Y register.
	pair<uint16_t, uint8_t> load_absolute_y(uint16_t address);

	// Absolute addressing for the first 256 bytes in memory.
	pair<uint16_t, uint8_t> load_zero_page(uint8_t zero_page_address);

	// The address is calculated by taking the 8 bit zero page address from the instruction and adding the 
	// current value of the X register to it (with zero page wrap around).
	pair<uint16_t, uint8_t> load_zero_page_x(uint8_t zero_page_address);

	// The address is calculated by taking the 8 bit zero page address from the instruction and adding the 
	// current value of the Y register to it (with zero page wrap around).
	pair<uint16_t, uint8_t> load_zero_page_y(uint8_t zero_page_address);

	// A zero page address is taken from the instruction and the X register is added to it (with zero page wrap around)
	// to give the location of the least significant byte of the target address.
	pair<uint16_t, uint8_t> load_indirect_x(uint8_t zero_page_address);

	// The instruction contains the zero page location of the least significant byte of a 16 bit address.
	// The Y register is dynamically added to this value to generated the actual target address for operation.
	pair<uint16_t, uint8_t> load_indirect_y(uint8_t zero_page_address);


	// Store instructions return the address where the data was stored.
	uint16_t store_absolute(uint16_t address, uint8_t data);

	uint16_t store_absolute_x(uint16_t address, uint8_t data);

	uint16_t store_absolute_y(uint16_t address, uint8_t data);

	uint16_t store_zero_page(uint8_t zero_page_address, uint8_t data);

	uint16_t store_zero_page_x(uint8_t zero_page_address, uint8_t data);

	uint16_t store_zero_page_y(uint8_t zero_page_address, uint8_t data);

	uint16_t store_indirect_x(uint8_t zero_page_address, uint8_t data);

	uint16_t store_indirect_y(uint8_t zero_page_address, uint8_t data);


	// TODO: refactor below
	uint8_t* get_chr()
	{
		return chr;
	}
};
