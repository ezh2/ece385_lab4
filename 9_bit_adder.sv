module 9_bit_select_adder ( 
	input  logic  [8:0] a, //9bit input A
    input  logic  [8:0] b, //9bit input B 
	input  logic        cin, 
    input  logic        lastBit, //passed in from control, telling me whether we have reached the last bit
	 
	output logic  [8:0] s, //9bit output S
	output logic         cout //final carry out
); 
		 
	logic c4; // carry out of the first 4-bit block
    logic c8; // carry out of the second 4-bit block
    logic sum8_0, sum8_1; // sum of the 9th bit for both possible carry-in values
    logic cout8_0, cout8_1; // carry out of the 9th bit for both possible carry-in values
    
    //deals with subtraction case
    logic  sub, //if sub=1, then we will subtract b from a, if sub=0, then we will add a and b
    assign sub = lastBit & b[0];

    logic [8:0] ones;
    assign ones = 9'b111111111;
    logic [8:0] new_b;

    // check if we need to consider other things other than sub=1 when deciding whether it's a addtion or subtraction operation
    always_comb 
    begin
        if (sub) 
        begin
            new_b = ones ^ b; // if sub=1, then we will subtract b from a, so we need to take the 2's complement of b;
            // @@@ is thus valid way to solve the latch issue? @@@
            cin = 1'b1; // this makes new_b 2's complement of b (1 XOR B +1)
        end

        else 
        begin
            new_b = 9'b0; // if sub=0, nothing should be added to it, so we should just set new_b to 0
            cin = 1'b0; // if sub=0,  nothing should be added to it, so we should just set carry-in to 0
        end 
    end
    //end of subtraction dealing

    select_4bit first4 ( 
        .a    (a[3:0]), 
        .b    (new_b[3:0]), 
        .cin  (cin), 
        .s    (s[3:0]), 
        .cout (c4) 
    ); 
     
    select_4bit second4 ( 
    	.a    (a[7:4]), 
    	.b    (new_b[7:4]), 
    	.s    (s[7:4]), 
    	.cout (c8), 
    	.cin  (c4) 
    ); 

    // only for the 9th bit
    assign sum8_0  = a[8] ^ new_b[8];
    assign cout8_0 = a[8] & new_b[8];
    assign sum8_1  = a[8] ^ new_b[8] ^ 1'b1;
    assign cout8_1 = a[8] | new_b[8];
    assign s[8]    = c8 ? sum8_1  : sum8_0;
    assign cout    = c8 ? cout8_1 : cout8_0;

endmodule
 

module select_4bit( 
    input logic  [3:0] a, 
    input logic  [3:0] b, 
    output logic [3:0] s, 
    output logic cout, 
    input logic cin 
); 
 
// results for both possible carry-in values 
    logic [3:0] sum0; //var will save sum if carry in =0 
    logic [3:0] sum1; //var will save sum if carry in =1 
    logic       cout0; //var will save carryout if carry in =0 
    logic       cout1; //var will save carryout if carry in =1 

//mux is condition ? value if condition is 1 : value if condition is 0 
//mux will give s and cout thier vals accordin to cin 
assign s    = cin ? sum1  : sum0; 
assign cout = cin ? cout1 : cout0; 
 
endmodule 