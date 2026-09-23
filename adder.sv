//Correct as of 9/23 5:25 pm

module adder( 
	input  logic  [7:0] A, //8bit input A
    input  logic        X,
    input  logic  [7:0] S, //8bit input S
    input  logic  [7:0] B, //8bit input B

    input  logic        sub, //passed in from control, telling me whether we need to subtract 
      input  logic      add, //passed in from control, telling me whether we need to add
	output logic  [8:0] sum //9bit output Sum

    //output logic load_A     //this signal doesnt come from here... we load auto with the next clock edge which will be after the sum is ready
); 
		 //deleted the assign of load A cause thats not something the adder should worry about
    // do the sign extention
    logic [8:0] A_extended;
    assign A_extended = {X, A};
    logic [8:0] S_extended;
    assign S_extended = {S[7], S};
    //

    //local vars
    logic cin;
	logic c4; // carry out of the first 4-bit block
    logic c8; // carry out of the second 4-bit block
    logic sum8_0, sum8_1; // sum of the 9th bit for both possible carry-in values
    logic cout8_0, cout8_1; // carry out of the 9th bit for both possible carry-in values
    logic cout; // final carry out of the 9th bit
    
    //deals with subtraction case
    logic [8:0] ones;
    assign ones = 9'b111111111;
    logic [8:0] new_S;

    // check if we need to consider other things other than sub=1 when deciding whether it's a addtion or subtraction operation
    always_comb 
    begin
        if (sub & B[0]) //we actually need to sub
        begin
            new_S = ones ^ S_extended; // if sub=1, then we will subtract S from A, so we need to take the 2's complement of S;
            cin = 1'b1; // this makes new_S 2's complement of S (1 XOR S +1)
        end

        // needed to add this else if statement cause the last else will make us add add 00000 when b0=1 and add=1

         else if (add & B[0])
        begin
            new_S = S_extended; //add S only when Add=1 and B[0]=1
            cin = 1'b0;
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
        .s    (sum[3:0]), 
        .cout (c4) 
    ); 
     
    select_4bit second4 ( 
    	.a    (A_extended[7:4]), 
    	.b    (new_S[7:4]), 
    	.s    (sum[7:4]), 
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


//@@@ u never made the actual ripple addition copies assuming cin=0 or 1...
// note: the ripple adder file will need to be added so this can even work

    ripple_adder_4bits add_cin0 (
    .a    (a),
    .b    (b),
    .cin  (1'b0),
    .s    (sum0),
    .cout (cout0)
);
ripple_adder_4bits add_cin1 (
    .a    (a),
    .b    (b),
    .cin  (1'b1),
    .s    (sum1),
    .cout (cout1)
);

//mux is condition ? value if condition is 1 : value if condition is 0 
//mux will give s and cout thier vals accordin to cin 
assign s    = cin ? sum1  : sum0; 
assign cout = cin ? cout1 : cout0; 
 
endmodule 
