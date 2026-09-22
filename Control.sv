//this is correct as of 4:45, 9/22
//thi will have the fsm


module control (
	input  logic Clk,
	input  logic Reset_ClearA_LoadB,// does what the name suggest
    input  logic Run, //start the operation

    output logic Clr_Ld, //i dont know when to use clr_ld signal , is this about the registers?

    output logic Shift,// after we add
    output logic Add,// we add
    output logic Sub // we sub
);



//around 18 state? idle 8(add+ shift for each ),
//  i decided against using a counter

// Declare signals curr_state, next_state of type enum
// with enum values

	enum logic [4:0] { //18 states
		s_idle,
        Add_0, shift_0,
        Add_1, shift_1,
        Add_2, shift_2,
        Add_3, shift_3,
        Add_4, shift_4,
        Add_5, shift_5,
        Add_6, shift_6,
        sub_7, shift_7,
        s_clear, s_done
	} curr_state, next_state;

// Assign outputs based on state

	always_comb
	begin

		next_state = curr_state;	//required because I haven't enumerated all possibilities below. Synthesis would infer latch without this

		unique case (curr_state)

			s_idle :
			begin
				if (Run)
				begin
					next_state = Add_0;
				end
			end

        //clear will make it go to idle
			Add_0:   next_state = shift_0;
            shift_0: next_state = Add_1;

			Add_1:   next_state = shift_1;
            shift_1: next_state = Add_2;

			Add_2:   next_state = shift_2;
            shift_2: next_state = Add_3;

			Add_3:   next_state = shift_3;
            shift_3: next_state = Add_4;

			Add_4:   next_state = shift_4;
            shift_4: next_state = Add_5;

			Add_5:   next_state = shift_5;
            shift_5: next_state = Add_6;

			Add_6:   next_state = shift_6;
            shift_6: next_state = sub_7;

			sub_7:   next_state = shift_7;
            shift_7: next_state = s_done;

            s_clear: next_state = s_idle;

			s_done :
			begin
				if (!Run)
				begin
					next_state = s_idle;
				end
			end

            default: next_state = s_idle;

		endcase
	end


	always_comb
	begin
	// Assign outputs based on ‘state’

        // $$$ im not sure of each signal for eaxch state ?
        // Clr_Ld is for the registers:
        // X = 0, A = 0, B = switches
        Clr_Ld = Reset_ClearA_LoadB;
        Shift  = 1'b0;
        Add    = 1'b0;
        Sub    = 1'b0;

		unique case (curr_state)

			s_idle:
			begin
                
                Shift  = 1'b0;
                Add    = 1'b0;
                Sub    = 1'b0;
                // all outputs stay 0
			end

            s_clear:
            begin
                // Registers were cleared/loaded when button was pressed.
                // Then this state goes to s_idle.
            end

			s_done:
			begin
                // all outputs stay 0; product stays in AB
			end

            Add_0, Add_1, Add_2, Add_3,
            Add_4, Add_5, Add_6:
			begin
                Add = 1'b1;
			end

            sub_7:
			begin
                Sub = 1'b1;
			end

            shift_0, shift_1, shift_2, shift_3,
            shift_4, shift_5, shift_6, shift_7:
			begin
                Shift = 1'b1;
			end

			default:
			begin
                // Keep default values
			end

		endcase
	end


// $$$ what do we need to latch into

	//updates flip flop, current state is the only one
	always_ff @(posedge Clk)
	begin
		if (Reset_ClearA_LoadB)
		begin
			curr_state <= s_clear;
		end
		else
		begin
			curr_state <= next_state;
		end
	end

endmodule
