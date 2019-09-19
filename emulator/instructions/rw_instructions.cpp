#include "instructions.hpp"

void exec_ld(instruction ins)
{
	uint16_t address;
	uint8_t data;
	uint8_t *dest;

	switch (ins.opcode)
	{
	case LDA_ZERO_PAGE:
	case LDA_ZERO_PAGE_X:
	case LDA_ABSOLUTE:
	case LDA_ABSOLUTE_X:
	case LDA_ABSOLUTE_Y:
	case LDA_INDIRECT_X:
	case LDA_INDIRECT_Y:
		dest = &registers.a;
		break;

	case LDX_ZERO_PAGE:
	case LDX_ZERO_PAGE_Y:
	case LDX_ABSOLUTE:
	case LDX_ABSOLUTE_Y:
		dest = &registers.x;
		break;

	case LDY_ZERO_PAGE:
	case LDY_ZERO_PAGE_X:
	case LDY_ABSOLUTE:
	case LDY_ABSOLUTE_X:
		dest = &registers.y;
		break;

	default:
		assert(false);
	}

	switch (ins.opcode)
	{
	case LDA_ZERO_PAGE:
	case LDX_ZERO_PAGE:
	case LDY_ZERO_PAGE:
		tie(address, data) = mcu.load_zero_page(ins.argv[0]);
		break;

	case LDA_ZERO_PAGE_X:
	case LDY_ZERO_PAGE_X:
		tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
		break;

	case LDX_ZERO_PAGE_Y:
		tie(address, data) = mcu.load_zero_page_y(ins.argv[0]);
		break;

	case LDA_ABSOLUTE:
	case LDX_ABSOLUTE:
	case LDY_ABSOLUTE:
		tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
		break;

	case LDA_ABSOLUTE_X:
	case LDY_ABSOLUTE_X:
		tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
		break;

	case LDA_ABSOLUTE_Y:
	case LDX_ABSOLUTE_Y:
		tie(address, data) = mcu.load_absolute_y(build_dword(ins.argv[1], ins.argv[0]));
		break;

	case LDA_INDIRECT_X:
		tie(address, data) = mcu.load_indirect_x(ins.argv[0]);
		break;

	case LDA_INDIRECT_Y:
		tie(address, data) = mcu.load_indirect_y(ins.argv[0]);
		break;

	default:
		assert(false);
	}

	*dest = data;
	set_zero_flag(data);
	set_negative_flag(data);

	write_log(address, data);
}

void exec_ld_immediate(instruction ins)
{
	uint8_t data = ins.argv[0];
	uint8_t *dest;

	switch (ins.opcode)
	{
	case LDA_IMMEDIATE:
		dest = &registers.a;
		break;

	case LDX_IMMEDIATE:
		dest = &registers.x;
		break;

	case LDY_IMMEDIATE:
		dest = &registers.y;
		break;

	default:
		assert(false);
	}

	*dest = data;
	set_zero_flag(data);
	set_negative_flag(data);

	write_log();
}

void exec_st(instruction ins)
{
	uint16_t address;
	uint8_t data;

	switch (ins.opcode)
	{
	case STA_ZERO_PAGE:
	case STA_ZERO_PAGE_X:
	case STA_ABSOLUTE:
	case STA_ABSOLUTE_X:
	case STA_ABSOLUTE_Y:
	case STA_INDIRECT_X:
	case STA_INDIRECT_Y:
		data = registers.a;
		break;

	case STX_ZERO_PAGE:
	case STX_ZERO_PAGE_Y:
	case STX_ABSOLUTE:
		data = registers.x;
		break;

	case STY_ZERO_PAGE:
	case STY_ZERO_PAGE_X:
	case STY_ABSOLUTE:
		data = registers.y;
		break;

	default:
		assert(false);
	}
	
	switch (ins.opcode)
	{
	case STA_ZERO_PAGE:
	case STX_ZERO_PAGE:
	case STY_ZERO_PAGE:
		address = mcu.store_zero_page(ins.argv[0], data);
		break;

	case STA_ZERO_PAGE_X:
	case STY_ZERO_PAGE_X:
		address = mcu.store_zero_page_x(ins.argv[0], data);
		break;

	case STX_ZERO_PAGE_Y:
		address = mcu.store_zero_page_y(ins.argv[0], data);
		break;

	case STA_ABSOLUTE:
	case STX_ABSOLUTE:
	case STY_ABSOLUTE:
		address = mcu.store_absolute(build_dword(ins.argv[1], ins.argv[0]), data);
		break;

	case STA_ABSOLUTE_X:
		address = mcu.store_absolute_x(build_dword(ins.argv[1], ins.argv[0]), data);
		break;

	case STA_ABSOLUTE_Y:
		address = mcu.store_absolute_y(build_dword(ins.argv[1], ins.argv[0]), data);
		break;

	case STA_INDIRECT_X:
		address = mcu.store_indirect_x(ins.argv[0], data);
		break;

	case STA_INDIRECT_Y:
		address = mcu.store_indirect_y(ins.argv[0], data);
		break;

	default:
		assert(false);
	}

	write_log(address, data);
}

void exec_ph(instruction ins)
{
	uint8_t data;

	switch (ins.opcode)
	{
	case PHA:
		data = registers.a;
		break;
	case PHP:
		data = registers.p.v;
		break;
	
	default:
		assert(false);
	}

	uint16_t address = mcu.store_absolute(build_dword(0x01, registers.sp), data);
	registers.sp--;

	write_log(address, data);
}

void exec_pl(instruction ins)
{
	uint16_t address;
	uint8_t *dest;
	uint8_t data;

	switch (ins.opcode)
	{
	case PLA:
		dest = &registers.a;
		break;
	case PLP:
		dest = &registers.p.v;
		break;
	
	default:
		assert(false);
	}

	registers.sp++;
	tie(address, data) = mcu.load_absolute(build_dword(0x01, registers.sp));
	*dest = data;

	if (ins.opcode == PLA)
	{
		set_zero_flag(data);
		set_negative_flag(data);
	}

	write_log(address, data);
}
