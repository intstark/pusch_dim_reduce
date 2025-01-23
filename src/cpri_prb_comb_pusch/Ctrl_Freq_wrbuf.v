//---------------------------------------------------------------------------------------------------------
//slw
//---------------------------------------------------------------------------------------------------------
module Ctrl_Freq_wrbuf
    #(  
//      parameter [1:0]  AIU_NO     = 0,
//		parameter        CPRI_NO    = 0,
		parameter        CHIP_LEN   = 96,
		parameter        CHIP_LOOP  = 12,
		parameter        FF_DEPTH   = 256,
		parameter        FF_DW      = 11, 
//		parameter        RAM_D_DW   = 12,
//		parameter        RAM_P_DW   = 9,
		parameter        DAT_DW     = 64,
		parameter        SRS_RAM_DW = 10,
		parameter        SRS_RAM_DH = 512,
		parameter [15:0] CHIP_SYM   = 14'b0000_0000_0000_0001,
	    parameter        CHIP_SLOT  = 4
//	    parameter [1:0]  CHANNEL    = 2'd0
	)
(
      input                  clk               ,
      input                  rst               ,
      input [1:0]            channel_i         ,
      
      input                  pus_sop_i         ,
      input [DAT_DW-1:0]     pus_dat_i         ,  
            
      output [12 :0]         wr_daddr          ,         
      output [63 :0]         wr_ddat           ,                                                        
      output                 wr_dwen_oa        ,       
      output                 wr_dwen_ea        ,       
                 
      output  [8  :0]        wr_paddr          ,                    
      output  [111:0]        wr_pdat           ,
      output                 wr_pwen_oa        ,     
      output                 wr_pwen_ea        ,
                                    
      output  [1:0]          ant_wr_odd_end_o  ,
      input   [1:0]          ant_wr_odd_clr    ,     
      output  [1:0]          ant_wr_even_end_o ,     
      input   [1:0]          ant_wr_even_clr  
);

//---------------------------------------------------------------------------------------------------------
wire [DAT_DW-1:0]    pus_dat_ir [0:3];
wire                 pus_sop_ir [0:3];
wire [1:0]           CHANNEL;
assign CHANNEL   =   channel_i;

wire                pus_sop_or [0:3];
wire [DAT_DW-1:0]   pus_dat_or [0:3];

assign pus_sop0_o = pus_sop_or[0];
assign pus_sop1_o = pus_sop_or[1];
assign pus_sop2_o = pus_sop_or[2];
assign pus_sop3_o = pus_sop_or[3];

assign pus_dat0_o = pus_dat_or[0];
assign pus_dat1_o = pus_dat_or[1];
assign pus_dat2_o = pus_dat_or[2];
assign pus_dat3_o = pus_dat_or[3];

wire [12 :0]        wr_daddr_or;
wire [63 :0]        wr_ddat_or ;
wire [8  :0]        wr_paddr_or;
wire [111:0]        wr_pdat_or ;
wire                wr_dwen_or  [0:3];
wire                wr_pwen_or  [0:3];
//---------------------------------------------------------------------------------------------------------

reg  [8:0]          sop_dly;
reg  [DAT_DW-1:0]   dat_dly [0:8];

always @(posedge clk) begin 
    if(rst) begin 
        sop_dly    <=    'd0;
        dat_dly[0] <=  64'd0;
        dat_dly[1] <=  64'd0;
        dat_dly[2] <=  64'd0;
        dat_dly[3] <=  64'd0;
        dat_dly[4] <=  64'd0;
        dat_dly[5] <=  64'd0;
        dat_dly[6] <=  64'd0;
        dat_dly[7] <=  64'd0;
        dat_dly[8] <=  64'd0;
    end 
    else begin 
        sop_dly    <= {sop_dly[7:0],pus_sop_i};
        dat_dly[0] <=  pus_dat_i;
        dat_dly[1] <=  dat_dly[0];
        dat_dly[2] <=  dat_dly[1];
        dat_dly[3] <=  dat_dly[2];
        dat_dly[4] <=  dat_dly[3];
        dat_dly[5] <=  dat_dly[4];    
        dat_dly[6] <=  dat_dly[5];    
        dat_dly[7] <=  dat_dly[6];    
        dat_dly[8] <=  dat_dly[7];    
    end 
end 
//---------------------------------------------------------------------------------------------------------

