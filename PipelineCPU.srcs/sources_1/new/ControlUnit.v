`timescale 1ns / 1ps
`include "Define.vh"
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ControlUnit
//////////////////////////////////////////////////////////////////////////////////


module ControlUnit(
    input [5:0] op,
    input [5:0] func,
    input wire zero,

    output wire[2:0] alu_op,
    output wire alu_src,
    output wire[1:0] reg_src,
    output wire reg_dst,
    output wire reg_we, // reg file write enable 
    output wire mem_we, // mem write enable
    output wire[1:0] ext_signal, // immediate number extend 
    output wire[2:0] jump, // decide J, BEQ or normal
    output wire overflow_check
    );

    wire inst_type_r;
    wire lui, addiu, addi, sltiu, andi, ori, xori, bne, lw, sw, beq, j, jr;
    wire func_add, func_sll, func_sub, func_addu, func_subu, func_slt, func_sltu, func_and, func_or, func_nor, func_srl, func_sra, func_xor;
    
    // R-type
    assign inst_type_r = (op == 6'b000000) ? 1 : 0;
    assign func_add = (inst_type_r && func == 6'b100000) ? 1 : 0;
    assign func_sub = (inst_type_r && func == 6'b100011) ? 1 : 0;
    assign func_sll = (inst_type_r && func == 6'b000000) ? 1 : 0;
    assign func_addu = (inst_type_r && func == 6'b100001) ? 1 : 0;
    assign func_subu = (inst_type_r && func == 6'b100011) ? 1 : 0;
    assign func_slt = (inst_type_r && func == 6'b101010) ? 1 : 0;
    assign func_sltu = (inst_type_r && func == 6'b101011) ? 1 : 0;
    assign func_and = (inst_type_r && func == 6'b100100) ? 1 : 0;
    assign func_or = (inst_type_r && func == 6'b100101) ? 1 : 0;
    assign func_nor = (inst_type_r && func == 6'b100111) ? 1 : 0;
    assign func_srl = (inst_type_r && func == 6'b000010) ? 1 : 0;
    assign func_sra = (inst_type_r && func == 6'b000011) ? 1 : 0;
    assign func_xor = (inst_type_r && func == 6'b100110) ? 1 : 0;

    // I-type
    assign lui = (op == 6'b001111) ? 1 : 0;
    assign addiu = (op == 6'b001001) ? 1 : 0;
    assign lw = (op == 6'b100011) ? 1 : 0;
    assign sw = (op == 6'b101011) ? 1 : 0;
    assign beq = (op == 6'b000100) ? 1 : 0;
    assign addi = (op == 6'b001000) ? 1 : 0;
    assign sltiu = (op == 6'b001011) ? 1 : 0;
    assign andi = (op == 6'b000100) ? 1 : 0;
    assign ori = (op == 6'b001101) ? 1 : 0;
    assign xori = (op == 6'b001110) ? 1 : 0;
    assign bne = (op == 6'b000101) ? 1 : 0;


    // J-type
    assign j = (op == 6'b000010) ? 1 : 0;
    assign jr = (op == 6'b000000) ? 1 : 0;

    assign alu_op = (func_add || func_addu || addi || addiu || lw || sw) ? `ALU_OP_ADD :
                        (beq || func_sub || func_subu || bne) ? `ALU_OP_SUB :
                        (func_slt || sltiu || func_sltu) ? `ALU_OP_SLT :
                        (func_and || andi) ? `ALU_OP_AND :
                        (func_or ||ori) ? `ALU_OP_OR :
                        (func_xor || xori) ? `ALU_OP_XOR :
                        (func_nor) ? `ALU_OP_NOR :
                        (func_sll) ? `ALU_OP_SLL : 
                        (func_srl) ? `ALU_OP_SRL :
                        (func_sra) ? `ALU_OP_SRA :
                        `ALU_OP_DEFAULT;
    
    assign alu_src = (addiu || addi || sltiu || andi || ori || xori || lw || sw) ? 1 : 0;

    assign reg_src = (lui) ? 2'b01 : // from extend module
                        (addiu || addi || sltiu || andi || ori || xori || func_add || func_addu || func_sll || func_sub || func_subu || func_slt ||
                        func_sltu || func_and || func_or || func_nor || func_xor || func_srl || func_sra) ? 2'b10 : // from ALU
                        (lw) ? 2'b11 : 2'b00; // from data memory
    
    assign reg_dst = (func_add || func_addu || func_subu || func_slt || func_sltu || func_and || func_or || func_nor || func_sll || func_sub ||
                        func_xor || func_sll || func_srl || func_sra) ? 1 : 0; // destination rd or rt
    
    assign reg_we = (inst_type_r || lui || addi || addiu || andi || sltiu || ori || xori || lw || func_sll) ? 1 : 0; 
    assign mem_we = (sw) ? 1 : 0;

    assign overflow_check = (func_add || func_sub || addi) ? 1 : 0;

    assign ext_signal = (lui) ? 2'b01 : // shift left 16
                            (addiu || func_add || sltiu) ? 2'b10 : // signed extend
                            (lw || sw || andi || ori || xori) ? 2'b11 : 2'b00; // unsigned extend

    assign jump = (lui || addiu || func_add || lw || sw || func_sll || func_sub || func_slt || func_sltu || func_addu || 
                    func_and || func_nor || func_or || func_sra || func_srl || func_xor || func_subu || addi || sltiu || andi || 
                    ori || xori) ? 3'b001 :
                    ((beq && !zero) || (bne && zero)) ? 3'b010 : ((beq && zero) || (bne && !zero)) ? 3'b011 : (j || jr) ? 3'b100 : 3'b000;
                    // normal jump, next instruction \ beq, but not equal or bne, but equal \ beq, and equal or bne, and not equal \ unconditional jump
endmodule

