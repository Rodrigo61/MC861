#pragma once

#include "../cpu.hpp"

#define LDA_IMMEDIATE 0xA9
#define LDA_ZERO_PAGE 0xA5
#define LDA_ZERO_PAGE_X 0xB5
#define LDA_ABSOLUTE 0xAD
#define LDA_ABSOLUTE_X 0xBD
#define LDA_ABSOLUTE_Y 0xB9
#define LDA_INDIRECT_X 0xA1
#define LDA_INDIRECT_Y 0xB1

#define LDX_IMMEDIATE 0xA2
#define LDX_ZERO_PAGE 0xA6
#define LDX_ZERO_PAGE_Y 0xB6
#define LDX_ABSOLUTE 0xAE
#define LDX_ABSOLUTE_Y 0xBE

#define LDY_IMMEDIATE 0xA0
#define LDY_ZERO_PAGE 0xA4
#define LDY_ZERO_PAGE_X 0xB4
#define LDY_ABSOLUTE 0xAC
#define LDY_ABSOLUTE_X 0xBC

#define STA_ZERO_PAGE 0x85
#define STA_ZERO_PAGE_X 0x95
#define STA_ABSOLUTE 0x8D
#define STA_ABSOLUTE_X 0x9D
#define STA_ABSOLUTE_Y 0x99
#define STA_INDIRECT_X 0x81
#define STA_INDIRECT_Y 0x91

#define STX_ZERO_PAGE 0x86
#define STX_ZERO_PAGE_Y 0x96
#define STX_ABSOLUTE 0x8E

#define STY_ZERO_PAGE 0x84
#define STY_ZERO_PAGE_X 0x94
#define STY_ABSOLUTE 0x8C

#define PHA 0x48
#define PHP 0x08

#define PLA 0x68
#define PLP 0x28

#define BRK 0x00

#define INC_ZEROPAGE 0xE6
#define INC_ZEROPAGE_X 0xF6
#define INC_ABSOLUTE 0xEE
#define INC_ABSOLUTE_X 0xFE

#define CMP_IMMEDIATE 0xC9
#define CMP_ZEROPAGE 0xC5  
#define CMP_ZEROPAGE_X 0xD5
#define CMP_ABSOLUTE 0xCD
#define CMP_ABSOLUTE_X 0xDD
#define CMP_ABSOLUTE_Y 0xD0
#define CMP_INDIRECT_X 0XC1
#define CMP_INDIRECT_Y  0XD1

#define CPX_IMMEDIATE 0xE0
#define CPX_ZEROPAGE 0xE4
#define CPX_ABSOLUTE 0xEC

#define CPY_IMMEDIATE 0xC0
#define CPY_ZEROPAGE 0xC4
#define CPY_ABSOLUTE 0xCC

#define DEC_ZEROPAGE 0xC6
#define DEC_ZEROPAGE_X 0xD6
#define DEC_ABSOLUTE 0xCE
#define DEC_ABSOLUTE_X 0xDE

#define ADC_IMMEDIATE 0x69
#define ADC_ZEROPAGE 0x65  
#define ADC_ZEROPAGE_X 0x75
#define ADC_ABSOLUTE 0x6D
#define ADC_ABSOLUTE_X 0x7D
#define ADC_ABSOLUTE_Y 0x79
#define ADC_INDIRECT_X 0X61
#define ADC_INDIRECT_Y 0X71

#define SBC_IMMEDIATE 0xE9
#define SBC_ZEROPAGE 0xE5  
#define SBC_ZEROPAGE_X 0xF5
#define SBC_ABSOLUTE 0xED
#define SBC_ABSOLUTE_X 0xFD
#define SBC_ABSOLUTE_Y 0xF9
#define SBC_INDIRECT_X 0XE1
#define SBC_INDIRECT_Y 0XF1

#define CLC 0x18
#define SEC 0x38
#define CLV 0xB8
#define SED 0XF8
#define CLD 0xD8
#define DEX 0XCA
#define INX 0xE8
#define DEY 0x88
#define INY 0xC8

struct instruction;

void build_instruction_set();
 
void exec_brk(instruction ins);

void exec_ld(instruction ins);

void exec_ld_immediate(instruction ins);

void exec_st(instruction ins);

void exec_ph(instruction ins);

void exec_pl(instruction ins);

void exec_adc(instruction ins);

void exec_adc_immediate(instruction ins);

void exec_sbc(instruction ins);

void exec_sbc_immediate(instruction ins);

void exec_clc(instruction ins);

void exec_cld(instruction ins);

void exec_clv(instruction ins);

void exec_cmp(instruction ins);

void exec_cmp_immediate(instruction ins);

void exec_cpx(instruction ins);

void exec_cpx_immediate(instruction ins);

void exec_cpy(instruction ins);

void exec_cpy_immediate(instruction ins);

void exec_dec(instruction ins);

void exec_dex(instruction ins);

void exec_dey(instruction ins);

void exec_inc(instruction ins);

void exec_inx(instruction ins);

void exec_iny(instruction ins);

void exec_sbc(instruction ins);

void exec_sec(instruction ins);

void exec_sed(instruction ins);