reg [3:0] chip_flag_a;
reg [3:0] chip_flag_b;
reg [7:0] dat_cnt;
reg       dat1_vld;
reg       dat2_vld;
always @(posedge clk) begin 
    if(rst)  
        dat1_vld <= 1'b0;
    else if(sop_dly[5]) 
        dat1_vld <= 1'b1;
    else if(dat_cnt>='d42)  
        dat1_vld <= 1'b0;
    else ;
end 

wire   data_ram0_wren; 
wire   data_ram1_wren; 
wire   data_ram2_wren; 
wire   data_ram3_wren; 
wire   para_ram0_wren; 
wire   para_ram1_wren; 
wire   para_ram2_wren; 
wire   para_ram3_wren;

assign para_ram0_wren = sop_dly[6] ? chip_flag_a[0] : (sop_dly[7] ? chip_flag_b[0] : 1'b0);
assign para_ram1_wren = sop_dly[6] ? chip_flag_a[1] : (sop_dly[7] ? chip_flag_b[1] : 1'b0);
assign para_ram2_wren = sop_dly[6] ? chip_flag_a[2] : (sop_dly[7] ? chip_flag_b[2] : 1'b0);
assign para_ram3_wren = sop_dly[6] ? chip_flag_a[3] : (sop_dly[7] ? chip_flag_b[3] : 1'b0);
//---------------------------------------------------------------------------------------------------------

reg dat1_vld_dly;
reg dat2_vld_dly;
always @(posedge clk) begin
    dat1_vld_dly <= dat1_vld;
    dat2_vld_dly <= dat2_vld;
end 

wire   dat1_vld_rise;
wire   dat2_vld_rise;
assign dat1_vld_rise = (dat1_vld && (~dat1_vld_dly));
assign dat2_vld_rise = (dat2_vld && (~dat2_vld_dly));

assign data_ram0_wren = dat1_vld_dly ? chip_flag_a[0] : (dat2_vld_dly ? chip_flag_b[0] : 1'b0);
assign data_ram1_wren = dat1_vld_dly ? chip_flag_a[1] : (dat2_vld_dly ? chip_flag_b[1] : 1'b0);
assign data_ram2_wren = dat1_vld_dly ? chip_flag_a[2] : (dat2_vld_dly ? chip_flag_b[2] : 1'b0);
assign data_ram3_wren = dat1_vld_dly ? chip_flag_a[3] : (dat2_vld_dly ? chip_flag_b[3] : 1'b0);
//---------------------------------------------------------------------------------------------------------

always @(posedge clk) begin 
    if(rst)  
        dat_cnt <= 'd0;
    else if(sop_dly[5]) 
        dat_cnt <= 'd1;
    else if(dat_cnt>='d84)  
        dat_cnt <= 'd0;
    else if(dat_cnt > 0)
        dat_cnt <= dat_cnt + 1'b1;
end 

always @(posedge clk) begin 
    if(rst)  
        dat2_vld <= 1'b0;
    else if((dat_cnt>='d42)&&dat_cnt<='d83)
        dat2_vld <= 1'b1;
    else 
        dat2_vld <= 1'b0;
end 

//---------------------------------------------------------------------------------------------------------
reg [DAT_DW-1:0] Iq_hd_reg;
always @(posedge clk) begin 
    if(rst)  
        Iq_hd_reg <= 64'd0;
    else if(sop_dly[2])  
        Iq_hd_reg <= pus_dat_i;
    else ;
end 
//---------------------------------------------------------------------------------------------------------
reg [31:0] FFT_AGC1;
reg [31:0] FFT_AGC2;

always @(posedge clk) begin
    if(rst) begin 
        FFT_AGC1 <= 32'd0;
        FFT_AGC2 <= 32'd0;
    end
    else if(sop_dly[3]) begin 
        FFT_AGC1 <= pus_dat_i[63:32];
        FFT_AGC2 <= pus_dat_i[31: 0]; 
    end
    else ;
end
//---------------------------------------------------------------------------------------------------------
//dat_dly[0] <=  pus_dat_i
reg [31:0] AGC_0L,AGC_0H;
reg [31:0] AGC_1L,AGC_1H;
always @(posedge clk) begin
    if(rst) begin     
        AGC_0L <= 32'd0;
        AGC_0H <= 32'd0;    
        AGC_1L <= 32'd0;
        AGC_1H <= 32'd0;         
    end
    else if(sop_dly[5]) begin   
        AGC_0L <= {dat_dly[0][47:32],dat_dly[0][15:0]};//32'd0;
        AGC_0H <= {pus_dat_i[47:32] ,pus_dat_i[15:0] };//32'd0;
        AGC_1L <= {dat_dly[0][63:48],dat_dly[0][31:16]};//32'd0; 
        AGC_1H <= {pus_dat_i[63:48] ,pus_dat_i[31:16] };//32'd0;    
    end
    else ;
end

//---------------------------------------------------------------------------------------------------------
//always @(posedge clk) begin
//    if(rst) begin         
//        AGC_1L <= 16'd0;
//        AGC_1H <= 16'd0;        
//    end
//    else if(sop_dly[5]) begin        
//        AGC_1L <= pus_dat_i[31 :0];
//        AGC_1H <= pus_dat_i[63:32];        
//    end
//    else ;
//end
//---------------------------------------------------------------------------------------------------------
wire [3:0]  aiu_rbG_num  ;
wire [1:0]  aiu_num      ;
wire [2:0]  ant_grp_num  ;
wire [3:0]  chip_ch_type ;
wire [7:0]  chip_prb_idx1;
wire [7:0]  chip_prb_idx2;
wire        chip_cell_idx;
wire [6:0]  chip_slot_idx;
wire [3:0]  chip_syml_idx;
wire [3:0]  chip_ant1_idx;
wire [3:0]  chip_ant2_idx;

assign  aiu_rbG_num    = Iq_hd_reg[48:45];
assign  aiu_num        = Iq_hd_reg[44:43];
assign  ant_grp_num    = Iq_hd_reg[42:40];
assign  chip_ch_type   = Iq_hd_reg[39:36];
assign  chip_prb_idx1  = Iq_hd_reg[35:28];
assign  chip_prb_idx2  = Iq_hd_reg[27:20];
assign  chip_cell_idx  = Iq_hd_reg[   19];
assign  chip_slot_idx  = Iq_hd_reg[18:12];
assign  chip_syml_idx  = Iq_hd_reg[11: 8];
assign  chip_ant1_idx  = Iq_hd_reg[ 7: 4];
assign  chip_ant2_idx  = Iq_hd_reg[ 3: 0];

wire [107:0] para_idx1; 
wire [107:0] para_idx2; 
assign para_idx1 = {chip_cell_idx,chip_slot_idx,chip_syml_idx,FFT_AGC1,AGC_0H,AGC_0L};
assign para_idx2 = {chip_cell_idx,chip_slot_idx,chip_syml_idx,FFT_AGC2,AGC_1H,AGC_1L};
                       //1              7           4           32          32     16     16     16     16
//assign  para_idx = {chip_cell_idx,chip_slot_idx,chip_syml_idx,FFT_AGC2,FFT_AGC1,AGC_1H,AGC_0H,AGC_1L,AGC_0L};
//---------------------------------------------------------------------------------------------------------
wire    prb_match;
wire    ant_match;
wire    E8_ant_flag;
assign  prb_match    = (chip_prb_idx1 == chip_prb_idx2);
assign  ant_match    = (chip_ant1_idx == chip_ant2_idx);
assign  E8_ant_flag  = (~prb_match) && (~ant_match) ;
//---------------------------------------------------------------------------------------------------------
reg [1:0] chip_grp_num_a;
reg [1:0] chip_grp_num_b;
always @(posedge clk) begin 
    if(rst) begin
        chip_flag_a    <= 4'b0000;
        chip_flag_b    <= 4'b0000;
        chip_grp_num_a <= 2'd0;
        chip_grp_num_b <= 2'd0;
    end
    else if(sop_dly[3]) begin
        if(ant_grp_num[0] == 1'b0) begin    // ant group : 0 , 0-7;1 , 8-15   ===1
            if(chip_ant1_idx == 4'd0) begin // ant : 0000 ,even ;0001,odd
                chip_flag_a    <= 4'b0001;
                chip_grp_num_a <= 2'd0;
            end 
            else if(chip_ant1_idx == 4'd1) begin 
                chip_flag_a    <= 4'b0100;
                chip_grp_num_a <= 2'd2;
            end 
            else ;
        end
        else begin 
            if(chip_ant1_idx == 4'd0) begin 
                chip_flag_a    <= 4'b0010;
                chip_grp_num_a <= 2'd1;
            end 
            else if(chip_ant1_idx == 4'd1) begin 
                chip_flag_a    <= 4'b1000;
                chip_grp_num_a <= 2'd3;
            end 
            else ;        
        end 
        
        if(ant_grp_num[0] == 1'b0) begin 
            if(chip_ant2_idx == 4'd0) begin 
                chip_flag_b    <= 4'b0001;
                chip_grp_num_b <= 2'd0;
            end 
            else if(chip_ant2_idx == 4'd1) begin 
                chip_flag_b    <= 4'b0100;
                chip_grp_num_b <= 2'd2;
            end 
            else ;
        end
        else begin 
            if(chip_ant2_idx == 4'd0) begin 
                chip_flag_b    <= 4'b0010;
                chip_grp_num_b <= 2'd1;
            end 
            else if(chip_ant2_idx == 4'd1) begin 
                chip_flag_b    <= 4'b1000;
                chip_grp_num_b <= 2'd3;
            end 
            else ;        
        end         
    end
    else ; 
end 

reg [2:0] channel_num;
always @(posedge clk) begin 
    if(rst) begin
        channel_num    <= 3'd0;
    end
    else if(sop_dly[3]) begin
        channel_num    <= 3'd0;
    end
end 
//---------------------------------------------------------------------------------------------------------
wire [10:0] chip_prb1_addr_idx;
wire [10:0] chip_prb2_addr_idx;
assign chip_prb1_addr_idx = {chip_prb_idx1[7:2],5'd0}+{chip_prb_idx1[7:2],3'd0}+{chip_prb_idx1[7:2],1'd0};
assign chip_prb2_addr_idx =  ant_match ? (chip_prb1_addr_idx + 'd42) : ({chip_prb_idx2[7:2],5'd0}+{chip_prb_idx2[7:2],3'd0}+{chip_prb_idx2[7:2],1'd0});

wire [11:0] chip_prb1_addr_comb_base;
wire [11:0] chip_prb2_addr_comb_base;
assign chip_prb1_addr_comb_base    =  chip_prb1_addr_idx;
assign chip_prb2_addr_comb_base    =  chip_prb2_addr_idx;

//---------------------------------------------------------------------------------------------------------
wire  [6:0] para_addr1;
wire  [6:0] para_addr2;
assign  para_addr1 =  chip_prb_idx1[7:2];
assign  para_addr2 =  ant_match ? (para_addr1 + 'd1) : chip_prb_idx2[7:2];

wire [7:0] para_addr1_base;
wire [7:0] para_addr2_base;
assign para_addr1_base  = para_addr1;
assign para_addr2_base  = para_addr2;
//---------------------------------------------------------------------------------------------------------
wire         para_vld;
wire [7  :0] para_addr;
wire [107:0] para_idx;
assign para_addr = sop_dly[7] ? para_addr2_base : para_addr1_base;
assign para_idx  = sop_dly[7] ? para_idx2  : para_idx1 ;
//---------------------------------------------------------------------------------------------------------
reg [11:0] chip_prb1_addr_comb_idx;
always @(posedge clk) begin 
    if(rst) begin 
        chip_prb1_addr_comb_idx <= 0;
    end 
    else if(dat1_vld_rise) begin 
        chip_prb1_addr_comb_idx <= chip_prb1_addr_comb_base;    
    end 
    else if(dat1_vld_dly) begin 
        chip_prb1_addr_comb_idx <= chip_prb1_addr_comb_idx + 1'b1;    
    end  
    else ;
end 
//---------------------------------------------------------------------------------------------------------
reg [11:0] chip_prb2_addr_comb_idx;
always @(posedge clk) begin 
    if(rst) begin 
        chip_prb2_addr_comb_idx <= 0;
    end 
    else if(dat2_vld_rise) begin 
        chip_prb2_addr_comb_idx <= chip_prb2_addr_comb_base;    
    end 
    else if(dat2_vld_dly) begin 
        chip_prb2_addr_comb_idx <= chip_prb2_addr_comb_idx + 1'b1;    
    end  
    else ;
end

wire [11:0] chip_prb_addr_idx;
assign  chip_prb_addr_idx = dat2_vld_dly ? chip_prb2_addr_comb_idx : chip_prb1_addr_comb_idx;
//---------------------------------------------------------------------------------------------------------
reg [1:0]  chip_symbol_ram_idx;
always @(posedge clk) begin 
    chip_symbol_ram_idx <= chip_syml_idx[0] ?  2'b10 : 2'b01;
end 
//---------------------------------------------------------------------------------------------------------
reg [1:0]   ant_wr_odd_end      [0:3];
reg [1:0]   ant_wr_even_end     [0:3];
wire        ant_wr_odd_end_fg   [0:3];
wire        ant_wr_even_end_fg  [0:3];

wire [3:0] data_ram_wren;
wire [3:0] para_ram_wren;
assign     data_ram_wren = {data_ram3_wren,data_ram2_wren,data_ram1_wren,data_ram0_wren};
assign     para_ram_wren = {para_ram3_wren,para_ram2_wren,para_ram1_wren,para_ram0_wren};
//---------------------------------------------------------------------------------------------------------
reg [1:0] ant_wr_eo_end [0:3];

genvar i;
generate
for(i=0; i<=3; i=i+1)begin
   
    always @(posedge clk) begin 
        if(rst) begin 
            ant_wr_even_end[i]  <= 2'b00;
            ant_wr_odd_end[i]   <= 2'b00;
        end
        else if(sop_dly[6] &&( i == CHANNEL)) begin 
            if(~chip_syml_idx[0]) begin 
                if((chip_prb_idx1 == 'd128)) begin //偶天线
                    ant_wr_even_end[i][0] <= 1'b1;
                    ant_wr_even_end[i][1] <= ant_wr_even_end[i][1];
                end
                else if((chip_prb_idx2 == 'd128)) begin //奇天线
                    ant_wr_even_end[i][1] <= 1'b1;
                    ant_wr_even_end[i][0] <= ant_wr_even_end[i][0];
                end
            end 
            else begin 
                if((chip_prb_idx1 == 'd128)) begin //偶天线
                    ant_wr_odd_end[i][0] <= 1'b1;
                    ant_wr_odd_end[i][1] <= ant_wr_odd_end[i][1];
                end
                else if((chip_prb_idx2 == 'd128)) begin //奇天线
                    ant_wr_odd_end[i][1] <= 1'b1;
                    ant_wr_odd_end[i][0] <= ant_wr_odd_end[i][0];
                end           
            end 
        end 
        else if(|ant_wr_even_clr) begin 
            if(i == CHANNEL) begin 
                if(ant_wr_even_clr[0]) begin
                    ant_wr_even_end[i][0] <= 1'b0;
                end
                else begin 
                    ant_wr_even_end[i][0] <= ant_wr_even_end[i][0];
                end 
            
                if(ant_wr_even_clr[1]) begin
                    ant_wr_even_end[i][1] <= 1'b0;
                end
                else begin 
                    ant_wr_even_end[i][1] <= ant_wr_even_end[i][1]; 
                end
            end
        end 
        else if(|ant_wr_odd_clr) begin 
            if(i == CHANNEL) begin 
                if(ant_wr_odd_clr[0]) begin
                    ant_wr_odd_end[i][0] <= 1'b0;
                end
                else begin 
                    ant_wr_odd_end[i][0] <= ant_wr_odd_end[i][0];
                end 
            
                if(ant_wr_odd_clr[1]) begin
                    ant_wr_odd_end[i][1] <= 1'b0;
                end
                else begin 
                    ant_wr_odd_end[i][1] <= ant_wr_odd_end[i][1]; 
                end
            end
        end           
        else ; 
    end 
   
    assign wr_dwen_or[i]  =  data_ram_wren[i];
    assign wr_pwen_or[i]  =  |sop_dly[7:6] && para_ram_wren[i];    
end

endgenerate

assign wr_daddr_or        = {chip_syml_idx[0],chip_prb_addr_idx};
assign wr_ddat_or         = dat_dly[0] ;

assign wr_daddr           = wr_daddr_or;
assign wr_ddat            = wr_ddat_or ;

assign wr_dwen_ea         = (CHANNEL[0] ? wr_dwen_or[1] : wr_dwen_or[0]) ; 
assign wr_dwen_oa         = (CHANNEL[0] ? wr_dwen_or[3] : wr_dwen_or[2]) ; 
assign wr_pwen_ea         = (CHANNEL[0] ? wr_pwen_or[1] : wr_pwen_or[0]) ; 
assign wr_pwen_oa         = (CHANNEL[0] ? wr_pwen_or[3] : wr_pwen_or[2]) ; 

assign wr_paddr_or        = {chip_syml_idx[0],para_addr};
assign wr_pdat_or         = {4'd0,para_idx};

assign wr_paddr           =  wr_paddr_or;
assign wr_pdat            =  wr_pdat_or ;

assign ant_wr_odd_end_o   =  chip_syml_idx[0] ? ant_wr_odd_end[CHANNEL]   : 2'b00; 
assign ant_wr_even_end_o  = ~chip_syml_idx[0] ? ant_wr_even_end[CHANNEL]  : 2'b00;   
//---------------------------------------------------------------------------------------------------------
endmodule
//---------------------------------------------------------------------------------------------------------
