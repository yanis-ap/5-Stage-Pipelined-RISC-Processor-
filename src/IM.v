`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 03:30:25 PM
// Design Name: 
// Module Name: IM
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


module InstructionMemory(
    input [31:0] address,
    output [31:0] instruction
    );
    reg [31:0] mem [0:255];
    initial begin 
//       // 1. ADDI r1, r0, #5    (r1 = 5) - PC: 0x00
//mem[0] = {4'b0110, 4'd1, 4'd0, 4'd0, 16'h0005}; 

//// 2. ADDI r2, r0, #5    (r2 = 5) - PC: 0x04
//mem[1] = {4'b0110, 4'd2, 4'd0, 4'd0, 16'h0005}; 

//// 3. ADD r3, r3, r1     (r3 = r3 + 5) - PC: 0x08 <-- LOOP TARGET!
//mem[2] = {4'b0000, 4'd3, 4'd3, 4'd1, 16'h0000}; 

//// 4. BEQ r1, r2, -4     (Since 5 == 5, branch backward -4 bytes to PC 0x08!) - PC: 0x0C
//mem[3] = {4'b0111, 4'd0, 4'd1, 4'd2, 16'hFFFC}; // 16'hFFFC is -4 in two's complement

//// 5. ADDI r4, r0, #99   (r4 = 99) - PC: 0x10 <-- SHOULD ONLY BE FETCHED ONCE!
//mem[4] = {4'b0110, 4'd4, 4'd0, 4'd0, 16'h0063};

    mem[0]={4'b0000,4'd2,4'd3,4'd4,16'h0000};//ADD
    mem[1]={4'b0100,4'd5,4'd2,4'd0,16'h0000};
    
    mem[2]={4'b0101,4'd0,4'd3,4'd5,16'h0004};
    
    mem[3]={4'b0100,4'd6,4'd2,4'd0,16'h0004};
    
    mem[4]={4'b0010,4'd7,4'd6,4'd8,16'h0000};
    end
    
    assign instruction = mem[address [9:2]];
        
endmodule
