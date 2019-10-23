#pragma once

#include <bits/stdc++.h>
using namespace std;

class code_timer
{
	chrono::high_resolution_clock::time_point begin;

public:
	code_timer()
	{
		begin = chrono::high_resolution_clock::now();
	}

	double seconds()
	{
		return chrono::duration_cast<chrono::duration<double>>(chrono::high_resolution_clock::now() - begin).count();
	}
};

// Forms a 16-bit word (aka. double word or dword) from two bytes.
uint16_t build_dword(uint8_t high_byte, uint8_t low_byte);

// Get low byte (uint8_t) of the uint16_t data
uint8_t get_low(uint16_t data);

// Get high byte (uint8_t) of the uint16_t data
uint8_t get_high(uint16_t data);

// Print log information given all registers.
void print(uint8_t a, uint8_t x, uint8_t y, uint16_t sp, uint16_t pc, uint8_t p);

// Print log information given all registers and a memory value.
void printls(uint8_t a, uint8_t x, uint8_t y, uint16_t sp, uint16_t pc, uint8_t p, uint16_t addr, uint8_t data);

// Some useful debug printing tools. Completely defined in header since they are templates.

template <class TH>
void _dbg(const char *sdbg, TH h) { cerr << sdbg << '=' << h << endl; }

template <class TH, class... TA>
void _dbg(const char *sdbg, TH h, TA... a)
{
	while (*sdbg != ',')
		cerr << *sdbg++;
	cerr << '=' << h << ',';
	_dbg(sdbg + 1, a...);
}

template <class L, class R>
ostream &operator<<(ostream &os, pair<L, R> p)
{
	return os << "(" << p.first << ", " << p.second << ")";
}

template <class Iterable, class = typename enable_if<!is_same<string, Iterable>::value>::type>
auto operator<<(ostream &os, Iterable v) -> decltype(os << *begin(v))
{
	os << "[";
	for (auto vv : v)
		os << vv << ", ";
	return os << "]";
}

#define debug(...) _dbg(#__VA_ARGS__, __VA_ARGS__)
//#define debug(...) //
