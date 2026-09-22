module Adder( 
	input  logic  [8:0] a, //9bit input A
    input  logic  [8:0] b, //9bit input B 
	input  logic         cin, 
	
	output logic  [8:0] s, //9bit output S
	output logic         cout //final carry out
); 
		 
	logic c4; // carry out of the first 4-bit block
    logic c8; // carry out of the second 4-bit block
    logic sum8_0, sum8_1; // sum of the 9th bit for both possible carry-in values
    logic cout8_0, cout8_1; // carry out of the 9th bit for both possible carry-in values
         
    select_4bit first4 ( 
        .a    (a[3:0]), 
        .b    (b[3:0]), 
        .cin  (cin), 
        .s    (s[3:0]), 
        .cout (c4) 
    ); 
     
    select_4bit second4 ( 
    	.a    (a[7:4]), 
    	.b    (b[7:4]), 
    	.s    (s[7:4]), 
    	.cout (c8), 
    	.cin  (c4) 
    ); 

    // only for the 9th bit
    assign sum8_0  = a[8] ^ b[8];
    assign cout8_0 = a[8] & b[8];
    assign sum8_1  = a[8] ^ b[8] ^ 1'b1;
    assign cout8_1 = a[8] | b[8];
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
     
//then we call 4 bits adder twice for each possabillty of c in  
ripple_adder_4bits add_assuming_0 ( 
    .a    (a), 
    .b    (b), 
    .cin  (0), 
    .s    (sum0), 
    .cout (cout0) 
); 
ripple_adder_4bits add_assuming_1 ( 
    .a    (a), 
    .b    (b), 
    .cin  (1), 
    .s    (sum1), 
    .cout (cout1) 
); 
//mux is condition ? value if condition is 1 : value if condition is 0 
//mux will give s and cout thier vals accordin to cin 
assign s    = cin ? sum1  : sum0; 
assign cout = cin ? cout1 : cout0; 
 
endmodule 


 
