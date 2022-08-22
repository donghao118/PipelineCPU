`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: pc
//////////////////////////////////////////////////////////////////////////////////


module pc(
    input wire clk,
    input wire rst,
    input wire[31:0] next_pc,
    input wire[3:0] stall_signal,

    output reg[31:0] pc
    );

    always @(posedge clk) begin
        if(rst) 
            pc <= 32'h0000_0000;
        else if(stall_signal[0] == 0)
            pc <= next_pc;
        else begin
            // do nothing, stall a cycle
        end
    end
endmodule
