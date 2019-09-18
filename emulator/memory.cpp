#include "memory.hpp"

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

uint8_t memory_control_unit::load_absolute(uint16_t address)
{
	if (address >= ROM_BASE)
		return rom[address - ROM_BASE];
	else if (address < RAM_SIZE)
		return ram[address];
	else
	{
		cerr << "Invalid memory access at address " << address << endl;
		return 0;
	}
}
