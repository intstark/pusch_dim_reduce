`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  xxxxx. All rights reserved.
//Author(s)       :  xxxxx 
//Email           :  xxxxx 
//Creation Date   :  2024-03-07
//File name       :  package_data.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------


module package_data
(
    input   wire            clk               ,
    input   wire            rst               ,
    input   wire            i_sel             ,
    input   wire            i_vld             ,
    input   wire            i_sop             ,
    input   wire            i_eop             ,
    input   wire  [3:0]     i_pkg0_ch_type    ,
    input   wire            i_pkg0_cell_idx   ,
    input   wire  [1:0]     i_pkg0_ant_idx    ,
    input   wire  [6:0]     i_pkg0_slot_idx   ,
    input   wire  [3:0]     i_pkg0_sym_idx    ,
    input   wire  [8:0]     i_pkg0_prb_idx    ,
    input   wire  [7:0]     i_pkg0_info       ,
    input   wire  [13:0]    i_pkg0_data       ,
    input   wire  [3:0]     i_pkg0_shift      ,
    input   wire  [3:0]     i_pkg1_ch_type    ,
    input   wire            i_pkg1_cell_idx   ,
    input   wire  [1:0]     i_pkg1_ant_idx    ,
    input   wire  [6:0]     i_pkg1_slot_idx   ,
    input   wire  [3:0]     i_pkg1_sym_idx    ,
    input   wire  [8:0]     i_pkg1_prb_idx    ,
    input   wire  [7:0]     i_pkg1_info       ,
    input   wire  [13:0]    i_pkg1_data       ,
    input   wire  [3:0]     i_pkg1_shift      ,
    input   wire  [3:0]     i_pkg2_ch_type    ,
    input   wire            i_pkg2_cell_idx   ,
    input   wire  [1:0]     i_pkg2_ant_idx    ,
    input   wire  [6:0]     i_pkg2_slot_idx   ,
    input   wire  [3:0]     i_pkg2_sym_idx    ,
    input   wire  [8:0]     i_pkg2_prb_idx    ,
    input   wire  [7:0]     i_pkg2_info       ,
    input   wire  [13:0]    i_pkg2_data       ,
    input   wire  [3:0]     i_pkg2_shift      ,
    input   wire  [3:0]     i_pkg3_ch_type    ,
    input   wire            i_pkg3_cell_idx   ,
    input   wire  [1:0]     i_pkg3_ant_idx    ,
    input   wire  [6:0]     i_pkg3_slot_idx   ,
    input   wire  [3:0]     i_pkg3_sym_idx    ,
    input   wire  [8:0]     i_pkg3_prb_idx    ,
    input   wire  [7:0]     i_pkg3_info       ,
    input   wire  [13:0]    i_pkg3_data       ,
    input   wire  [3:0]     i_pkg3_shift      ,      
    output  reg             o_cpri_wen        ,
    output  reg   [6:0]     o_cpri_waddr      ,
    output  reg   [63:0]    o_cpri_wdata      ,
    output  reg             o_cpri_wlast      
);


    localparam  WDATA_WIDTH        =  64   ;
    localparam  WADDR_WIDTH        =  7    ;
    localparam  RDATA_WIDTH        =  64   ;
    localparam  RADDR_WIDTH        =  7    ;
    localparam  READ_LATENCY       =  3    ;
    localparam  FIFO_DEPTH         =  16   ;
    localparam  FIFO_WIDTH         =  256  ;
    localparam  LOOP_WIDTH         =  9    ;
    localparam  INFO_WIDTH         =  256  ;
    localparam  RAM_TYPE           =  1    ;



//(*keep = "true"*) reg  [2:0]   pkg_sel_1,pkg_sel_2  ;
reg  [2:0]   pkg_sel_1;
reg  [6:0]   pkg_waddr;
reg  [63:0]  pkg_head=0;
reg  [63:0]  pkg_info=0;
reg  [31:0]  ant0_shift,ant1_shift,ant2_shift,ant3_shift;
reg          pkg_last;
reg  [6:0]   pkg_raddr;
wire [63:0]  pkg_rdata;
wire         pkg_rvld;
reg          pkg_rvld_d1,pkg_rvld_d2,pkg_rvld_d3;
reg          pkg_rdy;
reg          pkg_rdy_d0,pkg_rdy_d1,pkg_rdy_d2,pkg_rdy_d3;
wire [255:0] pkg_rinfo;
reg  [63:0]  cpri_head0,cpri_head1,cpri_head2,cpri_head3;
reg  [2:0]   re_cnt,re_cnt_d1,re_cnt_d2,re_cnt_d3;
reg  [3:0]   group_cnt,group_cnt_d1,group_cnt_d2,group_cnt_d3;
wire [13:0]  a0_data,a1_data,a2_data,a3_data;
reg  [13:0]  a0_data_d1,a1_data_d1,a2_data_d1,a3_data_d1;
reg  [15:0]  a0_pkg_data,a1_pkg_data,a2_pkg_data,a3_pkg_data;
reg  [6:0]   cpri_waddr;
wire         [LOOP_WIDTH-WADDR_WIDTH:0] free_size;     
reg          pkg_rvld_d4_1,pkg_rvld_d4_2 /*synthesis preserve*/;
reg  [2:0]   re_cnt_d4_1,re_cnt_d4_2 /*synthesis preserve*/;
reg  [3:0]   group_cnt_d4_1,group_cnt_d4_2 /*synthesis preserve*/;

//-----------------------------------------------------------------------------

always @ (posedge clk)
    begin
         if(rst) 
            begin             
             pkg_sel_1 <= 3'd0; 
//             pkg_sel_2 <= 3'd0; 
            end   
         else if(i_eop == 1'd1)
            begin
             pkg_sel_1 <= pkg_sel_1 + 3'd1 ;
//             pkg_sel_2 <= pkg_sel_2 + 3'd1 ;
            end                            
         else                              
            begin                          
             pkg_sel_1 <= pkg_sel_1        ;
//             pkg_sel_2 <= pkg_sel_2        ;
            end
    end
    

//-----------------------------------------------------------------------------
//--common
always @ (posedge clk)
    begin
        if(i_sop  && (pkg_sel_1 == 3'd0))//
          begin
            pkg_head[63:36]    <= {24'd0,i_pkg0_ch_type};
            pkg_head[19:8]     <= {i_pkg0_cell_idx,i_pkg0_slot_idx,i_pkg0_sym_idx};
          end  
        else
          begin        
            pkg_head[63:36]    <= pkg_head[63:36] ;
            pkg_head[19:8]     <= pkg_head[19:8]  ;    
          end                                      
    end
    
//--group-0-prb_idx    
always @ (posedge clk)
    begin
        if(i_sop  && (pkg_sel_1 == 3'd0))//
          begin         
            pkg_head[35:28]  <= {i_pkg0_prb_idx};
            pkg_head[7:4]    <= i_pkg0_info[7:4];
          end  
        else 
          begin        
            pkg_head[35:28]  <= pkg_head[35:28];
            pkg_head[7:4]    <= pkg_head[7:4];            
          end  
    end

    
//--group-1-prb_idx      
always @ (posedge clk)
    begin
        if(i_sop  && (pkg_sel_1 ==3'd4))//
          begin         
            pkg_head[27:20]  <= {i_pkg0_prb_idx};
            pkg_head[3:0]    <= i_pkg0_info[7:4];            
          end  
        else
          begin        
            pkg_head[27:20]  <= pkg_head[27:20];
            pkg_head[3:0]    <= pkg_head[3:0] ;            
          end  
    end        

//-------------------------------------------------------------------------------
// FFT AGC SIM
//-------------------------------------------------------------------------------
wire           [  31: 0]                        fft_agc_sel             ;
reg            [  63: 0]                        pkg_agc               =0;

//assign fft_agc_sel =    (i_pkg0_sym_idx==0 && i_pkg0_info[7:4]==0) ? 32'h04030201 : 
//                        (i_pkg0_sym_idx==0 && i_pkg1_info[7:4]==1) ? 32'h08070605 :
//                        (i_pkg0_sym_idx==1 && i_pkg0_info[7:4]==0) ? 32'h04030201 : 
//                        (i_pkg0_sym_idx==1 && i_pkg1_info[7:4]==1) ? 32'h08070605 :
//                        (i_pkg0_sym_idx==2 && i_pkg1_info[7:4]==0) ? 32'h02020505 :
//                        (i_pkg0_sym_idx==2 && i_pkg1_info[7:4]==1) ? 32'h04040303 : 32'd0;

assign fft_agc_sel = 32'd0;

//--fft agc
always @ (posedge clk)
    begin
        if(i_sop  && (pkg_sel_1 == 3'd0))//
            pkg_agc[63:32]  <= fft_agc_sel;
        else  if(i_sop  && (pkg_sel_1 ==3'd4))//
            pkg_agc[31: 0]  <= fft_agc_sel;
        else 
            pkg_agc <= pkg_agc;            
    end

//--info null
//always @ (posedge clk)
//    begin
//        if(i_vld  && (pkg_waddr == 7'd0))//&& i_sop
//            pkg_info <= {i_pkg3_info,i_pkg2_info,i_pkg1_info,i_pkg0_info};
//        else
//            pkg_info <= pkg_info;
//    end

//-----------------------------------------------------------------------------
//--0
always @ (posedge clk)
    begin
        case( {pkg_sel_1[2],i_pkg0_prb_idx[1:0]})
            {1'd0,2'd0}    : ant0_shift[3:0]   <= i_pkg0_shift;
            {1'd0,2'd1}    : ant0_shift[7:4]   <= i_pkg0_shift;
            {1'd0,2'd2}    : ant0_shift[11:8]  <= i_pkg0_shift;
            {1'd0,2'd3}    : ant0_shift[15:12] <= i_pkg0_shift;           
            default        : ant0_shift[15:0]  <= ant0_shift[15:0];
        endcase
    end

always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg0_prb_idx[1:0]})
            {1'd1,2'd0}    : ant0_shift[19:16] <= i_pkg0_shift;
            {1'd1,2'd1}    : ant0_shift[23:20] <= i_pkg0_shift;
            {1'd1,2'd2}    : ant0_shift[27:24] <= i_pkg0_shift;
            {1'd1,2'd3}    : ant0_shift[31:28] <= i_pkg0_shift;
            default        : ant0_shift[31:16] <= ant0_shift[31:16];
        endcase
    end
    
//--1
always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg1_prb_idx[1:0]})
            {1'd0,2'd0}    : ant1_shift[3:0]   <= i_pkg1_shift;
            {1'd0,2'd1}    : ant1_shift[7:4]   <= i_pkg1_shift;
            {1'd0,2'd2}    : ant1_shift[11:8]  <= i_pkg1_shift;
            {1'd0,2'd3}    : ant1_shift[15:12] <= i_pkg1_shift;           
            default        : ant1_shift[15:0]  <= ant1_shift[15:0];
        endcase
    end

always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg1_prb_idx[1:0]})
            {1'd1,2'd0}    : ant1_shift[19:16] <= i_pkg1_shift;
            {1'd1,2'd1}    : ant1_shift[23:20] <= i_pkg1_shift;
            {1'd1,2'd2}    : ant1_shift[27:24] <= i_pkg1_shift;
            {1'd1,2'd3}    : ant1_shift[31:28] <= i_pkg1_shift;
            default        : ant1_shift[31:16] <= ant1_shift[31:16];
        endcase
    end

//--2
always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg2_prb_idx[1:0]})
            {1'd0,2'd0}    : ant2_shift[3:0]   <= i_pkg2_shift;
            {1'd0,2'd1}    : ant2_shift[7:4]   <= i_pkg2_shift;
            {1'd0,2'd2}    : ant2_shift[11:8]  <= i_pkg2_shift;
            {1'd0,2'd3}    : ant2_shift[15:12] <= i_pkg2_shift;           
            default        : ant2_shift[15:0]  <= ant2_shift[15:0];
        endcase
    end

always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg2_prb_idx[1:0]})
            {1'd1,2'd0}    : ant2_shift[19:16] <= i_pkg2_shift;
            {1'd1,2'd1}    : ant2_shift[23:20] <= i_pkg2_shift;
            {1'd1,2'd2}    : ant2_shift[27:24] <= i_pkg2_shift;
            {1'd1,2'd3}    : ant2_shift[31:28] <= i_pkg2_shift;
            default        : ant2_shift[31:16] <= ant2_shift[31:16];
        endcase
    end

//--3
always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg3_prb_idx[1:0]})
            {1'd0,2'd0}    : ant3_shift[3:0]   <= i_pkg3_shift;
            {1'd0,2'd1}    : ant3_shift[7:4]   <= i_pkg3_shift;
            {1'd0,2'd2}    : ant3_shift[11:8]  <= i_pkg3_shift;
            {1'd0,2'd3}    : ant3_shift[15:12] <= i_pkg3_shift;           
            default        : ant3_shift[15:0]  <= ant3_shift[15:0];
        endcase
    end

always @ (posedge clk)
    begin
        case({pkg_sel_1[2] , i_pkg3_prb_idx[1:0]})
            {1'd1,2'd0}    : ant3_shift[19:16] <= i_pkg3_shift;
            {1'd1,2'd1}    : ant3_shift[23:20] <= i_pkg3_shift;
            {1'd1,2'd2}    : ant3_shift[27:24] <= i_pkg3_shift;
            {1'd1,2'd3}    : ant3_shift[31:28] <= i_pkg3_shift;
            default        : ant3_shift[31:16] <= ant3_shift[31:16];
        endcase
    end


//-----------------------------------------------------------------------------
always @ (posedge clk)
    begin
        if(rst)
            pkg_waddr <= 7'd0;
        else if(i_vld)
            begin
                if(pkg_waddr == 7'd95)
                    pkg_waddr <= 7'd0;
                else
                    pkg_waddr <= pkg_waddr + 7'd1;
            end
        else
            pkg_waddr <= pkg_waddr;    
    end

always @ (posedge clk)
 if (pkg_waddr == 7'd94)
       pkg_last <= 1'd1;  
 else
       pkg_last <= 1'd0; 
                        
//assign pkg_last = (i_vld && i_eop && (pkg_waddr == 7'd95))? 1'd1 : 1'd0;

loop_buffer_sync_intel #
//loop_buffer_sync #
(
    .WDATA_WIDTH                (WDATA_WIDTH                                                   ),
    .WADDR_WIDTH                (WADDR_WIDTH                                                   ),
    .RDATA_WIDTH                (RDATA_WIDTH                                                   ),
    .RADDR_WIDTH                (RADDR_WIDTH                                                   ),
    .READ_LATENCY               (READ_LATENCY                                                  ),
    .FIFO_DEPTH                 (FIFO_DEPTH                                                    ),
    .FIFO_WIDTH                 (FIFO_WIDTH                                                    ),
    .LOOP_WIDTH                 (LOOP_WIDTH                                                    ),
    .INFO_WIDTH                 (INFO_WIDTH                                                    ),
    .RAM_TYPE                   (RAM_TYPE                                                      )
)u_pkg_ram
(
    .syn_rst                    (rst                                                           ),
    .clk                        (clk                                                           ), 
    .wr_wen                     (i_vld                                                         ),
    .wr_addr                    (pkg_waddr                                                     ),
    .wr_data                    ({8'd0,i_pkg3_data,i_pkg2_data,i_pkg1_data,i_pkg0_data}        ),  
    .wr_wlast                   (pkg_last                                                      ),
    .wr_info                    ({pkg_head,pkg_agc,ant1_shift,ant0_shift,ant3_shift,ant2_shift}),
    .free_size                  (free_size                                                     ),
    .rd_addr                    (pkg_raddr                                                     ),
    .rd_data                    (pkg_rdata                                                     ),
    .rd_vld                     (pkg_rvld                                                      ),
    .rd_info                    (pkg_rinfo                                                     ),
    .rd_rdy                     (pkg_rdy                                                       )
);






//-----------------------------------------------------------------------------
always @ (posedge clk)
    begin
        pkg_rvld_d1   <= pkg_rvld;
        pkg_rvld_d2   <= pkg_rvld_d1;
        pkg_rvld_d3   <= pkg_rvld_d2;
        pkg_rvld_d4_1 <= pkg_rvld_d3;
        pkg_rvld_d4_2 <= pkg_rvld_d3;
    end

always @ (posedge clk)
    begin
        if(pkg_rvld)
            begin
                if(pkg_raddr == 7'd95)
                    pkg_raddr <= 7'd0;
                else
                    pkg_raddr <= pkg_raddr + 7'd1;
            end           
        else
            pkg_raddr <= 7'd0;
    end
    
always @ (posedge clk)
 if (pkg_rvld && (pkg_raddr == 7'd94))
       pkg_rdy <= 1'd1;  
 else
       pkg_rdy <= 1'd0;    


always @ (posedge clk)
    begin
        pkg_rdy_d0 <= pkg_rdy;
        pkg_rdy_d1 <= pkg_rdy_d0;
        pkg_rdy_d2 <= pkg_rdy_d1;
        pkg_rdy_d3 <= pkg_rdy_d2;
    end
//-----------------------------------------------------------------------------
//--CPRI-head   
always @ (posedge clk)
    begin
        if(pkg_rvld)
            cpri_head3 <= pkg_rinfo[63:0];
        else
            cpri_head3 <= 64'd0;    
    end 

always @ (posedge clk)
    begin
        if(pkg_rvld)
            cpri_head2 <= pkg_rinfo[127:64];
        else
            cpri_head2 <= 64'd0;    
    end 

always @ (posedge clk)
    begin
        if(pkg_rvld)
            cpri_head1 <= pkg_rinfo[191:128];
        else
            cpri_head1 <= 64'd0;    
    end
    
always @ (posedge clk)
    begin
        if(pkg_rvld)
            cpri_head0 <= pkg_rinfo[255:192];
        else
            cpri_head0 <= 64'd0;    
    end 
        
//-----------------------------------------------------------------------------
//8DW = a group

always @ (posedge clk)
    begin
        if(pkg_rvld)
            re_cnt <= re_cnt + 3'd1;
        else
            re_cnt <= 3'd0;
    end    

always @ (posedge clk)
    begin
        re_cnt_d1  <= re_cnt;
        re_cnt_d2  <= re_cnt_d1;
        re_cnt_d3  <= re_cnt_d2;
        re_cnt_d4_1 <= re_cnt_d3;
        re_cnt_d4_2 <= re_cnt_d3;
    end
//12group*8=96DW

//compress data
//14bit*8DW turn into 16bit*7DW

//12group
always @ (posedge clk)
    begin
        if(pkg_rvld)
            begin
                if(re_cnt == 3'd7)
                    begin
                        if(group_cnt == 4'd11)
                            group_cnt <= 4'd0;
                        else
                            group_cnt <= group_cnt + 4'd1;
                    end
                else
                    group_cnt <= group_cnt;               
            end            
        else
            group_cnt <= 4'd0;
    end
//-----------------------------------------------------------------------------
always @ (posedge clk)
    begin
        group_cnt_d1   <= group_cnt;
        group_cnt_d2   <= group_cnt_d1;
        group_cnt_d3   <= group_cnt_d2;
        group_cnt_d4_1 <= group_cnt_d3;
        group_cnt_d4_2 <= group_cnt_d3;
    end
  
  


assign a0_data = pkg_rdata[13:0];
assign a1_data = pkg_rdata[27:14];
assign a2_data = pkg_rdata[41:28];
assign a3_data = pkg_rdata[55:42];

always @ (posedge clk)
    begin
        a0_data_d1  <= a0_data;
        a1_data_d1  <= a1_data;
        a2_data_d1  <= a2_data;
        a3_data_d1  <= a3_data;      
    end  
//-----------------------------------------------------------------------------
always @ (posedge clk)
    begin
        if(pkg_rvld_d3)
            begin
                case(re_cnt_d3)
                    3'd1    : a0_pkg_data <= {a0_data[1:0] , a0_data_d1       };
                    3'd2    : a0_pkg_data <= {a0_data[3:0] , a0_data_d1[13:2] };
                    3'd3    : a0_pkg_data <= {a0_data[5:0] , a0_data_d1[13:4] };
                    3'd4    : a0_pkg_data <= {a0_data[7:0] , a0_data_d1[13:6] };
                    3'd5    : a0_pkg_data <= {a0_data[9:0] , a0_data_d1[13:8] };
                    3'd6    : a0_pkg_data <= {a0_data[11:0], a0_data_d1[13:10]};
                    3'd7    : a0_pkg_data <= {a0_data      , a0_data_d1[13:12]};
                    default : a0_pkg_data <= 16'd0;
                endcase
            end
        else
            a0_pkg_data <= 16'd0;
    end    

always @ (posedge clk)
    begin
        if(pkg_rvld_d3)
            begin
                case(re_cnt_d3)
                    3'd1    : a1_pkg_data <= {a1_data[1:0] , a1_data_d1       };
                    3'd2    : a1_pkg_data <= {a1_data[3:0] , a1_data_d1[13:2] };
                    3'd3    : a1_pkg_data <= {a1_data[5:0] , a1_data_d1[13:4] };
                    3'd4    : a1_pkg_data <= {a1_data[7:0] , a1_data_d1[13:6] };
                    3'd5    : a1_pkg_data <= {a1_data[9:0] , a1_data_d1[13:8] };
                    3'd6    : a1_pkg_data <= {a1_data[11:0], a1_data_d1[13:10]};
                    3'd7    : a1_pkg_data <= {a1_data      , a1_data_d1[13:12]};
                    default : a1_pkg_data <= 16'd0;
                endcase
            end
        else
            a1_pkg_data <= 16'd0;
    end   

always @ (posedge clk)
    begin
        if(pkg_rvld_d3)
            begin
                case(re_cnt_d3)
                    3'd1    : a2_pkg_data <= {a2_data[1:0] , a2_data_d1       };
                    3'd2    : a2_pkg_data <= {a2_data[3:0] , a2_data_d1[13:2] };
                    3'd3    : a2_pkg_data <= {a2_data[5:0] , a2_data_d1[13:4] };
                    3'd4    : a2_pkg_data <= {a2_data[7:0] , a2_data_d1[13:6] };
                    3'd5    : a2_pkg_data <= {a2_data[9:0] , a2_data_d1[13:8] };
                    3'd6    : a2_pkg_data <= {a2_data[11:0], a2_data_d1[13:10]};
                    3'd7    : a2_pkg_data <= {a2_data      , a2_data_d1[13:12]};
                    default : a2_pkg_data <= 16'd0;
                endcase
            end
        else
            a2_pkg_data <= 16'd0;
    end 

always @ (posedge clk)
    begin
        if(pkg_rvld_d3)
            begin
                case(re_cnt_d3)
                    3'd1    : a3_pkg_data <= {a3_data[1:0] , a3_data_d1       };
                    3'd2    : a3_pkg_data <= {a3_data[3:0] , a3_data_d1[13:2] };
                    3'd3    : a3_pkg_data <= {a3_data[5:0] , a3_data_d1[13:4] };
                    3'd4    : a3_pkg_data <= {a3_data[7:0] , a3_data_d1[13:6] };
                    3'd5    : a3_pkg_data <= {a3_data[9:0] , a3_data_d1[13:8] };
                    3'd6    : a3_pkg_data <= {a3_data[11:0], a3_data_d1[13:10]};
                    3'd7    : a3_pkg_data <= {a3_data      , a3_data_d1[13:12]};
                    default : a3_pkg_data <= 16'd0;
                endcase
            end
        else
            a3_pkg_data <= 16'd0;
    end 
//-----------------------------------------------------------------------------
//group_cnt=12group  group_cnt_d4_1[1:0]=12/4=3cycle
      
always @ (posedge clk)
    begin
        if( pkg_rvld_d4_1 )
//        if(pkg_rvld_d4_1 && ((re_cnt_d4_1 != 3'd0) || (group_cnt_d4_1[1:0] != 2'd0)))
            o_cpri_wen <= 1'd1;           
        else
            o_cpri_wen <= 1'd0;//96DW-3cycle=93DW
    end


//12*8=96,it has 12-zero,96-12=84,
//3-86=84num
always @ (posedge clk)
    begin
        if(pkg_rvld_d4_1)
            begin
                if(re_cnt_d4_1 != 3'd0)
                    begin
                        if(cpri_waddr == 7'd90)
                            cpri_waddr <= 7'd7;
                        else
                            cpri_waddr <= cpri_waddr + 7'd1;
                    end                   
                else
                    cpri_waddr <= cpri_waddr;
            end
        else
            cpri_waddr <= 7'd7;
    end
//add 12-data
//address 0 write twice
always @ (posedge clk)
    begin
        if(pkg_rvld_d4_1 && (re_cnt_d4_1 == 3'd0))
            case(group_cnt_d4_1)
// group_cnt_d4_1 0--11           
                4'd0    : o_cpri_waddr <= 7'd0;
                4'd1    : o_cpri_waddr <= 7'd1;
                4'd2    : o_cpri_waddr <= 7'd2;
                4'd3    : o_cpri_waddr <= 7'd3;
                4'd4    : o_cpri_waddr <= 7'd4;
                4'd5    : o_cpri_waddr <= 7'd5;
                4'd6    : o_cpri_waddr <= 7'd6;
                4'd7    : o_cpri_waddr <= 7'd91;
                4'd8    : o_cpri_waddr <= 7'd92;
                4'd9    : o_cpri_waddr <= 7'd93;
                4'd10   : o_cpri_waddr <= 7'd94;
                4'd11   : o_cpri_waddr <= 7'd95;
                default : o_cpri_waddr <= 7'd0;
            endcase
        else
            o_cpri_waddr <= cpri_waddr;
    end 
//12-4=8
always @ (posedge clk)
    begin

                            
        if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd3))
            o_cpri_wdata <= cpri_head0;
        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd4))
            o_cpri_wdata <= cpri_head1;
        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd5))
            o_cpri_wdata <= cpri_head2; 
        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd6))
            o_cpri_wdata <= cpri_head3;  
//for test            
//        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd0))
//            o_cpri_wdata <= 64'd5;
//        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd1))
//            o_cpri_wdata <= 64'd6;            
//        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd2))
//            o_cpri_wdata <= 64'd7; 
//        else if(pkg_rvld_d4_2 && (re_cnt_d4_2 == 3'd0) && (group_cnt_d4_2 == 4'd11))
//            o_cpri_wdata <= 64'd11;                            
        else
            o_cpri_wdata <= {a3_pkg_data,a2_pkg_data,a1_pkg_data,a0_pkg_data};
    end

always @ (posedge clk)           
    o_cpri_wlast <= pkg_rdy_d3;

        
        

                  
        
                   
endmodule