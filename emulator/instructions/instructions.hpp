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

// Logical instructions
#define AND_IMMEDIATE 0x29
#define AND_ZERO_PAGE 0x25
#define AND_ZERO_PAGE_X 0x35
#define AND_ABSOLUTE 0x2D
#define AND_ABSOLUTE_X 0x3D
#define AND_ABSOLUTE_Y 0x39
#define AND_INDIRECT_X 0x21
#define AND_INDIRECT_Y 0x31

#define ASL_ACCUMULATOR 0x0A
#define ASL_ZERO_PAGE 0x06
#define ASL_ZERO_PAGE_X 0x16
#define ASL_ABSOLUTE 0x0E
#define ASL_ABSOLUTE_X 0x1E

#define BIT_ZERO_PAGE 0x24
#define BIT_ABSOLUTE 0x2C

#define EOR_IMMEDIATE 0x49
#define EOR_ZERO_PAGE 0x45
#define EOR_ZERO_PAGE_X 0x55
#define EOR_ABSOLUTE 0x4D
#define EOR_ABSOLUTE_X 0x5D
#define EOR_ABSOLUTE_Y 0x59
#define EOR_INDIRECT_X 0x41
#define EOR_INDIRECT_Y 0x51

#define LSR_ACCUMULATOR 0x4A
#define LSR_ZERO_PAGE 0x46
#define LSR_ZERO_PAGE_X 0x56
#define LSR_ABSOLUTE 0x4E
#define LSR_ABSOLUTE_X 0x5E

#define ORA_IMMEDIATE 0x09
#define ORA_ZERO_PAGE 0x05
#define ORA_ZERO_PAGE_X 0x15
#define ORA_ABSOLUTE 0x0D
#define ORA_ABSOLUTE_X 0x1D
#define ORA_ABSOLUTE_Y 0x19
#define ORA_INDIRECT_X 0x01
#define ORA_INDIRECT_Y 0x11

#define ROL_ACCUMULATOR 0x2A
#define ROL_ZERO_PAGE 0x26
#define ROL_ZERO_PAGE_X 0x36
#define ROL_ABSOLUTE 0x2E
#define ROL_ABSOLUTE_X 0x3E

#define ROR_ACCUMULATOR 0x6A
#define ROR_ZERO_PAGE 0x66
#define ROR_ZERO_PAGE_X 0x76
#define ROR_ABSOLUTE 0x6E
#define ROR_ABSOLUTE_X 0x7E

#define TAX 0xAA
#define TXA 0x8A
#define TAY 0xA8
#define TYA 0x98
#define TSX 0xBA
#define TXS 0x9A

#define NOP 0xEA

#define SEI 0x78
#define CLI 0x58

#define JMP_ABSOLUTE 0x4C
#define JMP_INDIRECT 0x6C

#define JSR 0x20
#define RTS 0x60

#define RTI 0x40

#define BCC 0x90
#define BCS 0xB0
#define BNE 0xD0
#define BEQ 0xF0
#define BPL 0x10
#define BMI 0x30
#define BVC 0x50
#define BVS 0x70


struct instruction;

void build_instruction_set();

void exec_brk(instruction ins);

void exec_nop(instruction ins);

void change_I_flag(instruction ins);

void exec_jmp(instruction ins);

void exec_jsr(instruction ins);

void exec_rts(instruction ins);

void exec_branch(instruction ins);

void exec_ld(instruction ins);

void exec_ld_immediate(instruction ins);

void exec_st(instruction ins);

void exec_ph(instruction ins);

void exec_pl(instruction ins);

// Logical

void exec_transfer(instruction ins);

void exec_logical(instruction ins);

void exec_shift(instruction ins);

void exec_rotate(instruction ins);

void exec_bit(instruction ins);
