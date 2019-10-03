#include "instructions.hpp"

// Set of functions to push and pull registers's value from the stack.
// PULL modify the correspondent register
void pull_p_from_stack()
{
	registers.sp++;
	registers.p.v = mcu.load_absolute(build_dword(0x01, registers.sp)).second;
	// flags B and R flags never change in register
	registers.p.f.b = 0;
	registers.p.f.r = 1;
}

void pull_pc_from_stack()
{
	registers.sp++;
	uint8_t low = mcu.load_absolute(build_dword(0x01, registers.sp)).second;
	registers.sp++;
	uint8_t high = mcu.load_absolute(build_dword(0x01, registers.sp)).second;

	registers.pc = build_dword(high, low);
}

void push_pc_to_stack()
{
	registers.pc--;
	mcu.store_absolute(build_dword(0x01, registers.sp), get_high(registers.pc));
	registers.sp--;
	mcu.store_absolute(build_dword(0x01, registers.sp), get_low(registers.pc));
	registers.sp--;
}

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
		uint8_t address_high = mcu.load_absolute(build_dword(get_high(indirect_address), uint8_t(get_low(indirect_address) + 1))).second;
		address = build_dword(address_high, address_low);
	}

	registers.pc = (uint16_t)(address);

	write_log();
}

void exec_jsr(instruction ins)
{
	push_pc_to_stack();
	
	uint16_t address = build_dword(ins.argv[1], ins.argv[0]);
	registers.pc = (uint16_t)(address);

	write_log();
}

void exec_rts(instruction ins)
{
	assert(ins.opcode == RTS); // to prevent for warnings
	
	pull_pc_from_stack();

	registers.pc++;

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
	case BCS:
		should_branch = registers.p.f.c == 1;
		break;
	case BNE:
		should_branch = registers.p.f.z == 0;
		break;
	case BEQ:
		should_branch = registers.p.f.z == 1;
		break;
	case BPL:
		should_branch = registers.p.f.n == 0;
		break;
	case BMI:
		should_branch = registers.p.f.n == 1;
		break;
	case BVC:
		should_branch = registers.p.f.v == 0;
		break;
	case BVS:
		should_branch = registers.p.f.v == 1;
		break;
	default:
		assert(false);
	}

	if (should_branch)
	{
		int8_t relative_offset = int8_t(ins.argv[0]);
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

void exec_rti(instruction ins)
{
	assert(ins.opcode == RTI); // to prevent for warnings
	
	pull_p_from_stack();	
	pull_pc_from_stack();
	
	write_log();
}



