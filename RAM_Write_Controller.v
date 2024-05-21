`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 03:12:02
// Design Name: 
// Module Name: RAM_Write_Controller
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


module RAM_Write_Controller(
    input clk,
    input rst_n,
    input store_C,
    input finish,
    input [1055:0] dataCf_out,
    output store_C_ready
    // output [1023:0] DINA,
    // output [4:0] ADDRA,
    // output WEA,
    // output ENA          
    );
    //重要的事件是store_C信号输入，返回store_C_ready信号,需要一个计数器控制store_C_ready的拉高时间,这个行为发送99次，33次，66次，99次做特殊处理
    //一旦finish信号输入，模块内所有动作结束

    //////////////////////////////变量定义/////////////////////////////////
    ////////////内部寄存器变量/////////////////////////////////////////////
    ////u_Bram_Onput的输入输出端口//////////////////////////////////////////////////////////////
    reg [4:0] w_addr; //写地址（存储阵列深度为64）
    reg [1023:0] w_data; //写数据
    reg wea;//口A写使能
    reg [4:0] r_addr;//读地址
    wire [1023:0] r_data;//读数据
    ///对store_C信号进行检测的标志位寄存器////
    reg store_C_last,
        store_C_rising_edge;
    ///延迟一个clock保证O_store_C_ready拉高和BRAM中的数据真正写入时刻一致/////
    reg flag_delay_ready;
    ///标志只改变addr一次的寄存器////
    reg flag_change_addr_once;
    ////计数器/////////////////////////////////////////////////////////////
    integer i;
    reg [2:0] count_for_store_C_ready;//计数store_C_ready信号拉高时钟周期的计数器
    reg [6:0] count_for_write_row_C;//计数取数矩阵A对应行次数的计数器（三个模式，fetch_A共拉高99次，这时需要7位宽）
    ///////////连接到输出端口的寄存器型变量/////////////////////////////////
    reg O_store_C_ready;

    //处理store_C信号上升沿的逻辑
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            //捕捉store_C上升沿
            store_C_last <= 1'b0;
            store_C_rising_edge <= 1'b0;
            //计数store_C_ready拉高clock数
            count_for_store_C_ready <= 3'd0;
            //计数store_C上升沿个数
            count_for_write_row_C <= 7'd0;
            //写使能
            wea <= 1'b0;
            //写完成
            O_store_C_ready <= 1'b0;
            //写地址
            w_addr <= 5'd0;
            //延迟一个时钟周期的寄存器变量
            flag_delay_ready <= 1'b0;
            //改变w_addr一次的寄存器
            flag_change_addr_once <= 1'b0;
        end else begin
            //处理store_C上升沿
            store_C_last <= store_C;
            store_C_rising_edge <= (!store_C_last&&store_C);
            
            //把事件分开来看，store_C到来时，先计数，后写BRAM，再拉高store_C_ready信号3个时钟周期，finish信号不用管，因为count_for_write_row_C计数器计数到99就意味着已经结束了
            if(store_C_rising_edge) begin
                //有效写数是发生在count_for_write_row_C增加之后发生的还是，count_for_write_C之前发生的
                //实际情况是store_C信号上升沿以一个很缓慢的速度到来（间隔clockS数很多，有很长的时间)
                if(count_for_write_row_C == 7'd99) begin
                    count_for_write_row_C <= 7'd1;
                end else begin
                    count_for_write_row_C <= count_for_write_row_C + 1'b1;
                end
                wea <= 1'b1;//写使能拉高
                // count_for_write_row_C <= count_for_write_row_C + 1'b1;
                //  延迟一个clock，让O_store_C_ready拉高
            end

            if(wea) begin
                if(!flag_change_addr_once)begin
                    //对写地址，写数据做出部署，对w_addr和w_data进行逻辑设计
                    if((count_for_write_row_C == 7'd1)||(count_for_write_row_C == 7'd34)||(count_for_write_row_C == 7'd67)) begin //清零，从RAM头开始写
                        w_addr <= 5'd0;
                        w_data <= dataCf_out [1023:0];
                        flag_delay_ready <= 1'b1;
                        flag_change_addr_once <= 1'b1;
                    end else if((count_for_write_row_C == 7'd33)||(count_for_write_row_C == 7'd66)||(count_for_write_row_C == 7'd99)) begin
                        w_addr <= w_addr;
                        w_data <= w_data;
                        flag_delay_ready <= 1'b1;
                        flag_change_addr_once <= 1'b1;
                    end else begin
                        w_addr <= w_addr + 1'b1;
                        w_data <= dataCf_out [1023:0];
                        flag_delay_ready <= 1'b1;
                        flag_change_addr_once <= 1'b1;
                    end
                end
            end

            if(flag_delay_ready) begin
                O_store_C_ready <= 1'b1;
                if(count_for_store_C_ready < 3'd4) begin
                    count_for_store_C_ready <= count_for_store_C_ready + 1'b1;
                end else begin
                    count_for_store_C_ready <= 3'd0;
                    O_store_C_ready <= 1'b0;
                    flag_delay_ready <= 1'b0;
                    //关闭写使能
                    wea <= 1'b0;
                    flag_change_addr_once <= 1'b0;
                end
            end
            
        end
    end
    


    Bram_Output your_instance_name (
        .clka(clk),    // input wire clka
        .wea(wea),      // input wire [0 : 0] wea
        .addra(w_addr),  // input wire [4 : 0] addra
        .dina(w_data),    // input wire [1023 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(r_addr),  // input wire [4 : 0] addrb
        .doutb(r_data)  // output wire [1023 : 0] doutb
    );
        
    assign store_C_ready = O_store_C_ready;

endmodule
