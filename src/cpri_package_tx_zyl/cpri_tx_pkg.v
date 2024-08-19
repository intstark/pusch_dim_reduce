`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2024-04-17
//File name       :  cpri_tx_pkg.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------


module cpri_tx_pkg
(
    input   wire            wr_clk            ,
    input   wire            wr_rst            ,  
    input   wire            rd_clk            ,
    input   wire            rd_rst            , 
    input   wire            i_vld             ,
    input   wire            i_sop             ,
    input   wire            i_eop             ,  
    input   wire [63:0]     i_data            ,   
        
    
	  input	  wire            i_iq_tx_enable    ,	
		output	wire            o_iq_tx_valid     ,    
	  output	wire  [63:0]    o_iq_tx_data      ,     
	  output	reg   [3:0]     o_free_size           

);


    localparam  WDATA_WIDTH        =  64   ;
    localparam  WADDR_WIDTH        =  7    ;
    localparam  RDATA_WIDTH        =  64   ;
    localparam  RADDR_WIDTH        =  7    ;
    localparam  READ_LATENCY       =  3    ;
    localparam  FIFO_DEPTH         =  16   ;
    localparam  FIFO_WIDTH         =  1    ;
    localparam  LOOP_WIDTH         =  10   ;
    localparam  INFO_WIDTH         =  1    ;
    localparam  RAM_TYPE           =  1    ;



reg  [1:0]   pkg_sel=0                            ;
reg  [3:0]   data_type=0                          ;
reg  [6:0]   total_num                            ;
reg  [6:0]   pkg_waddr                            ;
wire         pkg_last                             ;
wire [63:0]  cpri_rdata                           ;
wire         cpri_rinfo                           ;
wire         cpri_rdy                             ;
wire         cpri_rvld                            ;
reg          cpri_rvld_d1                         ;
reg          cpri_rvld_d2                         ;
reg          cpri_rvld_d3                         ;
reg          rd_valid                             ;
reg  [6:0]   cpri_raddr                           ;
wire         [LOOP_WIDTH-WADDR_WIDTH:0] free_size ;

//-----------------------------------------------------------------------------

always @ (posedge wr_clk)
    begin
         if(i_sop) 
             pkg_sel <= 2'd0; 
         else if(pkg_sel == 2'd3)
             pkg_sel <= pkg_sel          ;
         else                              
             pkg_sel <= pkg_sel + 2'd1   ;
    end
    

//-----------------------------------------------------------------------------
//--common
always @ (posedge wr_clk)
    begin
        if( i_vld  && pkg_sel == 2'd2 )          
            data_type     <= i_data[7:4];
        else
            data_type     <= data_type  ;                                                
    end

//i_data_type  1:power, 2:data, 3:data+bf-12RB ;4:data+bf-6RB 
//always @ (posedge wr_clk)
//begin
//    if(data_type==4'd1 )    
//        total_num  <= 7'd55;//6+50=56   
//    else if(data_type==4'd2 )                    
//        total_num  <= 7'd37;//6+32=38
//    else if(data_type==4'd3 )                    
//        total_num  <= 7'd85;//6+32+48=86      
//    else
//        total_num  <= 7'd61;//6+32+24=62           
//end 


always @ (posedge wr_clk)
    begin
       case(data_type)
           4'd1    : total_num <= 7'd55;//6+50=56   
           4'd2    : total_num <= 7'd37;//6+32=38 
           4'd3    : total_num <= 7'd85;//6+32+48=86    
           4'd4    : total_num <= 7'd61;//6+32+24=62   
           default : total_num <= 7'd127;
       endcase
    end

   
//-----------------------------------------------------------------------------
always @ (posedge wr_clk)
    begin
        if(wr_rst)
            pkg_waddr <= 7'd0;
        else if(i_vld)
            begin
                if(pkg_waddr == total_num)
                    pkg_waddr <= 7'd0;
                else
                    pkg_waddr <= pkg_waddr + 7'd1;
            end
        else
            pkg_waddr <= pkg_waddr;    
    end


// 修改，打拍，以前的代码也改组包                       
assign pkg_last = (i_vld && i_eop && (pkg_waddr == total_num))? 1'd1 : 1'd0;


loop_buffer_async #
(
    .WDATA_WIDTH                (WDATA_WIDTH                        ),
    .WADDR_WIDTH                (WADDR_WIDTH                        ),
    .RDATA_WIDTH                (RDATA_WIDTH                        ),
    .RADDR_WIDTH                (RADDR_WIDTH                        ),
    .READ_LATENCY               (READ_LATENCY                       ),
    .FIFO_DEPTH                 (FIFO_DEPTH                         ),
    .FIFO_WIDTH                 (FIFO_WIDTH                         ),
    .LOOP_WIDTH                 (LOOP_WIDTH                         ),
    .INFO_WIDTH                 (INFO_WIDTH                         ),
    .RAM_TYPE                   (RAM_TYPE                           )
)u_pkg_ram
(
    .wr_rst                     (wr_rst                             ),
    .wr_clk                     (wr_clk                             ),  
    .rd_rst                     (rd_rst                             ), 
    .rd_clk                     (rd_clk                             ),     
    .wr_wen                     (i_vld                              ),
    .wr_addr                    (pkg_waddr                          ),
    .wr_data                    (i_data                             ),  
    .wr_wlast                   (pkg_last                           ),
    .wr_info                    (pkg_last                           ),
    .free_size                  (free_size                          ),
    .rd_addr                    (cpri_raddr                         ),
    .rd_data                    (cpri_rdata                         ),
    .rd_vld                     (cpri_rvld                          ),
    .rd_info                    (cpri_rinfo                         ),
    .rd_rdy                     (cpri_rdy                           )
);
//-----------------------------------------------------------------------------
//少写多读，info判断长度，
always @ (posedge rd_clk)
    begin
        if( wr_rst )//rd_rst
            rd_valid <= 1'd0;     
//        else if( cpri_rvld )
        else if( i_iq_tx_enable && cpri_rvld )
            rd_valid <= 1'd1; 
        else if(cpri_rvld == 1'd0)
            rd_valid <= 1'd0;  
        else 
            rd_valid <= rd_valid;                                                                      
    end

//always @ (posedge rd_clk)
//    begin
//      if(cpri_rvld && i_iq_tx_enable )
//                cpri_raddr <= 7'd3;     
//      else if(rd_valid && cpri_rvld)
//            if(cpri_raddr == 7'd98)
//                cpri_raddr <= 7'd3;
//            else
//                cpri_raddr <= cpri_raddr + 7'd1;
//       else 
//                cpri_raddr <= 7'd0;                                                        
//    end
    
//skip head-0-1-2
always @ (posedge rd_clk)
    begin
        if(rd_valid && cpri_rvld)
            if(cpri_raddr == 7'd98)
                cpri_raddr <= 7'd3;
            else
                cpri_raddr <= cpri_raddr + 7'd1;
        else 
                cpri_raddr <= 7'd3;                                                        
    end

assign cpri_rdy = (cpri_rvld && (cpri_raddr == 7'd98))? 1'd1 : 1'd0;


assign    o_iq_tx_data  = cpri_rvld ?  cpri_rdata : 1'b0 ;
assign    o_iq_tx_valid = rd_valid  &  cpri_rvld  ;

always @ (posedge rd_clk)
  begin
    cpri_rvld_d1  <= rd_valid   ;
    cpri_rvld_d2  <= cpri_rvld_d1;
    cpri_rvld_d3  <= cpri_rvld_d2;
  end
        
always @ (posedge wr_clk)
    begin
            o_free_size     <= free_size  ;                                                
    end        
//-----------------------------------------------------------------------------
//--test
reg    [15:0]  sim_cnt=0;
reg            stop     ;


always @ (posedge rd_clk )
 begin 
   if (o_iq_tx_valid ==1'd1)  
     sim_cnt <= sim_cnt + 1;    
   else
     sim_cnt <= 0;   
 end


 

                  




reg    [9:0]  wlast_cnt=0;
reg    [9:0]  rlast_cnt=0;
 

always @ (posedge wr_clk )
 begin
  if (rd_valid ==1'd0)  
    wlast_cnt <=0;
  else if (pkg_last ==1'd1)  
     wlast_cnt <= wlast_cnt + 1;    
   else
     wlast_cnt <= wlast_cnt;   
 end


always @ (posedge rd_clk )
 begin 
    if (rd_valid ==1'd0)  
    rlast_cnt <=0;
  else  if (cpri_rdy ==1'd1)  
     rlast_cnt <= rlast_cnt + 1;    
   else
     rlast_cnt <= rlast_cnt;   
 end
        
                   
endmodule