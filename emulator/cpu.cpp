#include "cpu.hpp"

opcode_definition instruction_set[256];

register_bank registers;

memory_control_unit mcu;

long long cycle_count = 0;

// True if nmi should happen as soon as possible.
bool nmi_flag = false;

void cpu_init(const string rom_path)
{
	build_instruction_set();

	mcu.load_nes_rom(rom_path);

	// Initial state
	registers.p.v = 0x34;
	registers.sp = 0xFD;
	registers.pc = build_dword(mcu.load_absolute(RESET_ADDRESS_HIGH).second, mcu.load_absolute(RESET_ADDRESS_LOW).second);

	// nestest
	if (NESTEST_DEBUG)
	{
		registers.pc = 0xc000;
		registers.p.v = 0x24;
	}

	cycle_count = 0;
}

void cpu_clock()
{
	/*
		This functions is not really using each clock cycle to 
		execute the instructions (as is in a real NES).
		What is actually doing is executing the whole instrunction
		and then waiting for the remaining clocks of it.
	*/
	if (cycle_count == 0)
	{
		if (nmi_flag)
		{
			nmi_flag = false;
			exec_nmi();
		}

		instruction ins = decode_next_instruction();

		if (NESTEST_DEBUG)
		{
			cout << uppercase << hex <<  setfill('0') << setw(4) << (int)registers.pc << " ";
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

		cycle_count = instruction_set[ins.opcode].num_cycles;

		if (NESTEST_DEBUG && registers.pc == 0xc6bd)
		{
			exit(0);
		}
	}
	else
		cycle_count--;
}

void write_log()
{
	if (!NESTEST_DEBUG)
		print(registers.a, registers.x, registers.y, build_dword(0x01, registers.sp), registers.pc, registers.p.v);
}

void write_log(uint16_t addr, uint8_t data)
{
	if (!NESTEST_DEBUG)
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

void set_zero_flag(uint8_t value)
{
	// Explicitly acknowledge you do not need the excess bits to solve warning.
	registers.p.f.z = ((value == 0) ? 1 : 0) & 1;
}

// TODO: change this name.
void set_carry_flag(uint8_t value)
{
	registers.p.f.c = ((value != 0) ? 1 : 0) & 1;
}

void test_carry(uint8_t a, uint8_t b, uint8_t carry_in)
{
	uint16_t r = (uint16_t)((uint16_t)a + (uint16_t)b + (uint16_t)carry_in);
	registers.p.f.c = ((r > 255) ? 1 : 0) & 1;
}

void set_overflow_flag(uint8_t value)
{
	registers.p.f.v = ((value != 0) ? 1 : 0) & 1;
}

void test_overflow(int8_t m, int8_t n, int8_t carry_in, int8_t result)
{
	int r = (int)m + (int)n + (int)carry_in;
	registers.p.f.v = ((r == (int)result) ? 0 : 1) & 1;
}

void set_decimal_flag(uint8_t value)
{
	registers.p.f.d = (((value != 0)) ? 1 : 0) & 1;
}

void set_negative_flag(uint8_t data)
{
	// Explicitly acknowledge you do not need the excess bits to solve warning.
	registers.p.f.n = (((data & bit7_mask) > 0) ? 1 : 0) & 1;
}

void set_nmi()
{
	nmi_flag = true;
}
