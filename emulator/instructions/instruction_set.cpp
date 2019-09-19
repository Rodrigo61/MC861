#include "instructions.hpp"

void build_instruction_set()
{
	instruction_set[BRK] = {exec_brk, 1, 7};

	instruction_set[LDA_IMMEDIATE] = {exec_ld_immediate, 2, 2};
	instruction_set[LDA_ZERO_PAGE] = {exec_ld, 2, 3};
	instruction_set[LDA_ZERO_PAGE_X] = {exec_ld, 2, 4};
	instruction_set[LDA_ABSOLUTE] = {exec_ld, 3, 4};
	instruction_set[LDA_ABSOLUTE_X] = {exec_ld, 3, 4};
	instruction_set[LDA_ABSOLUTE_Y] = {exec_ld, 3, 4};
	instruction_set[LDA_INDIRECT_X] = {exec_ld, 2, 6};
	instruction_set[LDA_INDIRECT_Y] = {exec_ld, 2, 5};

	instruction_set[LDX_IMMEDIATE] = {exec_ld_immediate, 2, 2};
	instruction_set[LDX_ZERO_PAGE] = {exec_ld, 2, 3};
	instruction_set[LDX_ZERO_PAGE_Y] = {exec_ld, 2, 4};
	instruction_set[LDX_ABSOLUTE] = {exec_ld, 3, 4};
	instruction_set[LDX_ABSOLUTE_Y] = {exec_ld, 3, 4};

	instruction_set[LDY_IMMEDIATE] = {exec_ld_immediate, 2, 2};
	instruction_set[LDY_ZERO_PAGE] = {exec_ld, 2, 3};
	instruction_set[LDY_ZERO_PAGE_X] = {exec_ld, 2, 4};
	instruction_set[LDY_ABSOLUTE] = {exec_ld, 3, 4};
	instruction_set[LDY_ABSOLUTE_X] = {exec_ld, 3, 4};

	instruction_set[STA_ZERO_PAGE] = {exec_st, 2, 3};
	instruction_set[STA_ZERO_PAGE_X] = {exec_st, 2, 4};
	instruction_set[STA_ABSOLUTE] = {exec_st, 3, 4};
	instruction_set[STA_ABSOLUTE_X] = {exec_st, 3, 5};
	instruction_set[STA_ABSOLUTE_Y] = {exec_st, 3, 5};
	instruction_set[STA_INDIRECT_X] = {exec_st, 2, 6};
	instruction_set[STA_INDIRECT_Y] = {exec_st, 2, 6};

	instruction_set[STX_ZERO_PAGE] = {exec_st, 2, 3};
	instruction_set[STX_ZERO_PAGE_Y] = {exec_st, 2, 4};
	instruction_set[STX_ABSOLUTE] = {exec_st, 3, 4};

	instruction_set[STY_ZERO_PAGE] = {exec_st, 2, 3};
	instruction_set[STY_ZERO_PAGE_X] = {exec_st, 2, 4};
	instruction_set[STY_ABSOLUTE] = {exec_st, 3, 4};

	instruction_set[PHA] = {exec_ph, 1, 3};
	instruction_set[PHP] = {exec_ph, 1, 3};

	instruction_set[PLA] = {exec_pl, 1, 4};
	instruction_set[PLP] = {exec_pl, 1, 4};

	instruction_set[TAX] = {exec_transfer, 1, 2};
	instruction_set[TXA] = {exec_transfer, 1, 2};
	instruction_set[TAY] = {exec_transfer, 1, 2};
	instruction_set[TYA] = {exec_transfer, 1, 2};
	instruction_set[TSX] = {exec_transfer, 1, 2};
	instruction_set[TXS] = {exec_transfer, 1, 2};

	instruction_set[AND_IMMEDIATE] = {exec_and, 2, 2};
	instruction_set[AND_ZERO_PAGE] = {exec_and, 2, 3};
	instruction_set[AND_ZERO_PAGE_X] = {exec_and, 2, 4};
	instruction_set[AND_ABSOLUTE] = {exec_and, 3, 4};
	instruction_set[AND_ABSOLUTE_X] = {exec_and, 3, 4};
	instruction_set[AND_ABSOLUTE_Y] = {exec_and, 3, 4};
	instruction_set[AND_INDIRECT_X] = {exec_and, 2, 6};
	instruction_set[AND_INDIRECT_Y] = {exec_and, 2, 5};

	instruction_set[ASL_ACCUMULATOR] = {exec_asl, 1, 2	};
	instruction_set[ASL_ZERO_PAGE] = {exec_asl, 2, 5};
	instruction_set[ASL_ZERO_PAGE_X] = {exec_asl, 2, 6};
	instruction_set[ASL_ABSOLUTE] = {exec_asl, 3, 6};
	instruction_set[ASL_ABSOLUTE_X] = {exec_asl, 3, 7};
}
