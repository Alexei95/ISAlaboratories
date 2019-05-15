//`timescale 1ns


module tb_mips_lite ();

   wire A, clk, rstn, inst_mem_rstn, inst_mem_wr_en ; 
   wire [8:0] inst_mem_wr_addr; 
   wire [31:0] inst_mem_wr_data; 
   wire inst_mem_rd_en;
    wire [8:0] inst_mem_addr;
    wire [31:0] inst_mem_data;

    wire [8:0] address;
    wire [31:0] write_data;
    wire [31:0] read_data;
    wire enable_write;
    wire enable_read;
   testbench TB (.A(A), .clk(clk), .rstn(rstn), 
		.inst_mem_rstn(inst_mem_rstn), .inst_mem_wr_en(inst_mem_wr_en), 
		.inst_mem_wr_addr(inst_mem_wr_addr), .inst_mem_wr_data(inst_mem_wr_data));
   
   instruction_memory inst_mem
                   (.clk(clk),
                    .RSn(inst_mem_rstn),
                    .rd_enable(inst_mem_rd_en),
                    .rd_address(inst_mem_addr),
                    .read_data(inst_mem_data),
                    .wr_address(inst_mem_wr_addr),
                    .wr_enable(inst_mem_wr_en),
                    .write_data(inst_mem_wr_data)); 
   
    data_memory data_mem
                   (.clk(clk),
                    .RSn(inst_mem_rstn),
                    .enable_write(enable_write),
                    .enable_read(enable_read),
                    .address(address),
                    .write_data(write_data),
                    .read_data(read_data));
   mips_lite UUT 
                    (.inst_mem_rd_en(inst_mem_rd_en),
                    .inst_mem_addr(inst_mem_addr),
                    .inst_mem_data(inst_mem_data),

                    .address(address),
                    .write_data(write_data),
                    .read_data(read_data),
                    .enable_write(enable_write),
                    .enable_read(enable_read),
		    .clk(clk),
                    .rstn(rstn));

   initial begin
   $read_lib_saif("../saif/NangateOpenCellLibrary.saif");
   $set_gate_level_monitoring("on");
   $set_toggle_region(UUT);
   $toggle_start;
   end

   always @ ( A ) begin
   if (A) begin
   $toggle_stop;
   $toggle_report("../saif/mips_lite_back.saif", 1.0e-9, "tb_mips_lite.UUT");
   $stop;
   end
   end 

endmodule
