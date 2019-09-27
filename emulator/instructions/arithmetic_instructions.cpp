#include "instructions.hpp"

void test_flags_sum(uint8_t m, uint8_t n, uint8_t carry_in, uint8_t result)
{
    test_overflow((int8_t)m, (int8_t)n, (int8_t)carry_in, (int8_t)result);
    test_carry(m, n, carry_in);
    set_negative_flag(result);
    set_zero_flag(result);
}

void cmp_family_test_and_set(uint8_t data, uint8_t acc)
{
    uint8_t sub = (uint8_t)(acc - data);

    if (acc < data)
    {
        set_carry_flag(0);
        registers.p.f.z = 0;
    }
    else if (acc == data)
    {
        set_carry_flag(1);
        registers.p.f.z = 0;
    }
    else if (acc > data)
    {
        set_carry_flag(1);
        registers.p.f.z = 1;
    }

    set_negative_flag(sub);
}

void exec_adc(instruction ins)
{
    uint16_t address;
    uint8_t data;
    uint8_t acc = registers.a;
    switch (ins.opcode)
    {
    case ADC_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    case ADC_ZEROPAGE_X:
        tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
        break;
    case ADC_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case ADC_ABSOLUTE_X:
        tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case ADC_ABSOLUTE_Y:
        tie(address, data) = mcu.load_absolute_y(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case ADC_INDIRECT_X:
        tie(address, data) = mcu.load_indirect_x(ins.argv[0]);
        break;
    case ADC_INDIRECT_Y:
        tie(address, data) = mcu.load_indirect_y(ins.argv[0]);
        break;
    default:
        break;
    }

    registers.a = (uint8_t)(registers.a + data + registers.p.f.c);
    test_flags_sum(data, acc, registers.p.f.c, registers.a);
    write_log(address, data);
}

void exec_adc_immediate(instruction ins)
{
    uint8_t data = ins.argv[0];
    uint8_t acc = registers.a;
    registers.a = (uint8_t)(registers.a + data + registers.p.f.c);
    test_flags_sum(data, acc, registers.p.f.c, registers.a);
    write_log();
}

void exec_sbc(instruction ins)
{
    uint16_t address;
    uint8_t data;
    uint8_t acc = registers.a;
    switch (ins.opcode)
    {
    case SBC_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    case SBC_ZEROPAGE_X:
        tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
        break;
    case SBC_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case SBC_ABSOLUTE_X:
        tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case SBC_ABSOLUTE_Y:
        tie(address, data) = mcu.load_absolute_y(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case SBC_INDIRECT_X:
        tie(address, data) = mcu.load_indirect_x(ins.argv[0]);
        break;
    case SBC_INDIRECT_Y:
        tie(address, data) = mcu.load_indirect_y(ins.argv[0]);
        break;
    default:
        break;
    }
    data = (uint8_t)(0xff ^ ins.argv[0]);
    registers.a = (uint8_t)(registers.a + data + registers.p.f.c);
    test_flags_sum(data, acc, registers.p.f.c, registers.a);
    write_log(address, data);
}

void exec_sbc_immediate(instruction ins)
{
    uint8_t data = (uint8_t)(0xff ^ ins.argv[0]);
    uint8_t acc = registers.a;
    registers.a = (uint8_t)(registers.a + data + registers.p.f.c);
    test_flags_sum(data, acc, registers.p.f.c, registers.a);
    write_log();
}

void exec_clc(instruction ins)
{
    assert(ins.opcode != 0);
    set_carry_flag(0);
    write_log();
}

void exec_cld(instruction ins)
{
    assert(ins.opcode != 0);
    set_decimal_flag(0);
    write_log();
}

void exec_clv(instruction ins)
{
    assert(ins.opcode != 0);
    set_overflow_flag(0);
    write_log();
}

void exec_cmp(instruction ins)
{
    uint16_t address;
    uint8_t data;
    uint8_t acc = registers.a;
    switch (ins.opcode)
    {
    case CMP_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case CMP_ABSOLUTE_X:
        tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case CMP_ABSOLUTE_Y:
        tie(address, data) = mcu.load_absolute_y(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case CMP_INDIRECT_X:
        tie(address, data) = mcu.load_indirect_x(ins.argv[0]);
        break;
    case CMP_INDIRECT_Y:
        tie(address, data) = mcu.load_indirect_y(ins.argv[0]);
        break;
    case CMP_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    case CMP_ZEROPAGE_X:
        tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
        break;
    default:
        break;
    }
    cmp_family_test_and_set(data, acc);
    write_log(address, data);
}

void exec_cmp_immediate(instruction ins)
{
    uint8_t data = ins.argv[0];
    uint8_t acc = registers.a;
    cmp_family_test_and_set(data, acc);
    write_log();
}

void exec_cpx(instruction ins)
{
    uint16_t address;
    uint8_t data;
    uint8_t acc = registers.x;
    switch (ins.opcode)
    {
    case CPX_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case CPX_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    default:
        break;
    }
    cmp_family_test_and_set(data, acc);
    write_log(address, data);
}

void exec_cpx_immediate(instruction ins)
{
    uint8_t data = ins.argv[0];
    uint8_t acc = registers.x;
    cmp_family_test_and_set(data, acc);
    write_log();
}

void exec_cpy(instruction ins)
{
    uint16_t address;
    uint8_t data;
    uint8_t acc = registers.y;
    switch (ins.opcode)
    {
    case CPY_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case CPY_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    default:
        break;
    }
    cmp_family_test_and_set(data, acc);
    write_log(address, data);
}

void exec_cpy_immediate(instruction ins)
{
    uint8_t data = ins.argv[0];
    uint8_t acc = registers.y;
    cmp_family_test_and_set(data, acc);
    write_log();
}

void exec_dec(instruction ins)
{
    uint16_t address;
    uint8_t data;
    switch (ins.opcode)
    {
    case DEC_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case DEC_ABSOLUTE_X:
        tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case DEC_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    case DEC_ZEROPAGE_X:
        tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
        break;
    default:
        break;
    }
    data--;
    set_negative_flag(data);
    set_zero_flag(data);
    mcu.store_absolute(address, data);
    write_log(address, data);
}

void exec_dex(instruction ins)
{
    assert(ins.opcode != 0);
    registers.x--;
    set_negative_flag(registers.x);
    set_zero_flag(registers.x);
    write_log();
}

void exec_dey(instruction ins)
{
    assert(ins.opcode != 0);
    registers.y--;
    set_negative_flag(registers.y);
    set_zero_flag(registers.y);
    write_log();
}

void exec_inc(instruction ins)
{
    uint16_t address;
    uint8_t data;
    switch (ins.opcode)
    {
    case INC_ZEROPAGE:
        tie(address, data) = mcu.load_zero_page(ins.argv[0]);
        break;
    case INC_ZEROPAGE_X:
        tie(address, data) = mcu.load_zero_page_x(ins.argv[0]);
        break;
    case INC_ABSOLUTE:
        tie(address, data) = mcu.load_absolute(build_dword(ins.argv[1], ins.argv[0]));
        break;
    case INC_ABSOLUTE_X:
        tie(address, data) = mcu.load_absolute_x(build_dword(ins.argv[1], ins.argv[0]));
        break;
    default:
        break;
    }
    data++;
    set_negative_flag(data);
    set_zero_flag(data);
    mcu.store_absolute(address, data);
    write_log(address, data);
}

void exec_inx(instruction ins)
{
    assert(ins.opcode != 0);
    registers.x++;
    set_negative_flag(registers.x);
    set_zero_flag(registers.x);
    write_log();
}

void exec_iny(instruction ins)
{
    assert(ins.opcode != 0);
    registers.y++;
    set_negative_flag(registers.y);
    set_zero_flag(registers.y);
    write_log();
}

void exec_sec(instruction ins)
{
    assert(ins.opcode != 0);
    set_carry_flag(1);
    write_log();
}

void exec_sed(instruction ins)
{
    assert(ins.opcode != 0);
    set_decimal_flag(1);
    write_log();
}
