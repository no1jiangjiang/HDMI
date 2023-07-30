//这个模块是用于生成显示图案的
//这里我们只需要实现彩条的显示，
//其实就是通过x、y的坐标对不同范围的频幕给不同的颜色即可
module video_display(
    input                   pixel_clk       ,//75MHZ
    input                   sys_rst_n       ,
    input [10:0]            pixel_xpos      ,//像素点横坐标
    input [10:0]            pixel_ypos      ,//像素点纵坐标

    output reg [23:0]       pixel_data//像素点数据，传回驱动模块用于在有效数据发送期间进行发送
    
);
/*彩条显示
parameter H_DISP = 11'd1280,
          V_DISP = 11'd720;

//几种颜色的编码
localparam WHITE  = 24'b11111111_11111111_11111111;  //RGB888 白色
localparam BLACK  = 24'b00000000_00000000_00000000;  //RGB888 黑色
localparam RED    = 24'b11111111_00001100_00000000;  //RGB888 红色
localparam GREEN  = 24'b00000000_11111111_00000000;  //RGB888 绿色
localparam BLUE   = 24'b00000000_00000000_11111111;  //RGB888 蓝色

//根据当前的像素点坐标指定当前颜色
always @(posedge pixel_clk) begin
    if(!sys_rst_n)
        pixel_data <= 24'd0;
    else begin
        if((pixel_xpos >= 0) && (pixel_xpos < (H_DISP/5)*1))
            pixel_data <= WHITE;
        else if((pixel_xpos >= (H_DISP/5)*1) && (pixel_xpos < (H_DISP/5)*2))
            pixel_data <= BLACK;
        else if((pixel_xpos >= (H_DISP/5)*2) && (pixel_xpos < (H_DISP/5)*3))
            pixel_data <= RED;
        else if((pixel_xpos >= (H_DISP/5)*3) && (pixel_xpos < (H_DISP/5)*4))
            pixel_data <= GREEN;
        else
            pixel_data <= BLUE;
    end
end*/
/**************
这里的方块动态显示模块实际上就是依据左上角的一个坐标确定整个方块的位置
并给小方块颜色，同样根据左上角坐标点的位置判定是否到达边界。
**************/ 

parameter H_DISP = 11'd1280;//分辨率--行
parameter V_DISP = 11'd720;//分辨率--列

localparam SIDE_W  = 11'd40,//屏幕边框
           BLOCK_W = 11'd40,//方块宽度
           BLUE    = 24'b00000000_00000000_11111111,  //屏幕颜色，蓝色
           WHITE   = 24'b11111111_11111111_11111111,  //背景颜色，白色
           BLACK   = 24'b00000000_00000000_00000000;  //方块颜色， 黑色
//左上角方块初始位置
reg [10:0] block_x = SIDE_W;
reg [10:0] block_y = SIDE_W;

reg [21:0] div_cnt;//分频计数器
reg h_direct;//指示水平移动方向 1：右移，0：左移
reg v_direct;//指示垂直移动方向 1：向下，0：向上

wire move_en;//方块移动使能，100HZ

assign move_en = (div_cnt == 22'd742500) ? 1'b1 : 1'b0;

//计数实现时钟分频
always @(posedge pixel_clk) begin
    if(!sys_rst_n)begin
        div_cnt <= 22'd0;
    end
    else begin
        if(div_cnt < 22'd742500)
            div_cnt <= div_cnt + 1'b1;
        else
            div_cnt <= 22'd0;
    end
end

//判断方块移动到边界，改变移动方向
always @(posedge pixel_clk) begin
    if(!sys_rst_n) begin
        h_direct <= 1'b1;               //初始向右移动
        v_direct <= 1'b1;               //初始竖直向下
    end
    else begin
        //判断水平位置
        if(block_x == SIDE_W - 1'b1) //到达左边界，水平向右
            h_direct <= 1'b1;
        else if(block_x == H_DISP - SIDE_W - BLOCK_W)
            h_direct <= 1'b0;
        else
            h_direct <= h_direct;
        //判断垂直位置
        if(block_y == SIDE_W - 1'b1)
            v_direct <= 1'b1;
        else if(block_y == V_DISP - SIDE_W - BLOCK_W)
            v_direct <= 1'b0;
        else
            v_direct <= v_direct;
    end
end

//根据方块移动方向，改变坐标
always @(posedge pixel_clk) begin
    if(!sys_rst_n)begin
        block_x <= SIDE_W;           //初始化方块坐标
        block_y <= SIDE_W;
    end
    else if(move_en) begin//10ms改变坐标，实现动态效果
        if(h_direct)
           block_x <= block_x + 1'b1;//向右
        else
            block_x <= block_x - 1'b1;

        if(v_direct)
            block_y <= block_y + 1'b1;//向下
        else
            block_y <= block_y - 1'b1;
    end
    else begin
        block_x <= block_x;
        block_y <= block_y;
    end
end

//不同区域绘制不同颜色

always @(posedge pixel_clk) begin
    if(!sys_rst_n)
        pixel_data <= BLACK;
    else begin
         if(  (pixel_xpos < SIDE_W) || (pixel_xpos >= H_DISP - SIDE_W)
           || (pixel_ypos < SIDE_W) || (pixel_ypos >= V_DISP - SIDE_W))
             pixel_data <= BLUE;                 //绘制屏幕边框为蓝色
         else
         if(  (pixel_xpos >= block_x) && (pixel_xpos < block_x + BLOCK_W)
           && (pixel_ypos >= block_y) && (pixel_ypos < block_y + BLOCK_W))
             pixel_data <= BLACK;                //绘制方块为黑色
         else
             pixel_data <= WHITE;                //绘制背景为白色
    end
end
endmodule