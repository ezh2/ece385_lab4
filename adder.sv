//under editing 6:24

module adder( 
	input  logic  [7:0] A, //8bit input A
    input  logic  [7:0] S, //8bit input S
    input  logic  [7:0] B, //8bit input B
    input logic   x_0,

    input  logic        sub, //passed in from control, telling me whether we need to subtract 
    input  logic      add, //passed in from control, telling me whether we need to add
	output logic  [8:0] sum //9bit output Sum

    //output logic load_A     //this signal doesnt come from here... we load auto with the next clock edge which will be after the sum is ready
); 
		 //deleted the assign of load A cause thats not something the adder should worry about
         
    // do the sign extention
    logic [8:0] A_extended;
    assign A_extended = {x_0, A};       // maybe check this?
    logic [8:0] S_extended;
    assign S_extended = {S[7], S};
    //

    //local vars
    logic cin;  // 2's compement thing
    logic cout; // final carry out of the 9th bit
    
    //deals with subtraction case
    logic [8:0] ones;
    assign ones = 9'b111111111;
    logic [8:0] new_S;

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

    
    //CLA
    //top level P, G, and C
	logic [1:0] P; // P0, P4
	logic [1:0] G; // G0, G4
	logic [1:0] C; // C4, C8

	CLA_8bit carry_unit (
		.cin(cin),
		.P(P[1:0]), // P0, P4
		.G(G[1:0]), // G0, G4
		.C(C[1:0]) //C4, C8
	);

	CLA_4bit cla_first4 (
		.a(A_extended[3:0]), // a0, a1, a2, a3 inputted to first 4-bit CLA
		.b(new_S[3:0]), // b0, b1, b2, b3 inputted to first 4-bit CLA
		.cin(cin), // C0 inputted to first 4-bit CLA
		.s(sum[3:0]), // s0, s1, s2, s3 outputted from first 4-bit CLA
		.P(P[0]), // P0 catches the P from first 4-bit CLA
		.G(G[0]) // G0 catches the G from first 4-bit CLA
	);
	CLA_4bit cla_second4 (
		.a(A_extended[7:4]), 
		.b(new_S[7:4]), 
		.cin(C[0]), // C4
		.s(sum[7:4]), 
		.P(P[1]), // P4 
		.G(G[1]) // G4
	);

    // manually doing CLA for the 9th bit @@@ dk if this is right, please check @@@
    logic sum8_xor;
    assign sum8_xor = A_extended[8] ^ new_S[8];
    assign sum[8]   = sum8_xor ^ C[1];
    assign cout     = (A_extended[8] & new_S[8]) | (C[1] & sum8_xor);

endmodule


module CLA_4bit(
	input logic [3:0] a,
	input logic [3:0] b,
	input logic		    cin,

	output logic [3:0] s,
	output logic P, // high-level propagate (can be P0, P4, P8, or P12)
	output logic G // high-level generate (can be G0, G4, G8, or G12)
);

// low-level (for each 4-bit only) p, g, and c
	logic [3:0] p; // propagate
	logic [3:0] g; // generate
	logic [3:0] c; // carry

	assign p = a ^ b; // propagate is A XOR B
	assign g = a & b; // generate is A AND B

	// low-level carry logic c1 based on c0, c2 based on c1, and c3 based on c2...
	assign c[0] = cin;
	// c1 = g0 OR (p0 AND c0)
    assign c[1] = g[0] | (p[0] & cin); 
	// c2 = g1 OR (p1 AND g0) OR (p1 AND p0 AND c0)
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin); 
	// c3 = g2 OR (p2 AND g1) OR (p2 AND p1 AND g0) OR (p2 AND p1 AND p0 AND c0)
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])| (p[2] & p[1] & p[0] & cin); 

	assign s = p ^ c; // sum is p XOR c
	assign P = p[3] & p[2] & p[1] & p[0]; // high-level propagate = p3 AND p2 AND p1 AND p0
	assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]); // high-lelve generate = g3 OR (p3 AND g2) OR (p3 AND p2 AND g1) OR (p3 AND p2 AND p1 AND g0)

endmodule

module CLA_8bit(
	input logic		    cin, //c0
	input logic [1:0] P, //P0, P4
	input logic [1:0] G, //G0, G4
	output logic [1:0] C //C4, C8
);

//C4 = G0 OR (P0 AND C0)
	assign C[0] = G[0] | (P[0] & cin);
//C8 = G1 OR (P1 AND G0) OR (P1 AND P0 AND C0)
	assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & cin);
	
endmodule
