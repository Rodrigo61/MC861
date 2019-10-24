#include "controller.hpp"

int cur_key = -1;
vector<int> keylist[2];

void controller_init()
{
	// 0 - A
	// 1 - B
	// 2 - Select
	// 3 - Start
	// 4 - Up
	// 5 - Down
	// 6 - Left
	// 7 - Right 

	keylist[0] = {'q','e','1','2','w','s','a','d'};
	keylist[1] = {'u','o','8','9','i','k','j','l'};
}

void feed_key_controller(int key)
{
	cur_key = key;
}

list<uint8_t> buttons[2];

uint8_t read_controller(uint16_t address)
{
	uint8_t retv = 1;
	if (buttons[address != 0x4016].size())
	{
		retv = buttons[address != 0x4016].front();
		buttons[address != 0x4016].pop_front();
	}

	return retv;
}

void write_controller(uint8_t data)
{
	if (data == 0)
	{
		for (int i = 0; i < 2; i++)
		{
			buttons[i].clear();

			for (auto key : keylist[i])
			{
				buttons[i].push_back((cur_key == key) ? 1 : 0);
			}
		}
	}
}

