#include "instructions.hpp"

void exec_brk(instruction ins)
{
	assert(ins.opcode == 0);
	exit(0);
}
