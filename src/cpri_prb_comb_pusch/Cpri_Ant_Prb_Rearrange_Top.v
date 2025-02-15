//---------------------------------------------------------------------------------------------------------
//slw
//---------------------------------------------------------------------------------------------------------
module Cpri_Ant_Prb_Rearrange_Top
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
	)
(
      input                  clk,
      input                  rst,
      
      input                  pus_sop0_i,
      input [DAT_DW-1:0]     pus_dat0_i,  
      input                  pus_sop1_i,
      input [DAT_DW-1:0]     pus_dat1_i,  
      input                  pus_sop2_i,
      input [DAT_DW-1:0]     pus_dat2_i,        
      input                  pus_sop3_i,
      input [DAT_DW-1:0]     pus_dat3_i,        
            
      output                 pus_sop0_o,
      output [DAT_DW-1:0]    pus_dat0_o,                                                
      output                 pus_sop1_o,
      output [DAT_DW-1:0]    pus_dat1_o,
      output                 pus_sop2_o,
      output [DAT_DW-1:0]    pus_dat2_o,              
      output                 pus_sop3_o,
      output [DAT_DW-1:0]    pus_dat3_o       
);

//reg file_out0_vld;
//reg file_out1_vld;
//reg file_out2_vld;
//reg file_out3_vld;
//
//always @(posedge clk) begin 
//    if(rst) begin 
//        file_out0_vld <= 0;
//    end
//    else if(pus_sop0_o) begin 
//        file_out0_vld <= 1'b1;
//    end 
//    else ;
//end 
//
//always @(posedge clk) begin 
//    if(rst) begin 
//        file_out1_vld <= 0;
//    end
//    else if(pus_sop1_o) begin 
//        file_out1_vld <= 1'b1;
//    end 
//    else ;
//end 
//
//always @(posedge clk) begin 
//    if(rst) begin 
//        file_out2_vld <= 0;
//    end
//    else if(pus_sop2_o) begin 
//        file_out2_vld <= 1'b1;
//    end 
//    else ;
//end 
//
//always @(posedge clk) begin 
//    if(rst) begin 
//        file_out3_vld <= 0;
//    end
//    else if(pus_sop3_o) begin 
//        file_out3_vld <= 1'b1;
//    end 
//    else ;
//end 
//
//
//integer file_out0;
//integer file_out1;
//integer file_out2;
//integer file_out3;
//
//initial begin
//    file_out0 = $fopen("D:/printer/pus_dat0_sim.dat","w");
//end
//
//always @(posedge clk)begin
////    if(file_out0_vld == 1'b1)
//        $fwrite(file_out0,"%h\n",pus_dat0_o);
//end
//
//initial begin
//    file_out1 = $fopen("D:/printer/pus_dat1_sim.dat","w");
//end
//
//always @(posedge clk)begin
////    if(file_out1_vld == 1'b1)
//        $fwrite(file_out1,"%h\n",pus_dat1_o);
//end
//
//initial begin
//    file_out2 = $fopen("D:/printer/pus_dat2_sim.dat","w");
//end
//
//always @(posedge clk)begin
////    if(file_out2_vld == 1'b1)
//        $fwrite(file_out2,"%h\n",pus_dat2_o);
//end
//
//initial begin
//    file_out3 = $fopen("D:/printer/pus_dat3_sim.dat","w");
//end
//
//always @(posedge clk)begin
////    if(file_out3_vld == 1'b1)
//        $fwrite(file_out3,"%h\n",pus_dat3_o);
//end
//---------------------------------------------------------------------------------------------------------
wire [DAT_DW-1:0] pus_dat_ir          [0:3];
wire              pus_sop_ir          [0:3];

wire              pus_sop_or          [0:3];
wire [DAT_DW-1:0] pus_dat_or          [0:3];

wire [1:0]        ant_wr_odd_end      [0:3];
wire [1:0]        ant_wr_even_end     [0:3];

wire              ant_wr_odd_clr      [0:3];
wire              ant_wr_even_clr     [0:3];

