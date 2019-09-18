#pragma once

#include "../cpu.hpp"

struct instruction;

void build_instruction_set();

void exec_brk(instruction ins);

void exec_lda(instruction ins);
