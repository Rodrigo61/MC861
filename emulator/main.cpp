#include "cpu.hpp"
#include "ppu.hpp"

#define ESC_CHAR 27

int main(int argc, const char *argv[])
{
	if (argc != 2)
	{
		cerr << "Missing argument" << endl;
		cerr << "Usage: " << argv[0] << " <rom_path>" << endl;
		exit(1);
	}

	cpu_init(argv[1]);
	ppu_init();

	// this system clock is at same speed as PPU clock
	long long system_clock = 0;

	code_timer timer;
	double ppu_clock_speed = 21.477272e6 / 4; // in Hz.

	while (true)
	{
		system_clock++;

		ppu_clock();

		if (system_clock % 3 == 0)
		{
			cpu_clock();
		}

		double time_diff = system_clock / ppu_clock_speed - timer.seconds();
		if (system_clock % 1000000 == 0)
			cout << system_clock << " clocks in " << timer.seconds() << " seconds / " << time_diff << " s difference" << endl;

		if (time_diff > 2e-3) // 2 miliseconds.
		{
			std::this_thread::sleep_for(std::chrono::duration<double>(time_diff));
		}

		if (updated_frame)
		{
			updated_frame = false;
		    if (cv::waitKey(1) == ESC_CHAR)
				break;
		}
	}
}
