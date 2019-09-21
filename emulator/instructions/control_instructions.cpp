#include "instructions.hpp"

void exec_brk(instruction ins)
{
	assert(ins.opcode == 0);
	exit(0);
}

void exec_jmp(instruction ins)
{
	uint16_t address;
	
	if (ins.opcode == JMP_ABSOLUTE)
		address = build_dword(ins.argv[1], ins.argv[0]);
	else
	{
		uint16_t indirect_address = build_dword(ins.argv[1], ins.argv[0]);
		uint8_t address_low = mcu.load_absolute(indirect_address).second;
		uint8_t address_high = mcu.load_absolute((uint16_t)(indirect_address + 1)).second;
		address = build_dword(address_high, address_low);
	}

	registers.pc = (uint16_t)(address);

	write_log();
}