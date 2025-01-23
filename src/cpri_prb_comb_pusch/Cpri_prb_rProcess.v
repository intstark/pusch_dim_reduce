//---------------------------------------------------------------------------------------------------------
//slw
//---------------------------------------------------------------------------------------------------------
module Cpri_prb_rProcess
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
	   parameter        CHIP_SLOT  = 4,
	   parameter [2:0]  CPRI_CH    = 0
	)
(
      input                  clk                 ,
      input                  rst                 ,
      
      input [12:0]           wr_daddr0            ,
      input [DAT_DW-1:0]     wr_ddat0             ,
      input                  wr_dwen0             , 

      input [12:0]           wr_daddr1            ,
      input [DAT_DW-1:0]     wr_ddat1             ,
      input                  wr_dwen1             , 
       
      input                  wr_symbol           ,
 
      input [8  :0]          wr_paddr0            ,
      input [107:0]          wr_pdat0             ,
      input                  wr_pwen0             , 
      
      input [8  :0]          wr_paddr1            ,
      input [107:0]          wr_pdat1             ,
      input                  wr_pwen1             ,      

      input  [1:0]           ant_wr_odd_end      ,
      output reg             ant_wr_odd_clr      , 
      input  [1:0]           ant_wr_even_end     ,
      output reg             ant_wr_even_clr     ,
                                                
      output                 Cpri_sop_o          ,
      output [DAT_DW-1:0]    Cpri_dat_o
);
//---------------------------------------------------------------------------------------------------------
wire [11 :0]       rd_daddr0   ;
wire [63 :0]       rd_dq0      ;
wire [11 :0]       rd_daddr1   ;
wire [63 :0]       rd_dq1      ;
reg  [7  :0]       rd_paddr0  ;
wire [107:0]       rd_pq0     ;
reg  [7  :0]       rd_paddr1  ;
wire [107:0]       rd_pq1     ;
reg                evn_odd_flg;


Simple_Dual_Port_BRAM_XPM_intel
  #(    
//   .MEMORY_SIZE          (64*(2**13) ),
     .WDATA_WIDTH          (64         ),
     .NUMWORDS_A           (8192       ),
     .RDATA_WIDTH          (64         ),
     .NUMWORDS_B           (8192       )
  ) 
 INST_DAT_URAM0                                         
 (                                                                   
     .clock                   (clk                      ),
     .wren                    ({(64/8){wr_dwen0}}       ),
     .wraddress               ( wr_daddr0               ),     
     .data                    ( wr_ddat0                ),
     .rdaddress               ({evn_odd_flg,rd_daddr0}  ),
     .q                       (rd_dq0                   )
 ); 

 
Simple_Dual_Port_BRAM_XPM_intel
  #(    
//   .MEMORY_SIZE          (64*(2**13) ),
     .WDATA_WIDTH          (64         ),
     .NUMWORDS_A           (8192       ),
     .RDATA_WIDTH          (64         ),
     .NUMWORDS_B           (8192       )
  ) 
 INST_DAT_URAM1                                         
 (                                                                   
     .clock                    (clk                      ),
     .wren                     ({(64/8){wr_dwen1}}       ),
     .wraddress                (wr_daddr1                ),     
     .data                     (wr_ddat1                 ),
     .rdaddress                ({evn_odd_flg,rd_daddr1}  ),
     .q                        (rd_dq1                   )
 ); 
//---------------------------------------------------------------------------------------------------------
Simple_Dual_Port_BRAM_XPM_intel
  #(    
