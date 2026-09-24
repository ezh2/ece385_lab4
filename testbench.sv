module testbench(); //even though the testbench doesn't create any hardware, it still needs to be a module

    timeunit 10ns; // This is the amount of time represented by #1 
    timeprecision 1ns;

	// These signals are internal because the processor will be 
	// instantiated as a submodule in testbench.
    logic Clk;
    logic Reset_Load_Clear;
    logic Run;
    logic [7:0] SW;
    logic [1:0] LED;
    logic [7:0] hex_seg;
    logic [3:0] hex_grid;
    logic [7:0] Aval;
    logic [7:0] Bval;
    logic Xval;

    multiplier_t_level dut (
        .Clk(Clk),
        .Reset_Load_Clear(Reset_Load_Clear),
        .Run(Run),
        .SW(SW),
        .LED(LED),
        .hex_seg(hex_seg),
        .hex_grid(hex_grid),
        .Aval(Aval),
        .Bval(Bval),
        .Xval(Xval)
    );

    initial begin
        Clk = 1'b0;
    end

    always begin
        #5 Clk = ~Clk; // delay 5 time units
    end

    initial begin
        Reset_Load_Clear = 1'b0;
        Run = 1'b0; // Initialize Run to 0
        SW = 8'h00; // Initialize SW to 0

        repeat (3) @(posedge Clk);

        // Test 1: 8-bit multiplication, 7 x -59 = 15 (+,-)
        SW = 8'b00000111; // Load 7
        repeat (1) @(posedge Clk);
        Reset_Load_Clear = 1'b1; // press Reset_Load_Clear to load the first operand
        repeat (5) @(posedge Clk);
        Reset_Load_Clear = 1'b0; // release Reset_Load_Clear
        repeat (2) @(posedge Clk);

        // Load second operand
        SW = 8'b11000101; // Load -59
        repeat (1) @(posedge Clk);
        Run = 1'b1; // press Run
        repeat (5) @(posedge Clk);
        Run = 1'b0; // release Run

        // Let the multiplier run for several cycles to make sure the computation is complete
        repeat (20) @(posedge Clk);

        // Check the final 8-bit result is correct for 7 x -59 = 1111111001100011
        assert (Bval == 8'b01100011) else $error("Unexpected Bval for first multiply: expected 01100011, got %b", Bval);
		assert (Aval == 8'b11111110) else $error("Unexpected product for first multiply: expected 11111110, got %b", Aval);
        $display ("test 1 successful");
        // Test 2: 8-bit multiplication, -10 x 30 = -300 11111110 11010100 (-,+)
        SW = 8'b11110110; // Load -10
        repeat (1) @(posedge Clk);
        Reset_Load_Clear = 1'b1; // press Reset_Load_Clear to load the first operand
        repeat (5) @(posedge Clk);
        Reset_Load_Clear = 1'b0; // release Reset_Load_Clear
        repeat (2) @(posedge Clk);

        SW = 8'b00011110; // Load 30
        repeat (1) @(posedge Clk);
        Run = 1'b1; // press Run
        repeat (5) @(posedge Clk);
        Run = 1'b0; // release Run

        repeat (25) @(posedge Clk);

        assert (Bval == 8'b11010100) else $error("Unexpected Bval for second multiply: expected 11010100, got %h", Bval);
        assert (Aval == 8'b11111110) else $error("Unexpected product for second multiply: expected 11111110, got %h", Aval);
        $display ("test 2 successful");

		// Test 3: 8-bit multiplication, 10 x 30 = 300 00000001 00101100 (+,+)
		SW = 8'b00001010; // Load 10
        repeat (1) @(posedge Clk);
        Reset_Load_Clear = 1'b1; // press Reset_Load_Clear to load the first operand
        repeat (5) @(posedge Clk);
        Reset_Load_Clear = 1'b0; // release Reset_Load_Clear
        repeat (2) @(posedge Clk);

        SW = 8'b00011110; // Load 30
        repeat (1) @(posedge Clk);
        Run = 1'b1; // press Run
        repeat (5) @(posedge Clk);
        Run = 1'b0; // release Run

        repeat (25) @(posedge Clk);

        assert (Bval == 8'b00101100) else $error("Unexpected Bval for third multiply: expected 00101100, got %h", Bval);
        assert (Aval == 8'b00000001) else $error("Unexpected product for third multiply: expected 00000001, got %h", Aval);
        $display ("test 3 successful");

		// Test 4: 8-bit multiplication, -10 x -30 = 300 00000001 00101100 (-,-)
		SW = 8'b11110110; // Load -10
        repeat (1) @(posedge Clk);
        Reset_Load_Clear = 1'b1; // press Reset_Load_Clear to load the first operand
        repeat (5) @(posedge Clk);
        Reset_Load_Clear = 1'b0; // release Reset_Load_Clear
        repeat (2) @(posedge Clk);

        SW = 8'b11100010; // Load -30
        repeat (1) @(posedge Clk);
        Run = 1'b1; // press Run
        repeat (5) @(posedge Clk);
        Run = 1'b0; // release Run

        repeat (25) @(posedge Clk);

        assert (Bval == 8'b00101100) else $error("Unexpected Bval for fourth multiply: expected 00101100, got %h", Bval);
        assert (Aval == 8'b00000001) else $error("Unexpected product for fourth multiply: expected 00000001, got %h", Aval);
        $display ("test 4 successful");

        $finish();
    end

endmodule