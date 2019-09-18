#include "instructions.hpp"

#define LDA_ABSOLUTE 0xAD

#define BRK 0x00

void build_instruction_set()
{
	instruction_set[BRK] = {exec_brk, 1, 7};
	instruction_set[LDA_ABSOLUTE] = {exec_lda, 3, 4};
}