//   .MEMORY_SIZE          (64*(2**9)  ),
     .WDATA_WIDTH          (112         ),
     .NUMWORDS_A           (512        ),
     .RDATA_WIDTH          (112         ),
     .NUMWORDS_B           (512        )
  ) 
 INST_AGC_PARA_URAM0                                         
 (                                                                   
     .clock                     (clk                      ),
     .wren                      ({(112/8){wr_pwen0}}      ),
     .wraddress                 ( wr_paddr0               ),     
     .data                      ({4'd0,wr_pdat0 }         ),
     .rdaddress                 ( {evn_odd_flg,rd_paddr0} ),
     .q                         ( rd_pq0                  )
 ); 

Simple_Dual_Port_BRAM_XPM_intel
  #(    
//   .MEMORY_SIZE          (64*(2**9)  ),
     .WDATA_WIDTH          (112         ),
     .NUMWORDS_A           (512        ),
     .RDATA_WIDTH          (112         ),
     .NUMWORDS_B           (512        )
  ) 
 INST_AGC_PARA_URAM1                                         
 (                                                                   
      .clock                    (clk                      ),
      .wren                     ({(112/8){wr_pwen1}}      ),
      .wraddress                ( wr_paddr1               ),     
      .data                     ({4'd0,wr_pdat1 }         ),
      .rdaddress                ( {evn_odd_flg,rd_paddr1} ),
      .q                        ( rd_pq1                  )
 ); 
//--------------------------------------------------------------------------------------------------------- 
reg  [7:0]   dat_per_cnt      ;
reg          chip_cell_idx    ;
reg  [6 :0]  chip_slot_idx    ;
reg  [3 :0]  chip_syml_idx    ;
reg  [31:0]  FFT_AGC1,FFT_AGC2;
reg  [31:0]  AGC_0H,AGC_0L    ;
reg  [31:0]  AGC_1H,AGC_1L    ;
wire [3 :0]  pkg_ch_type      ;
wire [2 :0]  cpri_num         ;
reg  [1 :0]  aiu_num          ;

assign pkg_ch_type    =  4'b1000;
assign cpri_num       = {2'b00,CPRI_CH[1]};
always @(posedge clk) begin 
    if(rst) begin 
        aiu_num <= 0;
    end
    else begin 
//        if(CPRI_CH[1]) begin 
//            if(dat_per_cnt <= 'd16) begin 
//                aiu_num <= 2'd2;
//            end
//            else begin 
//                aiu_num <= 2'd3;
//            end 
//        end
//        else begin 
//            if(dat_per_cnt <= 'd16) begin 
//                aiu_num <= 2'd0;
//            end
//            else begin 
//                aiu_num <= 2'd1;
//            end       
//        end 
          if(dat_per_cnt <= 'd16) begin 
              aiu_num <= 2'd0;
          end
          else begin 
              aiu_num <= 2'd1;
          end       
     end 
end 

//--------------------------------------------------------------------------------------------------------- 
reg  [31:0] FFT_AGC1_r;
reg  [31:0] AGC_0H_r  ;
reg  [31:0] AGC_0L_r  ;
always @(posedge clk) begin
    FFT_AGC1_r <= FFT_AGC1;
    AGC_0H_r   <= AGC_0H  ;
    AGC_0L_r   <= AGC_0L  ;
end 
//--------------------------------------------------------------------------------------------------------- 
reg [7:0]   hdr_pro_cnt;
reg [7:0]   dat_pro_cnt;
reg [7:0]   res_pro_cnt;

reg [63:0]  FFT_AGC;
reg [63:0]  AGC0   ;
reg [63:0]  AGC1   ;

//--------------------------------------------------------------------------------------------------------- 
reg  [3:0]   chip_ant1_idx;
reg  [3:0]   chip_ant2_idx;
always @(posedge clk) begin 
    if(rst) begin 
        chip_ant1_idx <= 0;
        chip_ant2_idx <= 0;
    end 
    else begin 
        if(~CPRI_CH[0]) begin 
            chip_ant1_idx <= 4'b0000;
            chip_ant2_idx <= 4'b0000;
        end 
        else begin 
            chip_ant1_idx <= 4'b0001;
            chip_ant2_idx <= 4'b0001;        
        end
    end 
end 
//---------------------------------------------------------------------------------------------------------
reg  [7:0]   chip_prb1_idx;
reg  [7:0]   chip_prb2_idx;

wire [4:0] dat_per_cnt_ap;
wire [4:0] dat_per_cnt_ap_pro;
assign  dat_per_cnt_ap = (dat_per_cnt > 'd16) ? (dat_per_cnt-'d16) : dat_per_cnt;
assign  dat_per_cnt_ap_pro = ({dat_per_cnt_ap,1'b0});
always @(posedge clk) begin 
    if(rst) begin 
        chip_prb1_idx <= 0;
        chip_prb2_idx <= 0;
    end 
    else if(dat_per_cnt == 'd16) begin 
        chip_prb1_idx <= {dat_per_cnt[4:0],3'd0};
        chip_prb2_idx <= 'd0;
    end 
    else if(dat_per_cnt > 'd16) begin 
        chip_prb1_idx <= {dat_per_cnt_ap,3'd0}-'d4;
        chip_prb2_idx <= {dat_per_cnt_ap,3'd0};
    end   
    else  begin 
        chip_prb1_idx <= {dat_per_cnt[4:0],3'd0};
        chip_prb2_idx <= {dat_per_cnt[4:0],3'd0}+'d4;
    end       
end 

//---------------------------------------------------------------------------------------------------------
wire        pus_srs_flag; 
assign      pus_srs_flag = 1'b0;
wire [63:0] IQ_hd; 
assign      IQ_hd = {pus_srs_flag,18'd0,aiu_num,cpri_num,pkg_ch_type,chip_prb1_idx,chip_prb2_idx,chip_cell_idx,chip_slot_idx,chip_syml_idx,chip_ant1_idx,chip_ant2_idx};
// 1+18+2+3+4+8+8+1+7+4+4+4=64
//---------------------------------------------------------------------------------------------------------
//state ctrl
localparam[3:0]     IDLE		=   'b0001,
                    HD_PRO  	=	'b0010,
					DAT_PRO		=	'b0100,
					RES_PRO     =   'b1000;
//---------------------------------------------------------------------------------------------------------
reg [3:0]  state,nt_state;
always @(posedge clk) begin 
    if(rst) begin 
        state <= IDLE;
    end 
    else begin 
        state <= nt_state;
    end 
end 
//---------------------------------------------------------------------------------------------------------
wire        hd_pro_end ;
wire        dat_pro_end;
wire        res_pro_end;
wire        res_pro_bfend;

reg  ant_wr_even_end0;
reg  ant_wr_even_end1;
always @(posedge clk) begin 
    if(rst) begin 
        ant_wr_even_end0 <= 0;
        ant_wr_even_end1 <= 0;
    end 
    else begin 
        ant_wr_even_end0 <= ant_wr_even_end[0];
        ant_wr_even_end1 <= ant_wr_even_end[1];
    end 
end 

reg  ant_wr_even_end0r;
reg  ant_wr_even_end1r;

always @(posedge clk) begin 
    if(rst) begin 
        ant_wr_even_end0r <= 0;
    end 
    else if(ant_wr_even_end[0]&&(~ant_wr_even_end0)) begin 
        ant_wr_even_end0r <= 1'b1;
    end 
    else if(state[0] && ant_wr_even_end0r && ant_wr_even_end1r) begin 
        ant_wr_even_end0r <= 1'b0;
    end 
end 

always @(posedge clk) begin 
    if(rst) begin 
        ant_wr_even_end1r <= 0;
    end 
    else if(ant_wr_even_end[1]&&(~ant_wr_even_end1)) begin 
        ant_wr_even_end1r <= 1'b1;
    end 
    else if(state[0] && ant_wr_even_end0r && ant_wr_even_end1r) begin 
        ant_wr_even_end1r <= 1'b0;
    end 
end 

reg  ant_wr_odd_end0;
reg  ant_wr_odd_end1;
always @(posedge clk) begin 
    if(rst) begin 
        ant_wr_odd_end0 <= 0;
        ant_wr_odd_end1 <= 0;
    end 
    else begin 
        ant_wr_odd_end0 <= ant_wr_odd_end[0];
        ant_wr_odd_end1 <= ant_wr_odd_end[1];
    end 
end 

reg  ant_wr_odd_end0r;
reg  ant_wr_odd_end1r;

always @(posedge clk) begin 
    if(rst) begin 
        ant_wr_odd_end0r <= 0;
    end 
    else if(ant_wr_odd_end[0]&&(~ant_wr_odd_end0)) begin 
        ant_wr_odd_end0r <= 1'b1;
    end 
    else if(state[0] && ant_wr_odd_end0r && ant_wr_odd_end1r) begin 
        ant_wr_odd_end0r <= 1'b0;
    end 
end 

always @(posedge clk) begin 
    if(rst) begin 
        ant_wr_odd_end1r <= 0;
    end 
    else if(ant_wr_odd_end[1]&&(~ant_wr_odd_end1)) begin 
        ant_wr_odd_end1r <= 1'b1;
    end 
    else if(state[0] && ant_wr_odd_end0r && ant_wr_odd_end1r) begin 
        ant_wr_odd_end1r <= 1'b0;
    end 
end 

always @(*) begin
        case(state) 
        IDLE   : begin 
            if(ant_wr_even_end0r && ant_wr_even_end1r) begin
                nt_state     = HD_PRO;
            end
            else if(ant_wr_odd_end0r && ant_wr_odd_end1r) begin 
                nt_state     = HD_PRO;
            end 
            else begin
                nt_state     = IDLE ;
            end
        end 
        
        HD_PRO : begin 
            if(hd_pro_end) begin
                nt_state = DAT_PRO;
            end
            else begin
                nt_state = HD_PRO ;
            end        
        end 
        
        DAT_PRO: begin 
            if(dat_pro_end) begin
                nt_state = RES_PRO ;
            end
            else begin
                nt_state = DAT_PRO ;
            end          
        end 
        
        RES_PRO : begin 
            if(res_pro_bfend && (dat_per_cnt == 'd32)) begin
                nt_state = IDLE;  //RES_PRO ;
            end
            else if(res_pro_end) begin 
                nt_state = HD_PRO;  //RES_PRO ;
            end 
            else begin 
                nt_state = RES_PRO ;
            end  
        end
          
        default: begin 
            nt_state = IDLE ;
        end       
        
        endcase        
end 

always @(posedge clk) begin 
    if(rst) begin 
        evn_odd_flg <= 1'b0;
    end 
    else if(state[0]) begin 
        if(ant_wr_even_end0r && ant_wr_even_end1r) begin 
            evn_odd_flg <= 1'b0;
        end
        else if(ant_wr_odd_end0r && ant_wr_odd_end1r) begin 
            evn_odd_flg <= 1'b1;
        end
    end 
    else ;
end 
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin
        ant_wr_odd_clr <= 1'b0;
    end 
    else if(state[0] && nt_state[1]) begin 
        if(ant_wr_odd_end0r && ant_wr_odd_end1r) begin
            ant_wr_odd_clr <= 1'b1;
         end
         else begin 
            ant_wr_odd_clr <= ant_wr_odd_clr;
         end 
    end
    else begin
        ant_wr_odd_clr <= 1'b0;
    end
end 
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin
        ant_wr_even_clr <= 1'b0;
    end 
    else if(state[0] && nt_state[1]) begin 
        if(ant_wr_even_end0r && ant_wr_even_end1r) begin
            ant_wr_even_clr <= 1'b1;
         end
         else begin 
            ant_wr_even_clr <= ant_wr_even_clr;
         end 
    end
    else begin
        ant_wr_even_clr <= 1'b0;
    end
end 
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin 
        dat_per_cnt <= 0;
    end
    else if(state[3] && nt_state[1] ) begin 
        dat_per_cnt <= dat_per_cnt + 1'b1;
    end 
    else if(state[3] && nt_state[0]) begin 
        dat_per_cnt <= 0;
    end
    else ; 
end 
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin
        hdr_pro_cnt <= 0;    
    end
    else if(state[0]) begin
        hdr_pro_cnt <= 0;    
    end
    else if(state[1]) begin
        hdr_pro_cnt <= hdr_pro_cnt + 1'b1;    
    end
    else begin 
        hdr_pro_cnt <= 0;    
    end 
end 
assign hd_pro_end = (hdr_pro_cnt == 'd6);
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin
        dat_pro_cnt <= 0;    
    end
    else if(state[0]) begin
        dat_pro_cnt <= 0;    
    end
    else if(state[2]) begin
        dat_pro_cnt <= dat_pro_cnt + 1'b1;    
    end
    else begin 
        dat_pro_cnt <= 0;    
    end 
end 
assign dat_pro_end = (dat_pro_cnt == 'd83);
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin
        res_pro_cnt <= 0;    
    end
    else if(state[0]) begin
        res_pro_cnt <= 0;    
    end
    else if(state[3]) begin
        res_pro_cnt <= res_pro_cnt + 1'b1;    
    end
    else begin 
        res_pro_cnt <= 0;    
    end 
end 
assign res_pro_end   = (res_pro_cnt == 'd4);
assign res_pro_bfend = (res_pro_cnt == 'd3);
//---------------------------------------------------------------------------------------------------------
reg        sop_or;
reg  [4:0] sop_or_reg;

always @(posedge clk) begin 
    if(rst) begin 
        sop_or_reg <= 0;
    end 
    else begin
        sop_or_reg <= {sop_or_reg[3:0],sop_or};
    end 
end 

always @(posedge clk) begin 
    if(rst) begin 
        rd_paddr0 <= 0;
    end 
    else if(hdr_pro_cnt=='d1) begin 
        rd_paddr0 <= {dat_per_cnt,1'b0};
    end
    else if(hdr_pro_cnt=='d2) begin 
        rd_paddr0 <= {dat_per_cnt,1'b1};
    end 
    else ;
end 

wire [4:0] dat_per_cnt_2;
wire [4:0] dat_per_cnt_a;
assign  dat_per_cnt_2 = ((dat_per_cnt >= 'd16) ? (dat_per_cnt - 'd16) : dat_per_cnt);
assign  dat_per_cnt_a = ((dat_per_cnt > 'd16)  ? (dat_per_cnt - 'd16) : dat_per_cnt);

always @(posedge clk) begin 
    if(rst) begin 
        rd_paddr1 <= 0;
    end 
    else begin 
        if(dat_per_cnt == 'd16) begin 
              rd_paddr1 <= 'd0;
        end 
        else if(dat_per_cnt > 'd16) begin 
            if(hdr_pro_cnt=='d1) begin 
                rd_paddr1 <= {dat_per_cnt_a,1'b0} - 1'b1;
            end
            else if(hdr_pro_cnt=='d2) begin 
                rd_paddr1 <= {dat_per_cnt_a,1'b0};
            end        
        end 
        else begin 
            rd_paddr1 <= 0;
        end 
    end
end

//---------------------------------------------------------------------------------------------------------
wire   nt_state_1;
assign nt_state_1 = (~state[1] && nt_state[1]);

reg [7:0] nt_state_1dly;
always @(posedge clk) begin 
    nt_state_1dly <= {nt_state_1dly[6:0],nt_state_1};
end 
//---------------------------------------------------------------------------------------------------------
reg [7:0] dat_per_cnt_reg0;
reg [7:0] dat_per_cnt_reg1;
reg [7:0] dat_per_cnt_reg2;
reg [7:0] dat_per_cnt_reg3;
always @(posedge clk) begin 
    dat_per_cnt_reg0 <= dat_per_cnt;
    dat_per_cnt_reg1 <= dat_per_cnt_reg0;
    dat_per_cnt_reg2 <= dat_per_cnt_reg1;
    dat_per_cnt_reg3 <= dat_per_cnt_reg2;
end 
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin
    if(rst) begin 
        chip_cell_idx  <=  0; 
        chip_slot_idx  <=  0; 
        chip_syml_idx  <=  0; 
        FFT_AGC1       <=  0;    
        AGC_0H         <=  0; 
        AGC_0L         <=  0;     
        FFT_AGC2       <=  0; 
        AGC_1H         <=  0; 
        AGC_1L         <=  0;     
    end 
    else begin 
        if(dat_per_cnt_reg3 == 'd16) begin 
            if(sop_or) begin 
                chip_cell_idx  <=  rd_pq0[107]    ; 
                chip_slot_idx  <=  rd_pq0[106:100]; 
                chip_syml_idx  <=  rd_pq0[99:96]  ; 
                FFT_AGC1       <=  rd_pq0[95:64]  ;    
                AGC_0H         <=  rd_pq0[63:32]  ; 
                AGC_0L         <=  rd_pq0[31: 0]  ;          
            end 
            else if(sop_or_reg[0]) begin 
                FFT_AGC2       <=  rd_pq1[95:64]  ; 
                AGC_1H         <=  rd_pq1[63:32]  ; 
                AGC_1L         <=  rd_pq1[31: 0]  ;      
            end
        end
        else if(dat_per_cnt_reg3 > 'd16) begin 
            if(sop_or) begin 
                chip_cell_idx  <=  rd_pq1[107]    ; 
                chip_slot_idx  <=  rd_pq1[106:100]; 
                chip_syml_idx  <=  rd_pq1[99:96]  ; 
                FFT_AGC1       <=  rd_pq1[95:64]  ;    
                AGC_0H         <=  rd_pq1[63:32]  ; 
                AGC_0L         <=  rd_pq1[31: 0]  ;          
            end 
            else if(sop_or_reg[0]) begin 
                FFT_AGC2       <=  rd_pq1[95:64]  ; 
                AGC_1H         <=  rd_pq1[63:32]  ; 
                AGC_1L         <=  rd_pq1[31: 0]  ;      
            end        
        end 
        else begin 
            if(sop_or) begin 
                chip_cell_idx  <=  rd_pq0[107]    ; 
                chip_slot_idx  <=  rd_pq0[106:100]; 
                chip_syml_idx  <=  rd_pq0[99:96]  ; 
                FFT_AGC1       <=  rd_pq0[95:64]  ;    
                AGC_0H         <=  rd_pq0[63:32]  ; 
                AGC_0L         <=  rd_pq0[31: 0]  ;          
            end 
            else if(sop_or_reg[0]) begin 
                FFT_AGC2       <=  rd_pq0[95:64]  ; 
                AGC_1H         <=  rd_pq0[63:32]  ; 
                AGC_1L         <=  rd_pq0[31: 0]  ;   
            end   
        end 
    end
end 
//---------------------------------------------------------------------------------------------------------
reg [11:0] dat_base_addr0;
reg [11:0] dat_base_addr1;
//assign   dat_base_addr = {dat_per_cnt[4:0],6'd0}+{dat_per_cnt[4:0],4'd0}+{dat_per_cnt[4:0],2'd0};
always @(posedge clk) begin 
    if(rst) begin 
        dat_base_addr0 <= 0;
    end
    else if(dat_per_cnt <= 'd16) begin 
        dat_base_addr0 <= {dat_per_cnt[4:0],6'd0}+{dat_per_cnt[4:0],4'd0}+{dat_per_cnt[4:0],2'd0} + dat_pro_cnt;
    end
    else ; 
end

assign rd_daddr0 = dat_base_addr0;
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin 
        dat_base_addr1 <= 0;
    end
    else if(dat_per_cnt == 'd16) begin 
        if(dat_pro_cnt >= 'd42) begin 
            dat_base_addr1 <= {dat_per_cnt_2[4:0],6'd0}+{dat_per_cnt_2[4:0],4'd0}+{dat_per_cnt_2[4:0],2'd0} + dat_pro_cnt - 'd42;
        end
        else begin 
            dat_base_addr1 <= {dat_per_cnt_2[4:0],6'd0}+{dat_per_cnt_2[4:0],4'd0}+{dat_per_cnt_2[4:0],2'd0} + dat_pro_cnt;
        end 
    end
    else if(dat_per_cnt > 'd16) begin 
            dat_base_addr1 <= {dat_per_cnt_2[4:0],6'd0}+{dat_per_cnt_2[4:0],4'd0}+{dat_per_cnt_2[4:0],2'd0} + dat_pro_cnt - 'd42;
    end
    else ; 
end

assign   rd_daddr1 = dat_base_addr1;
//---------------------------------------------------------------------------------------------------------
always @(posedge clk) begin 
    if(rst) begin 
        sop_or <= 'd0;
    end 
    else if(hdr_pro_cnt == 'd4) begin 
        sop_or <= 'b1;
    end
    else begin 
        sop_or <= 'd0;
    end
end 

always @(posedge clk) begin
    if(rst) begin 
        FFT_AGC   <=  0; 
        AGC0      <=  0; 
        AGC1      <=  0;      
    end 
    else begin 
        if(sop_or_reg[1]) begin 
            FFT_AGC <=  {FFT_AGC1,FFT_AGC2};
            AGC0    <=  {AGC_1L[31:16],AGC_0L[31:16],AGC_1L[15:0],AGC_0L[15:0]};
            AGC1    <=  {AGC_1H[31:16],AGC_0H[31:16],AGC_1H[15:0],AGC_0H[15:0]};  
        end
    end
end 
//---------------------------------------------------------------------------------------------------------
reg [7:0]   hdr_pro_cnt_reg0;
reg [7:0]   hdr_pro_cnt_reg1;
reg [7:0]   hdr_pro_cnt_reg2;
reg [7:0]   dat_pro_cnt_reg0;
reg [7:0]   dat_pro_cnt_reg1;
reg [7:0]   dat_pro_cnt_reg2;
always @(posedge clk) begin 
    hdr_pro_cnt_reg0 <= hdr_pro_cnt;
    hdr_pro_cnt_reg1 <= hdr_pro_cnt_reg0;
    hdr_pro_cnt_reg2 <= hdr_pro_cnt_reg1;
    dat_pro_cnt_reg0 <= dat_pro_cnt;
    dat_pro_cnt_reg1 <= dat_pro_cnt_reg0;
    dat_pro_cnt_reg2 <= dat_pro_cnt_reg1;
end 

reg [63:0] dat_or;
always @(posedge clk) begin 
    if(rst) begin 
        dat_or <= 'd0;
    end 
    else if((hdr_pro_cnt_reg2 >= 'd1) && (hdr_pro_cnt_reg2 <= 'd3)) begin 
        dat_or <= 'd0;
    end
    else if(hdr_pro_cnt_reg2 == 'd4) begin 
        dat_or <= IQ_hd;
    end
    else if(hdr_pro_cnt_reg2 == 'd5) begin 
        dat_or <= FFT_AGC;
    end  
    else if(hdr_pro_cnt_reg2 == 'd6) begin 
        dat_or <= AGC0;
    end  
    else if(hdr_pro_cnt_reg2 == 'd7) begin 
        dat_or <= AGC1;
    end        
    else if((dat_pro_cnt_reg2 > 'd0)) begin 
       if(dat_per_cnt_reg3 == 'd16) begin 
         if (dat_pro_cnt_reg2 < 'd43) begin 
              dat_or <= rd_dq0;
         end 
         else begin 
              dat_or <= rd_dq1;
         end 
       end
       else if(dat_per_cnt_reg3 > 'd16) begin 
           dat_or <= rd_dq1;
       end 
       else begin 
           dat_or <= rd_dq0;
       end 
    end
    else begin 
        dat_or <= 0;
    end
end

assign Cpri_sop_o = sop_or;
assign Cpri_dat_o = dat_or;
//---------------------------------------------------------------------------------------------------------
endmodule
//---------------------------------------------------------------------------------------------------------