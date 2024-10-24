`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2024-03-06
//File name       :  dl_data_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------
module dl_data_gen
(

    input  wire           sys_clk_491_52         ,
    input  wire           sys_rst_491_52         ,   
    input  wire           sys_clk_368_64         ,
    input  wire           sys_rst_368_64         ,   
    input  wire           sys_clk_245_76         ,    
    input  wire           sys_rst_245_76         ,      
    input  wire           fpga_clk_250mhz        ,
    input  wire           fpga_rst_250mhz        

);


localparam           RE_NUM        =   4'd12         ; 
localparam           SYM_NUM       =   4'd14         ; 
localparam           PRB_NUM       =   9'd132        ;//
                     
localparam integer   INIT_NUM      =  1;
localparam integer   TOTAL_DL      =  2*SYM_NUM*PRB_NUM*RE_NUM;
localparam integer   TOTAL_CPRI    =  150*256*96       ;
localparam integer   ANT_NUM       =  1;

wire [63:0]     dl_head;
reg  [3:0]      re_idx;
reg  [8:0]      prb_idx;
reg  [7:0]      slot_idx;
reg  [3:0]      sym_idx; 

reg  [3:0]      ant0_idx; 
reg  [3:0]      ant1_idx; 
reg  [3:0]      ant2_idx; 
reg  [3:0]      ant3_idx; 
reg  [3:0]      ant_group_idx; 
      
reg             dl_data_sel=0;
reg             dl_data_sop;
reg             dl_data_vld;
reg             dl_data_eop;

wire [31:0]     dl_data_din0;
wire [31:0]     dl_data_din1;
wire [31:0]     dl_data_din2;
wire [31:0]     dl_data_din3;

reg  [15:0]     dl_cnt;
reg  [63:0]     dl_cnt_addr;  
reg  [127:0]    dl_data_din;
reg  [127:0]    dl_data_sim [0: TOTAL_DL-1];//10ms


assign       dl_head = {64'd0};   
   



always @ (posedge sys_clk_491_52)
    if (sys_rst_491_52)
        dl_cnt <= 0;
    else if (dl_cnt==INIT_NUM + PRB_NUM*RE_NUM )
        dl_cnt <= 0;
    else
        dl_cnt <= dl_cnt + 1;

      
        
always @ (posedge sys_clk_491_52)                                
        dl_data_sop <= ((dl_cnt== INIT_NUM  ) || ( dl_cnt==INIT_NUM+(prb_idx[8:2]+1)*4*RE_NUM )) && (dl_cnt <= INIT_NUM + PRB_NUM*RE_NUM-1);//4RB + 4ant      
       

    
always @ (posedge sys_clk_491_52)
        dl_data_eop <= (re_idx== RE_NUM-2);   
//        dl_data_eop <= (dl_cnt== INIT_NUM + PRB_NUM*RE_NUM-1);   
    
     
always @ (posedge sys_clk_491_52)
        dl_data_vld <= (dl_cnt >= INIT_NUM && dl_cnt <= INIT_NUM + PRB_NUM*RE_NUM-1 ); 

always @ (posedge sys_clk_491_52)
      if (dl_cnt== INIT_NUM)
           dl_data_sel <= ~dl_data_sel;
      else
           dl_data_sel <=  dl_data_sel;           




always @ (posedge sys_clk_491_52)
    if (sys_rst_491_52)
        dl_cnt_addr <= 0;
    else if ((dl_cnt >= INIT_NUM && dl_cnt <= INIT_NUM + PRB_NUM*RE_NUM-1 ))
        dl_cnt_addr <= dl_cnt_addr + 1; 
    else        
        dl_cnt_addr <= dl_cnt_addr;

//always @ (posedge sys_clk_491_52)
//    if (dl_data_sop)
//        dl_data <= dl_data;
//    else if (dl_data_vld)
//        dl_data <= dl_data +  1;
//    else
//        dl_data <= dl_data;
        
always @ (posedge sys_clk_491_52)
//    if (dl_data_sop)
//        dl_data_din <= dl_head;
//    else
        dl_data_din <= dl_data_sim[dl_cnt_addr];

assign dl_data_din0  =  dl_data_din[31:0]    ;
assign dl_data_din1  =  dl_data_din[63:32]   ;
assign dl_data_din2  =  dl_data_din[95:64]   ;
assign dl_data_din3  =  dl_data_din[127:96]  ;



//-----------------------------------------------------------------------------
always @ (posedge sys_clk_491_52)
      if (dl_cnt== INIT_NUM)
           dl_data_sel <= ~dl_data_sel;
      else
           dl_data_sel <=  dl_data_sel;    
           
always @ (*)
      if (dl_data_sel==1'd1)
           begin
             ant0_idx <=4'd0;
             ant1_idx <=4'd2;
             ant2_idx <=4'd4;
             ant3_idx <=4'd6;
             ant_group_idx <=4'd0;
           end
      else
           begin
             ant0_idx <=4'd1;
             ant1_idx <=4'd3;
             ant2_idx <=4'd5;
             ant3_idx <=4'd7; 
             ant_group_idx <=4'd1;             
           end           



//--132RB=16pkg*8+4
//--132RB=33pkg*4
always @ (posedge sys_clk_491_52)
    if (sys_rst_491_52)
        re_idx <= 0;
    else if (re_idx == RE_NUM-1 )
        re_idx <= 0;
    else if (dl_data_vld) 
        re_idx <= re_idx + 1;
    else
        re_idx <= 0;


always @ (posedge sys_clk_491_52)
    if (sys_rst_491_52)
        prb_idx <= 0;
    else if ((prb_idx==PRB_NUM-1) && re_idx == RE_NUM-1)
        prb_idx <= 0;
    else if (re_idx == RE_NUM-1)
        prb_idx <= prb_idx + 1;
    else
        prb_idx <= prb_idx;
        
always @ (posedge sys_clk_491_52)
    if (sys_rst_491_52)
        sym_idx <= 0;
    else if ((sym_idx==SYM_NUM-1)&&(prb_idx==PRB_NUM-1)&&(re_idx == RE_NUM-1))
        sym_idx <= 0;
    else if ((prb_idx==PRB_NUM-1)&&(re_idx == RE_NUM-1))
        sym_idx <= sym_idx + 1;
    else
        sym_idx <= sym_idx;       
always @ (posedge sys_clk_491_52)
    if (sys_rst_491_52)
        slot_idx <= 0;
    else if ((sym_idx==SYM_NUM-1)&&(prb_idx==PRB_NUM-1)&&(re_idx == RE_NUM-1))
        slot_idx <= slot_idx + 1;
    else
        slot_idx <= slot_idx;
 
          
                 
initial $readmemh ( "../vector/dl_data_sim.txt", dl_data_sim);

//-----------------------------------------------------------------------------
//--
reg    [15:0]  sim_cnt;
reg    [6:0]   iq_tx_cnt;
reg            iq_tx_enable;
reg    [8:0]   chip_num;


always @ (posedge sys_clk_368_64 )
 begin 
  if (sys_rst_368_64 ==1'd0)  
     if (sim_cnt ==16'd100 )  
         sim_cnt <= sim_cnt;   
      else 
         sim_cnt <= sim_cnt + 1;    
   else
     sim_cnt <= 0;   
 end

always @ (posedge sys_clk_368_64 )
 begin 
     if (sim_cnt ==16'd100  )  
          if (iq_tx_cnt ==7'd95 )  
             iq_tx_cnt <= 7'd0; 
          else  
             iq_tx_cnt <= iq_tx_cnt+1;   
      else 
         iq_tx_cnt <= 7'd0;     
 end


always @ (posedge sys_clk_368_64 )
 begin 
     if (iq_tx_cnt ==7'd95  )  
         iq_tx_enable <=1'd1; 
      else 
         iq_tx_enable <=1'd0; 
 end


always @ (posedge sys_clk_368_64 )
 begin 
   if (sys_rst_368_64 ==1'd1) 
         chip_num <= 9'd511;   
   else if (iq_tx_cnt ==7'd95  )  
         chip_num <= chip_num + 1'd1; 
      else 
         chip_num <=chip_num; 
 end

 
//-----------------------------------------------------------------------------

reg            p_data_sel       [0:ANT_NUM]; 
reg            p_data_sop       [0:ANT_NUM]; 
reg            p_data_vld       [0:ANT_NUM]; 
reg            p_data_eop       [0:ANT_NUM]; 
reg [31:0]     p_data_din0      [0:ANT_NUM]; 
reg [31:0]     p_data_din1      [0:ANT_NUM]; 
reg [31:0]     p_data_din2      [0:ANT_NUM]; 
reg [31:0]     p_data_din3      [0:ANT_NUM]; 
reg [7:0]      p_slot_idx       [0:ANT_NUM]; 
reg [3:0]      p_sym_idx        [0:ANT_NUM]; 
reg [8:0]      p_prb_idx        [0:ANT_NUM]; 
reg [7:0]      p_info0          [0:ANT_NUM]; 
reg [7:0]      p_info1          [0:ANT_NUM]; 
reg [7:0]      p_info2          [0:ANT_NUM]; 
reg [7:0]      p_info3          [0:ANT_NUM]; 
reg            p_iq_tx_enable   [0:ANT_NUM];
reg [8:0]      p_chip_num       [0:ANT_NUM];
wire           p_iq_tx_valid    [0:ANT_NUM];
wire [63:0]    p_iq_tx_data     [0:ANT_NUM];





  integer j;
  always @(posedge sys_clk_491_52) 
    begin
         for (j = 0; j < ANT_NUM; j=j+1) 
         begin
           p_data_sel[j]       <=  dl_data_sel                ;
           p_data_vld[j]       <=  dl_data_vld                ;
           p_data_sop[j]       <=  dl_data_sop                ;
           p_data_eop[j]       <=  dl_data_eop                ;
           p_data_din0[j]      <=  dl_data_din0               ;
           p_data_din1[j]      <=  dl_data_din1               ;
           p_data_din2[j]      <=  dl_data_din2               ;
           p_data_din3[j]      <=  dl_data_din3               ;
           p_slot_idx[j]       <=  slot_idx                   ;
           p_sym_idx[j]        <=  sym_idx                    ;
           p_prb_idx[j]        <=  prb_idx                    ;
           p_info0[j]          <=  {ant_group_idx,ant0_idx}   ;
           p_info1[j]          <=  {ant_group_idx,ant1_idx}   ;
           p_info2[j]          <=  {ant_group_idx,ant2_idx}   ;
           p_info3[j]          <=  {ant_group_idx,ant3_idx}   ;        
         end
    end


  always @(posedge sys_clk_368_64) 
    begin
         for (j = 0; j < ANT_NUM; j=j+1) 
         begin     
           
           p_chip_num[j]       <=  chip_num               ;                
           p_iq_tx_enable[j]   <=  iq_tx_enable           ;                
         end
    end



genvar i;  
generate  
for(i=0;i<ANT_NUM;i=i+1)      
  begin:ant_parallel  
 
  dl_symb_if  u_dl_symb_if
  (
        .sys_clk_491_52      (sys_clk_491_52                    ),
        .sys_rst_491_52      (sys_rst_491_52                    ),                            
        .sys_clk_368_64      (sys_clk_368_64                    ),
        .sys_rst_368_64      (sys_rst_368_64                    ),   
  	    .i_if_re_sel         (p_data_sel[i]                     ),
  	    .i_if_re_vld         (p_data_vld[i]                     ),
  	    .i_if_re_sop         (p_data_sop[i]                     ),
  	    .i_if_re_eop         (p_data_eop[i]                     ),
  	    .i_if_re_ant0        (p_data_din0[i]                    ),
  	    .i_if_re_ant1        (p_data_din1[i]                    ),
  	    .i_if_re_ant2        (p_data_din2[i]                    ),
  	    .i_if_re_ant3        (p_data_din3[i]                    ),
  	    .i_if_re_slot_idx    (p_slot_idx[i]                     ),
  	    .i_if_re_sym_idx     (p_sym_idx[i]                      ),
  	    .i_if_re_prb_idx     (p_prb_idx[i]                      ),
  	    .i_if_re_info0       (p_info0[i]                        ),    
  	    .i_if_re_info1       (p_info1[i]                        ),    
  	    .i_if_re_info2       (p_info2[i]                        ),    
  	    .i_if_re_info3       (p_info3[i]                        ),    
        .i_iq_tx_enable      (p_iq_tx_enable[i]                 ),
        .o_iq_tx_valid       (p_iq_tx_valid[i]                  ),
        .o_iq_tx_data        (p_iq_tx_data[i]                   )
                              
  );

 end        
endgenerate
 
   

// 
//reg      [15:0]             data_cnt_0  = 0      ; 
//reg      [15:0]             data_cnt_1  = 0      ; 
//reg      [15:0]             data_cnt_2  = 0      ; 
//reg      [15:0]             data_cnt_r  = 0      ; 
//
//
//wire     [63:0]             uram_rdata  = 0      ;
//reg      [255:0]            data_set_0  = 0      ;
//reg      [31:0]             data_keep_0 = 0      ;
//reg                         data_valid_0= 0      ;
//reg                         data_last_0 = 0      ;
//
//wire [0 : 511]   s_axi_tx_tdata              ;
//wire             s_axi_tx_tvalid             ;
//wire             s_axi_tx_tready             ;
//wire [0 : 63]    s_axi_tx_tkeep              ;
//wire             s_axi_tx_tlast              ;
//wire [0 : 511]   m_axi_rx_tdata              ;
//wire             m_axi_rx_tvalid             ;
//wire [0 : 63]    m_axi_rx_tkeep              ;
//wire             m_axi_rx_tlast              ;
//wire             s_axis_tready               ;
//
//always @ (posedge sys_clk_368_64 )
// begin 
//  if (sys_rst_368_64 ==1'd0)  
//     if (data_cnt_0 ==20000 )  
//         data_cnt_0 <= 0;   
//      else 
//         data_cnt_0 <= data_cnt_0 + 1;    
//   else
//     data_cnt_0 <= 0;   
// end
//
//always @ (posedge sys_clk_368_64 )
// begin 
//             data_cnt_1 <=	data_cnt_0;         	                         		      	                         		  
//             data_cnt_2 <=	data_cnt_1;         	                         		      	                         		  
//  
// end 
//
//
//always @ (posedge sys_clk_368_64 )
// begin 
//  if (sys_rst_368_64 ==1'd0)  
//     if (data_cnt_0 >=200 && data_cnt_0<=20000 )  
//         data_cnt_r <= data_cnt_r + 1;    
//      else 
//         data_cnt_r <= 0;    
//      
//   else
//     data_cnt_r <= 0;   
// end
//
//
//always @ (posedge sys_clk_368_64 )
// begin 
// 
//        if(data_cnt_0 >= 1 && data_cnt_0 <= 20000)  
//             data_set_0 <=	{16{data_cnt_0}};         	                         		  
//        else
//             data_set_0 <=	256'd0;     	                         		  
//     	                         		  
// end
//
//always @ (posedge sys_clk_368_64 )
// begin 
//             data_keep_0 <=	32'hffffffff;         	                         		      	                         		  
// end 
//
//
//always @ (posedge sys_clk_368_64 )
// begin   
//        if(data_cnt_0 >= 1 && data_cnt_0 <= 20000   ) 
//             data_valid_0 <=	1;
//        else
//             data_valid_0 <=	0;         	      	                   				  
// end
//
//
//always @ (posedge sys_clk_368_64 )
// begin  
//        if(  data_cnt_0 == 20000)  
//             data_last_0 <=	1;
//        else
//             data_last_0 <=	0;         	                                                            				  
// end
//


//puc_uram_6cascade u0_puc_uram_6cascade
//
//( 
//    //--write
//    .clk                              ( sys_clk_368_64            ),
//    .rst                              ( sys_rst_368_64            ),
//    .addr_a                           ({ 8'h0, data_cnt_2[14:0] } ),
//    .rdb_wr_a                         ( data_valid_0              ),
//    .din_a                            ( data_set_0[63:0]          ),
//    .dout_a                           (                           ),
//    //--read
//    .addr_b                           ( { 12'h0, data_cnt_r[14:0]}),
//    .rdb_wr_b                         ( 1'b0                      ),
//    .din_b                            ( 64'h0                     ),
//    .dout_b                           ( uram_rdata                )
//
//); 





//------------------------------------------------------------------------------ 
//-sim type2
//------------------------------------------------------------------------------ 
reg      [15:0]             data_cnt_0  = 0      ;
reg      [255:0]            data_set_0  = 0      ;
reg      [31:0]             data_keep_0 = 0      ;
reg                         data_valid_0= 0      ;
reg                         data_last_0 = 0      ;

wire [0 : 511]   s_axi_tx_tdata              ;
wire             s_axi_tx_tvalid             ;
wire             s_axi_tx_tready             ;
wire [0 : 63]    s_axi_tx_tkeep              ;
wire             s_axi_tx_tlast              ;
wire [0 : 511]   m_axi_rx_tdata              ;
wire             m_axi_rx_tvalid             ;
wire [0 : 63]    m_axi_rx_tkeep              ;
wire             m_axi_rx_tlast              ;
wire             s_axis_tready               ;

always @ (posedge sys_clk_368_64 )
 begin 
  if (sys_rst_368_64 ==1'd0)  
     if (data_cnt_0 ==1000 )  
         data_cnt_0 <= 0;   
      else 
         data_cnt_0 <= data_cnt_0 + 1;    
   else
     data_cnt_0 <= 0;   
 end


always @ (posedge sys_clk_368_64 )
 begin 
 
        if(data_cnt_0 >= 1 && data_cnt_0 <= 800)  
             data_set_0 <=	{16{data_cnt_0}};         	                         		  
        else
             data_set_0 <=	256'd0;     	                         		  
     	                         		  
 end

always @ (posedge sys_clk_368_64 )
 begin 
             data_keep_0 <=	32'hffffffff;         	                         		      	                         		  
 end 


always @ (posedge sys_clk_368_64 )
 begin   
        if(data_cnt_0 >= 1 && data_cnt_0 <= 800   ) 
             data_valid_0 <=	1;
        else
             data_valid_0 <=	0;         	      	                   				  
 end


always @ (posedge sys_clk_368_64 )
 begin  
        if(  data_cnt_0 == 800)  
             data_last_0 <=	1;
        else
             data_last_0 <=	0;         	                                                            				  
 end

//------------------------------------------------------------------------------ 





reg          i_cpri_wen   ;
reg  [9:0]   i_cpri_waddr ;
reg  [63:0]  i_cpri_wdata ;
reg          i_cpri_wlast ;



wire [63:0]  cpri_rdata  ;
wire [10:0]  cpri_rinfo  ;
wire         cpri_rdy    ;
wire         cpri_rvld   ;
reg          cpri_rvld_d1;
reg          cpri_rvld_d2;
reg          cpri_rvld_d3;
reg          rd_valid    ;
reg  [9:0]   cpri_raddr  ;
wire         [10:0] free_size;
   
//-----------------------------------------------------------------------------
//--
reg    [15:0]  stop_cnt=0;
reg            stop     ;


always @ (posedge sys_clk_368_64 )
 begin 
   if (i_cpri_wen ==1'd1)  
     stop_cnt <= stop_cnt + 1;    
   else
     stop_cnt <= stop_cnt;   
 end


always @ (posedge sys_clk_368_64 )
 begin 
     if (stop_cnt >=16'd5000 && stop_cnt <=16'd6000 )  
         stop <=1'd0; 
      else 
         stop <=1'd1; 
 end


//-----------------------------------------------------------------------------
//--write

always @ (posedge sys_clk_368_64)
    begin
      i_cpri_wdata  <= data_set_0[63:0] ;
      i_cpri_wen    <= data_valid_0     ;
      i_cpri_wlast  <= data_last_0      ;                                                 
    end



always @ (posedge sys_clk_368_64)
    begin
        if(i_cpri_wen)
                i_cpri_waddr <= i_cpri_waddr + 1'd1;
        else
                i_cpri_waddr <= 0;                                                        
    end




//-----------------------------------------------------------------------------
//--read

always @ (posedge sys_clk_368_64)
    begin
        if( sys_clk_368_64 )
            rd_valid <= 1'd0;     
        else if( iq_tx_enable && cpri_rvld )
            rd_valid <= 1'd1; 
        else if(cpri_raddr == 7'd98)
            rd_valid <= 1'd0;  
        else 
            rd_valid <= rd_valid;                                                                      
    end
    
//skip head-0-1-2
always @ (posedge sys_clk_368_64)
    begin
        if(cpri_rvld)
            if(cpri_raddr == 10'd799)
                cpri_raddr <= 0;
            else
                cpri_raddr <= cpri_raddr + 1'd1;
        else
                cpri_raddr <= 0;                                                        
    end

assign cpri_rdy = (cpri_rvld && (cpri_raddr == 10'd799))? 1'd1 : 1'd0;

//
//
//cyc_buffer_sync #(                                     
//    .WDATA_WIDTH       (64                              ),
//    .WADDR_WIDTH       (10                              ),//10
//    .RDATA_WIDTH       (64                              ),
//    .RADDR_WIDTH       (10                              ),//11
//    .READ_LATENCY      (3                               ),//3
//    .FIFO_DEPTH        (16                              ),
//    .FIFO_WIDTH        (11                              ),
//    .INFO_WIDTH        (11                              ),
//    .RAM_TYPE          (1                               )
//    )
//    u_cyc_buffer_sync
//    (
//    .syn_rst           (sys_rst_368_64              ),
//    .clk               (sys_clk_368_64              ),
//    .wr_addr           (i_cpri_waddr                ),
//    .wr_data           (i_cpri_wdata                ),//512
//    .wr_wen            (i_cpri_wen && stop          ),
//    .wr_wlast          (i_cpri_wlast  && stop       ),
//    .wr_len            (10'd800                     ),
//    .wr_info           ({i_cpri_wlast,i_cpri_waddr }),//x2
//    .free_size         (free_size                   ),//length = 1024
//                       
//                       
//    .rd_addr           (cpri_raddr             ),
//    .rd_data           (cpri_rdata             ),//256 
//    .rd_vld            (cpri_rvld              ),
//    .rd_info           (cpri_rinfo             ),
//    .rd_rdy            (cpri_rdy               )
//    
//    );
    
                                                       








   
   
endmodule
