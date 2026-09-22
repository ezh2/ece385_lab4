module load_reg #(
    parameter DATA_WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 reset,
    input  logic                 load_button,    // press once: load switch into B, clear A
    input  logic                 execute_button, // press after: load switch into A
    input  logic [DATA_WIDTH-1:0] S,

    output logic [DATA_WIDTH-1:0] regA,
    output logic [DATA_WIDTH-1:0] regB
);

    always_ff @(posedge clk) 
	begin
		if (load_button) //when load_b_reset_A is press
		begin
            regB <= S;
            regA <= '0;
        end
        else if (execute_button) //when exe is press
		begin
            regA <= S;
        end
        else //when no button is press
		begin
            regA <= regA;
            regB <= regB;
        end
    end

endmodule
