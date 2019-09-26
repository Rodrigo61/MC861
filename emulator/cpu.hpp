#pragma once

#include "utils.hpp"
#include "memory.hpp"
#include "instructions/instructions.hpp"

const uint8_t bit7_mask = (1 << 7);

#define RESET_ADDRESS_LOW 0xfffc
#define RESET_ADDRESS_HIGH 0xfffd

// Represents status register as a sequence of one bit integers. Names given as in 6502 manual.
struct flags_t
{
	uint8_t c : 1; // Carry.
	uint8_t z : 1; // Zero result.
	uint8_t i : 1; // Interrupt disable.
	uint8_t d : 1; // Decimal mode.
	uint8_t b : 1; // Break command.
	uint8_t r : 1; // Expansion.
	uint8_t v : 1; // Overflow.
	uint8_t n : 1; // Negative result.
};

// It is possible to represent the flags both as uint8_t and struct with this.
union flags {
	flags_t f;
	uint8_t v;
};

struct register_bank
{
	uint8_t a;
	uint8_t x;
	uint8_t y;
	uint8_t sp;  // Stack pointer.
	uint16_t pc; // Program counter.
	flags p;	 // Status register.
};

struct instruction
{
	uint8_t opcode;
	uint8_t argv[2]; // Arguments if applicable.
};

struct opcode_definition
{
	void (*exec)(instruction); // Functions called to execute opcode.
	uint16_t num_bytes;		   // Number of bytes used by instructions of this opcode.
	uint16_t num_cycles;	   // Number of cycles used by instructions of this opcode.
};

// Bitmask for nth bit
uint8_t bitmask(uint8_t n);

// Array where instruction_set[i] defines what should happen for opcode i.
extern opcode_definition instruction_set[];

// Grouping of all cpu registers.
extern register_bank registers;

// Memory control unit.
extern memory_control_unit mcu;

// Writes a log line using current register values.
void write_log();

// Writes a log line using current register values and given memory values.
void write_log(uint16_t addr, uint8_t data);

// Decodes and returns instruction stating at current pc.
instruction decode_next_instruction();

// Sets or resets zero flag based on the given data.
void set_zero_flag(uint8_t data);

// Sets or resets carry flag based on the given data.
void set_carry_flag(uint8_t data);
void test_carry(uint8_t a, uint8_t b, uint8_t carry_in);

// Sets or resets overflow flag based on the given data.
void set_overflow_flag(uint8_t data);
void test_overflow(int8_t m, int8_t n, int8_t carry_in, int8_t result);

// Sets or resets decimal flag based on the given data.
void set_decimal_flag(uint8_t data);

// Sets or resets negative flag based on the given data.
void set_negative_flag(uint8_t data);

