//在video_driver 模块的驱动下按照工业标准的VGA 显示时序
//输出视频信号、行场同步信号以及视频有效信号。这些信号作为RGB2DVI模块的输入
module video_driver (
    input               pixel_clk             ,
    input               sys_rst_n             ,
    input [23:0]        pixel_data            ,//像素点数据

    //RGB接口
    output              video_hs              ,//行同步信号
    output              video_vs              ,//场同步信号
    output              video_de              ,//数据使能
    output [23:0]       video_rgb             ,//RGB888颜色数据

    output [10:0]       pixel_xpos            ,//像素点横坐标
    output [10:0]       pixel_ypos             //像素点纵坐标
);

//1280*720 分辨率时序参数
parameter H_SYNC = 11'd40,      //行同步
          H_BACK = 11'd220,     //行显示后沿
          H_DISP = 11'd1280,    //行有效数据
          H_FRONT = 11'd110,    //行显示前沿
          H_TOTAL = 11'd1650;   //行扫描周期

parameter V_SYNC = 11'd5,      //场同步
          V_BACK = 11'd20,     //场显示后沿
          V_DISP = 11'd720,    //场有效数据
          V_FRONT = 11'd5,    //场显示前沿
          V_TOTAL = 11'd750;   //场扫描周期

reg [10:0] cnt_h;
reg [10:0] cnt_v;

wire video_en;
wire data_req;

assign video_de = video_en;

assign video_hs = (cnt_h < H_SYNC ) ? 1'b0 : 1'b1;
assign video_vs = (cnt_v < V_SYNC ) ? 1'b0 : 1'b1;

//有效信号输出时序
assign video_en = (((cnt_h >= H_SYNC + H_BACK) && (cnt_h < H_SYNC + H_BACK + H_DISP)) 
                && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK + V_DISP)))
                ? 1'b1 : 1'b0;
//RGB888数据输出
assign video_rgb = video_en ? pixel_data : 24'd0;

//请求像素点颜色数据输入
assign data_req = (((cnt_h >= H_SYNC + H_BACK - 1'b1) && (cnt_h < H_SYNC + H_BACK + H_DISP - 1'b1)) 
                && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK + V_DISP)))
                ? 1'b1 : 1'b0;

//像素点坐标
assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 11'd0;
assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 11'd0;

//行计数器对像素时钟计数
//使用同步复位信号：抗干扰能力强、消除毛刺，同步消耗资源较多、
//需要保持一个时钟周期以上才可以复位、可能带来时钟偏移等问题

//异步复位信号则相反消耗资源少、抗干扰弱、有亚稳态问题

//行计数器对像素时钟进行计数
always @(posedge pixel_clk) begin
    if(!sys_rst_n)
        cnt_h <= 11'd0;
    else if(cnt_h == H_TOTAL - 1'b1)
        cnt_h <= 11'd0;
    else 
        cnt_h <= cnt_h + 1'b1;
end

//场计数器对行计数，一个场内的行计完切换下一帧
always @(posedge pixel_clk) begin
    if(!sys_rst_n)
        cnt_v <= 11'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else
            cnt_v <= 11'd0;
    end
end

endmodule