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
  write_log();
}

void exec_and(instruction ins){
  uint16_t address;
  uint8_t data;

  switch(ins.opcode){
    case AND_IMMEDIATE:
      data = ins.argv[0];
      break;

    case AND_ZERO_PAGE:
      tie(address, data) = mcu.load_zero_page(ins.argv[0]);
      break;

    case AND_ZERO_PAGE_X:
      tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
      break;

    case AND_ABSOLUTE:
      tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case AND_ABSOLUTE_X:
      tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case AND_ABSOLUTE_Y:
      tie(address, data) = mcu.load_absolute_y(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case AND_INDIRECT_X:
      tie(address, data) = mcu.load_indirect_x(ins.argv[0]);
      break;

    case AND_INDIRECT_Y:
      tie(address, data) = mcu.load_indirect_y(ins.argv[0]);
      break;
  }

  registers.a = registers.a & data;

  set_zero_flag(registers.a);
  set_negative_flag(registers.a);
  write_log();
}

void exec_asl(instruction ins){
  uint16_t address;
  uint8_t data;
  uint8_t s_result;

  switch(ins.opcode){
    case ASL_ACCUMULATOR:
      data = registers.a;
      s_result = data<<1;
      registers.a = s_result;
      break;

    case ASL_ZERO_PAGE:
      tie(address, data) = mcu.load_zero_page(ins.argv[0]);
      s_result = data<<1;
      mcu.store_zero_page(ins.argv[0], s_result);
      break;

    case ASL_ZERO_PAGE_X:
      tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
      s_result = data<<1;
      mcu.store_zero_page_x(ins.argv[0], s_result);
      break;

    case ASL_ABSOLUTE:
      tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
      s_result = data<<1;
      mcu.store_absolute(build_dword(ins.argv[1], ins.argv[0]), s_result);
      break;

    case ASL_ABSOLUTE_X:
      tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
      s_result = data<<1;
      mcu.store_absolute_x(build_dword(ins.argv[1], ins.argv[0]), s_result);
      break;
  }

  set_zero_flag(s_result);
  set_negative_flag(s_result);

  // set carry flag
  registers.p.f.c = (((int)data*2 != (int)s_result) ? 1 : 0) & 1;

  if(ins.opcode == ASL_ACCUMULATOR){
    write_log();
  }else{
    write_log(address, data);
  }
}
