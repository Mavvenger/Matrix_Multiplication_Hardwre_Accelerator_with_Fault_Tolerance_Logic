`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/12 20:38:06
// Design Name: 
// Module Name: top_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_ram(
    input clk,
    input rst_n
    );

    wire RRCMMHAFTC_start,
         MMHAFTCRWC_finish,
         MMHAFTCRWC_store_C,
         RWCMMHAFTC_store_C_ready,
         MMHAFTCRRC_fetch_A,
         MMHAFTCRRC_fetch_B;
    wire [1023:0] RRCMMHAFTC_data_in;
    wire [1055:0] MMHAFTCRWC_dataCf_out;

    top u_top (
        //input
        .start(RRCMMHAFTC_start),
        .clk(clk),
        .rst_n(rst_n),
        .store_C_ready(RWCMMHAFTC_store_C_ready),
        .data_in(RRCMMHAFTC_data_in[1023:0]),
        //output
        .dataCf_out(MMHAFTCRWC_dataCf_out[1055:0]),
        .fetch_A(MMHAFTCRRC_fetch_A),
        .fetch_B(MMHAFTCRRC_fetch_B),
        .store_C(MMHAFTCRWC_store_C),
        .finish(MMHAFTCRWC_finish)
    );

    RAM_Read_Controller u_RAM_Read_Controller(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .fetch_A(MMHAFTCRRC_fetch_A),
        .fetch_B(MMHAFTCRRC_fetch_B),
        .finish(MMHAFTCRWC_finish),
        //output
        .start(RRCMMHAFTC_start),
        .data_in(RRCMMHAFTC_data_in[1023:0])
    );

    RAM_Write_Controller u_RAM_Write_Controller(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .store_C(MMHAFTCRWC_store_C),
        .finish(MMHAFTCRWC_finish),
        .dataCf_out(MMHAFTCRWC_dataCf_out[1055:0]),
        //output
        .store_C_ready(RWCMMHAFTC_store_C_ready)
    );

endmodule
