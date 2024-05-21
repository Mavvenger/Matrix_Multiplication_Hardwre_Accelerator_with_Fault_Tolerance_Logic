`timescale  1ns / 1ps

module tb_RAM_Read_Controller;

// RAM_Read_Controller Parameters
parameter PERIOD  = 10;


// RAM_Read_Controller Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   fetch_A                              = 0 ;
reg   fetch_B                              = 0 ;
reg   finish                               = 0 ;

// RAM_Read_Controller Outputs
wire  start                                ;
wire  [1023:0]  data_in                    ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

RAM_Read_Controller  u_RAM_Read_Controller (
    .clk                     ( clk               ),
    .rst_n                   ( rst_n             ),
    .fetch_A                 ( fetch_A           ),
    .fetch_B                 ( fetch_B           ),
    .finish                  ( finish            ),

    .start                   ( start             ),
    .data_in                 ( data_in  [1023:0] )
);

//  `define Verify_A 1'b0;

initial 
begin
    `ifdef Verify_A
    # 725
    fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    # 20 fetch_A = 0;
    # 20 fetch_A = 1;
    `else 
    # 735 fetch_A = 1'b1;//如果测试count_for_fetch_A=1的情况下，添上248至249两行代码，否则，删除248，249两行代码，将250行代码的延迟值改为735
    # 30  fetch_A = 1'b0;
    # 40 fetch_B = 1'b1;
    # 100 fetch_B = 1'b0;
    // # 2500 fetch_B = 1'b1;
    // # 100 fetch_B = 1'b0;
    `endif 
end

initial
begin
    # 300
    $finish;
end

endmodule