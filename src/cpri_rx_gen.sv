//----------------------------------------------------------------------------- 
//Copyright @2023 ,  All rights reserved.
//Creation Date   :  2024-03-06
//File name       :  cpri_rx_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

//100*(150*256)*(96*64)-chip=1s
//10ms=80slot --> (150*256)*(96*64)=38400chip
//125us=1slot -->38400/80=480chip

module cpri_rx_gen
(
    input  wire                                     wr_clk                  ,
    input  wire                                     wr_rst                  ,
    input  wire                                     rd_clk                  ,
    input  wire                                     rd_rst                  ,
    input  wire                                     i_cpri_wen              ,
    input  wire    [   6: 0]                        i_cpri_waddr            ,
    input  wire    [  63: 0]                        i_cpri_wdata            ,
    input  wire                                     i_cpri_wlast            ,

    input  wire                                     i_rready                ,
    input  wire                                     i_rx_enable             ,
    output wire                                     o_tvalid                ,
    output wire                                     o_tready                ,
    output wire    [ 255: 0]                        o_rx_info               ,
    output wire    [   7: 0]                        o_iq_raddr              ,
    output wire    [  63: 0]                        o_iq_rx_data             

);


//--------------------------------------------------------------------------------------
// PARAMETER
//--------------------------------------------------------------------------------------
localparam  WDATA_WIDTH        =  64   ; 
localparam  WADDR_WIDTH        =  7    ; 
localparam  RDATA_WIDTH        =  64   ; 
localparam  RADDR_WIDTH        =  7    ; 
localparam  READ_LATENCY       =  3    ; 
localparam  FIFO_DEPTH         =  8    ; 
localparam  FIFO_WIDTH         =  256  ; 
localparam  LOOP_WIDTH         =  10   ; 
localparam  INFO_WIDTH         =  256  ; 
localparam  RAM_TYPE           =  1    ; 
  
//--------------------------------------------------------------------------------------
// WIRE & REGISTER
//--------------------------------------------------------------------------------------
wire           [  63: 0]                        cpri_rdata              ;
wire           [INFO_WIDTH-1: 0]                cpri_rinfo              ;
reg            [INFO_WIDTH-1: 0]                cpri_rinfo_d1         =0;
reg            [INFO_WIDTH-1: 0]                cpri_rinfo_d2         =0;
reg            [INFO_WIDTH-1: 0]                cpri_rinfo_d3         =0;
wire                                            cpri_rdy                ;
wire                                            cpri_rvld               ;
reg            [  13: 0]                        cpri_rvld_dly         =0;
reg                                             rd_valid              =0;
reg            [   6: 0]                        cpri_raddr            =3;
wire           [LOOP_WIDTH-WADDR_WIDTH: 0]      free_size               ;
reg            [2:0][7: 0]                      iq_raddr              ='{default:0};

//--------------------------------------------------------------------------------------
// Debug 
//--------------------------------------------------------------------------------------
reg            [  15: 0]                        sim_cnt=0               ;
reg                                             stop                    ;


