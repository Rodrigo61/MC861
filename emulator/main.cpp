#include "cpu.hpp"

int main(int argc, const char *argv[])
{
	if (argc != 2)
	{
		cerr << "Missing argument" << endl;
		cerr << "Usage: " << argv[0] << " <rom_path>" << endl;
		exit(1);
	}

	build_instruction_set();

	mcu.load_nes_rom(argv[1]);

	registers.pc = build_dword(mcu.load_absolute(RESET_ADDRESS_HIGH).second, mcu.load_absolute(RESET_ADDRESS_LOW).second);

	long long cycle_count = 0;

	while (true)
	{
		instruction ins = decode_next_instruction();

		instruction_set[ins.opcode].exec(ins);

		cycle_count += instruction_set[ins.opcode].num_cycles;

		registers.pc = (uint16_t)(registers.pc + instruction_set[ins.opcode].num_bytes);
	}
}
