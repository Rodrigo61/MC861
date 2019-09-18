#pragma once

#include <bits/stdc++.h>
using namespace std;

// RAM is in the first 2KB of address space.
#define RAM_SIZE 0x0800

// ROM is interval [0x8000, 0xffff] of address space.
#define ROM_SIZE 0x8000
#define ROM_BASE 0x8000

// Size of character memory. TODO: set this dynamically based on header.
#define CHR_SIZE 0

// Size of iNES header.
#define NES_HEADER_SIZE 16

class memory_control_unit
{
private:
	// ram byte array.
	uint8_t ram[RAM_SIZE];

	// rom byte array.
	uint8_t rom[ROM_SIZE];

public:
	memory_control_unit();

	// Loads rom from assembler output file.
	void load_nes_rom(string rom_path);

	// Instructions using absolute addressing contain a full 16 bit address to identify the target location.
	uint8_t load_absolute(uint16_t address);
};
