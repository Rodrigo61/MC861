#include "instructions.hpp"

void exec_lda(instruction ins)
{
	uint16_t address = build_dword(ins.argv[1], ins.argv[0]);
	uint8_t data = mcu.load_absolute(address);
	registers.a = data;
	set_zero_flag(data);
	set_negative_flag(data);

	write_log(address, data);
}
