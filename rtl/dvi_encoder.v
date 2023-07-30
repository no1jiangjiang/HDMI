/***********
下面会用到一个#1，在1ns过后才开始进行赋值
作用：该延迟有效地实现了 1ns clk-to-q 或 rst_n-to-q 延迟，使用波形查看器查看时可以轻松解释。
比如：波形查看器中的小延迟还可以很容易地看到时序逻辑输出的值在时钟边沿之前是什么，
通过将波形查看器光标放在时钟边沿本身，大多数波形查看工具将显示相应的靠近波形显示左侧的信号名称旁边的二进制、十进制或十六进制值。
***********/
`timescale 1ps/1ps

module dvi_encoder(
    input               clkin   ,//像素时钟
    input               rst_n   ,//异步复位同步释放的复位信号、高有效
    input   [7:0]       din     ,//8位数据
    input               c0      ,//控制信号1
    input               c1      ,//控制信号2
    input               de      ,//发送时序

    output reg [9:0]    dout    //编码后的数据
);

reg [3:0] n1d;//1的个数
reg [7:0] din_q;//

//计算1的个数
always @(posedge clkin) begin
    n1d <=#1 din[0] + din[1] + din[2] + din[3] + din[4] + din[5] + din[6] + din[7];

    din_q <=#1 din;
end

wire  decision1;

assign decision1 = (n1d > 4'h4) || ((n1d == 4'h4) && (din_q[0] == 1'b0));

wire [8:0] q_m;
assign q_m[0] = din_q[0];
assign q_m[1] = (decision1) ? (q_m[0] ^~ din_q[1]) : (q_m[0] ^ din_q[1]);
assign q_m[2] = (decision1) ? (q_m[1] ^~ din_q[2]) : (q_m[1] ^ din_q[2]);
assign q_m[3] = (decision1) ? (q_m[2] ^~ din_q[3]) : (q_m[2] ^ din_q[3]);
assign q_m[4] = (decision1) ? (q_m[3] ^~ din_q[4]) : (q_m[3] ^ din_q[4]);
assign q_m[5] = (decision1) ? (q_m[4] ^~ din_q[5]) : (q_m[4] ^ din_q[5]);
assign q_m[6] = (decision1) ? (q_m[5] ^~ din_q[6]) : (q_m[5] ^ din_q[6]);
assign q_m[7] = (decision1) ? (q_m[6] ^~ din_q[7]) : (q_m[6] ^ din_q[7]);
assign q_m[8] = (decision1) ? 1'b0 : 1'b1;

//计算q_m的1的个数用于下一个decision条件
reg [3:0] n1q_m, n0q_m;

always @(posedge clkin) begin
    n1q_m <=#1 q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
    n0q_m <=#1 4'h8 - (q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7]);
end

//两个控制信号的四种编码情况
parameter CTRLTOKEN0 = 10'b1101010100,
          CTRLTOKEN1 = 10'b0010101011,
          CTRLTOKEN2 = 10'b0101010100,
          CTRLTOKEN3 = 10'b1010101011;

reg [4:0] cnt ;
wire decision2,decision3;

assign decision2 = (cnt == 5'h0) || (n0q_m == n1q_m);
assign decision3 = ((~cnt[4]) && (n1q_m > n0q_m)) || ((cnt[4]) && (n1q_m < n0q_m));

reg de_q, de_reg;
reg c0_q,c1_q;
reg c0_reg,c1_reg;
reg [8:0] q_m_reg;
//应该是延后一个时钟周期用于与前面寄存din_q同步
always @(posedge clkin)begin
    de_q <=#1 de;
    de_reg <=#1 de_q;

    c0_q <=#1 c0;
    c0_reg <=#1 c0_q;
    c1_q <=#1 c1;
    c0_reg <=#1 c1_q;

    q_m_reg <=#1 q_m;
end

always @(posedge clkin or posedge rst_n) begin
    if(rst_n)begin
        dout <= 10'h0;
        cnt <= 5'h0;
    end
    else begin
        if(de_reg) begin//有效数据传输过程
            if(decision2) begin
                dout[9] <=#1 ~q_m_reg[8];
                dout[8] <=#1 q_m_reg[8];
                dout[7:0] <=#1 (q_m_reg[8]) ? q_m_reg[7:0] : ~q_m_reg[7:0];

                cnt <=#1 (~q_m_reg[8]) ? (cnt + n0q_m - n1q_m) : (cnt + n1q_m - n0q_m);
            end
            else begin
                if(decision3)begin
                    dout[9] <=#1 1'b1;
                    dout[8] <=#1 q_m_reg[8];
                    dout[7:0] <=#1 ~q_m_reg[7:0];

                    cnt <=#1 cnt + {q_m_reg[8],1'b0} + (n0q_m - n1q_m);
                end
                else begin
                    dout[9] <=#1 1'b0;
                    dout[8] <=#1 q_m_reg[8];
                    dout[7:0] <=#1 q_m_reg[7:0];

                    cnt <=#1 cnt - {~q_m_reg[8],1'b0} + (n1q_m - n0q_m);
                end
            end
        end
        else begin
            case ({c1_reg , c0_reg})
                2'b00: dout <=#1 CTRLTOKEN0; 
                2'b01: dout <=#1 CTRLTOKEN1;
                2'b10: dout <=#1 CTRLTOKEN2; 
                default: dout <=#1 CTRLTOKEN3;
            endcase

            cnt <=#1 5'h0;
        end
    end
end
endmodule