wire [1:0]        ant_wr_odd_clr_reg  [0:3];
wire [1:0]        ant_wr_even_clr_reg [0:3];
//---------------------------------------------------------------------------------------------------------
assign pus_dat_ir[0] = pus_dat0_i;
assign pus_dat_ir[1] = pus_dat1_i;
assign pus_dat_ir[2] = pus_dat2_i;
assign pus_dat_ir[3] = pus_dat3_i;

assign pus_sop_ir[0] = pus_sop0_i;
assign pus_sop_ir[1] = pus_sop1_i;
assign pus_sop_ir[2] = pus_sop2_i;
assign pus_sop_ir[3] = pus_sop3_i;

assign pus_sop0_o = pus_sop_or[0];
assign pus_sop1_o = pus_sop_or[1];
assign pus_sop2_o = pus_sop_or[2];
assign pus_sop3_o = pus_sop_or[3];

assign pus_dat0_o = pus_dat_or[0];
assign pus_dat1_o = pus_dat_or[1];
assign pus_dat2_o = pus_dat_or[2];
assign pus_dat3_o = pus_dat_or[3];
//---------------------------------------------------------------------------------------------------------
wire [12 :0]        wr_daddr_or    [0:3];
wire [63 :0]        wr_ddat_or     [0:3]; 
wire [8  :0]        wr_paddr_or    [0:3];
wire [111:0]        wr_pdat_or     [0:3];
wire                wr_dwen_ea_or  [0:3];
wire                wr_dwen_oa_or  [0:3];
wire                wr_pwen_ea_or  [0:3];
wire                wr_pwen_oa_or  [0:3];
//---------------------------------------------------------------------------------------------------------
genvar i;
generate
for(i=0; i<=3; i=i+1)begin
    Ctrl_Freq_wrbuf  u_Ctrl_Freq_wrbuf(
        .clk                  (clk                      ),
        .rst                  (rst                      ),
        .channel_i            (i                        ),

        .pus_dat_i            (pus_dat_ir[i]            ),
        .pus_sop_i            (pus_sop_ir[i]            ),

        .wr_daddr             (wr_daddr_or[i]           ),
        .wr_ddat              (wr_ddat_or[i]            ),
        .wr_dwen_oa           (wr_dwen_oa_or[i]         ),//&&chip_symbol_ram_idx[i]
        .wr_dwen_ea           (wr_dwen_ea_or[i]         ),//&&chip_symbol_ram_idx[i]
       
        .wr_paddr             (wr_paddr_or[i]           ),
        .wr_pdat              (wr_pdat_or[i]            ),
        .wr_pwen_oa           (wr_pwen_oa_or[i]         ),//&&chip_symbol_ram_idx[i]  
        .wr_pwen_ea           (wr_pwen_ea_or[i]         ),//&&chip_symbol_ram_idx[i]  
        
        .ant_wr_odd_end_o     (ant_wr_odd_end[i]        ), 
        .ant_wr_odd_clr       (ant_wr_odd_clr_reg[i]    ),
        .ant_wr_even_end_o    (ant_wr_even_end[i]       ), 
        .ant_wr_even_clr      (ant_wr_even_clr_reg[i]   )
                
//      .Cpri_dat_o           (pus_dat_or[i]            ),
//      .Cpri_sop_o           (pus_sop_or[i]            )      
);
end   
endgenerate
//---------------------------------------------------------------------------------------------------------
assign ant_wr_odd_clr_reg[0]  = {ant_wr_odd_clr[1] ,ant_wr_odd_clr[0] };
assign ant_wr_odd_clr_reg[1]  = {ant_wr_odd_clr[3] ,ant_wr_odd_clr[2] };
assign ant_wr_odd_clr_reg[2]  = {ant_wr_odd_clr[1] ,ant_wr_odd_clr[0] };
assign ant_wr_odd_clr_reg[3]  = {ant_wr_odd_clr[3] ,ant_wr_odd_clr[2] };

