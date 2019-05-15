//`timescale 1ns


module tb_fir ();

   wire CLK_i;
   wire RST_n_i;
   wire [29:0] DIN_i;
   wire VIN_i;
   wire [89:0] b_i;
   wire [29:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   signal_generator SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VIN(VIN_i),
		 .DIN(DIN_i),
		 .END_SIM(END_SIM_i),
         .b(b_i));

   // FIR_filter_dadda UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_no_dadda UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_dadda_standard UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_dadda_standard_no6LSB UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_dadda_no6LSB UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_dadda_approx_layer2 UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_ambe_approx_layer2 UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   // FIR_filter_ambe UUT(.CLK(CLK_i),
	//      .RST_n(RST_n_i),
	//      .DIN(DIN_i),
   //       .VIN(VIN_i),
	//      .b(b_i),
   //       .DOUT(DOUT_i),
   //       .VOUT(VOUT_i));

   FIR_filter_dadda_final_approx UUT(.CLK(CLK_i),
      .RST_n(RST_n_i),
      .DIN(DIN_i),
      .VIN(VIN_i),
      .b(b_i),
      .DOUT(DOUT_i),
      .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));

   initial begin
   $read_lib_saif("../saif/NangateOpenCellLibrary.saif");
   $set_gate_level_monitoring("on");
   $set_toggle_region(UUT);
   $toggle_start;
   end

   always @ ( END_SIM_i ) begin
   if (END_SIM_i) begin
   $toggle_stop;
   $toggle_report("../saif/FIR_filter_switching.saif", 1.0e-9, "tb_fir.UUT");
   end
   end

endmodule
