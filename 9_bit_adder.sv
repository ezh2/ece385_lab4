// @@@ needs changing, i dont have access to B, I am adding S and A
module 9_bit_select_adder ( 
	input  logic  [7:0] A, //9bit input A
    input  logic  [7:0] S, //9bit input B 
	input  logic        cin, 
    input  logic        sub, //passed in from control, telling me whether we need to subtract or add. sub = 1 = subtract, sub = 0 = add
    ///input  logic        b0, //passed in from top level, which is the original MSB of B.
	 
	output logic  [8:0] sum, //9bit output S
); 
		 
    // do the sign extention
    logic [8:0] A_extended;
    logic [8:0] S_extended;
    A_extended = {A[7], A};
    S_extended = {S[7], S};
    //

    //local vars
	logic c4; // carry out of the first 4-bit block
    logic c8; // carry out of the second 4-bit block
    logic sum8_0, sum8_1; // sum of the 9th bit for both possible carry-in values
    logic cout8_0, cout8_1; // carry out of the 9th bit for both possible carry-in values
    logic cout; // final carry out of the 9th bit
    
    //deals with subtraction case
    //logic  sub, //if sub=1, then we will subtract b from a, if sub=0, then we will add a and b
    //assign sub = lastBit & b[0];

    logic [8:0] ones;
    assign ones = 9'b111111111;
    logic [8:0] new_S;

    // check if we need to consider other things other than sub=1 when deciding whether it's a addtion or subtraction operation
    always_comb 
    begin
        if (sub) 
        begin
            new_S = ones ^ S; // if sub=1, then we will subtract S from A, so we need to take the 2's complement of S;
            // @@@ is thus valid way to solve the latch issue? @@@
            cin = 1'b1; // this makes new_S 2's complement of S (1 XOR S +1)
        end

        else 
        begin
            new_S = 9'b0; // if sub=0, nothing should be added to it, so we should just set new_S to 0
            cin = 1'b0; // if sub=0,  nothing should be added to it, so we should just set carry-in to 0
        end 
    end
    //end of subtraction dealing

    select_4bit first4 ( 
        .a    (A_extended[3:0]), 
        .b    (new_S[3:0]), 
        .cin  (cin), 
        .s    (S_extended[3:0]), 
        .cout (c4) 
    ); 
     
    select_4bit second4 ( 
    	.a    (A_extended[7:4]), 
    	.b    (new_S[7:4]), 
    	.s    (S_extended[7:4]), 
    	.cout (c8), 
    	.cin  (c4) 
    ); 

    // only for the 9th bit
    assign sum8_0  = A_extended[8] ^ new_S[8];
    assign cout8_0 = A_extended[8] & new_S[8];
    assign sum8_1  = A_extended[8] ^ new_S[8] ^ 1'b1;
    assign cout8_1 = A_extended[8] | new_S[8];
    assign sum[8]    = c8 ? sum8_1  : sum8_0;
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