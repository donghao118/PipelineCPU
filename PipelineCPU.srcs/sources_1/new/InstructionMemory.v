`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: InstructionMemory
//////////////////////////////////////////////////////////////////////////////////


module InstructionMemory(
    input wire[11:2] pc_addr,
    
    output wire[31:0] inst
    );

    reg [31:0] inst_mem[1023:0];
    assign inst = inst_mem[pc_addr];
endmodule
