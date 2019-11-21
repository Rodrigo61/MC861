#pragma once

#include "utils.hpp"

void set_apu_flags(uint16_t index, uint8_t value);

struct channel{
    int16_t length_counter, linear_counter, address, envelope;
    int16_t sweep_delay, env_delay, wave_counter, hold, phase, level;
    uint16_t duty_cycle;
    uint16_t sweep_shift;
    uint16_t noise_freq;
    uint16_t env_decay_disable;
    uint16_t sweep_decrease;
    uint16_t noise_type;
    uint16_t env_decay_rate;
    uint16_t sweep_rate;
    uint16_t wave_length;
    uint16_t env_decay_loop_enable;
    uint16_t sweep_enable;
    uint16_t fixed_volume;
    uint16_t length_counter_disable;
    uint16_t length_counter_init;
    uint16_t linear_counter_init;
    uint16_t loop_enabled;
    uint16_t linear_counter_disable;
};
void apu_clock();
void apu_init();
void print_flags(channel c);
