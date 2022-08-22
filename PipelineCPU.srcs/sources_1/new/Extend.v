`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Extend
//////////////////////////////////////////////////////////////////////////////////


module extend(
    input wire[15:0] imm,
    input wire[1:0] ext_signal,

    output reg[31:0] imm_extended
    );

  always @(*) begin
    case(ext_signal)
        2'b01:
            imm_extended <= {imm, 16'b0};
        2'b10:
            imm_extended <= {{16{imm[15]}}, imm};
        2'b11:
            imm_extended <= {16'b0, imm};
        default:
            imm_extended <= {16'b0, imm}; //default 
    endcase
  end
endmodule
