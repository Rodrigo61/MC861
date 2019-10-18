#include "cpu.hpp"

int main(int argc, const char *argv[])
{
	if (argc != 2)
	{
		cerr << "Missing argument" << endl;
		cerr << "Usage: " << argv[0] << " <rom_path>" << endl;
		exit(1);
	}

	cpu_init(argv[1]);

	// this system clock is at same speed as PPU clock
	long long system_clock = 0;

	while (true)
	{
		system_clock++;

		if (system_clock % 3 == 0)
		{
			cpu_clock();
		}
	
		// TODO: Add a sleep
	}
}
