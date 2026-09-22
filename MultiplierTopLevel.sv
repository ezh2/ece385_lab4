//4-bit logic processor top level module
//for use with ECE 385 Fall 2023
//last modified by Satvik Yellanki


//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module multiplier_t_level (
	input  logic        Clk,     // Internal
	input  logic      	Reset_Load_Clear,   // Push button 0
	input  logic        Run, // Push button 1 (Execute)
	input  logic [7:0]  SW, // Switches input

	output logic [1:0]  LED, //display button press
	//HEX Output
	output logic [7:0]  hex_seg, // Hex display control
	output logic [3:0]  hex_grid, // Hex display control
	output logic [7:0]  Aval, //output of register A
	output logic [7:0]  Bval, //output of register B
	output logic 	    Xval //output of register X
); 

    //local logic variables go here

	//synchronized inputs
	logic Reset_Load_Clear_SH;
	logic Run_SH;
	logic [7:0] SW_Synced; 
	//end of synchronized inputs	

	//load and shift control signals
	logic       Ld_A;
	logic       Ld_B;
	logic       Ld_X;
	logic       newA;
	logic       newB;
	logic       newX;
	logic       Shift_En;
	//end of load and shift control signals

	//adder output
	logic       Sum;
	logic [7:0] A; 				
	logic [7:0] B; 				
	logic [7:0] X;
	//end of adder output		
	 
//We can use the "assign" statement to do simple combinational logic
	assign Aval = A;
	assign Bval = B;
	assign Xval = X;
	assign LED  = {Reset_Load_Clear_SH, Run_SH}; //Concatenate is a common operation in HDL

//Instantiation of modules here
	register_unit reg_unit (
		.Clk        (Clk),
		.Reset      (Reset_Load_Clear_SH),

		.A_In       (newA),
		.B_In       (newB),
		.X_In       (newX),

		.Ld_A       (Ld_A),
		.Ld_B       (Ld_B),
		.Ld_X       (Ld_X),
		.Shift_En   (Shift_En),
		.D          ({1'b0, SW_Synced}),

		.A          (A),
		.B          (B),
		.X          (X)
	);

	// @@ probably done @@
	adder_9bit adder_unit (
		.A          (A),
		.S          (S), 
		.B        	(Bval), // passed in from register unit
		.sub          (), //passed in from control
		.sum       (Sum)
	);


	// @@@@@@ needs work @@@@@@@@@
	control control_unit ( 
		.Clk        (Clk),
		.Reset      (Reset_LOAD_Clear_SH),

		.Execute    (Run_SH),

		.Shift_En   (Shift_En),
		.Ld_A       (Ld_A),
		.Ld_B       (Ld_B) 
	);


// @@@@@@ everything below this line is for HEX and sync of inputs, should work @@@@@@@

//When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
	HexDriver HexA (
		.clk        (Clk),
		.reset      (Reset_LOAD_Clear_SH),

		.in         ({A[7:4], A[3:0], B[7:4], B[3:0]}), //@@@ changed to 8 bits @@@
		.hex_seg    (hex_seg),
		.hex_grid   (hex_grid)
	);
                            
//Input synchronizers required for asynchronous inputs (in this case, from the switches)
//These are array module instantiations
//Note: S stands for SYNCHRONIZED, H stands for active HIGH, in addition in synthesis they are also debounced

	sync_debounce button_sync [3:0] (
		.Clk  (Clk),

		.d    ({Reset_Load_Clear, Run}),
		.q    ({Reset_LOAD_Clear_SH, Run_SH})
	);


	sync_debounce SW_sync [7:0] (
		.Clk  (Clk), 

		.d    (SW), 
		.q    (SW_Synced)
	);
	  
endmodule
