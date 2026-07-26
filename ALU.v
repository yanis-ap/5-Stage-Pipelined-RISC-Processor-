`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 04:03:00 PM
// Design Name: 
// Module Name: ALU
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


//module ALU(
//    input [31:0] a,b,
//    input [1:0] alu_op,
//    output reg [31:0] result,
//    output zero
//    );
    
    
//    always @(*) begin
//        case (alu_op)
//            2'b00: result=a + b;
//            2'b01:result=a & b;
       
//            default: result=32'h0;
//        endcase
//    end
//    assign zero =(result==32'h0);
//endmodule

module ALU(
    input [31:0] a, b,
    input [1:0] alu_op,
    output reg [31:0] result,
    output zero
);
    always @(*) begin
        case (alu_op)
            2'b00: result = a + b; // ADD (Used by ADD, ADDI, LW, SW)
            2'b01: result = a - b; // SUB (Used by SUB)
            2'b10: result = a & b; // AND
            2'b11: result = a | b; // OR
            default: result = 32'h0;
        endcase
    end
    
    assign zero = (result == 32'h0);
endmodule