assign ant_wr_even_clr_reg[0] = {ant_wr_even_clr[1],ant_wr_even_clr[0]};
assign ant_wr_even_clr_reg[1] = {ant_wr_even_clr[3],ant_wr_even_clr[2]};
assign ant_wr_even_clr_reg[2] = {ant_wr_even_clr[1],ant_wr_even_clr[0]};
assign ant_wr_even_clr_reg[3] = {ant_wr_even_clr[3],ant_wr_even_clr[2]};
//---------------------------------------------------------------------------------------------------------
Cpri_prb_rProcess #(.CPRI_CH (0)) u_Cpri_prb_rProcess0(
        .clk                   (clk                                     ),
        .rst                   (rst                                     ),
                              
        .wr_daddr0             (wr_daddr_or[0]                          ),
        .wr_ddat0              (wr_ddat_or[0]                           ),
        .wr_dwen0              (wr_dwen_ea_or[0]                        ),//&&chip_symbol_ram_idx[i]
        
        .wr_daddr1             (wr_daddr_or[2]                          ),
        .wr_ddat1              (wr_ddat_or[2]                           ),
        .wr_dwen1              (wr_dwen_ea_or[2]                        ),//&&chip_symbol_ram_idx[i]        
                              
        .wr_paddr0             (wr_paddr_or[0]                          ),
        .wr_pdat0              (wr_pdat_or[0]                           ),
        .wr_pwen0              (wr_pwen_ea_or[0]                        ),//&&chip_symbol_ram_idx[i]  
        
        .wr_paddr1            (wr_paddr_or[2]                           ),
        .wr_pdat1             (wr_pdat_or[2]                            ),
        .wr_pwen1             (wr_pwen_ea_or[2]                         ),//&&chip_symbol_ram_idx[i]          
        
        .ant_wr_odd_end       ({ant_wr_odd_end[2][0],ant_wr_odd_end[0][0]}), 
        .ant_wr_odd_clr       (ant_wr_odd_clr[0]                        ),
        .ant_wr_even_end      ({ant_wr_even_end[2][0],ant_wr_even_end[0][0]}), 
        .ant_wr_even_clr      (ant_wr_even_clr[0]                       ),
                
        .Cpri_dat_o           (pus_dat_or[0]                            ),
        .Cpri_sop_o           (pus_sop_or[0]                            )      
);
//---------------------------------------------------------------------------------------------------------
Cpri_prb_rProcess #(.CPRI_CH (1))  u_Cpri_prb_rProcess1(
        .clk                   (clk                                     ),
        .rst                   (rst                                     ),
                              
        .wr_daddr0             (wr_daddr_or[0]                          ),
        .wr_ddat0              (wr_ddat_or[0]                           ),
        .wr_dwen0              (wr_dwen_oa_or[0]                        ),//&&chip_symbol_ram_idx[i]
        
        .wr_daddr1             (wr_daddr_or[2]                          ),
        .wr_ddat1              (wr_ddat_or[2]                           ),
        .wr_dwen1              (wr_dwen_oa_or[2]                        ),//&&chip_symbol_ram_idx[i]        
                              
        .wr_paddr0            (wr_paddr_or[0]                           ),
        .wr_pdat0             (wr_pdat_or[0]                            ),
        .wr_pwen0             (wr_pwen_oa_or[0]                         ),//&&chip_symbol_ram_idx[i]  
        
        .wr_paddr1            (wr_paddr_or[2]                           ),
        .wr_pdat1             (wr_pdat_or[2]                            ),
        .wr_pwen1             (wr_pwen_oa_or[2]                         ),//&&chip_symbol_ram_idx[i]          
        
        .ant_wr_odd_end       ({ant_wr_odd_end[2][1],ant_wr_odd_end[0][1]}), 
        .ant_wr_odd_clr       (ant_wr_odd_clr[1]                        ),
        .ant_wr_even_end      ({ant_wr_even_end[2][1],ant_wr_even_end[0][1]}), 
        .ant_wr_even_clr      (ant_wr_even_clr[1]                       ),
                
        .Cpri_dat_o           (pus_dat_or[1]                            ),
        .Cpri_sop_o           (pus_sop_or[1]                            )      
);
//---------------------------------------------------------------------------------------------------------
Cpri_prb_rProcess  #(.CPRI_CH (2)) u_Cpri_prb_rProcess2(
        .clk                   (clk                                     ),
        .rst                   (rst                                     ),
                              
        .wr_daddr0             (wr_daddr_or[1]                          ),
        .wr_ddat0              (wr_ddat_or[1]                           ),
        .wr_dwen0              (wr_dwen_ea_or[1]                        ),//&&chip_symbol_ram_idx[i]
        
        .wr_daddr1             (wr_daddr_or[3]                          ),
        .wr_ddat1              (wr_ddat_or[3]                           ),
        .wr_dwen1              (wr_dwen_ea_or[3]                        ),//&&chip_symbol_ram_idx[i]        
                              
        .wr_paddr0            (wr_paddr_or[1]                           ),
        .wr_pdat0             (wr_pdat_or[1]                            ),
        .wr_pwen0             (wr_pwen_ea_or[1]                         ),//&&chip_symbol_ram_idx[i]  
        
        .wr_paddr1            (wr_paddr_or[3]                           ),
        .wr_pdat1             (wr_pdat_or[3]                            ),
        .wr_pwen1             (wr_pwen_ea_or[3]                         ),//&&chip_symbol_ram_idx[i]          
        
        .ant_wr_odd_end       ({ant_wr_odd_end[3][0],ant_wr_odd_end[1][0]}), 
        .ant_wr_odd_clr       (ant_wr_odd_clr[2]                        ),
        .ant_wr_even_end      ({ant_wr_even_end[3][0],ant_wr_even_end[1][0]}), 
        .ant_wr_even_clr      (ant_wr_even_clr[2]                       ),
                
        .Cpri_dat_o           (pus_dat_or[2]                            ),
        .Cpri_sop_o           (pus_sop_or[2]                            )      
);
//---------------------------------------------------------------------------------------------------------
Cpri_prb_rProcess  #(.CPRI_CH (3)) u_Cpri_prb_rProcess3(
        .clk                   (clk                                     ),
        .rst                   (rst                                     ),
                              
        .wr_daddr0             (wr_daddr_or[1]                          ),
        .wr_ddat0              (wr_ddat_or[1]                           ),
        .wr_dwen0              (wr_dwen_oa_or[1]                        ),//&&chip_symbol_ram_idx[i]
        
        .wr_daddr1             (wr_daddr_or[3]                          ),
        .wr_ddat1              (wr_ddat_or[3]                           ),
        .wr_dwen1              (wr_dwen_oa_or[3]                        ),//&&chip_symbol_ram_idx[i]        
                              
        .wr_paddr0            (wr_paddr_or[1]                           ),
        .wr_pdat0             (wr_pdat_or[1]                            ),
        .wr_pwen0             (wr_pwen_oa_or[1]                         ),//&&chip_symbol_ram_idx[i]  
        
        .wr_paddr1            (wr_paddr_or[3]                           ),
        .wr_pdat1             (wr_pdat_or[3]                            ),
        .wr_pwen1             (wr_pwen_oa_or[3]                         ),//&&chip_symbol_ram_idx[i]          
        
        .ant_wr_odd_end       ({ant_wr_odd_end[3][1],ant_wr_odd_end[1][1]}), 
        .ant_wr_odd_clr       (ant_wr_odd_clr[3]                        ),
        .ant_wr_even_end      ({ant_wr_even_end[3][1],ant_wr_even_end[1][1]}), 
        .ant_wr_even_clr      (ant_wr_even_clr[3]                       ),
                
        .Cpri_dat_o           (pus_dat_or[3]                            ),
        .Cpri_sop_o           (pus_sop_or[3]                            )      
);        

//---------------------------------------------------------------------------------------------------------
endmodule
//---------------------------------------------------------------------------------------------------------
