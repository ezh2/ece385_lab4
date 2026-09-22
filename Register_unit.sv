module register_unit (
    input  logic        Clk,
    input  logic        A_In,
    input  logic        B_In,
    input  logic        Run, //in this case, run is the same as load_a
    input  logic        Reset_Load_Clear, //in this case, Reset_Load_Clear is the same as load_b
    input  logic        Shift_En,
	input  logic        SW, //switch input


    output logic        A_out,
    output logic        B_out,

    output logic [7:0]  A,
    output logic [7:0]  B,
	output logic        EXE
);
	logic [7:0]  A_content, // the A data to be loaded into the registers
    logic [7:0]  B_content, // the B data to be loaded into the registers

	always_ff @(posedge clk) 
	begin
		if (Reset_Load_Clear) //when load_b_reset_A is press
		begin
            B_content <= SW;
            A_content <= '0;
			regX <= 1'b0;
			EXE <= 1'b0; //execute is set to 0 when load_b_reset_A is pressed
		end
        else if (Run) //when run is press
		begin
            A_content <= SW;
			EXE <= 1'b1; //execute is set to 1 when run is pressed
        end
        else //when no button is press
		begin
            A_content <= A_content;
            B_content <= B_content;
			regX <= regX;
			EXE <= EXE;
        end
    end

	    reg_8 reg_A (
        .Clk       (Clk),
        .Reset     (Reset),

        .Shift_In  (A_In),
        .Load      (Run),
        .Shift_En  (Shift_En),
        .D         (A_content),

        .Shift_Out (A_out),
        .Data_Out  (A)
    );

    reg_8 reg_B (
        .Clk       (Clk),
        .Reset     (Reset),

        .Shift_In  (B_In),
        .Load      (Reset_Load_Clear),
        .Shift_En  (Shift_En),
        .D         (B_content),

        .Shift_Out (B_out),
        .Data_Out  (B)
    );

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
