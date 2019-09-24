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

	instruction_set[INC_ZEROPAGE] = {exec_inc,  2, 5};
	instruction_set[INC_ZEROPAGE_X] = {exec_inc, 2, 6};
	instruction_set[INC_ABSOLUTE] = {exec_inc, 3, 6};
	instruction_set[INC_ABSOLUTE_X] = {exec_inc, 3, 7};

	instruction_set[CMP_IMMEDIATE] = {exec_cmp_immediate, 2, 2};
	instruction_set[CMP_ZEROPAGE] = {exec_cmp, 2, 3};  
	instruction_set[CMP_ZEROPAGE_X] = {exec_cmp, 2, 3};
	instruction_set[CMP_ABSOLUTE] = {exec_cmp, 2, 4};
	instruction_set[CMP_ABSOLUTE_X] = {exec_cmp, 3, 4};
	instruction_set[CMP_ABSOLUTE_Y] = {exec_cmp, 3, 4};
	instruction_set[CMP_INDIRECT_X] = {exec_cmp, 2, 6};
	instruction_set[CMP_INDIRECT_Y] = {exec_cmp, 2, 5};

	instruction_set[CPX_IMMEDIATE] = {exec_cpx_immediate, 2, 2};
	instruction_set[CPX_ZEROPAGE] = {exec_cpx, 2, 3};
	instruction_set[CPX_ABSOLUTE] = {exec_cpx, 3, 4};

	instruction_set[CPY_IMMEDIATE] = {exec_cpy_immediate, 2, 2};
	instruction_set[CPY_ZEROPAGE] = {exec_cpy, 2, 3};
	instruction_set[CPY_ABSOLUTE] = {exec_cpy, 3, 4};

	instruction_set[DEC_ZEROPAGE] = {exec_dec, 2, 5};
	instruction_set[DEC_ZEROPAGE_X] = {exec_dec, 2, 6};
	instruction_set[DEC_ABSOLUTE] = {exec_dec, 3, 6};
	instruction_set[DEC_ABSOLUTE_X] = {exec_dec, 3, 7};

	instruction_set[ADC_IMMEDIATE] = {exec_adc_immediate, 2, 2};
	instruction_set[ADC_ZEROPAGE] = {exec_adc, 2, 3};  
	instruction_set[ADC_ZEROPAGE_X] = {exec_adc, 2, 4};
	instruction_set[ADC_ABSOLUTE] = {exec_adc, 3, 4};
	instruction_set[ADC_ABSOLUTE_X] = {exec_adc, 3, 4};
	instruction_set[ADC_ABSOLUTE_Y] = {exec_adc, 3, 4};
	instruction_set[ADC_INDIRECT_X] = {exec_adc, 2, 6};
	instruction_set[ADC_INDIRECT_Y] = {exec_adc, 2, 5};

	instruction_set[SBC_IMMEDIATE] = {exec_sbc_immediate, 2, 2};
	instruction_set[SBC_ZEROPAGE] = {exec_sbc, 2, 3};  
	instruction_set[SBC_ZEROPAGE_X] = {exec_sbc, 2, 4};
	instruction_set[SBC_ABSOLUTE] = {exec_sbc, 3, 4};
	instruction_set[SBC_ABSOLUTE_X] = {exec_sbc, 3, 4};
	instruction_set[SBC_ABSOLUTE_Y] = {exec_sbc, 3, 4};
	instruction_set[SBC_INDIRECT_X] = {exec_sbc, 2, 6};
	instruction_set[SBC_INDIRECT_Y] = {exec_sbc, 2, 5}; 

	instruction_set[CLC] = {exec_clc, 1, 2};
	instruction_set[SEC] = {exec_sec, 1, 2};
	instruction_set[CLV] = {exec_clv, 1, 2};
	instruction_set[SED] = {exec_sed, 1, 2};
	instruction_set[CLD] = {exec_cld, 1, 2};
	instruction_set[DEX] = {exec_dex, 1, 2};
	instruction_set[INX] = {exec_inx, 1, 2};
	instruction_set[DEY] = {exec_dey, 1, 2};
	instruction_set[INY] = {exec_iny, 1, 2};
}
