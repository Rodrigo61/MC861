#include "instructions.hpp"

void build_instruction_set()
{
	instruction_set[BRK] = {exec_brk, 1, 7};
	
	instruction_set[NOP] = {exec_nop, 1, 2};

	instruction_set[SEI] = {change_I_flag, 1, 2};
	instruction_set[CLI] = {change_I_flag, 1, 2};

	instruction_set[JMP_ABSOLUTE] = {exec_jmp, 3, 3};
	instruction_set[JMP_INDIRECT] = {exec_jmp, 3, 5};

	instruction_set[JSR] = {exec_jsr, 3, 6};
	instruction_set[RTS] = {exec_rts, 1, 6};

	instruction_set[BCC] = {exec_branch, 2, 2}; 
	instruction_set[BCS] = {exec_branch, 2, 2}; 
	instruction_set[BNE] = {exec_branch, 2, 2}; 
	instruction_set[BEQ] = {exec_branch, 2, 2}; 
	instruction_set[BPL] = {exec_branch, 2, 2}; 
	instruction_set[BMI] = {exec_branch, 2, 2}; 
	instruction_set[BVC] = {exec_branch, 2, 2}; 
	instruction_set[BVS] = {exec_branch, 2, 2}; 

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

	instruction_set[AND_IMMEDIATE] = {exec_logical, 2, 2};
	instruction_set[AND_ZERO_PAGE] = {exec_logical, 2, 3};
	instruction_set[AND_ZERO_PAGE_X] = {exec_logical, 2, 4};
	instruction_set[AND_ABSOLUTE] = {exec_logical, 3, 4};
	instruction_set[AND_ABSOLUTE_X] = {exec_logical, 3, 4};
	instruction_set[AND_ABSOLUTE_Y] = {exec_logical, 3, 4};
	instruction_set[AND_INDIRECT_X] = {exec_logical, 2, 6};
	instruction_set[AND_INDIRECT_Y] = {exec_logical, 2, 5};

	instruction_set[ASL_ACCUMULATOR] = {exec_shift, 1, 2	};
	instruction_set[ASL_ZERO_PAGE] = {exec_shift, 2, 5};
	instruction_set[ASL_ZERO_PAGE_X] = {exec_shift, 2, 6};
	instruction_set[ASL_ABSOLUTE] = {exec_shift, 3, 6};
	instruction_set[ASL_ABSOLUTE_X] = {exec_shift, 3, 7};

	instruction_set[BIT_ZERO_PAGE] = {exec_bit, 2, 3};
	instruction_set[BIT_ABSOLUTE] = {exec_bit, 3, 4};

	instruction_set[EOR_IMMEDIATE] = {exec_logical, 2, 2};
	instruction_set[EOR_ZERO_PAGE] = {exec_logical, 2, 3};
	instruction_set[EOR_ZERO_PAGE_X] = {exec_logical, 2, 4};
	instruction_set[EOR_ABSOLUTE] = {exec_logical, 3, 4};
	instruction_set[EOR_ABSOLUTE_X] = {exec_logical, 3, 4};
	instruction_set[EOR_ABSOLUTE_Y] = {exec_logical, 3, 4};
	instruction_set[EOR_INDIRECT_X] = {exec_logical, 2, 6};
	instruction_set[EOR_INDIRECT_Y] = {exec_logical, 2, 5};

	instruction_set[LSR_ACCUMULATOR] = {exec_shift, 1, 2	};
	instruction_set[LSR_ZERO_PAGE] = {exec_shift, 2, 5};
	instruction_set[LSR_ZERO_PAGE_X] = {exec_shift, 2, 6};
	instruction_set[LSR_ABSOLUTE] = {exec_shift, 3, 6};
	instruction_set[LSR_ABSOLUTE_X] = {exec_shift, 3, 7};

	instruction_set[ORA_IMMEDIATE] = {exec_logical, 2, 2};
	instruction_set[ORA_ZERO_PAGE] = {exec_logical, 2, 3};
	instruction_set[ORA_ZERO_PAGE_X] = {exec_logical, 2, 4};
	instruction_set[ORA_ABSOLUTE] = {exec_logical, 3, 4};
	instruction_set[ORA_ABSOLUTE_X] = {exec_logical, 3, 4};
	instruction_set[ORA_ABSOLUTE_Y] = {exec_logical, 3, 4};
	instruction_set[ORA_INDIRECT_X] = {exec_logical, 2, 6};
	instruction_set[ORA_INDIRECT_Y] = {exec_logical, 2, 5};

	instruction_set[ROL_ACCUMULATOR] = {exec_rotate, 1, 2};
	instruction_set[ROL_ZERO_PAGE] = {exec_rotate, 2, 5};
	instruction_set[ROL_ZERO_PAGE_X] = {exec_rotate, 2, 6};
	instruction_set[ROL_ABSOLUTE] = {exec_rotate, 3, 6};
	instruction_set[ROL_ABSOLUTE_X] = {exec_rotate, 3, 7};

	instruction_set[ROR_ACCUMULATOR] = {exec_rotate, 1, 2};
	instruction_set[ROR_ZERO_PAGE] = {exec_rotate, 2, 5};
	instruction_set[ROR_ZERO_PAGE_X] = {exec_rotate, 2, 6};
	instruction_set[ROR_ABSOLUTE] = {exec_rotate, 3, 6};
	instruction_set[ROR_ABSOLUTE_X] = {exec_rotate, 3, 7};
}
