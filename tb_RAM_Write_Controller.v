`timescale  1ns / 1ps

module tb_RAM_Write_Controller;

// RAM_Write_Controller Parameters
parameter PERIOD  = 10;


// RAM_Write_Controller Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   store_C                              = 0 ;
reg   finish                               = 0 ;
reg   [1055:0]  dataCf_out                 = 0 ;

// RAM_Write_Controller Outputs
wire  store_C_ready                        ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

RAM_Write_Controller  u_RAM_Write_Controller (
    //Inputs
    .clk                     ( clk                     ),
    .rst_n                   ( rst_n                   ),
    .store_C                 ( store_C                 ),
    .finish                  ( finish                  ),
    .dataCf_out              ( dataCf_out     [1055:0] ),
    //Output
    .store_C_ready           ( store_C_ready           )
);

initial begin
    # 30 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;
    # 100 store_C = 1'b1;
    # 30 store_C = 1'b0;

end

initial
begin
    # 1000
    $finish;
end

endmodule