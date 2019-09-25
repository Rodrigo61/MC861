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

void exec_logical(instruction ins){
  uint16_t address;
  uint8_t data;

  switch(ins.opcode){
    case AND_IMMEDIATE:
    case EOR_IMMEDIATE:
    case ORA_IMMEDIATE:
      data = ins.argv[0];
      break;

    case AND_ZERO_PAGE:
    case EOR_ZERO_PAGE:
    case ORA_ZERO_PAGE:
      tie(address, data) = mcu.load_zero_page(ins.argv[0]);
      break;

    case AND_ZERO_PAGE_X:
    case EOR_ZERO_PAGE_X:
    case ORA_ZERO_PAGE_X:
      tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
      break;

    case AND_ABSOLUTE:
    case EOR_ABSOLUTE:
    case ORA_ABSOLUTE:
      tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case AND_ABSOLUTE_X:
    case EOR_ABSOLUTE_X:
    case ORA_ABSOLUTE_X:
      tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case AND_ABSOLUTE_Y:
    case EOR_ABSOLUTE_Y:
    case ORA_ABSOLUTE_Y:
      tie(address, data) = mcu.load_absolute_y(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case AND_INDIRECT_X:
    case EOR_INDIRECT_X:
    case ORA_INDIRECT_X:
      tie(address, data) = mcu.load_indirect_x(ins.argv[0]);
      break;

    case AND_INDIRECT_Y:
    case EOR_INDIRECT_Y:
    case ORA_INDIRECT_Y:
      tie(address, data) = mcu.load_indirect_y(ins.argv[0]);
      break;
  }

  switch (ins.opcode) {
    case AND_IMMEDIATE:
    case AND_ZERO_PAGE:
    case AND_ZERO_PAGE_X:
    case AND_ABSOLUTE:
    case AND_ABSOLUTE_X:
    case AND_ABSOLUTE_Y:
    case AND_INDIRECT_X:
    case AND_INDIRECT_Y:
      registers.a = registers.a & data;
      break;
    case EOR_IMMEDIATE:
    case EOR_ZERO_PAGE:
    case EOR_ZERO_PAGE_X:
    case EOR_ABSOLUTE:
    case EOR_ABSOLUTE_X:
    case EOR_ABSOLUTE_Y:
    case EOR_INDIRECT_X:
    case EOR_INDIRECT_Y:
      registers.a = registers.a ^ data;
      break;
    case ORA_IMMEDIATE:
    case ORA_ZERO_PAGE:
    case ORA_ZERO_PAGE_X:
    case ORA_ABSOLUTE:
    case ORA_ABSOLUTE_X:
    case ORA_ABSOLUTE_Y:
    case ORA_INDIRECT_X:
    case ORA_INDIRECT_Y:
      registers.a = registers.a | data;
      break;
  }


  set_zero_flag(registers.a);
  set_negative_flag(registers.a);
  write_log();
}

void exec_shift(instruction ins){
  uint16_t address;
  uint8_t data;
  uint8_t s_result;

  switch(ins.opcode){
    case ASL_ACCUMULATOR:
    case LSR_ACCUMULATOR:
      data = registers.a;
      break;

    case ASL_ZERO_PAGE:
    case LSR_ZERO_PAGE:
      tie(address, data) = mcu.load_zero_page(ins.argv[0]);
      break;

    case ASL_ZERO_PAGE_X:
    case LSR_ZERO_PAGE_X:
      tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
      break;

    case ASL_ABSOLUTE:
    case LSR_ABSOLUTE:
      tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case ASL_ABSOLUTE_X:
    case LSR_ABSOLUTE_X:
      tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
      break;
  }

  switch (ins.opcode) {
    case ASL_ACCUMULATOR:
    case ASL_ZERO_PAGE:
    case ASL_ZERO_PAGE_X:
    case ASL_ABSOLUTE:
    case ASL_ABSOLUTE_X:
      s_result = (uint8_t)(data << 1);
      // set carry flag
      registers.p.f.c = (((int)data*2 != (int)s_result) ? 1 : 0) & 1;
      break;

    case LSR_ACCUMULATOR:
    case LSR_ZERO_PAGE:
    case LSR_ZERO_PAGE_X:
    case LSR_ABSOLUTE:
    case LSR_ABSOLUTE_X:
      s_result = (uint8_t)(data >> 1);
      // set carry flag - last bit of the original data
      registers.p.f.c = data & 1;
      break;

  }

  switch (ins.opcode) {
    case ASL_ACCUMULATOR:
    case LSR_ACCUMULATOR:
      registers.a = s_result;
      break;

    case ASL_ZERO_PAGE:
    case LSR_ZERO_PAGE:
      mcu.store_zero_page(ins.argv[0], s_result);
      break;

    case ASL_ZERO_PAGE_X:
    case LSR_ZERO_PAGE_X:
      mcu.store_zero_page_x(ins.argv[0], s_result);
      break;

    case ASL_ABSOLUTE:
    case LSR_ABSOLUTE:
      mcu.store_absolute(build_dword(ins.argv[1], ins.argv[0]), s_result);
      break;

    case ASL_ABSOLUTE_X:
    case LSR_ABSOLUTE_X:
      mcu.store_absolute_x(build_dword(ins.argv[1], ins.argv[0]), s_result);
      break;

  }

  set_zero_flag(s_result);
  set_negative_flag(s_result);

  switch (ins.opcode) {
    case ASL_ACCUMULATOR:
    case LSR_ACCUMULATOR:
      write_log();
      break;
    default:
      write_log(address, s_result);
      break;
  }
}

void exec_rotate(instruction ins){
  uint16_t address;
  uint8_t data;
  uint8_t s_result;
  uint8_t tmp_carry;

  switch(ins.opcode){
    case ROL_ACCUMULATOR:
    case ROR_ACCUMULATOR:
      data = registers.a;
      break;

    case ROL_ZERO_PAGE:
    case ROR_ZERO_PAGE:
      tie(address, data) = mcu.load_zero_page(ins.argv[0]);
      break;

    case ROL_ZERO_PAGE_X:
    case ROR_ZERO_PAGE_X:
      tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
      break;

    case ROL_ABSOLUTE:
    case ROR_ABSOLUTE:
      tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
      break;

    case ROL_ABSOLUTE_X:
    case ROR_ABSOLUTE_X:
      tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
      break;
  }

  switch (ins.opcode) {
    case ROL_ACCUMULATOR:
    case ROL_ZERO_PAGE:
    case ROL_ZERO_PAGE_X:
    case ROL_ABSOLUTE:
    case ROL_ABSOLUTE_X:
      s_result = (uint8_t)(data << 1);

      tmp_carry = registers.p.f.c;

      // set carry flag
      registers.p.f.c = (((int)data*2 != (int)s_result) ? 1 : 0) & 1;

      // last bit of s_result will always be 0. Hence, in order to s_result
      // have the old carry as last bit, it is enough to sum the old carry.
      s_result = (uint8_t)(s_result + tmp_carry);

      break;

    case ROR_ACCUMULATOR:
    case ROR_ZERO_PAGE:
    case ROR_ZERO_PAGE_X:
    case ROR_ABSOLUTE:
    case ROR_ABSOLUTE_X:
      s_result = (uint8_t)(data >> 1);

      tmp_carry = registers.p.f.c;

      // set carry flag - last bit of the original data
      registers.p.f.c = data & 1;

      // last bit of s_result will always be 0. Hence, in order to s_result
      // have the old carry as last bit, it is enough to sum the old tmp_carry
      // shifted 7 positions.
      tmp_carry = (uint8_t)(tmp_carry << 7);
      s_result = (uint8_t)(s_result + tmp_carry);

      break;

  }

  switch (ins.opcode) {
    case ROL_ACCUMULATOR:
    case ROR_ACCUMULATOR:
      registers.a = s_result;
      break;

    case ROL_ZERO_PAGE:
    case ROR_ZERO_PAGE:
      mcu.store_zero_page(ins.argv[0], s_result);
      break;

    case ROL_ZERO_PAGE_X:
    case ROR_ZERO_PAGE_X:
      mcu.store_zero_page_x(ins.argv[0], s_result);
      break;

    case ROL_ABSOLUTE:
    case ROR_ABSOLUTE:
      mcu.store_absolute(build_dword(ins.argv[1], ins.argv[0]), s_result);
      break;

    case ROL_ABSOLUTE_X:
    case ROR_ABSOLUTE_X:
      mcu.store_absolute_x(build_dword(ins.argv[1], ins.argv[0]), s_result);
      break;

  }

  set_zero_flag(s_result);
  set_negative_flag(s_result);

  switch (ins.opcode) {
    case ROL_ACCUMULATOR:
    case ROR_ACCUMULATOR:
      write_log();
      break;
    default:
      write_log(address, s_result);
      break;
  }
}

void exec_bit(instruction ins){
  uint16_t address;
  uint8_t data;
  uint8_t result;
  uint8_t bit6_mask = (1 << 6);

  switch (ins.opcode) {
    case BIT_ZERO_PAGE:
      tie(address, data) = mcu.load_zero_page(ins.argv[0]);
      break;
    case BIT_ABSOLUTE:
      tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
      break;
  }

  result = registers.a & data;

  set_zero_flag(result);
  set_negative_flag(data);

  // set overflow flag
  registers.p.f.v = (((data & bit6_mask) > 0) ? 1 : 0) & 1;

  write_log();

}
