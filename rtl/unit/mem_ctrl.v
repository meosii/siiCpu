`ifndef SIICPU_MEM_CTRL
`define SIICPU_MEM_CTRL

`include "define.v"

module mem_ctrl (
    input wire                              clk,
    input wire                              rst_n,
    input wire [`WORD_WIDTH - 1 : 0]        ex_insn,
    input wire [`DATA_WIDTH_MEM_OP - 1 : 0] ex_mem_op,      //from decoder
    input wire [`WORD_WIDTH - 1 : 0]        ex_alu_out,     // ex_alu_out -> mem_addr
    input wire [`WORD_WIDTH - 1 : 0]        ex_store_data,
    input wire [3 : 0]                      ex_store_byteena,
    input wire [`WORD_WIDTH - 1 : 0]        spm_rd_data,       // spm_rd_data -> load_data
    // to spm
    output reg                              mem_we_en,
    output reg                              mem_rd_en,
    output wire [`WORD_WIDTH - 1 : 0]       mem_addr,
    // to gpr or decoder
    output reg [`WORD_WIDTH - 1 : 0]        load_data,
    output reg [`WORD_WIDTH - 1 : 0]        prev_ex_store_data,
    output wire                             load_after_store_en, // load fetch hazard could fetch data in mem-stage
    output wire                             miss_align
);

wire [`DATA_WIDTH_OFFSET - 1 : 0] offset;

assign mem_addr     = ex_alu_out; // 31 : 0
assign offset       = ex_alu_out[`BYTE_OFFSET_LOC];
assign miss_align   = (offset == `BYTE_OFFSET_WORD)? 1'b0 : 1'b1;

reg                                 mem_we_en_r1;
reg [`WORD_WIDTH - 1 : 0]           mem_addr_r1;
reg [3 : 0]                         ex_store_byteena_r1;
reg                                 load_after_store_en_r1;
reg [`WORD_WIDTH - 1 : 0]           prev_ex_store_data_r1;
reg [`DATA_WIDTH_MEM_OP - 1 : 0]    ex_mem_op_r1;
wire [`WORD_WIDTH - 1 : 0]          load_data_tmp;

assign load_after_store_en = ( (ex_insn[`ALL_TYPE_OPCODE] == `OP_LOAD) && 
                            (mem_we_en_r1 == `ENABLE) && (mem_addr_r1 == mem_addr)
                            && (ex_store_byteena_r1 == 4'b1111)
                            )? 1'b1 : 1'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_we_en_r1            <= 1'b0;
        mem_addr_r1             <= 1'b0;
        prev_ex_store_data      <= `WORD_WIDTH'b0;
        prev_ex_store_data_r1   <= `WORD_WIDTH'b0;
        load_after_store_en_r1  <= 1'b0;
        ex_store_byteena_r1     <= 4'b0000;
        ex_mem_op_r1            <= `DATA_WIDTH_MEM_OP'b0;
    end else begin
        mem_we_en_r1            <= mem_we_en;
        mem_addr_r1             <= mem_addr;
        prev_ex_store_data      <= ex_store_data;
        prev_ex_store_data_r1   <= prev_ex_store_data;
        load_after_store_en_r1  <= load_after_store_en;
        ex_store_byteena_r1     <= ex_store_byteena;
        ex_mem_op_r1            <= ex_mem_op;
    end
end

assign load_data_tmp = (load_after_store_en_r1)? prev_ex_store_data_r1 : spm_rd_data;

always @* begin
    mem_we_en       = `DISABLE;
    mem_rd_en       = `DISABLE;
    case (ex_mem_op)
        `MEM_OP_LOAD_LW: begin
            mem_we_en   = `DISABLE;
            mem_rd_en   = `ENABLE;
        end
        `MEM_OP_LOAD_LH: begin
            mem_we_en   = `DISABLE;
            mem_rd_en   = `ENABLE;
        end
        `MEM_OP_LOAD_LHU: begin
            mem_we_en   = `DISABLE;
            mem_rd_en   = `ENABLE;
        end
        `MEM_OP_LOAD_LB: begin
            mem_we_en   = `DISABLE;
            mem_rd_en   = `ENABLE;
        end
        `MEM_OP_LOAD_LBU: begin
            mem_we_en   = `DISABLE;
            mem_rd_en   = `ENABLE;
        end
        `MEM_OP_SW, `MEM_OP_SH, `MEM_OP_SB: begin
            mem_we_en   = `ENABLE;
            mem_rd_en   = `DISABLE;
        end
        default: begin //Reads and writes of memory are not performed
            mem_we_en   = `DISABLE;
            mem_rd_en   = `DISABLE;
        end
    endcase
end

always @* begin
    load_data   = `WORD_WIDTH'b0;
    case (ex_mem_op_r1)
        `MEM_OP_LOAD_LW: begin
            load_data   = load_data_tmp;
        end
        `MEM_OP_LOAD_LH: begin
            load_data   = {{16{load_data_tmp[`WORD_WIDTH/2 - 1]}}, load_data_tmp[`WORD_WIDTH/2 - 1 : 0]};
        end
        `MEM_OP_LOAD_LHU: begin
            load_data   = {16'b0, load_data_tmp[`WORD_WIDTH/2 - 1 : 0]};
        end
        `MEM_OP_LOAD_LB: begin
            load_data   = {{24{load_data_tmp[`WORD_WIDTH/4 - 1]}}, load_data_tmp[`WORD_WIDTH/4 - 1 : 0]};
        end
        `MEM_OP_LOAD_LBU: begin
            load_data   = {24'b0, load_data_tmp[`WORD_WIDTH/4 - 1 : 0]};
        end
        `MEM_OP_SW, `MEM_OP_SH, `MEM_OP_SB: begin
            load_data   = `WORD_WIDTH'b0;
        end
        default: begin //Reads and writes of memory are not performed
            load_data   = `WORD_WIDTH'b0;
        end
    endcase
end

endmodule

`endif 