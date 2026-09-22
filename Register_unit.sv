module register_unit (
	input  logic        Clk, 
	input  logic        Reset,
	input  logic        A_In,
	input  logic        B_In,
	input  logic        X_In,
	

	input  logic        Ld_A, // = to run signal
	input  logic        Ld_B, // = to load_B clear A
	input  logic		Ld_X,  // not sure if we need this
	input  logic        Shift_En,

	input  logic [8:0]  D, 

	output logic [7:0]  A,
	output logic [7:0]  B,
	output logic        X
);

	logic Shift_Out_A;

	reg_8 reg_A (
		.Clk            (Clk), 
		.Reset          (Reset),

		.Shift_In       (A_In), 
		.Load           (Ld_A), 
		.Shift_En       (Shift_En),
		.D              (D[0:7]),

		.Shift_Out      (Shift_Out_A),
		.Data_Out       (A)
	);

	reg_8 reg_B (
		.Clk            (Clk), 
		.Reset          (Reset),

		.Shift_In       (Shift_Out_A), 
		.Load           (Ld_B), 
		.Shift_En       (Shift_En),
		.D              (D[0:7]),

		.Shift_Out      (),
		.Data_Out       (B)
	);

	reg_1 reg_X (
		.Clk            (Clk), 
		.Reset          (Reset),

		.Shift_In       (X_In), 
		.Load           (Ld_X), 
		.Shift_En       (Shift_En),
		.D              (D[8]),

		.Shift_Out      (),
		.Data_Out       (X)
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
