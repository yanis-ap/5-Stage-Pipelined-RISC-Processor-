`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 04:08:41 PM
// Design Name: 
// Module Name: DM
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


module DataMemory(
    input clk,mem_write,mem_read,
    input [31:0] address, write_data, 
    output [31:0] read_data//made a change
    );
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for(i=0;i<64;i=i+1) mem[i]=32'h0;
        mem[17]=32'hF;
        mem[21]=32'hC;
    end
    
    always @(posedge clk) begin
        if(mem_write)
            mem[address] <=write_data;
    end
    assign read_data = (mem_read)? mem[address] :32'h0;
endmodule
