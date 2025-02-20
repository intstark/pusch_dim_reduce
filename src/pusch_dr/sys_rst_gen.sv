//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NEWHUI
// 
// Create Date: 2025/02/12 14:54:23
// Design Name: 
// Module Name: sys_rst_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module  sys_rst_gen (
    input          [   7: 0]                        i_cpri_clk              ,
    input          [   7: 0]                        i_cpri_rst              ,
    input          [7:0][63: 0]                     i_cpri_rx_data          ,
    input          [   7: 0]                        i_cpri_rx_vld           ,

    input                                           i_clk                   ,
    input                                           i_reset                 ,

    input                                           i_auto_rst_en           ,
    input                                           i_rxbuf_en              ,

    output         [   7: 0]                        o_cpri_rst              ,   // cpri clock domain
    output                                          o_sys_rst                   // system clock domain
);


//--------------------------------------------------------------------------------------
// WIRE AND REG DECLARATION
//--------------------------------------------------------------------------------------
reg            [   4: 0]                        rx_vld_buf            =0;
reg            [   6: 0]                        slot_idx              =0;
reg            [   3: 0]                        symb_idx              =0;
reg            [   7: 0]                        prb0_idx              =0;
reg            [   7: 0]                        prb1_idx              =0;
reg            [   3: 0]                        pkg_type              =0;
reg            [   3: 0]                        ant0_idx              =0;
reg            [   3: 0]                        ant1_idx              =0;
reg                                             srs_en                =0;
reg                                             pusch_pkg             =0;
reg                                             rx_slot_rst           =0;

reg            [   7: 0]                        enable_buf            =0;
reg                                             enable_neg            =0;

wire           [   7: 0]                        cpri_rst                ;
wire                                            sys_rst                 ;



//--------------------------------------------------------------------------------------
// cpri clock domain 
//--------------------------------------------------------------------------------------
always @(posedge i_cpri_clk[0]) begin
    rx_vld_buf[4:0] <= {rx_vld_buf[3:0],i_cpri_rx_vld[0]};
    if(i_cpri_rst[0])begin
        pkg_type <= 'd0;
        prb0_idx <= 'd0;
        prb1_idx <= 'd0;
        slot_idx <= 'd0;
        symb_idx <= 'd0;
        ant0_idx <= 'd0;
        ant1_idx <= 'd0;
    end else if(rx_vld_buf[2])begin
        pkg_type <= i_cpri_rx_data[0][39:36];
        prb0_idx <= i_cpri_rx_data[0][35:28];
        prb1_idx <= i_cpri_rx_data[0][27:20];
        slot_idx <= i_cpri_rx_data[0][18:12];
        symb_idx <= i_cpri_rx_data[0][11: 8];
        ant0_idx <= i_cpri_rx_data[0][ 7: 4];
        ant1_idx <= i_cpri_rx_data[0][ 3: 0];
    end
end

// filter up-stream
always @(posedge i_cpri_clk) begin
    if(i_cpri_rst[0])
        pusch_pkg <= 1'b0;
    else if(pkg_type == 4'd8)
        pusch_pkg <= 1'b1;
    else begin
        pusch_pkg <= 1'b0;
    end
end

// filter up-stream slots
always @(posedge i_cpri_clk[0]) begin
    if(i_cpri_rst[0])
        srs_en <= 1'b0;
    else begin
        case(slot_idx)
            7'd3    :   srs_en <= 1'b1;
            7'd8    :   srs_en <= 1'b1;
            7'd13   :   srs_en <= 1'b1;
            7'd18   :   srs_en <= 1'b1;
            7'd23   :   srs_en <= 1'b1;
            7'd28   :   srs_en <= 1'b1;
            7'd33   :   srs_en <= 1'b1;
            7'd38   :   srs_en <= 1'b1;
            7'd43   :   srs_en <= 1'b1;
            7'd48   :   srs_en <= 1'b1;
            7'd53   :   srs_en <= 1'b1;
            7'd58   :   srs_en <= 1'b1;
            7'd63   :   srs_en <= 1'b1;
            7'd68   :   srs_en <= 1'b1;
            7'd73   :   srs_en <= 1'b1;
            7'd78   :   srs_en <= 1'b1;
            default :   srs_en <= 1'b0;
        endcase
    end
end

// generate cpri valid
always @(posedge i_cpri_clk[0]) begin
    if(i_auto_rst_en && srs_en && pusch_pkg && symb_idx == 4'd0)
        rx_slot_rst <= 1'b1;
    else
        rx_slot_rst <= 1'b0;
end

//--------------------------------------------------------------------------------------
// cpri rx domain reset synchronization 
//--------------------------------------------------------------------------------------
generate for(genvar i=0;i<8;i=i+1)begin
assign cpri_rst[i] = enable_neg | rx_slot_rst | i_cpri_rst[i];
alt_reset_synchronizer #(
    .depth                                              (4                      ),
    .rst_value                                          (1                      ) 
)cpri_rst_sync(
    .clk                                                (i_cpri_clk[i]          ),
    .reset_n                                            (!cpri_rst [i]          ),
    .rst_out                                            (o_cpri_rst[i]          ) 
);
end    
endgenerate



//--------------------------------------------------------------------------------------
// system domain 
//--------------------------------------------------------------------------------------
always @(posedge i_clk) begin
    enable_buf[7:0] <= {enable_buf[6:0],i_rxbuf_en};
end


always @(posedge i_clk)begin
    enable_neg <= (~enable_buf[0]) && enable_buf[7];
end

//--------------------------------------------------------------------------------------
// system domain reset synchronization 
//--------------------------------------------------------------------------------------
assign sys_rst = enable_neg | rx_slot_rst | i_reset;

alt_reset_synchronizer #(
    .depth                                              (4                      ),
    .rst_value                                          (1                      ) 
)sys_rst_sync(
    .clk                                                (i_clk                  ),
    .reset_n                                            (!sys_rst               ),
    .rst_out                                            (o_sys_rst              ) 
);




endmodule
