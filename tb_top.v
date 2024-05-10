`timescale  1ns / 1ps

module tb_top;

// top Parameters
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

// top Inputs
reg   [1023:0]  data_in                    = 0 ;
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   start                                = 0 ;
reg   store_C_ready                        = 0 ;

// top Outputs
wire  [1055:0]  dataCf_out                 ;
wire  fetch_A                              ;
wire  fetch_B                              ;
wire  store_C                              ;
wire  finish                               ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

top  u_top (
    .data_in                 ( data_in        [1023:0] ),
    .clk                     ( clk                     ),
    .rst_n                   ( rst_n                   ),
    .start                   ( start                   ),
    .store_C_ready           ( store_C_ready           ),

    .dataCf_out              ( dataCf_out     [1055:0] ),
    .fetch_A                 ( fetch_A                 ),
    .fetch_B                 ( fetch_B                 ),
    .store_C                 ( store_C                 ),
    .finish                  ( finish                  )
);

//为了方便在仿真波形图中查看，使用字符串描述状
reg [223:0] state_name;
always@(*)
    begin
        case(u_top.u_FSM_for_Baseline_with_Fault_Tolerance_Logic.state)
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

reg [31:0] dataA_value [0:31][0:31];
reg [31:0] dataB_value [0:31][0:31];
reg [31:0] dataC_value [0:32][0:32];
//给dataA_value，dataB_value,dataC_value赋初值
integer i,j;
initial begin
    for (i = 0;i < 32;i = i + 1)begin
        for(j = 0;j < 32;j = j + 1)begin
            dataA_value[i][j] = 32'd1;
            dataC_value[i][j] = 32'd0;// MACs模块在启动时，reset信号也拉高，输出端口复位为零，这里测试台文件中写dataC_value的寄存器初始值置零没有什么关系
            if(i == j)begin
                dataB_value[i][j] = 32'd2;
            end else begin
                dataB_value[i][j] = 32'd0;
            end
        end
    end
    for(i = 0;i < 33;i = i + 1)begin
        dataC_value[i][32] = 32'd0;
        dataC_value[32][i] = 32'd0;
    end
    //这是一个探针数据
    // dataB_value[1][1] = 32'd3;
end
///////////////////////////////////联合仿真规划//////////////////////////////////////////////////////////////////////////////////////////
//从矩阵A,B取数(占很大一片区域，但是没什么逻辑,别怕)，往矩阵Cf写数(就是往testbench里面写数，也没什么逻辑，别怕)
//三个模式，正常计算&&故障检测模式：CG模块工作，CV模块工作（正常往Cf中写数，如果不出错，那么就没有后面两个模式）
///////////第一次纠正计算&&故障纠正模式：CV模块不工作(往Cf中写第15列以外的所有列，因为第16列出错)
///////////第二次纠正计算&&故障纠正模式:CV模块不工作(往Cf中写第15列)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//定义从dataA_value,dataB_value取数的计数器
integer k = 0;//选择矩阵A的对应行
integer p = 0;//选择矩阵B全部行时的计数变量
integer r = 0;//往dataC_value里面写数的变量

//定义 32个fetch_A,fetch_B,store_C事件
event pos_fetchA_1, pos_fetchA_2, pos_fetchA_3, pos_fetchA_4, pos_fetchA_5, pos_fetchA_6, pos_fetchA_7, pos_fetchA_8,
      pos_fetchA_9, pos_fetchA_10, pos_fetchA_11, pos_fetchA_12, pos_fetchA_13, pos_fetchA_14, pos_fetchA_15, pos_fetchA_16,
      pos_fetchA_17, pos_fetchA_18, pos_fetchA_19, pos_fetchA_20, pos_fetchA_21, pos_fetchA_22, pos_fetchA_23, pos_fetchA_24,
      pos_fetchA_25, pos_fetchA_26, pos_fetchA_27, pos_fetchA_28, pos_fetchA_29, pos_fetchA_30, pos_fetchA_31, pos_fetchA_32,pos_fetchA_33,
      pos_fetchA_34, pos_fetchA_35, pos_fetchA_36, pos_fetchA_37, pos_fetchA_38, pos_fetchA_39, pos_fetchA_40, pos_fetchA_41,
      pos_fetchA_42, pos_fetchA_43, pos_fetchA_44, pos_fetchA_45, pos_fetchA_46, pos_fetchA_47, pos_fetchA_48, pos_fetchA_49,
      pos_fetchA_50, pos_fetchA_51, pos_fetchA_52, pos_fetchA_53, pos_fetchA_54, pos_fetchA_55, pos_fetchA_56, pos_fetchA_57,
      pos_fetchA_58, pos_fetchA_59, pos_fetchA_60, pos_fetchA_61, pos_fetchA_62, pos_fetchA_63, pos_fetchA_64, pos_fetchA_65,pos_fetchA_66,
      pos_fetchA_67, pos_fetchA_68, pos_fetchA_69, pos_fetchA_70, pos_fetchA_71, pos_fetchA_72, pos_fetchA_73, pos_fetchA_74,
      pos_fetchA_75, pos_fetchA_76, pos_fetchA_77, pos_fetchA_78, pos_fetchA_79, pos_fetchA_80, pos_fetchA_81, pos_fetchA_82,
      pos_fetchA_83, pos_fetchA_84, pos_fetchA_85, pos_fetchA_86, pos_fetchA_87, pos_fetchA_88, pos_fetchA_89, pos_fetchA_90,
      pos_fetchA_91, pos_fetchA_92, pos_fetchA_93, pos_fetchA_94, pos_fetchA_95, pos_fetchA_96, pos_fetchA_97, pos_fetchA_98,pos_fetchA_99;

event pos_fetchB_1, pos_fetchB_2, pos_fetchB_3, pos_fetchB_4, pos_fetchB_5, pos_fetchB_6, pos_fetchB_7, pos_fetchB_8,
      pos_fetchB_9, pos_fetchB_10, pos_fetchB_11, pos_fetchB_12, pos_fetchB_13, pos_fetchB_14, pos_fetchB_15, pos_fetchB_16,
      pos_fetchB_17, pos_fetchB_18, pos_fetchB_19, pos_fetchB_20, pos_fetchB_21, pos_fetchB_22, pos_fetchB_23, pos_fetchB_24,
      pos_fetchB_25, pos_fetchB_26, pos_fetchB_27, pos_fetchB_28, pos_fetchB_29, pos_fetchB_30, pos_fetchB_31, pos_fetchB_32,pos_fetchB_33,
      pos_fetchB_34, pos_fetchB_35, pos_fetchB_36, pos_fetchB_37, pos_fetchB_38, pos_fetchB_39, pos_fetchB_40, pos_fetchB_41,
      pos_fetchB_42, pos_fetchB_43, pos_fetchB_44, pos_fetchB_45, pos_fetchB_46, pos_fetchB_47, pos_fetchB_48, pos_fetchB_49,
      pos_fetchB_50, pos_fetchB_51, pos_fetchB_52, pos_fetchB_53, pos_fetchB_54, pos_fetchB_55, pos_fetchB_56, pos_fetchB_57,
      pos_fetchB_58, pos_fetchB_59, pos_fetchB_60, pos_fetchB_61, pos_fetchB_62, pos_fetchB_63, pos_fetchB_64, pos_fetchB_65,pos_fetchB_66,
      pos_fetchB_67, pos_fetchB_68, pos_fetchB_69, pos_fetchB_70, pos_fetchB_71, pos_fetchB_72, pos_fetchB_73, pos_fetchB_74,
      pos_fetchB_75, pos_fetchB_76, pos_fetchB_77, pos_fetchB_78, pos_fetchB_79, pos_fetchB_80, pos_fetchB_81, pos_fetchB_82,
      pos_fetchB_83, pos_fetchB_84, pos_fetchB_85, pos_fetchB_86, pos_fetchB_87, pos_fetchB_88, pos_fetchB_89, pos_fetchB_90,
      pos_fetchB_91, pos_fetchB_92, pos_fetchB_93, pos_fetchB_94, pos_fetchB_95, pos_fetchB_96, pos_fetchB_97, pos_fetchB_98,pos_fetchB_99;

event pos_storeC_1, pos_storeC_2, pos_storeC_3, pos_storeC_4, pos_storeC_5, pos_storeC_6, pos_storeC_7, pos_storeC_8,
      pos_storeC_9, pos_storeC_10, pos_storeC_11, pos_storeC_12, pos_storeC_13, pos_storeC_14, pos_storeC_15, pos_storeC_16,
      pos_storeC_17, pos_storeC_18, pos_storeC_19, pos_storeC_20, pos_storeC_21, pos_storeC_22, pos_storeC_23, pos_storeC_24,
      pos_storeC_25, pos_storeC_26, pos_storeC_27, pos_storeC_28, pos_storeC_29, pos_storeC_30, pos_storeC_31, pos_storeC_32,pos_storeC_33,
      pos_storeC_34, pos_storeC_35, pos_storeC_36, pos_storeC_37, pos_storeC_38, pos_storeC_39, pos_storeC_40, pos_storeC_41,
      pos_storeC_42, pos_storeC_43, pos_storeC_44, pos_storeC_45, pos_storeC_46, pos_storeC_47, pos_storeC_48, pos_storeC_49,
      pos_storeC_50, pos_storeC_51, pos_storeC_52, pos_storeC_53, pos_storeC_54, pos_storeC_55, pos_storeC_56, pos_storeC_57,
      pos_storeC_58, pos_storeC_59, pos_storeC_60, pos_storeC_61, pos_storeC_62, pos_storeC_63, pos_storeC_64, pos_storeC_65,pos_storeC_66,
      pos_storeC_67, pos_storeC_68, pos_storeC_69, pos_storeC_70, pos_storeC_71, pos_storeC_72, pos_storeC_73, pos_storeC_74,
      pos_storeC_75, pos_storeC_76, pos_storeC_77, pos_storeC_78, pos_storeC_79, pos_storeC_80, pos_storeC_81, pos_storeC_82,
      pos_storeC_83, pos_storeC_84, pos_storeC_85, pos_storeC_86, pos_storeC_87, pos_storeC_88, pos_storeC_89, pos_storeC_90,
      pos_storeC_91, pos_storeC_92, pos_storeC_93, pos_storeC_94, pos_storeC_95, pos_storeC_96, pos_storeC_97, pos_storeC_98,pos_storeC_99;

reg [6:0] count_fetchA = 0, //计数值最大为127
          count_fetchB = 0,
          count_storeC = 0;

//设置这些事件的触发条件
always@(posedge fetch_A) begin
    count_fetchA = count_fetchA + 1'b1;
    case(count_fetchA)
        7'd1: -> pos_fetchA_1;
        7'd2: -> pos_fetchA_2;
        7'd3: -> pos_fetchA_3;
        7'd4: -> pos_fetchA_4;
        7'd5: -> pos_fetchA_5;
        7'd6: -> pos_fetchA_6;
        7'd7: -> pos_fetchA_7;
        7'd8: -> pos_fetchA_8;
        7'd9: -> pos_fetchA_9;
        7'd10: -> pos_fetchA_10;
        7'd11: -> pos_fetchA_11;
        7'd12: -> pos_fetchA_12;
        7'd13: -> pos_fetchA_13;
        7'd14: -> pos_fetchA_14;
        7'd15: -> pos_fetchA_15;
        7'd16: -> pos_fetchA_16;
        7'd17: -> pos_fetchA_17;
        7'd18: -> pos_fetchA_18;
        7'd19: -> pos_fetchA_19;
        7'd20: -> pos_fetchA_20;
        7'd21: -> pos_fetchA_21;
        7'd22: -> pos_fetchA_22;
        7'd23: -> pos_fetchA_23;
        7'd24: -> pos_fetchA_24;
        7'd25: -> pos_fetchA_25;
        7'd26: -> pos_fetchA_26;
        7'd27: -> pos_fetchA_27;
        7'd28: -> pos_fetchA_28;
        7'd29: -> pos_fetchA_29;
        7'd30: -> pos_fetchA_30;
        7'd31: -> pos_fetchA_31;
        7'd32: -> pos_fetchA_32;
        7'd33: -> pos_fetchA_33;
        7'd34: -> pos_fetchA_34;
        7'd35: -> pos_fetchA_35;
        7'd36: -> pos_fetchA_36;
        7'd37: -> pos_fetchA_37;
        7'd38: -> pos_fetchA_38;
        7'd39: -> pos_fetchA_39;
        7'd40: -> pos_fetchA_40;
        7'd41: -> pos_fetchA_41;
        7'd42: -> pos_fetchA_42;
        7'd43: -> pos_fetchA_43;
        7'd44: -> pos_fetchA_44;
        7'd45: -> pos_fetchA_45;
        7'd46: -> pos_fetchA_46;
        7'd47: -> pos_fetchA_47;
        7'd48: -> pos_fetchA_48;
        7'd49: -> pos_fetchA_49;
        7'd50: -> pos_fetchA_50;
        7'd51: -> pos_fetchA_51;
        7'd52: -> pos_fetchA_52;
        7'd53: -> pos_fetchA_53;
        7'd54: -> pos_fetchA_54;
        7'd55: -> pos_fetchA_55;
        7'd56: -> pos_fetchA_56;
        7'd57: -> pos_fetchA_57;
        7'd58: -> pos_fetchA_58;
        7'd59: -> pos_fetchA_59;
        7'd60: -> pos_fetchA_60;
        7'd61: -> pos_fetchA_61;
        7'd62: -> pos_fetchA_62;
        7'd63: -> pos_fetchA_63;
        7'd64: -> pos_fetchA_64;
        7'd65: -> pos_fetchA_65;
        7'd66: -> pos_fetchA_66;
        7'd67: -> pos_fetchA_67;
        7'd68: -> pos_fetchA_68;
        7'd69: -> pos_fetchA_69;
        7'd70: -> pos_fetchA_70;
        7'd71: -> pos_fetchA_71;
        7'd72: -> pos_fetchA_72;
        7'd73: -> pos_fetchA_73;
        7'd74: -> pos_fetchA_74;
        7'd75: -> pos_fetchA_75;
        7'd76: -> pos_fetchA_76;
        7'd77: -> pos_fetchA_77;
        7'd78: -> pos_fetchA_78;
        7'd79: -> pos_fetchA_79;
        7'd80: -> pos_fetchA_80;
        7'd81: -> pos_fetchA_81;
        7'd82: -> pos_fetchA_82;
        7'd83: -> pos_fetchA_83;
        7'd84: -> pos_fetchA_84;
        7'd85: -> pos_fetchA_85;
        7'd86: -> pos_fetchA_86;
        7'd87: -> pos_fetchA_87;
        7'd88: -> pos_fetchA_88;
        7'd89: -> pos_fetchA_89;
        7'd90: -> pos_fetchA_90;
        7'd91: -> pos_fetchA_91;
        7'd92: -> pos_fetchA_92;
        7'd93: -> pos_fetchA_93;
        7'd94: -> pos_fetchA_94;
        7'd95: -> pos_fetchA_95;
        7'd96: -> pos_fetchA_96;
        7'd97: -> pos_fetchA_97;
        7'd98: -> pos_fetchA_98;
        7'd99: -> pos_fetchA_99;
        default : count_fetchA = 7'b000_000;
    endcase
end

always@(posedge fetch_B) begin
    count_fetchB = count_fetchB + 1'b1;
    case(count_fetchB)
        7'd1: -> pos_fetchB_1;
        7'd2: -> pos_fetchB_2;
        7'd3: -> pos_fetchB_3;
        7'd4: -> pos_fetchB_4;
        7'd5: -> pos_fetchB_5;
        7'd6: -> pos_fetchB_6;
        7'd7: -> pos_fetchB_7;
        7'd8: -> pos_fetchB_8;
        7'd9: -> pos_fetchB_9;
        7'd10: -> pos_fetchB_10;
        7'd11: -> pos_fetchB_11;
        7'd12: -> pos_fetchB_12;
        7'd13: -> pos_fetchB_13;
        7'd14: -> pos_fetchB_14;
        7'd15: -> pos_fetchB_15;
        7'd16: -> pos_fetchB_16;
        7'd17: -> pos_fetchB_17;
        7'd18: -> pos_fetchB_18;
        7'd19: -> pos_fetchB_19;
        7'd20: -> pos_fetchB_20;
        7'd21: -> pos_fetchB_21;
        7'd22: -> pos_fetchB_22;
        7'd23: -> pos_fetchB_23;
        7'd24: -> pos_fetchB_24;
        7'd25: -> pos_fetchB_25;
        7'd26: -> pos_fetchB_26;
        7'd27: -> pos_fetchB_27;
        7'd28: -> pos_fetchB_28;
        7'd29: -> pos_fetchB_29;
        7'd30: -> pos_fetchB_30;
        7'd31: -> pos_fetchB_31;
        7'd32: -> pos_fetchB_32;
        7'd33: -> pos_fetchB_33;
        7'd34: -> pos_fetchB_34;
        7'd35: -> pos_fetchB_35;
        7'd36: -> pos_fetchB_36;
        7'd37: -> pos_fetchB_37;
        7'd38: -> pos_fetchB_38;
        7'd39: -> pos_fetchB_39;
        7'd40: -> pos_fetchB_40;
        7'd41: -> pos_fetchB_41;
        7'd42: -> pos_fetchB_42;
        7'd43: -> pos_fetchB_43;
        7'd44: -> pos_fetchB_44;
        7'd45: -> pos_fetchB_45;
        7'd46: -> pos_fetchB_46;
        7'd47: -> pos_fetchB_47;
        7'd48: -> pos_fetchB_48;
        7'd49: -> pos_fetchB_49;
        7'd50: -> pos_fetchB_50;
        7'd51: -> pos_fetchB_51;
        7'd52: -> pos_fetchB_52;
        7'd53: -> pos_fetchB_53;
        7'd54: -> pos_fetchB_54;
        7'd55: -> pos_fetchB_55;
        7'd56: -> pos_fetchB_56;
        7'd57: -> pos_fetchB_57;
        7'd58: -> pos_fetchB_58;
        7'd59: -> pos_fetchB_59;
        7'd60: -> pos_fetchB_60;
        7'd61: -> pos_fetchB_61;
        7'd62: -> pos_fetchB_62;
        7'd63: -> pos_fetchB_63;
        7'd64: -> pos_fetchB_64;
        7'd65: -> pos_fetchB_65;
        7'd66: -> pos_fetchB_66;
        7'd67: -> pos_fetchB_67;
        7'd68: -> pos_fetchB_68;
        7'd69: -> pos_fetchB_69;
        7'd70: -> pos_fetchB_70;
        7'd71: -> pos_fetchB_71;
        7'd72: -> pos_fetchB_72;
        7'd73: -> pos_fetchB_73;
        7'd74: -> pos_fetchB_74;
        7'd75: -> pos_fetchB_75;
        7'd76: -> pos_fetchB_76;
        7'd77: -> pos_fetchB_77;
        7'd78: -> pos_fetchB_78;
        7'd79: -> pos_fetchB_79;
        7'd80: -> pos_fetchB_80;
        7'd81: -> pos_fetchB_81;
        7'd82: -> pos_fetchB_82;
        7'd83: -> pos_fetchB_83;
        7'd84: -> pos_fetchB_84;
        7'd85: -> pos_fetchB_85;
        7'd86: -> pos_fetchB_86;
        7'd87: -> pos_fetchB_87;
        7'd88: -> pos_fetchB_88;
        7'd89: -> pos_fetchB_89;
        7'd90: -> pos_fetchB_90;
        7'd91: -> pos_fetchB_91;
        7'd92: -> pos_fetchB_92;
        7'd93: -> pos_fetchB_93;
        7'd94: -> pos_fetchB_94;
        7'd95: -> pos_fetchB_95;
        7'd96: -> pos_fetchB_96;
        7'd97: -> pos_fetchB_97;
        7'd98: -> pos_fetchB_98;
        7'd99: -> pos_fetchB_99;
        default : count_fetchB = 7'b000_000;
    endcase
end

always@(posedge store_C) begin
    count_storeC = count_storeC + 1'b1;
    case(count_storeC)
        7'd1: -> pos_storeC_1;
        7'd2: -> pos_storeC_2;
        7'd3: -> pos_storeC_3;
        7'd4: -> pos_storeC_4;
        7'd5: -> pos_storeC_5;
        7'd6: -> pos_storeC_6;
        7'd7: -> pos_storeC_7;
        7'd8: -> pos_storeC_8;
        7'd9: -> pos_storeC_9;
        7'd10: -> pos_storeC_10;
        7'd11: -> pos_storeC_11;
        7'd12: -> pos_storeC_12;
        7'd13: -> pos_storeC_13;
        7'd14: -> pos_storeC_14;
        7'd15: -> pos_storeC_15;
        7'd16: -> pos_storeC_16;
        7'd17: -> pos_storeC_17;
        7'd18: -> pos_storeC_18;
        7'd19: -> pos_storeC_19;
        7'd20: -> pos_storeC_20;
        7'd21: -> pos_storeC_21;
        7'd22: -> pos_storeC_22;
        7'd23: -> pos_storeC_23;
        7'd24: -> pos_storeC_24;
        7'd25: -> pos_storeC_25;
        7'd26: -> pos_storeC_26;
        7'd27: -> pos_storeC_27;
        7'd28: -> pos_storeC_28;
        7'd29: -> pos_storeC_29;
        7'd30: -> pos_storeC_30;
        7'd31: -> pos_storeC_31;
        7'd32: -> pos_storeC_32;
        7'd33: -> pos_storeC_33;
        7'd34: -> pos_storeC_34;
        7'd35: -> pos_storeC_35;
        7'd36: -> pos_storeC_36;
        7'd37: -> pos_storeC_37;
        7'd38: -> pos_storeC_38;
        7'd39: -> pos_storeC_39;
        7'd40: -> pos_storeC_40;
        7'd41: -> pos_storeC_41;
        7'd42: -> pos_storeC_42;
        7'd43: -> pos_storeC_43;
        7'd44: -> pos_storeC_44;
        7'd45: -> pos_storeC_45;
        7'd46: -> pos_storeC_46;
        7'd47: -> pos_storeC_47;
        7'd48: -> pos_storeC_48;
        7'd49: -> pos_storeC_49;
        7'd50: -> pos_storeC_50;
        7'd51: -> pos_storeC_51;
        7'd52: -> pos_storeC_52;
        7'd53: -> pos_storeC_53;
        7'd54: -> pos_storeC_54;
        7'd55: -> pos_storeC_55;
        7'd56: -> pos_storeC_56;
        7'd57: -> pos_storeC_57;
        7'd58: -> pos_storeC_58;
        7'd59: -> pos_storeC_59;
        7'd60: -> pos_storeC_60;
        7'd61: -> pos_storeC_61;
        7'd62: -> pos_storeC_62;
        7'd63: -> pos_storeC_63;
        7'd64: -> pos_storeC_64;
        7'd65: -> pos_storeC_65;
        7'd66: -> pos_storeC_66;
        7'd67: -> pos_storeC_67;
        7'd68: -> pos_storeC_68;
        7'd69: -> pos_storeC_69;
        7'd70: -> pos_storeC_70;
        7'd71: -> pos_storeC_71;
        7'd72: -> pos_storeC_72;
        7'd73: -> pos_storeC_73;
        7'd74: -> pos_storeC_74;
        7'd75: -> pos_storeC_75;
        7'd76: -> pos_storeC_76;
        7'd77: -> pos_storeC_77;
        7'd78: -> pos_storeC_78;
        7'd79: -> pos_storeC_79;
        7'd80: -> pos_storeC_80;
        7'd81: -> pos_storeC_81;
        7'd82: -> pos_storeC_82;
        7'd83: -> pos_storeC_83;
        7'd84: -> pos_storeC_84;
        7'd85: -> pos_storeC_85;
        7'd86: -> pos_storeC_86;
        7'd87: -> pos_storeC_87;
        7'd88: -> pos_storeC_88;
        7'd89: -> pos_storeC_89;
        7'd90: -> pos_storeC_90;
        7'd91: -> pos_storeC_91;
        7'd92: -> pos_storeC_92;
        7'd93: -> pos_storeC_93;
        7'd94: -> pos_storeC_94;
        7'd95: -> pos_storeC_95;
        7'd96: -> pos_storeC_96;
        7'd97: -> pos_storeC_97;
        7'd98: -> pos_storeC_98;
        7'd99: -> pos_storeC_99;
        default : count_storeC = 7'b000_000;
    endcase
end

//正常计算detect_correct = 2'b01
initial begin
    #43  start = 1'b1;
    @(negedge clk)
    start = 1'b0;
end

initial begin
    @(pos_fetchA_1) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
        @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataA_value[k][j];
            end
        end
        k = k + 1;
    end
end

initial begin
    @(pos_fetchB_1) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end
end

initial begin
    //第一个模式计算Cf的第一行
    @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin//复位时候被认为是下降沿
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    repeat(30) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    //第一个模式写Cf的第一行
    @(pos_storeC_1) begin
        #(3*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    //正常计算模式写矩阵Cf第一行结束,同时开始生成矩阵Cf的第二行，下一个fetch_A上升沿来临时，拉低store_C_ready信号
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_2) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_2) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_2) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_3) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_3) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_3) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_4) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_4) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_4) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_5) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_5) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_5) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_6) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_6) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_6) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
        //////////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_7) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_7) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_7) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_8) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_8) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_8) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_9) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_9) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_9) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_10) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_10) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_10) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_11) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_11) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_11) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
     //////////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_12) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_12) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_12) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_13) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_13) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_13) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_14) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_14) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_14) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_15) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_15) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_15) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_16) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_16) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_16) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
        //////////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_17) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_17) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_17) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_18) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_18) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_18) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_19) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_19) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_19) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_20) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_20) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_20) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_21) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_21) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_21) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
     //////////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_22) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_22) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_22) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_23) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_23) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_23) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_24) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_24) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_24) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_25) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_25) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_25) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_26) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_26) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_26) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
        //////////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_27) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_27) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_27) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_28) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_28) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_28) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_29) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_29) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_29) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_30) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_30) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_30) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_31) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_31) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_31) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_32) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_32) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_32) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end

    ////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_33) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_33) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_33) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
            end
            store_C_ready = 1'b1;
            //r,k复位为0
            r = 0;
            k = 0;
        end
    end
    /////////////第一次纠正计算////////////////////////////////
    @(pos_fetchA_34) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end
    
    @(pos_fetchB_34) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_34) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_35) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_35) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_35) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_36) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_36) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_36) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_37) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_37) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_37) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_38) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_38) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_38) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_39) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_39) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_39) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_40) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_40) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_40) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_41) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_41) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_41) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_42) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_42) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_42) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_43) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_43) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_43) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_44) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_44) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_44) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_45) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_45) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_45) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_46) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_46) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_46) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_47) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_47) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_47) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_48) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_48) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_48) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_49) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_49) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_49) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_50) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_50) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_50) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_51) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_51) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_51) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_52) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_52) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_52) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_53) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_53) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_53) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_54) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_54) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_54) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_55) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_55) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_55) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_56) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_56) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_56) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_57) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_57) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_57) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_58) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_58) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_58) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////
    @(pos_fetchA_59) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_59) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_59) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_60) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_60) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_60) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_61) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_61) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_61) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_62) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_62) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_62) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_63) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_63) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_63) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_64) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_64) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_64) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_65) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_65) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_65) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////
    @(pos_fetchA_66) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_66) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_66) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    k = 0;
    r = 0;
    ////////////////第二次纠正计算//////////////////////////////////////////////
    @(pos_fetchA_67) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_67) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_67) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_68) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_68) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_68) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_69) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_69) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_69) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_70) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_70) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_70) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_71) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_71) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_71) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_72) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_72) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_72) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_73) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_73) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_73) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_74) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_74) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_74) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_75) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_75) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_75) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_76) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_76) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_76) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_77) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_77) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_77) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_78) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_78) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_78) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_79) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_79) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_79) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_80) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_80) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_80) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_81) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_81) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_81) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_82) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_82) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_82) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_83) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_83) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_83) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_84) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_84) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_84) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_85) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_85) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_85) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_86) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_86) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_86) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_87) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_87) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_87) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_88) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_88) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_88) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_89) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_89) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_89) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_90) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_90) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_90) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_91) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_91) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_91) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_92) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_92) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_92) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_93) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_93) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_93) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_94) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_94) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_94) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_95) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_95) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_95) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_96) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_96) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_96) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_97) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_97) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_97) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_98) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_98) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_98) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    ////////////////////////////////////////////////////////////////////////////////////
    @(pos_fetchA_99) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_99) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_99) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    
    /*
    @(pos_fetchA_67) begin
        # (2*PERIOD)  // 保证在fetch_A拉高后的第三个时钟上升沿、前的下降沿、取数矩阵A的对应行
            @(negedge clk) begin
                for( j = 0;j<32;j=j+1)begin
                    data_in[32*j+:32] = dataA_value[k][j];
                end
                store_C_ready = 1'b0;
            end
        k = k + 1;
    end

    @(pos_fetchB_67) begin
         # (2*PERIOD)
         @(negedge clk) begin
            for( j = 0;j<32;j=j+1)begin
                data_in[32*j+:32] = dataB_value[p][j];
            end
         end
        p = p + 1;
    end

    repeat(31) begin
        @(negedge u_top.u_CheckSum_Generation.flag_encode_B_row_over) begin
            # (4*PERIOD) 
                @(negedge clk) begin
                    for( j = 0;j<32;j=j+1)begin
                        data_in[32*j+:32] = dataB_value[p][j];
                    end
                end
            p = p + 1;
        end
    end

    p = 0;

    @(pos_storeC_67) begin
        #(2*PERIOD)
        @(negedge clk) begin
            for(j = 0;j < 33;j = j + 1)begin
                if(j!==15) begin
                    dataC_value[r][j] = dataCf_out[32*j+:32];
                end else begin
                    dataC_value[r][j] = 32'd0;
                end
            end
            store_C_ready = 1'b1;
            r = r + 1;
        end
    end
    */

end

initial
begin
    # 1000
    $finish;
end

/*
initial begin
    $dumpfile("240326.vcd");
    // $dumpvars(0,**);
end
*/

endmodule