always @ (posedge wr_clk )begin 
    if (i_cpri_wen ==1'd1)  
        sim_cnt <= sim_cnt + 1;    
    else
        sim_cnt <= sim_cnt;   
end


always @ (posedge wr_clk )begin 
    if (sim_cnt >=16'd5000 && sim_cnt <=16'd6000 )  
        stop <=1'd0; 
    else 
        stop <=1'd1; 
end

//------------------------------------------------------------------------------------------
// Generate CPRI header for every chip
//------------------------------------------------------------------------------------------
reg            [  63: 0]                        wr_info0              =0;
reg            [  63: 0]                        wr_info1              =0;
reg            [  63: 0]                        wr_info2              =0;
reg            [  63: 0]                        wr_info3              =0;
reg            [INFO_WIDTH-1: 0]                wr_info               =0;

always @ (posedge wr_clk )begin
    case(i_cpri_waddr)
        7'd3    : wr_info0 <= i_cpri_wdata;
        7'd4    : wr_info1 <= i_cpri_wdata;
        7'd5    : wr_info2 <= i_cpri_wdata;
        7'd6    : wr_info3 <= i_cpri_wdata;
        default : begin
                wr_info0 <= wr_info0;
                wr_info1 <= wr_info1;
                wr_info2 <= wr_info2;
                wr_info3 <= wr_info3;
            end
    endcase
end

always @(posedge wr_clk) begin
    if(i_cpri_waddr == 7'd7)
        wr_info <= {wr_info3,wr_info2,wr_info1,wr_info0};
    else
        wr_info <= wr_info;
end

//------------------------------------------------------------------------------------------
// LOOP BUFFER
//------------------------------------------------------------------------------------------
loop_buffer_async_intel #
(
    .WDATA_WIDTH                (WDATA_WIDTH                     ),
    .WADDR_WIDTH                (WADDR_WIDTH                     ),
    .RDATA_WIDTH                (RDATA_WIDTH                     ),
    .RADDR_WIDTH                (RADDR_WIDTH                     ),
    .READ_LATENCY               (READ_LATENCY                    ),    
    .FIFO_DEPTH                 (FIFO_DEPTH                      ),
    .FIFO_WIDTH                 (FIFO_WIDTH                      ),
    .LOOP_WIDTH                 (LOOP_WIDTH                      ),
    .INFO_WIDTH                 (INFO_WIDTH                      ),
    .RAM_TYPE                   (RAM_TYPE                        )
)u_cpri_rx_ram
(
    .wr_rst                     (wr_rst                          ),
    .wr_clk                     (wr_clk                          ),  
    .rd_rst                     (rd_rst                          ), 
    .rd_clk                     (rd_clk                          ),     
    .wr_wen                     (i_cpri_wen                      ),
    .wr_addr                    (i_cpri_waddr                    ),
    .wr_data                    (i_cpri_wdata                    ),  
    .wr_wlast                   (i_cpri_wlast                    ),
    .wr_info                    (wr_info                         ),
    .free_size                  (free_size                       ),    
    .rd_addr                    (cpri_raddr                      ),
    .rd_data                    (cpri_rdata                      ),
    .rd_vld                     (cpri_rvld                       ),
    .rd_info                    (cpri_rinfo                      ),
    .rd_rdy                     (cpri_rdy                        )  
);

//------------------------------------------------------------------------------------------
// Read logic 
//------------------------------------------------------------------------------------------
always @ (posedge rd_clk)
    begin
        if( rd_rst )
            rd_valid <= 1'd0;     
        else if(cpri_rvld )
            rd_valid <= 1'd1; 
        else if(cpri_rvld == 1'd0)
            rd_valid <= 1'd0;  
        else 
            rd_valid <= rd_valid;                                                                      
    end
    
//skip head-0-1-2
always @ (posedge rd_clk)
    begin
        if(rd_valid)begin
            if(cpri_raddr == 7'd90 && i_rready)
                cpri_raddr <= 7'd7;
            else if(i_rready)
                cpri_raddr <= cpri_raddr + 7'd1;
        end else
                cpri_raddr <= 7'd7;                                                        
    end

//always @ (posedge rd_clk)
// if (i_rready && cpri_rvld && (cpri_raddr == 7'd89))
//       cpri_rdy <= 1'd1;  
// else
//       cpri_rdy <= 1'd0;  

assign cpri_rdy = (i_rready && (cpri_raddr == 7'd90)) ? 1'd1 : 1'd0;




//------------------------------------------------------------------------------------------
// Output buffer 
//------------------------------------------------------------------------------------------
always @ (posedge rd_clk)
begin
    iq_raddr[0] <= cpri_raddr;
    for(int i=1; i<3; i++)begin
        iq_raddr[i] <= iq_raddr[i-1];
    end 
end


always @ (posedge rd_clk)
begin
    cpri_rvld_dly  <= {cpri_rvld_dly[12:0], rd_valid};
end

always @ (posedge rd_clk)
begin
    if(rd_valid)
        cpri_rinfo_d1 <= cpri_rinfo;
    else
        cpri_rinfo_d1 <= cpri_rinfo_d1;

    cpri_rinfo_d2 <= cpri_rinfo_d1;
    cpri_rinfo_d3 <= cpri_rinfo_d2;
end

assign o_iq_raddr   = iq_raddr[2];
assign o_iq_rx_data = cpri_rdata;
assign o_rx_info    = cpri_rinfo_d3;
assign o_tvalid     = cpri_rvld_dly[2];
assign o_tready     = (free_size==0) ? 1'b0 : 1'b1;
           
                   
endmodule