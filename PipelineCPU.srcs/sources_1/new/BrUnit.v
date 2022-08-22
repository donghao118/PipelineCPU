`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Module Name: BrUnit
//////////////////////////////////////////////////////////////////////////////////


module BrUnit(
    input wire[2:0] jump,

    input wire[31:0] pc,
    input wire[15:0] imm16,
    input wire[25:0] imm26,

    output reg[31:0] next_pc
    );


    always @(*) begin
        case(jump)
            3'b001: // normal next 
                next_pc <= pc + 32'h4;
            3'b010: // beq, but not equal
                next_pc <= pc + 32'h4;
            3'b100: // jump
                next_pc <= {pc[31:28], imm26, 2'b00};
            3'b011: // beq but equal
                next_pc <= {(pc + 32'h4) + {{14{imm16[15]}}, {imm16, 2'b00}}};
            default:
                next_pc <= pc + 32'h4;
        endcase
    end
endmodule
