`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 11:50:33 PM
// Design Name: 
// Module Name: branchpredictor
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


module BranchPredictor(
    input clk,
    input rst,
    // IF Stage Inputs & Outputs (Prediction)
    input [31:0] pc_if,
    output wire pred_taken_if,
    output wire [31:0] pred_target_if,
    
    // ID Stage Inputs (Training & Update)
    input [31:0] pc_id,
    input branch_id,           // Is the instruction in ID a branch?
    input jump_id,             // Is the instruction in ID a jump?
    input actual_taken_id,     // Did the branch/jump actually take?
    input [31:0] actual_target_id // What was the real target address?
);

    // 64-Entry Table Arrays
    reg valid_table [0:63];
    reg [1:0] state_table [0:63];
    reg [31:0] target_table [0:63];
    reg [5:0] idx_id;

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                valid_table[i] <= 1'b0;
                state_table[i] <= 2'b01; // Default: Weakly Not Taken (01)
                target_table[i] <= 32'h0;
            end
        end
        else if (branch_id || jump_id) begin
            // Update table when a branch/jump is evaluated in ID stage
            idx_id = pc_id[7:2];
            valid_table[idx_id] <= 1'b1;
            target_table[idx_id] <= actual_target_id;
            
            // 2-Bit Saturating Counter State Machine
            if (actual_taken_id) begin
                if (state_table[idx_id] != 2'b11)
                    state_table[idx_id] <= state_table[idx_id] + 2'b01;
            end
            else begin
                if (state_table[idx_id] != 2'b00)
                    state_table[idx_id] <= state_table[idx_id] - 2'b01;
            end
        end
    end

    // IF Stage Prediction (Combinational Lookup)
    wire [5:0] idx_if = pc_if[7:2];
    wire valid_match = valid_table[idx_if];
    wire [1:0] current_state = state_table[idx_if];

    // Predict TAKEN if Valid AND State is Weakly Taken (10) or Strongly Taken (11)
    assign pred_taken_if  = valid_match && (current_state[1] == 1'b1);
    assign pred_target_if = target_table[idx_if];

endmodule
