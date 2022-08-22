`timescale 1ns / 1ps
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
    output wire reg_we,
    output wire mem_we,
    output wire[1:0] ext_signal, // expend the symbol
    output wire[2:0] jump // decide J, BEQ or normal
    );

    wire inst_type_r;
    wire lui, addiu, func_add, lw, sw, beq, j, func_sll, func_sub;
    
    // R-type
    assign inst_type_r = (op == 6'b000000) ? 1 : 0;
    assign func_add = (inst_type_r && func == 6'b100000) ? 1 : 0;
    assign func_sub = (inst_type_r && func == 6'b100011) ? 1 : 0;
    assign func_sll = (inst_type_r && func == 6'b000000) ? 1 : 0;

    // I-type
    assign lui = (op == 6'b001111) ? 1 : 0;
    assign addiu = (op == 6'b001001) ? 1 : 0;
    assign lw = (op == 6'b100011) ? 1 : 0;
    assign sw = (op == 6'b101011) ? 1 : 0;
    assign beq = (op == 6'b000100) ? 1 : 0;

    // J-type
    assign j = (op == 6'b000010) ? 1 : 0;

    assign alu_op = (func_add || addiu || lw || sw) ? 3'b001 :
                        (beq || func_sub) ? 3'b010 :
                        (func_sll) ? 3'b011 :
                        3'b000;
    
    assign alu_src = (addiu || lw || sw) ? 1 : 0;
    assign reg_src = (lui) ? 2'b01 : // from extend module
                        (addiu || func_add || func_sll || func_sub) ? 2'b10 : // from ALU
                        (lw) ? 2'b11 : 2'b00; // from data memory
    assign reg_dst = (func_add || func_sll || func_sub) ? 1 : 0;
    assign reg_we = (inst_type_r || lui || func_sub || func_add || lw || addiu || func_sll) ? 1 : 0; 
    assign mem_we = (sw) ? 1 : 0;

    assign ext_signal = (lui) ? 2'b01 : // shift left 16
                            (addiu) ? 2'b10 : // signed extend
                            (lw || sw) ? 2'b11 : 2'b00; // unsigned extend

    assign jump = (lui || addiu || func_add || lw || sw || func_sll || func_sub) ? 3'b001 :
                    (beq && !zero) ? 3'b010 : (beq && zero) ? 3'b011 : (j) ? 3'b100 : 3'b000;
                    // normal jump / beq, but normal / beq, but jump to offset / unconditional jump
endmodule

