`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 03:48:18 PM
// Design Name: 
// Module Name: CU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//module ctrl(
//input [3:0] opcode,
//output reg reg_write,
//output reg mem_read,
//output reg mem_write,
//output reg mem_to_reg,
//output reg alu_src,
//output reg [1:0] alu_op
//    );
//always@(*) begin
//    reg_write=0;
//    mem_read=0;
//    mem_write=0;
//    mem_to_reg=0;
//    alu_src=0;
//    alu_op=0;
//    case(opcode)
//        4'b0000: begin
//        reg_write=1;alu_op=2'b00;
//        end
//        4'b0100:begin
//        reg_write=1;mem_read=1;mem_to_reg=1;alu_src=1;alu_op=2'b00;
//        end
//        4'b0010:begin
//        mem_write=1;alu_src=1;alu_op=2'b00;
//        end
//        4'b0001:begin
//        reg_write=1;mem_read=1;mem_to_reg=1;alu_src=1;alu_op=2'b00;
//        end
//        4'b1111:begin
//        reg_write=1;alu_op=2'b01;
//        end
//        default:begin
//        end
//    endcase
//end
//endmodule

module ctrl(
    input [3:0] opcode,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,
    output reg [1:0] alu_op,
    output reg branch,
    output reg jump
);
always @(*) begin
    // Default all signals to 0 to prevent latching and clean up code
    reg_write  = 0;
    mem_read   = 0;
    mem_write  = 0;
    mem_to_reg = 0;
    alu_src    = 0;
    alu_op     = 2'b00;
    branch     = 0;
    jump       = 0;

    case(opcode)
        4'b0000: begin // ADD (R-type)
            reg_write = 1;
            alu_op    = 2'b00;
        end
        4'b0001: begin // SUB (R-type)
            reg_write = 1;
            alu_op    = 2'b01;
        end
        4'b0010: begin // AND (R-type)
            reg_write = 1;
            alu_op    = 2'b10;
        end
        4'b0011: begin // OR (R-type)
            reg_write = 1;
            alu_op    = 2'b11;
        end
        4'b0100: begin // LW (I-type: Address = RS1 + Imm)
            reg_write  = 1;
            mem_read   = 1;
            mem_to_reg = 1;
            alu_src    = 1;
            alu_op     = 2'b00; // ALU does ADD for memory address
        end
        4'b0101: begin // SW (I-type: Address = RS1 + Imm)
            mem_write  = 1;
            alu_src    = 1;
            alu_op     = 2'b00; // ALU does ADD for memory address
        end
        4'b0110: begin // ADDI (I-type: RS1 + Imm -> RD)
            reg_write  = 1;
            alu_src    = 1;
            alu_op     = 2'b00; // ALU does ADD
        end
        4'b0111: begin //BEQ (Branch)
            branch = 1; alu_op = 2'b01;//SUB
        end
        4'b1000: begin //J (Jump)
            jump = 1;
        end
        default: begin
            // All signals remain 0 (NOP)
        end
    endcase
end
endmodule
