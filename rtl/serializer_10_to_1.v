module serializer_10_to_1(
    input               serial_clk_5x,//输入串行数据时钟
    input    [9:0]      paralell_data,//输入并行数据

    output              serial_data_p,//输出串行差分数据p
    output              serial_data_n //输出串行差分数据N
);

reg [2:0] bit_cnt = 0;
reg [4:0] datain_rise_shift = 0;
reg [4:0] datain_fall_shift = 0;

wire [4:0] datain_rise;
wire [4:0] datain_fall;

//拆分数据
assign datain_rise = {paralell_data[8],paralell_data[6],paralell_data[4],
                      paralell_data[2],paralell_data[0]};

assign datain_fall = {paralell_data[9],paralell_data[7],paralell_data[5],
                      paralell_data[3],paralell_data[1]};

//位计数器
always @(posedge serial_clk_5x) begin
    if(bit_cnt == 3'd4)
        bit_cnt <= 1'b0;
    else
        bit_cnt <= bit_cnt + 1'b1;
end

//移位寄存器，用于并行数据的每一位
always @(posedge serial_clk_5x) begin
    if(bit_cnt == 3'd4)begin
        datain_rise_shift <= datain_rise;
        datain_fall_shift <= datain_fall;
    end
    else begin
        datain_rise_shift <= datain_rise_shift[4:1];
        datain_fall_shift <= datain_fall_shift[4:1];
    end
end

//例化DDIO_OUT IP核，因为我们我们是差分传输，实际上是两条线，需要例化两个IP
ddio_out ddio_out_inst_1(
    .datain_h    (datain_rise_shift[0]),
    .datain_l    (datain_fall_shift[0]),
    .outclock    (serial_clk_5x),
    .dataout     (serial_data_p)
);
ddio_out ddio_out_inst_2(
    .datain_h    (~datain_rise_shift[0]),
    .datain_l    (~datain_fall_shift[0]),
    .outclock    (serial_clk_5x),
    .dataout     (serial_data_n)
);
endmodule