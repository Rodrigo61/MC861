#include "instructions.hpp"

void exec_brk(instruction ins)
{
	assert(ins.opcode == BRK); // to prevent for warnings
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

void exec_branch(instruction ins)
{
	bool should_branch;
	
	switch (ins.opcode)
	{
	case BCC:
		should_branch = registers.p.f.c == 0;
		break;
	case BNE:
		should_branch = registers.p.f.z == 0;
		break;
	case BPL:
		should_branch = registers.p.f.n == 0;
		break;
	case BVC:
		should_branch = registers.p.f.v == 0;
		break;
	default:
		assert(false);
	}

	if (should_branch)
	{
		uint8_t relative_offset = ins.argv[0];
		registers.pc = uint16_t(registers.pc + relative_offset);
	}
		
	write_log();
}

void exec_nop(instruction ins)
{
	assert(ins.opcode == NOP); // to prevent for warnings
	write_log();
}

void change_I_flag(instruction ins)
{
	if (ins.opcode == SEI)
		registers.p.f.i = 1;
	else
		registers.p.f.i = 0;
	
	write_log();
}