module tb_top_ram;

// top_ram Parameters
parameter PERIOD  = 10;
// FSM_for_Baseline_with_Fault_Tolerance_Logic Parameters
parameter   IDLE = 10'b00000_00001,
            Buffer_row_A = 10'b00000_00010,
            Multiply_accumulate = 10'b00000_00100,
            Write_row_C =10'b00000_01000,
            Buffer_row_A_Correct1 = 10'b00000_10000,
            Multiply_Accumulate_Correct1 = 10'b00001_00000,
            Write_row_C_Correct1 = 10'b00010_00000,
            Buffer_row_Correct2 = 10'b00100_00000,
            Multiply_Accumulate_Correct2 = 10'b01000_00000,
            Write_row_C_Correct2 = 10'b10000_00000;

// top_ram Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;

// top_ram Outputs



initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

initial
    begin
        #(PERIOD*2) rst_n  =  1;
    end

top_ram  u_top_ram (
    .clk                     ( clk     ),
    .rst_n                   ( rst_n   )
);

//为了方便在仿真波形图中查看，使用字符串描述状
reg [223:0] state_name;
always@(*)
    begin
        case(u_top_ram.u_top.u_FSM_for_Baseline_with_Fault_Tolerance_Logic.state)
            IDLE:
                state_name = "IDLE";
            Buffer_row_A:
                state_name = "Buffer_row_A";
            Multiply_accumulate:
                state_name = "Multiply_Accumulate";
            Write_row_C:
                state_name = "Write_row_C";
            Buffer_row_A_Correct1:
                state_name = "Buffer_row_A_Correct1";
            Multiply_Accumulate_Correct1:
                state_name = "Multiply_Accumulate_Correct1";
            Write_row_C_Correct1:
                state_name = "Write_row_C_Correct1";
            Buffer_row_Correct2:
                state_name = "Buffer_row_Correct2";
            Multiply_Accumulate_Correct2:
                state_name = "Multiply_Accumulate_Correct2";
            Write_row_C_Correct2:
                state_name = "Write_row_C_Correct2";
            default :
            state_name = "IDLE";
        endcase
    end

initial
    begin
        # 1000
        $finish;
    end

endmodule