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


module RAM_Read_Controller(
    input clk,
    input rst_n,
    input fetch_A,
    input fetch_B,
    input finish,
    //input [1023:0] DOUTB,
    //output [5:0] ADDRB,
    //output ENB,
    output start,
    output [1023:0] data_in
    );              
    //总体思路：内部产生数据往BRAM中写（使用位拼接操作符拼接对应的操作数{32'd1,32'd1,32'd1}），然后发出一个完成信号finish_generate_matrix，拉高start信号3个时钟周期，结合TestBench和控制器中的计数器进行代码编写
    //这个东西比较重要的事件是fetch_A和fetch_B,fetch_A对应一个计数器，fetch_B对应一个计数器,fetch_B拉高后又要子计数器，还算是使用fetch_B拉高后的第一个clk上升沿执行相关动作
    //还有比较重要的事件是接收finish信号的输入，一旦finish信号输入模块相关工作全部结束

    //////////////////////////////变量定义/////////////////////////////////
    ////////////内部寄存器变量/////////////////////////////////////////////
    ////u_Bram_Input的输入输出端口//////////////////////////////////////////////////////////////
    reg [5:0] w_addr; //写地址（存储阵列深度为64）
    reg [1023:0] w_data; //写数据
    reg wea;//口A写使能
    reg [5:0] r_addr;//读地址
    wire [1023:0] r_data;//读数据
    ///标志内部逻辑往BRAM中写数完成的寄存器///////////
    reg finish_generate_matrix;
    ///对fetch_A,fetch_B信号进行检测的标志位寄存器
    reg fetch_A_last,
        fetch_A_rising_edge;
    reg fetch_B_last,
        fetch_B_rising_edge;
    reg flag_first_fetch_B;
    ///取矩阵B的地址偏移量//////
    parameter offset_B = 32 ;
    ///标志从RAM中读矩阵B所有行的寄存器/////////////////////////
    reg flag_read_matrixB;
    ////计数器/////////////////////////////////////////////////////////////
    // integer i;
    reg [2:0] count_for_start;//计数strat信号拉高时钟周期的计数器
    reg [6:0] count_for_fetch_A;//计数取数矩阵A对应行次数的计数器（三个模式，fetch_A共拉高99次，这时需要7位宽）
    reg [5:0] count_for_Br_row;//计数当前取矩阵B第几行的计数器
    reg [5:0] interval_cnt;//拉开吐出矩阵B对应行数据的时间间隔，一定条件下r_addr保持，另外条件下r_addr自增
    ///////////连接到输出端口的寄存器型变量/////////////////////////////////
    reg O_start;


    //复位是让电路恢复到最初始的最安全的工作状态，初始化是让电路某些部分进入初值部分，工作是电路正常工作
    //Bram写数逻辑,内部逻辑生成数据往Bram IP中写
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            w_addr <= 6'd0;
            // w_data <= 1024'd1;
            w_data <= {32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,
                       32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,
                       32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,
                       32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1};
            finish_generate_matrix <= 1'b0;
        end else begin
            if(wea) begin
                
                if(w_addr < 6'd63) begin
                    w_addr <= w_addr + 1'b1;
                end else begin
                    w_addr <= w_addr;
                end

                if(w_addr < 6'd31) begin //存储矩阵A的数据，这里w_addr的判断是前一个时刻的值，数据赋得是地址为w_addr+1对应的存储阵列值
                    w_data <= {32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,
                               32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,
                               32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,
                               32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1,32'd1};
                end else if((w_addr >= 6'd31) && ( w_addr < 6'd63 )) begin //w_addr判断的是前一个时刻的值,这里w_addr的值从31遍历到62,历经32次变化，和存储阵列对上
                    //需要一个指定32位片选的数据赋给w_data,片选的下标与w_addr有关
                    //w_data[32*(w_addr-31)+:32] <= 32'd2;
                    //w_data[1023:32*(w_addr-30)] <= 0;
                    w_data <= 1024'd0 | 32'd2 <<(32*(w_addr-31));
                end else begin
                    w_data <= w_data;
                    finish_generate_matrix <= 1'b1;
                end
                /*
                if(&w_addr) begin
                    w_addr <= w_addr;
                    w_data <= w_data;
                end else begin
                    w_addr <= w_addr + 1'b1;
                    w_data <= w_data + 1'b1;
                end
                */
            end
        end
    end

    //对写使能信号做出配置
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wea <= 1'b0;
        end else begin
            if(& w_addr) begin
                wea <= 1'b0;
            end else begin
                wea <= 1'b1;
            end
        end
    end

    /*测试存储阵列的值的代码
    
    //对读地址做出部署
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            r_addr <= 6'd0;
        
        else if(| w_addr) 
            r_addr <= r_addr + 1'b1;
        else
            r_addr <= 6'd0;
    
        else begin
            if(finish_generate_matrix) begin
                if(r_addr == 6'd0)
                    r_addr <= r_addr + 6'd33;
                else
                    r_addr <= r_addr + 1'b1;
                // r_addr <= r_addr + 1'b1;
            end else begin
                 r_addr <= 6'd0;
            end
        end

    end
    */

    //对start信号做出配置,count_for_start信号计数O_start拉高的时钟周期数
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            O_start <= 1'b0;
            count_for_start <= 3'd0;
        end else begin
            if(finish_generate_matrix)begin
                if(count_for_start < 3'd3) begin //start信号拉高三个时钟周期，四个clk上升沿的事件
                    O_start <= 1'b1;
                    count_for_start <= count_for_start + 1'b1;
                end else begin
                    O_start <= 1'b0;
                    count_for_start <= count_for_start;
                end
            end else begin
                O_start <= O_start;
                count_for_start <= count_for_start;
            end
        end
    end

    //事件处理的逻辑是：内部逻辑先写完数，拉高finish_generate_matrix信号，然后写控制器给发出start信号，接受fetch_A拉高的信号，进行向容错核心输出数据的处理
    //处理fetch_A上升沿的逻辑，先功能正确，再时序正确,fetch_A上升沿来99次，第33次，66次，99次空转（即不送新数据过去）
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fetch_A_last <= 1'b0;
            fetch_A_rising_edge <= 1'b0;
            count_for_fetch_A <= 7'd0;
            //处理fetch_B上升沿
            fetch_B_last <= 1'b0;
            fetch_B_rising_edge <= 1'b0;
            count_for_Br_row <= 6'b0;
            //处理读地址
            r_addr <= 6'd0;
            //从RAM中标志是否读矩阵B寄存器
            flag_read_matrixB <= 1'd0;
            //复位interval_cnt
            interval_cnt <= 6'd0;
            flag_first_fetch_B <= 1'b0;
        end else begin
            //处理fetch_A上升沿
            fetch_A_last <= fetch_A;
            fetch_A_rising_edge <= (!fetch_A_last&&fetch_A);
            if(fetch_A_rising_edge) begin //分析读数据的地址和count_for_fetch_A的关系
        
                if(count_for_fetch_A == 7'd99) begin
                    count_for_fetch_A <= 7'd1;
                end else begin
                    count_for_fetch_A <= count_for_fetch_A + 1'b1;
                end

                if((count_for_fetch_A == 7'd33)||(count_for_fetch_A == 7'd66)||(count_for_fetch_A == 7'd0)||(count_for_fetch_A == 7'd99)) begin //清零
                    r_addr <= 6'd0;
                end else if((count_for_fetch_A == 7'd32)||(count_for_fetch_A == 7'd65)||(count_for_fetch_A == 7'd98)) begin //保持
                    r_addr <= 6'd31;
                end else if(count_for_fetch_A > 7'd0 && count_for_fetch_A < 7'd32) begin //自增
                    r_addr <= count_for_fetch_A;
                end else if(count_for_fetch_A > 7'd33 && count_for_fetch_A < 7'd65) begin
                    r_addr <= count_for_fetch_A - 7'd33;
                end else if(count_for_fetch_A > 7'd66 && count_for_fetch_A < 7'd98) begin
                    r_addr <= count_for_fetch_A - 7'd66;
                end
            end

            //处理fetch_B上升沿
            fetch_B_last <= fetch_B;
            fetch_B_rising_edge <= (!fetch_B_last&&fetch_B);
            if(fetch_B_rising_edge) begin  //这里拉高一个标志位，再进行送数矩阵B 32次的处理
                count_for_Br_row <= 6'd1;
                r_addr <= offset_B;//r_addr从这里(6'd32,offset_B)开始轮询至地址6'd63
                flag_read_matrixB <= 1'b1;
                interval_cnt <= 6'd1;
            end

            if(flag_read_matrixB) begin
                //判断
                interval_cnt <= interval_cnt + 1'b1;
                if(count_for_fetch_A == 7'd1) begin
                    if(interval_cnt == 7'd37) begin
                        //地址
                        if((count_for_Br_row == 6'd0)||(count_for_Br_row == 6'd32)) begin//清零
                            r_addr <= offset_B;
                        end else begin//自增
                            r_addr <= r_addr + 1'b1;
                        end
                        //计数Br矩阵行计数器自增
                        if(count_for_Br_row == 6'd32) begin
                            //清零复位的状态
                            count_for_Br_row <= 6'd0;
                            flag_read_matrixB <= 1'b0;
                        end else begin
                            count_for_Br_row <= count_for_Br_row + 1'b1;
                        end
                        interval_cnt <= 7'd0;
                    end else begin
                        r_addr <= r_addr;
                        count_for_Br_row <= count_for_Br_row;
                    end
                end else begin
                    if(interval_cnt == 7'd5) begin
                        //地址
                        if((count_for_Br_row == 6'd0)||(count_for_Br_row == 6'd32)) begin//清零
                            r_addr <= offset_B;
                        end else begin//自增
                            r_addr <= r_addr + 1'b1;
                        end
                        //计数Br矩阵行计数器自增
                        if(count_for_Br_row == 6'd32) begin
                            //清零复位的状态
                            count_for_Br_row <= 6'd0;
                            flag_read_matrixB <= 1'b0;
                        end else begin
                            count_for_Br_row <= count_for_Br_row + 1'b1;
                        end
                        interval_cnt <= 7'd0;
                    end else begin
                        r_addr <= r_addr;
                        count_for_Br_row <= count_for_Br_row;
                    end
                end
            end
        end
    end
    
    /*
    //处理fetch_B上升沿的逻辑
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fetch_B_last <= 1'b0;
            fetch_B_rising_edge <= 1'b0;
            count_for_Br_row <= 1'b0;
        end else begin
            fetch_B_last <= fetch_B;
            fetch_B_rising_edge <= (!fetch_B_last&&fetch_B);
            if(fetch_B_rising_edge) begin  //这里拉高一个标志位，再进行送数矩阵B 32次的处理
                count_for_Br_row <= count_for_Br_row + 1'b1;
                r_addr <= 6'd32;//r_addr从这里(6'd32)开始轮询至地址6'd63
            end
        end
    end
    */

    Bram_Input u_Bram_Input(
        .clka(clk),    // input wire clka
        .wea(wea),      // input wire [0 : 0] wea
        .addra(w_addr),  // input wire [8 : 0] addra
        .dina(w_data),    // input wire [15 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(r_addr),  // input wire [8 : 0] addrb
        .doutb(r_data)  // output wire [15 : 0] doutb
    );
    
    assign start = O_start;
    assign data_in = r_data;
    
endmodule
