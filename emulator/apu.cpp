#include "apu.hpp"

using namespace std;

bool count(int16_t &v, int16_t reset)
{
    v--;
    if (v < 0)
    {
        v = reset;
        return true;
    }
    return false;
}

static FILE *audio_output;
void apu_init()
{
    audio_output = popen("sox -e signed-integer -t s16 -c1 -r1789800 - -e signed-integer -t s16 -c2 - rate 48000 | aplay -fdat 2>/dev/null", "we");
}

static const uint8_t length_counters[32] = {10, 254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14,
                                            12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30};
bool five_cycle_divider = false, channel_is_enabled[4] = {false};
channel channels[5] = {};
int tick(int c)
{
    channel &ch = channels[c];
    if (!channel_is_enabled[c])
        return 8;
    int16_t wl = (ch.wave_length + 1) * 2;

    uint16_t volume = ch.length_counter ? ch.env_decay_disable ? ch.fixed_volume : ch.envelope : 0;
    auto &S = ch.level;
    if (!count(ch.wave_counter, wl))
        return S;
    switch (c)
    {
    case 0:
    case 1: // Square wave. With four different 8-step binary waveforms (32 bits of data total).
        if (wl < 8)
            S = 8;
        else
            S = (0xF33C0C04u & (1u << (++ch.phase % 8 + ch.duty_cycle * 8))) ? volume : 0;
        break;
    default:
        break;
    }
    return S;
}

struct
{
    uint16_t lo, hi;
} hz240counter = {0, 0};

void apu_clock()
{
    // Divide CPU clock by 7457.5 to get a 240 Hz, which controls certain events.
    if ((hz240counter.lo += 2) >= 14915)
    {
        hz240counter.lo -= 14915;
        if (++hz240counter.hi >= 4 + five_cycle_divider)
            hz240counter.hi = 0;

        // Some events are invoked at 96 Hz or 120 Hz rate. Others, 192 Hz or 240 Hz.
        bool half_tick = (hz240counter.hi & 5) == 1, full_tick = hz240counter.hi < 4;
        for (uint8_t c = 0; c < 4; c++)
        {
            int wl = channels[c].wave_length;

            if (half_tick && channels[c].length_counter && !(c == 2 ? channels[c].linear_counter_disable : channels[c].length_counter_disable))
                channels[c].length_counter -= 1;

            if (half_tick && c < 2 && count(channels[c].sweep_delay, channels[c].sweep_rate))
                if (wl >= 8 && channels[c].sweep_enable && channels[c].sweep_shift)
                {
                    int s = wl >> channels[c].sweep_shift, d[4] = {s, s, ~s, -s};
                    wl += d[channels[c].sweep_decrease * 2 + c];
                }

            if (full_tick && c == 2)
                channels[c].linear_counter = channels[c].linear_counter_disable
                                                 ? channels[c].linear_counter_init
                                                 : (channels[c].linear_counter > 0 ? channels[c].linear_counter - 1 : 0);

            if (full_tick && c != 2 && count(channels[c].env_delay, channels[c].env_decay_rate))
                if (channels[c].envelope > 0 || channels[c].env_decay_loop_enable)
                    channels[c].envelope = (channels[c].envelope - 1) & 15;
        }
    }

    int32_t sample = 1000 * (tick(0) + tick(1));

    fputc(sample, audio_output);
    fputc(sample / 256, audio_output);
}

uint8_t mask(uint8_t a, uint8_t n, uint8_t val)
{
    uint8_t r = 0, current;
    for (uint8_t i = a; i < a + n; i++)
        r |= 1 << i;
    return (val & r) >> a;
}

void print_flags(channel c)
{
    debug(c.duty_cycle);
    debug(c.sweep_shift);
    debug(c.noise_freq);
    debug(c.env_decay_disable);
    debug(c.sweep_decrease);
    debug(c.noise_type);
    debug(c.env_decay_rate);
    debug(c.sweep_rate);
    debug(c.wave_length);
    debug(c.env_decay_loop_enable);
    debug(c.sweep_enable);
    debug(c.fixed_volume);
    debug(c.length_counter_disable);
    debug(c.length_counter_init);
    debug(c.linear_counter_init);
    debug(c.loop_enabled);
    debug(c.linear_counter_disable);
}

void set_apu_flags(uint16_t index, uint8_t value)
{
    uint8_t ch_index = ((index - 4) / 4) % 5;
    channel &ch = channels[ch_index];
    uint8_t end;

    switch (index)
    {
    case 0x4000:
    case 0x4004:
    case 0x400C:
        ch.duty_cycle = mask(6, 2, value);
        ch.env_decay_disable = mask(4, 1, value);
        ch.env_decay_rate = mask(0, 4, value);
        ch.env_decay_loop_enable = mask(5, 1, value);
        ch.fixed_volume = mask(0, 4, value);
        ch.length_counter_disable = mask(5, 1, value);
        ch.linear_counter_init = mask(0, 7, value);
        ch.linear_counter_disable = mask(7, 1, value);
        break;
    case 0x4001:
    case 0x4005:
        ch.sweep_shift = mask(0, 3, value);
        ch.sweep_decrease = mask(4, 1, value);
        ch.sweep_delay = ch.sweep_rate = mask(5, 3, value);
        ch.sweep_enable = mask(8, 1, value);
        break;
    case 0x4002:
    case 0x4006:
    case 0x400A:
    case 0x400E:
        ch.noise_freq = mask(0, 4, value);
        ch.noise_type = mask(5, 1, value);
        ch.wave_length = (ch.wave_length & 0xff00) | value;
        break;
    case 0x4003:
    case 0x4007:
        ch.wave_length = (ch.wave_length & 0x00ff) | (mask(0, 3, value) << 8);
        ch.length_counter_init = mask(4, 3, value);
        ch.loop_enabled = mask(7, 1, value);
        if (channel_is_enabled[ch_index])
        {
            ch.length_counter = length_counters[ch.length_counter_init];
            ch.env_delay = ch.env_decay_rate;
            ch.envelope = 15;
            ch.phase = 0;
        }
        break;
    case 0x400B:
    case 0x400F:
        ch.wave_length = (ch.wave_length & 0x00ff) | (mask(0, 3, value) << 8);
        ch.length_counter_init = mask(4, 3, value);
        ch.loop_enabled = mask(7, 1, value);
        break;
    case 0x4015:
        for (uint8_t c = 0; c < 4; ++c)
            channel_is_enabled[c] = (value & (1 << c)) ? true : false;
        for (uint8_t c = 0; c < 4; ++c)
            if (!channel_is_enabled[c])
                channels[c].length_counter = 0;
        break;
    case 0x4017:
        five_cycle_divider = (value & 0x80) ? true : false;
        hz240counter = {0, 0};
        break;
    }
}
