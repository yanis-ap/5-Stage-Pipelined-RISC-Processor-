`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 06:52:27 PM
// Design Name: 
// Module Name: top
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

module top(
input clk, rst
);

wire [31:0] pc_current, instr_if;
wire [31:0] pc_id, instr_id;
wire [3:0]  opcode_id, rd_id, rs1_id, rs2_id;
wire [31:0] imm_id, read_data1_id, read_data2_id;
wire reg_write_id, mem_read_id, mem_write_id, mem_to_reg_id, alu_src_id;
wire [1:0]  alu_op_id;
wire stall_pc, stall_if_id, flush_id_ex;
wire reg_write_ex, mem_read_ex, mem_write_ex, mem_to_reg_ex, alu_src_ex;
wire [1:0]  alu_op_ex;
wire [31:0] pc_ex, read_data1_ex, read_data2_ex, imm_ex;
wire [3:0]  rs1_ex, rs2_ex, rd_ex;
wire [1:0]  forwardA, forwardB;
wire [31:0] alu_inputA, alu_inputB_pre, alu_inputB, alu_result_ex;
wire alu_zero;
wire reg_write_mem, mem_read_mem, mem_write_mem, mem_to_reg_mem;
wire [31:0] alu_result_mem, write_data_mem;
wire [3:0]  rd_mem;
wire [31:0] mem_read_data;
wire reg_write_wb, mem_to_reg_wb;
wire [31:0] alu_result_wb, mem_data_wb, write_back_data;
wire [3:0]  rd_wb;

assign opcode_id = instr_id[31:28];
assign rd_id = instr_id[27:24];
assign rs1_id= instr_id[23:20];
assign rs2_id = instr_id[19:16];
assign imm_id = {{16{instr_id[15]}}, instr_id[15:0]};
assign alu_inputA= (forwardA == 2'b10) ? alu_result_mem :
                         (forwardA == 2'b01) ? write_back_data : read_data1_ex;
assign alu_inputB_pre  = (forwardB == 2'b10) ? alu_result_mem :
                         (forwardB == 2'b01) ? write_back_data : read_data2_ex;
assign alu_inputB = alu_src_ex ? imm_ex : alu_inputB_pre;
assign write_back_data = mem_to_reg_wb ? mem_data_wb : alu_result_wb;
//reg flush_ex_mem_reg;
//always @(posedge clk or posedge rst) begin
//if(rst)
//   flush_ex_mem_reg <= 0;
//else
//   flush_ex_mem_reg <= flush_id_ex;
//end
wire [1:0] alu_op_id_mux     = flush_id_ex ? 2'b00 : alu_op_id;
wire       reg_write_id_mux  = flush_id_ex ? 1'b0  : reg_write_id;
wire       mem_read_id_mux   = flush_id_ex ? 1'b0  : mem_read_id;
wire       mem_write_id_mux  = flush_id_ex ? 1'b0  : mem_write_id;
wire       mem_to_reg_id_mux = flush_id_ex ? 1'b0  : mem_to_reg_id;
wire       alu_src_id_mux    = flush_id_ex ? 1'b0  : alu_src_id;

wire branch_id,jump_id;
wire branch_taken;

wire [31:0] branch_target_id, jump_target_id,pc_next;
wire flush_if_id;

// 1. Equality check in ID stage (RS1 == RS2)
// Note: If you want to handle register forwarding for branches in ID, 
// using register file read values directly works for basic tests:
wire registers_equal = (read_data1_id == read_data2_id);

// --- Branch Predictor Wires ---
wire pred_taken_if, pred_taken_id;
wire [31:0] pred_target_if;

// 1. Evaluate Actual Branch/Jump in ID Stage
wire actual_taken_id = (branch_id && registers_equal) || jump_id;
wire [31:0] actual_target_id = jump_id ? jump_target_id : branch_target_id;

// 2. Target Calculations
assign branch_target_id = pc_id + imm_id;                 // Branch Target (PC + Imm)
assign jump_target_id   = {pc_id[31:28], instr_id[27:0]};  // Jump Target
// 2. Misprediction Detection
// We mispredicted if our prediction in IF did not match reality in ID
wire mispredicted = (branch_id || jump_id) && (pred_taken_id != actual_taken_id);

// 3. Branch Taken Signal
assign branch_taken = (branch_id && registers_equal) || jump_id;
// 3. Next PC Selection Logic
// If we mispredicted in ID, we MUST override the PC to fix the mistake!
// Otherwise, trust the IF stage predictor!
assign pc_next = mispredicted ? 
                 (actual_taken_id ? actual_target_id : (pc_id + 32'd4)) : // Recovery PC
                 (pred_taken_if   ? pred_target_if   : (pc_current + 32'd4)); // Predicted PC

// 4. MUX for Next PC Selection
assign flush_if_id = mispredicted;
// 5. IF/ID Flush Signal
// If a branch/jump is taken, flush the instruction currently in IF/ID!

PC pc_reg (
    .clk(clk),.rst(rst),.stall(stall_pc),
    .pc_next(pc_next),.pc_out(pc_current)
);

InstructionMemory instr_mem (
    .address(pc_current),.instruction(instr_if)
);

if_id if_id_reg (
    .clk(clk), .reset(rst), .stall(stall_if_id), .flush(flush_if_id),
    .pc_in(pc_current), .instr_in(instr_if),
    .pc_out(pc_id), .instr_out(instr_id),
    .pred_taken_in(pred_taken_if),
    .pred_taken_out(pred_taken_id)
);

ctrl control_unit (
    .opcode(opcode_id),
    .reg_write(reg_write_id), .mem_read(mem_read_id),
    .mem_write(mem_write_id), .mem_to_reg(mem_to_reg_id),
    .alu_src(alu_src_id), .alu_op(alu_op_id),.branch(branch_id),.jump(jump_id)
);

registers reg_file (
    .clk(clk), .rst(rst), .write_enable(reg_write_wb),
    .read_reg1(rs1_id), .read_reg2(rs2_id),
    .write_reg(rd_wb), .write_data(write_back_data),
    .read_data1(read_data1_id), .read_data2(read_data2_id)
);

Hazard hazard_unit (
    .id_ex_mem_read(mem_read_ex), .id_ex_rd(rd_ex),
    .if_id_src1(rs1_id), .if_id_src2(rs2_id),
    .stall_pc(stall_pc), .stall_if_id(stall_if_id), .flush_id_ex(flush_id_ex)
);

id_ex id_ex_reg (
    .clk(clk), 
    .reset(rst), 
    .flush(1'b0), // Keep flush tied to 0 so the current EX instruction survives!
    .reg_write_in(reg_write_id_mux), 
    .mem_read_in(mem_read_id_mux),
    .mem_write_in(mem_write_id_mux), 
    .mem_to_reg_in(mem_to_reg_id_mux),
    .alu_src_in(alu_src_id_mux), 
    .alu_op_in(alu_op_id_mux),
    .pc_in(pc_id),
    .read_data1_in(read_data1_id), .read_data2_in(read_data2_id),
    .imm_in(imm_id), .rs1_in(rs1_id), .rs2_in(rs2_id), .rd_in(rd_id),
    .reg_write_out(reg_write_ex), .mem_read_out(mem_read_ex),
    .mem_write_out(mem_write_ex), .mem_to_reg_out(mem_to_reg_ex),
    .alu_src_out(alu_src_ex), .alu_op_out(alu_op_ex), .pc_out(pc_ex),
    .read_data1_out(read_data1_ex), .read_data2_out(read_data2_ex),
    .imm_out(imm_ex), .rs1_out(rs1_ex), .rs2_out(rs2_ex), .rd_out(rd_ex)
);

forwarding_unit fwd_unit (
    .ex_rs1(rs1_ex), .ex_rs2(rs2_ex),
    .mem_rd(rd_mem), .wb_rd(rd_wb),
    .mem_regwrite(reg_write_mem), .wb_regwrite(reg_write_wb),
    .forwardA(forwardA), .forwardB(forwardB)
);

ALU alu (
    .a(alu_inputA), .b(alu_inputB),
    .alu_op(alu_op_ex), .result(alu_result_ex), .zero(alu_zero)
);

ex_mem ex_mem_reg (
    .clk(clk), .reset(rst),
    .reg_write_in(reg_write_ex), .mem_read_in(mem_read_ex),
    .mem_write_in(mem_write_ex), .mem_to_reg_in(mem_to_reg_ex),
    .alu_result_in(alu_result_ex), .write_data_in(alu_inputB_pre), .rd_in(rd_ex),
    .reg_write_out(reg_write_mem), .mem_read_out(mem_read_mem),
    .mem_write_out(mem_write_mem), .mem_to_reg_out(mem_to_reg_mem),
    .alu_result_out(alu_result_mem), .write_data_out(write_data_mem), .rd_out(rd_mem)
);

DataMemory data_mem (
    .clk(clk), .mem_write(mem_write_mem), .mem_read(mem_read_mem),
    .address(alu_result_mem), .write_data(write_data_mem), .read_data(mem_read_data)
);

mem_wb mem_wb_reg (
    .clk(clk), .reset(rst),
    .reg_write_in(reg_write_mem), .mem_to_reg_in(mem_to_reg_mem),
    .alu_result_in(alu_result_mem), .mem_data_in(mem_read_data), .rd_in(rd_mem),
    .reg_write_out(reg_write_wb), .mem_to_reg_out(mem_to_reg_wb),
    .alu_result_out(alu_result_wb), .mem_data_out(mem_data_wb), .rd_out(rd_wb)
);

BranchPredictor bht_btb (
    .clk(clk), .rst(rst),
    .pc_if(pc_current),
    .pred_taken_if(pred_taken_if),
    .pred_target_if(pred_target_if),
    .pc_id(pc_id),
    .branch_id(branch_id),
    .jump_id(jump_id),
    .actual_taken_id(actual_taken_id),
    .actual_target_id(actual_target_id)
);

endmodule