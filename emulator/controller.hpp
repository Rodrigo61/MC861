#pragma once
#include "utils.hpp"
#include "colors.hpp"

void controller_init();

uint8_t read_controller(uint16_t address);

void write_controller(uint8_t data);

