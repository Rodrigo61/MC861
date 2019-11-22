#include "controller.hpp"
#include <X11/Xlib.h>
#include "X11/keysym.h"

Display *dpy;

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

	keylist[0] = {'q', 'e', '1', '2', 'w', 's', 'a', 'd'};
	keylist[1] = {'u', 'o', '8', '9', 'i', 'k', 'j', 'l'};

	dpy = XOpenDisplay(":0");
	assert(dpy);
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
		char keys_return[32];
		XQueryKeymap(dpy, keys_return);

		for (int i = 0; i < 2; i++)
		{
			buttons[i].clear();

			for (auto key : keylist[i])
			{
				KeyCode kc2 = XKeysymToKeycode(dpy, key);
				bool is_pressed = !!(keys_return[kc2 >> 3] & (1 << (kc2 & 7)));
				buttons[i].push_back(is_pressed ? 1 : 0);
			}
		}
	}
}
