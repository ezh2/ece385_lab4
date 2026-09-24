//Correct as of 9/23 6 pm

//4-bit logic processor top level module
//for use with ECE 385 Fall 2023
//last modified by Satvik Yellanki

// 1- top level will to check b[0] to either give the adder  0 or s as inpu
// 2 -pass b to the adder so in thh adder we check whether to add or sub

//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module multiplier_t_level (
	input  logic        Clk,     // Internal
	input  logic      	Reset_Load_Clear,   // Push button 0
	input  logic        Run, // Push button 1 (Execute)
	input  logic [7:0]  SW, // Switches input

	//output logic [1:0]  LED, //display buttons press for Run and Reset_Load_Clear buttons
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

	//control signals 
	logic Clr_;       //clear a and x in clear state 
	logic Shift_En;   //shift xab right 
	logic Add;        //adder will add s if b[0]=1 
	logic Sub;        //adder will sub s 
	//end of control signals 
 
	//values in registers and adder 
	logic [8:0] sum;  //sum[8] goes to x and sum[7:0] goes to a 
	logic [7:0] A;    //register a 
	logic [7:0] B;    //register b / multiplier 
	logic x_0;        //register x 
	//end of registers and adder 

//We can use the "assign" statement to do simple combinational logic
	assign Aval = A;
	assign Bval = B;
	assign Xval = x_0;
	//assign LED  = {Reset_Load_Clear_SH, Run_SH}; //Concatenate is a common operation in HDL

//Instantiation of modules here

// $$ done and checked
	register_unit reg_unit (
		.Clk        (Clk),

		.A_In       (sum),
		.B_In       (SW_Synced),

        .Clr_       (Clr_),

		.Ld_A_X     (Add | Sub), //$$ u gotta understand why i did this
		.Ld_B       (Reset_Load_Clear_SH),//only case where we load it
		.Shift_En   (Shift_En),

		.A          (A),
		.B          (B),
		.x_0        (x_0)
	);

	// @@ probably done @@ no Unfortunately it has mistakes, im leaving it commented for your understanding
	// adder_9bit adder_unit (
	// 	.A          (A),
	// 	.x_0 		(x_0),
	// 	.S          (S), 
	// 	.B        	(Bval), // passed in from register unit
	// 	.sub        (Sub), //passed in from control
	// 	.sum        (Sum)
	// 	.load_A     (Ld_A),
	// );

    adder adder_unit (
		.A    (A),
		.x_0   (x_0),
		.S    (SW_Synced),
		.B    (B),

		.add  (Add),
		.sub  (Sub),

		.sum  (sum)
	);


	// @@@@@@ needs work @@@@@@@@@ $$$$$ work is done i belive
	control control_unit ( 
		.Clk        (Clk),
		.Reset_ClearA_LoadB (Reset_Load_Clear_SH),
		.Run        (Run_SH),

		.Clr_     	(Clr_),// we dont use clr_ld we use clr_ since it doesnt load anything just clears
		.Shift      (Shift_En),
		.Add        (Add),
		.Sub        (Sub)
	);
    	
//When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
	HexDriver HexA (
		.clk        (Clk),

		//.reset      (Reset_LOAD_Clear_SH), @@@@@@@@$$$$$$$$$$$$$$ is there a reason to why u have it as LOAD?
        .reset      (Reset_Load_Clear_SH),

		.in         ({A[7:4], A[3:0], B[7:4], B[3:0]}), //@@@ changed to 8 bits @@@
		.hex_seg    (hex_seg),
		.hex_grid   (hex_grid)
	);

//Input synchronizers required for asynchronous inputs (in this case, from the switches)
//These are array module instantiations
//Note: S stands for SYNCHRONIZED, H stands for active HIGH, in addition in synthesis they are also debounced

// @@@@@@@@@@@ we need to debounce 2 buttons only
	sync_debounce button_sync [1:0] (
		.clk  (Clk),
		.d    ({Reset_Load_Clear, Run}),
		.q    ({Reset_Load_Clear_SH, Run_SH})
	);


	sync_debounce SW_sync [7:0] (
		.clk  (Clk), 

		.d    (SW), 
		.q    (SW_Synced)
	);
endmodule 