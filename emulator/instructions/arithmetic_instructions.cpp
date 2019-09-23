#include "instructions.hpp"


void exec_adc(instruction ins){	
   
}

void exec_clc(instruction ins){
    set_carry_flag(0);
}

void exec_cld(instruction ins){
    set_decimal_flag(0);
}

void exec_clv(instruction ins){
    set_overflow_flag(0);
}

void exec_cmp(instruction ins){
    
}
void exec_cpx(instruction ins){
    
}
void exec_cpy(instruction ins){
    
}

void exec_dec(instruction ins){
    
}

void exec_dex(instruction ins){    
    registers.x--;
    set_negative_flag(registers.x);
    set_zero_flag(registers.x);
}

void exec_dey(instruction ins){    
    registers.y--;
    set_negative_flag(registers.y);
    set_zero_flag(registers.y);
}

void exec_inc(instruction ins){
	uint16_t address;
	uint8_t data;
    switch (ins.opcode)
    {
    case INC_ZEROPAGE:
        tie(address,data) = mcu.load_zero_page(ins.argv[0]);
        data++;
        set_negative_flag(data);
        set_zero_flag(data);
        mcu.store_zero_page(address,data);
        break;    
    case INC_ZEROPAGE_X:
        tie(address,data) = mcu.load_zero_page_x(ins.argv[0]);
        data++;
        set_negative_flag(data);
        set_zero_flag(data);
        mcu.store_zero_page_x(address,data);
        break;
    case INC_ABSOLUTE:
        tie(address,data) = mcu.load_absolute(ins.argv[0]);
        data++;
        set_negative_flag(data);
        set_zero_flag(data);
        mcu.store_absolute(address,data);
        break;
    case INC_ABSOLUTE_X:
        tie(address,data) = mcu.load_absolute_x(ins.argv[0]);
        data++;
        set_negative_flag(data);
        set_zero_flag(data);
        mcu.store_absolute_x(address,data);
        break;
    default:
        break;
    }
}

void exec_inx(instruction ins){
    registers.x++;
    set_negative_flag(registers.x);
    set_zero_flag(registers.x);
}

void exec_iny(instruction ins){    
    registers.y++;
    set_negative_flag(registers.y);
    set_zero_flag(registers.y);
}

void exec_sbc(instruction ins){
    
}

void exec_sec(instruction ins){
    set_carry_flag(1);
}

void exec_sed(instruction ins){
    set_decimal_flag(1);
}