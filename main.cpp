#include <iostream>
#include <iomanip>
#include <stdint.h>
#include <bitset>
#include <fstream>
#include <vector>
#include <iterator>

using namespace std;

#define SIZE_MEM 65536
#define GAME "./game/game.bin"

#define SEI 0x78
#define CLD 0xD8
#define BRK 0x00

struct registers {
	uint8_t a;
	uint8_t x;
	uint8_t y;
	uint16_t sp;
	uint16_t pc;
};

struct tFlag {
	int c: 1;
	int z: 1;
	int i: 1;
	int d: 1;
	int b: 1;
	int r: 1;
	int v: 1;
	int n: 1;
};

// it is possible to represent the flags both as uint8_t and struct with this
union flags {
	tFlag f;
	uint8_t v;
};

void file_to_mem(string filename, uint8_t mem[]){
	int i, ix_mem;

	// open the file:
	ifstream file(filename, ios::binary);

	// Stop eating new lines in binary mode!!!
	file.unsetf(ios::skipws);

	// get its size:
	streampos fileSize;

	file.seekg(0, ios::end);
	fileSize = file.tellg();
	file.seekg(0, ios::beg);

	// reserve capacity
	vector<uint8_t> vec;
	vec.reserve(fileSize);

	// read the data:
	vec.insert(vec.begin(), istream_iterator<uint8_t>(file), istream_iterator<uint8_t>());

  // writing to the memory array
	ix_mem = 0xffff;
	for(i = vec.size() - 8193; i >= 16; i--){
		mem[ix_mem] = vec[i];
		ix_mem--;
	}
}

void print(uint8_t a, uint8_t x, uint8_t y, uint16_t sp, uint16_t pc, uint8_t p) {
	cout << setfill('0')
	     << "| pc = 0x" << hex << setw(4) << pc
	     << " | a = 0x" << hex << setw(2) << (unsigned) a
	     << " | x = 0x" << hex << setw(2) << (unsigned) x
	     << " | y = 0x" << hex << setw(2) << (unsigned) y
	     << " | sp = 0x" << hex << setw(4) << sp
	     << " | p[NV-BDIZC] = " << bitset<8>(p) << " |" << endl;
}

void printls(uint8_t a, uint8_t x, uint8_t y, uint16_t sp, uint16_t pc, uint8_t p, uint16_t addr, uint8_t data) {
	cout << setfill('0')
	     << "| pc = 0x" << hex << setw(4) << pc
	     << " | a = 0x" << hex << setw(2) << (unsigned) a
	     << " | x = 0x" << hex << setw(2) << (unsigned) x
	     << " | y = 0x" << hex << setw(2) << (unsigned) y
	     << " | sp = 0x" << hex << setw(4) << sp
	     << " | p[NV-BDIZC] = " << bitset<8>(p)
	     << " | MEM[0x" << hex << setw(4) << addr
	     << "] = 0x" << hex << setw(2) << (unsigned) data << " |" << endl;
}

int main(int argc, const char *argv[])
{
	uint8_t mem[SIZE_MEM];
	flags p;
	registers r;
	//print(0xFF, 0xEE, 0xDD, 0xCCCC, 0xBBBB, 0xAA);
	//printls(0xFF, 0xEE, 0xDD, 0xCCCC, 0xBBBB, 0xAA, 0xFFFF, 0x99);

  file_to_mem(GAME, mem);

	r.pc = mem[0xfffd] * 256 + mem[0xfffc];

	int b;
	while (true){
		b = mem[r.pc];

		switch(b){
			case SEI:
				p.f.i = 1;
				print(r.a, r.x, r.y, r.sp, r.pc, p.v);
				break;
			case CLD:
				p.f.d = 0;
				print(r.a, r.x, r.y, r.sp, r.pc, p.v);
				break;
			case BRK:
				return 0;
		}

		r.pc++;
	}

	return 0;
}
