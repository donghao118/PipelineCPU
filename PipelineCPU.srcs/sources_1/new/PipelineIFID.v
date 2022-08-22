`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: PipelineIFID
//////////////////////////////////////////////////////////////////////////////////


module PipelineIFID(
    input wire clk,
    input wire rst,
    input wire[31:0] pc_addr,
    input wire[3:0] stall_signal,

    output reg[31:0] O_inst
    );

    always @(posedge clk) begin
        if(rst)
            O_inst <= 32'h0000_0000;
        else if(stall_signal[1] == 0)
            O_inst <= pc_addr;
        else begin
            // do nothing, stalling
        end
    end
endmodule
