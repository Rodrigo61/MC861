#include "cpu.hpp"

opcode_definition instruction_set[256];

register_bank registers;

memory_control_unit mcu;

void write_log()
{
	print(registers.a, registers.x, registers.y, build_dword(0x01, registers.sp), registers.pc, registers.p.v);
}

void write_log(uint16_t addr, uint8_t data)
{
	printls(registers.a, registers.x, registers.y, build_dword(0x01, registers.sp), registers.pc, registers.p.v, addr, data);
}

instruction decode_next_instruction()
{
	instruction ins;
	ins.opcode = mcu.load_absolute(registers.pc).second;
	for (uint16_t i = 1; i < instruction_set[ins.opcode].num_bytes; i++)
		ins.argv[i - 1] = mcu.load_absolute((uint16_t)(registers.pc + i)).second;

	return ins;
}

void set_zero_flag(uint8_t data)
{
	// Explicitly acknowledge you do not need the excess bits to solve warning.
	registers.p.f.z = ((data == 0) ? 1 : 0) & 1;
}

void set_negative_flag(uint8_t data)
{
	// Explicitly acknowledge you do not need the excess bits to solve warning.
	registers.p.f.n = (((data & bit7_mask) > 0) ? 1 : 0) & 1;
}

void pull_p_from_stack()
{
	registers.sp++;
	registers.p.v = mcu.load_absolute(build_dword(0x01, registers.sp)).second;
}

void push_p_to_stack()
{
	mcu.store_absolute(build_dword(0x01, registers.sp), registers.p.v);
	registers.sp--;
}

void pull_pc_from_stack()
{
	registers.sp++;
	uint8_t high = mcu.load_absolute(build_dword(0x01, registers.sp)).second;
	registers.sp++;
	uint8_t low = mcu.load_absolute(build_dword(0x01, registers.sp)).second;

	registers.pc = build_dword(high, low);
}

void push_pc_to_stack()
{
	mcu.store_absolute(build_dword(0x01, registers.sp), get_low(registers.pc));
	registers.sp--;
	mcu.store_absolute(build_dword(0x01, registers.sp), get_high(registers.pc));
	registers.sp--;
}
