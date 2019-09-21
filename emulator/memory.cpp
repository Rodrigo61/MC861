#include "memory.hpp"
#include "cpu.hpp"

memory_control_unit::memory_control_unit()
{
	// Initialize ram and rom memory with zeros.
	memset(ram, 0, sizeof(ram));
	memset(rom, 0, sizeof(rom));
}

void memory_control_unit::load_nes_rom(string rom_path)
{
	// open the file:
	ifstream file(rom_path, ios::binary);

	if (file.fail())
	{
		cerr << "Could not open file: " << rom_path << endl;
		exit(1);
	}

	// Stop eating new lines in binary mode!!!
	file.unsetf(ios::skipws);

	// get its size:
	streampos fileSize;

	file.seekg(0, ios::end);
	fileSize = file.tellg();
	file.seekg(0, ios::beg);

	// reserve capacity
	vector<uint8_t> vec;
	vec.reserve(fileSize);

	// read the data:
	vec.insert(vec.begin(), istream_iterator<uint8_t>(file), istream_iterator<uint8_t>());

	// writing to the memory array
	int ix_mem = 0xffff - ROM_BASE;
	for (int i = (int)vec.size() - CHR_SIZE - 1; i >= NES_HEADER_SIZE; i--)
	{
		rom[ix_mem] = vec[i];
		ix_mem--;
	}
}

pair<uint16_t, uint8_t> memory_control_unit::load_absolute(uint16_t address)
{
	if (address >= ROM_BASE)
		return {address, rom[address - ROM_BASE]};
	else if (address < RAM_SIZE)
		return {address, ram[address]};
	else
	{
		// Mirror RAM in remaining address space. TODO: write test?
		return {address, ram[address % RAM_SIZE]};
	}
}

pair<uint16_t, uint8_t> memory_control_unit::load_absolute_x(uint16_t address)
{
	return load_absolute((uint16_t)(address + registers.x));
}

pair<uint16_t, uint8_t> memory_control_unit::load_absolute_y(uint16_t address)
{
	return load_absolute((uint16_t)(address + registers.y));
}

pair<uint16_t, uint8_t> memory_control_unit::load_zero_page(uint8_t zero_page_address)
{
	return load_absolute(build_dword(0x00, zero_page_address));
}

pair<uint16_t, uint8_t> memory_control_unit::load_zero_page_x(uint8_t zero_page_address)
{
	return load_absolute(build_dword(0x00, (uint8_t)(zero_page_address + registers.x)));
}

pair<uint16_t, uint8_t> memory_control_unit::load_zero_page_y(uint8_t zero_page_address)
{
	return load_absolute(build_dword(0x00, (uint8_t)(zero_page_address + registers.y)));
}

pair<uint16_t, uint8_t> memory_control_unit::load_indirect_x(uint8_t zero_page_address)
{
	uint16_t address = build_dword(load_zero_page_x((uint8_t)(zero_page_address + 1)).second, load_zero_page_x(zero_page_address).second);
	return load_absolute(address);
}

pair<uint16_t, uint8_t> memory_control_unit::load_indirect_y(uint8_t zero_page_address)
{
	uint16_t address = build_dword(load_zero_page((uint8_t)(zero_page_address + 1)).second, load_zero_page(zero_page_address).second);
	return load_absolute_y(address);
}

uint16_t memory_control_unit::store_absolute(uint16_t address, uint8_t data)
{
	if (address >= ROM_BASE)
	{
		// Write in ROM, do nothing. TODO: write test?
	}
	else if (address < RAM_SIZE)
	{
		ram[address] = data;
	}
	else
	{
		// Mirror RAM in remaining address space. TODO: write test?
		ram[address % RAM_SIZE] = data;
	}

	return address;
}

uint16_t memory_control_unit::store_absolute_x(uint16_t address, uint8_t data)
{
	address = load_absolute_x(address).first;
	store_absolute(address, data);
	return address;
}

uint16_t memory_control_unit::store_absolute_y(uint16_t address, uint8_t data)
{
	address = load_absolute_y(address).first;
	store_absolute(address, data);
	return address;
}

uint16_t memory_control_unit::store_zero_page(uint8_t zero_page_address, uint8_t data)
{
	uint16_t address = load_zero_page(zero_page_address).first;
	store_absolute(address, data);
	return address;
}

uint16_t memory_control_unit::store_zero_page_x(uint8_t zero_page_address, uint8_t data)
{
	uint16_t address = load_zero_page_x(zero_page_address).first;
	store_absolute(address, data);
	return address;
}

uint16_t memory_control_unit::store_zero_page_y(uint8_t zero_page_address, uint8_t data)
{
	uint16_t address = load_zero_page_y(zero_page_address).first;
	store_absolute(address, data);
	return address;
}

uint16_t memory_control_unit::store_indirect_x(uint8_t zero_page_address, uint8_t data)
{
	uint16_t address = load_indirect_x(zero_page_address).first;
	store_absolute(address, data);
	return address;
}

uint16_t memory_control_unit::store_indirect_y(uint8_t zero_page_address, uint8_t data)
{
	uint16_t address = load_indirect_y(zero_page_address).first;
	store_absolute(address, data);
	return address;
}
