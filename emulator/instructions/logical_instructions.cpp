#include "instructions.hpp"

// copies the content of one register to another
void exec_transfer(instruction ins){
  switch(ins.opcode){
    case TAX:
      registers.x = registers.a;

      set_zero_flag(registers.x);
      set_negative_flag(registers.x);
      break;

    case TXA:
      registers.a = registers.x;

      set_zero_flag(registers.a);
      set_negative_flag(registers.a);
      break;

    case TAY:
      registers.y = registers.a;

      set_zero_flag(registers.y);
      set_negative_flag(registers.y);
      break;

    case TYA:
      registers.a = registers.y;

      set_zero_flag(registers.a);
      set_negative_flag(registers.a);
      break;

    case TSX:
      registers.x = registers.sp;

      set_zero_flag(registers.x);
      set_negative_flag(registers.x);
      break;

    case TXS:
      registers.sp = registers.x;
      break;
  }
}
