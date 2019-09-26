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

	// Initial state
	registers.p.v = 0x34;
	registers.sp = 0xFD;
	registers.pc = build_dword(mcu.load_absolute(RESET_ADDRESS_HIGH).second, mcu.load_absolute(RESET_ADDRESS_LOW).second);

	// nestest
	//registers.pc = 0xc000;
	//registers.p.v = 0x24;

	long long cycle_count = 0;

	while (true)
	{
		instruction ins = decode_next_instruction();
	
		// nestest
		// cout << "code = " << hex << (int)ins.opcode << " ";
		// cout << flush;

		registers.pc = (uint16_t)(registers.pc + instruction_set[ins.opcode].num_bytes);
		
		instruction_set[ins.opcode].exec(ins);

		cycle_count += instruction_set[ins.opcode].num_cycles;

		// nestest
		// if (registers.pc == 0xc6bd)
		// {
		// 	cout << hex << (int)mcu.load_absolute(build_dword(0x00, 0x02)).second << endl;
		// 	cout << hex << (int)mcu.load_absolute(build_dword(0x00, 0x03)).second << endl;
		// 	exit(0);
		// }
	
	}
}
