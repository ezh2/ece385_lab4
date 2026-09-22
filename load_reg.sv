module load_reg #(
    parameter DATA_WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 RLC_button,    // press once: load switch into B, clear A
    input  logic                 run_button, // press after: load switch into A
    input  logic [DATA_WIDTH-1:0] S,

    output logic [DATA_WIDTH-1:0] regA,
    output logic [DATA_WIDTH-1:0] regB,
	output logic                  regX,
	output logic                  EXE //represents whether run have been pressed
);

    always_ff @(posedge clk) 
	begin
		if (RLC_button) //when load_b_reset_A is press
		begin
            regB <= S;
            regA <= '0;
			regX <= 1'b0;
			EXE <= 1'b0; //execute is set to 0 when load_b_reset_A is pressed
		end
        else if (run_button) //when run is press
		begin
            regA <= S;
			EXE <= 1'b1; //execute is set to 1 when run is pressed
        end
        else //when no button is press
		begin
            regA <= regA;
            regB <= regB;
			regX <= regX;
			EXE <= EXE;
        end
    end

endmodule
