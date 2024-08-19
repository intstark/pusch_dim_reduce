//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-12
//File name       :  loop_buffer_sync_intel.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

module FIFO_SYNC_XPM_intel #(
    parameter integer DATA_WIDTH = 64,
	parameter integer NUMWORDS =256,
	parameter integer ALMOST_FULL_VALUE=NUMWORDS-4,
	parameter integer ALMOST_EMPTY_VALUE=4
    )
	(
		input  wire [DATA_WIDTH-1:0] din,         //  fifo_input.datain
		input  wire        wr_en,        //            .wrreq
		input  wire        rd_en,        //            .rdreq
		input  wire        clk,        //            .clk
		input  wire        rst,         //            .sclr
        output wire [$clog2(NUMWORDS)-1:0]  usedw,        //            .usedw
		output wire [DATA_WIDTH-1:0] dout,            // fifo_output.dataout
		output wire        full,         //            .full
		output wire        empty,        //            .empty
        output wire        almost_full,  //            .almost_full
		output wire        almost_empty,  //            .almost_empty
		output wire        dout_valid
	);
 localparam   USEDWS_WIDTH=$clog2(NUMWORDS);   
assign dout_valid = ~empty;
    
 scfifo  scfifo_component (
                .clock (clk),
                .data (din),
                .rdreq (rd_en),
                .sclr (rst),
                .wrreq (wr_en),
                .almost_empty (almost_empty),
                .almost_full (almost_full),
                .empty (empty),
                .full (full),
                .q (dout),
                .usedw (usedw),
                .aclr (1'b0),
                .eccstatus ());
    defparam
        scfifo_component.add_ram_output_register  = "OFF",
        scfifo_component.almost_empty_value  = ALMOST_EMPTY_VALUE,
        scfifo_component.almost_full_value  = ALMOST_FULL_VALUE,
        scfifo_component.enable_ecc  = "FALSE",
        scfifo_component.intended_device_family  = "Agilex",
        scfifo_component.lpm_hint  = "RAM_BLOCK_TYPE=AUTO",
        scfifo_component.lpm_numwords  = NUMWORDS,
        scfifo_component.lpm_showahead  = "ON",
        scfifo_component.lpm_type  = "scfifo",
        scfifo_component.lpm_width  = DATA_WIDTH,
        scfifo_component.lpm_widthu  = USEDWS_WIDTH,
        scfifo_component.overflow_checking  = "ON",
        scfifo_component.underflow_checking  = "ON",
        scfifo_component.use_eab  = "ON";
endmodule
