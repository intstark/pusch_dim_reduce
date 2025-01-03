//---------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------
module cpri_prb_comb_gen
    #(parameter	 AIU_NO   = 0,
		parameter	 CPRI_NO    = 1,
		parameter	 CHIP_COUNT = 36,
		parameter	 CHIP_LEN   = 96,
		parameter  CHIP_LOOP  = 12,
		parameter	 FF_DEPTH   = 4096,
		parameter	 FF_DW      = 12, 
		parameter  RAM_D_DW   = 12,
		parameter  RAM_P_DW   = 9,
		parameter	 DAT_DW     = 64,
		parameter	 CHIP_SYM   = 1, 
		parameter	 STATE_DW   = 8
		)
(
      input         		clk,
      input         		rst,
      
      
      output                sop_cpri_o ,
      output [DAT_DW-1:0]   dat_cpri0_o,
      output [DAT_DW-1:0]   dat_cpri1_o,      
      output [DAT_DW-1:0]   dat_cpri2_o,      
      output [DAT_DW-1:0]   dat_cpri3_o,      
      output [DAT_DW-1:0]   dat_cpri4_o,
      output [DAT_DW-1:0]   dat_cpri5_o,      
      output [DAT_DW-1:0]   dat_cpri6_o,      
      output [DAT_DW-1:0]   dat_cpri7_o      
);
//--------------------------------------------------------------------------------------------------------
      
//---------------------------------------------------------------------------------------------------------
reg [15:0]  dat_r_cnt    =0;
reg [2 :0]  symbol_cnt   =0;
wire        symbol_valid;
always @(posedge clk) begin 
    if(rst) begin 
        dat_r_cnt <= 'hffff;
    end 
    else if(dat_r_cnt == 'hffff) begin 
        dat_r_cnt <= 0;
    end 
    else if(dat_r_cnt >= 'd12671)  begin 
        dat_r_cnt <= 0;
    end 
    else begin 
        dat_r_cnt <= dat_r_cnt + 1'b1;
    end 
end 
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin 
        symbol_cnt <= 'd4;
    end 
    else if(dat_r_cnt >= 'd12671)  begin 
        if(symbol_cnt ==  'd4) begin 
            symbol_cnt <= 'd0;
        end 
        else begin 
            symbol_cnt <= symbol_cnt + 1'b1;
        end
    end 
end 
reg [7:0] chip_cnt=0;

always @(posedge clk) begin 
    if(rst) begin 
        chip_cnt <= 'd3000;
    end 
    else if(chip_cnt == 'd3000) begin 
        chip_cnt <= 0;
    end 
    else if(chip_cnt >= 'd95)  begin 
        chip_cnt <= 0;
    end 
    else begin 
        chip_cnt <= chip_cnt + 1'b1;
    end 
end 

assign symbol_valid = (symbol_cnt == 'd0);

wire [15:0] ram_rd_addr;
assign  ram_rd_addr = symbol_valid ? dat_r_cnt : 'd0;
wire        ram_rd_en;
assign  ram_rd_en = symbol_valid ? 1'b1 : 1'b0;
wire [63:0] ram_rd_q0;
wire [63:0] ram_rd_q1;
wire [63:0] ram_rd_q2;
wire [63:0] ram_rd_q3;
wire [63:0] ram_rd_q4;
wire [63:0] ram_rd_q5;
wire [63:0] ram_rd_q6;
wire [63:0] ram_rd_q7;

//rom_65536x64_L0 u_rom_65536x64_L0(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q0)
//);

//rom_65536x64_L1 u_rom_65536x64_L1(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q1)
//);

//rom_65536x64_L2 u_rom_65536x64_L2(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q2)
//);

//rom_65536x64_L3 u_rom_65536x64_L3(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q3)
//);

//rom_65536x64_L4 u_rom_65536x64_L4(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q4)
//);

//rom_65536x64_L5 u_rom_65536x64_L5(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q5)
//);

//rom_65536x64_L6 u_rom_65536x64_L6(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q6)
//);

//rom_65536x64_L7 u_rom_65536x64_L7(
//    .clka    (clk),
//    .addra   (ram_rd_addr),
//    .ena     (1'b1),
//    .douta   (ram_rd_q7)
//);


rom_65536x64_L0 u_rom_65536x64_L0(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q0)
);

rom_65536x64_L1 u_rom_65536x64_L1(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q1)
);

rom_65536x64_L2 u_rom_65536x64_L2(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q2)
);

rom_65536x64_L3 u_rom_65536x64_L3(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q3)
);

rom_65536x64_L4 u_rom_65536x64_L4(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q4)
);

rom_65536x64_L5 u_rom_65536x64_L5(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q5)
);

rom_65536x64_L6 u_rom_65536x64_L6(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q6)
);

rom_65536x64_L7 u_rom_65536x64_L7(
    .clock      (clk),
    .address    (ram_rd_addr),
    .rden       (1'b1),
    .q          (ram_rd_q7)
);


wire      sop_cpri;
assign    sop_cpri = (chip_cnt == 'd3);


reg [DAT_DW-1:0]   dat_cpri0 =0;
reg [DAT_DW-1:0]   dat_cpri1 =0;      
reg [DAT_DW-1:0]   dat_cpri2 =0;      
reg [DAT_DW-1:0]   dat_cpri3 =0;      
reg [DAT_DW-1:0]   dat_cpri4 =0;
reg [DAT_DW-1:0]   dat_cpri5 =0;      
reg [DAT_DW-1:0]   dat_cpri6 =0;      
reg [DAT_DW-1:0]   dat_cpri7 =0;
      
always @(posedge clk) begin 
     dat_cpri0  <=  ram_rd_q0;
     dat_cpri1  <=  ram_rd_q1;
     dat_cpri2  <=  ram_rd_q2;
     dat_cpri3  <=  ram_rd_q3;
     dat_cpri4  <=  ram_rd_q4;
     dat_cpri5  <=  ram_rd_q5;
     dat_cpri6  <=  ram_rd_q6;
     dat_cpri7  <=  ram_rd_q7;
end 


assign    dat_cpri0_o = dat_cpri0;
assign    dat_cpri1_o = dat_cpri1;
assign    dat_cpri2_o = dat_cpri2;
assign    dat_cpri3_o = dat_cpri3;
assign    dat_cpri4_o = dat_cpri4;
assign    dat_cpri5_o = dat_cpri5;
assign    dat_cpri6_o = dat_cpri6;
assign    dat_cpri7_o = dat_cpri7;       
assign    sop_cpri_o  = sop_cpri ;
//---------------------------------------------------------------------------------------------------------
endmodule
//---------------------------------------------------------------------------------------------------------
