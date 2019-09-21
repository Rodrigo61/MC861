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

#define JMP_ABSOLUTE 0x4C
#define JMP_INDIRECT 0x6C

#define BCC 0x90
#define BNE 0xD0
#define BPL 0x10
#define BVC 0x50


struct instruction;

void build_instruction_set();

void exec_brk(instruction ins);

void exec_jmp(instruction ins);

void exec_branch(instruction ins);

void exec_ld(instruction ins);

void exec_ld_immediate(instruction ins);

void exec_st(instruction ins);

void exec_ph(instruction ins);

void exec_pl(instruction ins);
