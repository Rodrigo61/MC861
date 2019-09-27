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
	registers.p.v = 0x24;
	registers.sp = 0xFD;
	registers.pc = build_dword(mcu.load_absolute(RESET_ADDRESS_HIGH).second, mcu.load_absolute(RESET_ADDRESS_LOW).second);

	// nestest
	if (NESTEST_DEBUG)
	{
		registers.pc = 0xc000;
		registers.p.v = 0x24;
	}

	long long cycle_count = 0;

	while (true)
	{
		instruction ins = decode_next_instruction();
	
		if (NESTEST_DEBUG)
		{
			cout << uppercase << hex <<  setfill('0') << setw(2) << (int)registers.pc << " ";
			cout << " " << uppercase << hex << setfill('0') << setw(2) << (int)ins.opcode;
			for (int i = 0; i < 2; i++)
			{
				if (i < instruction_set[ins.opcode].num_bytes - 1)
					cout << " " << uppercase << hex << setfill('0') << setw(2) << (int)ins.argv[i];
				else
					cout << "   ";
			}
			
			cout << " A:" << uppercase << hex << setfill('0') << setw(2) << (int)registers.a;
			cout << " X:" << uppercase << hex << setfill('0') << setw(2) << (int)registers.x;
			cout << " Y:" << uppercase << hex << setfill('0') << setw(2) << (int)registers.y;
			cout << " P:" << uppercase << hex << setfill('0') << setw(2) << (int)registers.p.v;
			cout << " SP:" << uppercase << hex << setw(2) << (int)get_low(registers.sp);
			cout << endl;
		}

		registers.pc = (uint16_t)(registers.pc + instruction_set[ins.opcode].num_bytes);
		
		instruction_set[ins.opcode].exec(ins);

		cycle_count += instruction_set[ins.opcode].num_cycles;

		if (NESTEST_DEBUG && registers.pc == 0xc6bd)
		{
			exit(0);
		}
	
	}
}
