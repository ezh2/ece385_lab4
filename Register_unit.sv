
//Correct as of 9/23 5:45 pm
module register_unit (
	input  logic        Clk, 
	input  logic [8:0]  A_In,	// comes from the sum that is 9 (adder)
	input  logic [7:0]  B_In,	//comes from switches
	//clr ld as in 
	input  logic  	    Clr_,	//comes from control and tells to reset a and x_0
	input  logic        Ld_A_X, // @@ this comes from adder
	input  logic        Ld_B, // = Reset_ClearA_LoadB  button to load_B and clear A comes from top level
	input  logic        Shift_En,	//comes from the control unit
	
	output logic [7:0]  A,	//new one
	output logic [7:0]  B,	//new one
	output logic        x_0
);
//rename x to x_0
//signal
	
	logic A_shift_out;

	reg_8 reg_A (
		.Clk            (Clk), 
		.Reset          (Ld_B || Clr_),//cause the same signal(button) that loads b resets A
		.Shift_In       (x_0), 
		.Load           (Ld_A_X), 
		.Shift_En       (Shift_En),
		.D              (A_In[7:0]),
		.Shift_Out      (A_shift_out),
		.Data_Out       (A)
	);

	reg_8 reg_B (
		.Clk            (Clk), 
		.Reset          (1'b0), //we never reset it		
		.Shift_In       (A_shift_out), 
		.Load           (Ld_B), 
		.Shift_En       (Shift_En),
		.D              (B_In[7:0]),

		.Shift_Out      (),	//@@ ????? is it ok to leave it with no value
		.Data_Out       (B)
	);

	reg_1 reg_X (
		.Clk            (Clk), 
		.Reset		    (Ld_B || Clr_),	//yes we do reset it when we load a new b or do consequitve mult

		.Shift_In       (1'b0), //never used
		.Load           (Ld_A_X), //this is loaded with A
		.Shift_En       (1'b0),	
		.D              (A_In[8]),	
		
		.Shift_Out      (x_0),	//we shouldnt drive one signal by 2 signals
		.Data_Out       ()
	);


endmodule

module reg_1(
	input  logic 		  Clk, 
	input  logic 		  Reset,
	input  logic 		  Shift_In, 
	input  logic 		  Load, 
	input  logic 		  Shift_En,
	input  logic	      D, 

	output logic 		  Shift_Out,
	output logic          Data_Out 
);
	logic Data_Out_d;

	always_comb
	begin

		if (Load) 
		begin
			Data_Out_d = D;
		end
		else if (Shift_En)
		begin

			Data_Out_d = Shift_In;
		end
		else
		begin
			Data_Out_d = Data_Out; // Required to avoid synthesis inferring a latch
		end

	end

	always_ff @(posedge Clk)
	begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
		 begin

			Data_Out <= 1'b0;
		 end
		 else 
		 begin
			Data_Out <= Data_Out_d;
		 end
	end

	assign Shift_Out = Data_Out;

endmodule

module reg_8 (
	input  logic 		  Clk, 
	input  logic 		  Reset,
	input  logic 		  Shift_In, 
	input  logic 		  Load, 
	input  logic 		  Shift_En,
	input  logic [7:0]    D, 

	output logic 		  Shift_Out,

	output logic [7:0] 	  Data_Out 
);


	logic [7:0] Data_Out_d;

	always_comb
	begin

		if (Load) 
		begin
			Data_Out_d = D;
		end
		else if (Shift_En)
		begin

			Data_Out_d = { Shift_In, Data_Out[7:1] };
		end
		else
		begin
			Data_Out_d = Data_Out; // Required to avoid synthesis inferring a latch
		end

	end

	always_ff @(posedge Clk)
	begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
		 begin

			Data_Out <= 8'h0;
		 end
		 else 
		 begin
			Data_Out <= Data_Out_d;
		 end
	end

	assign Shift_Out = Data_Out[0];

endmodule
