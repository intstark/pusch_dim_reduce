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

module FIFO_ASYNC_XPM_intel #(
    parameter integer DATA_WIDTH_A = 64,
    parameter integer DATA_WIDTH_Q = 64,
	parameter integer NUMWORDS =256
    )
	(
	
    input    aclr,
    input  [DATA_WIDTH_A-1:0]  din,
    input    rclk,
    input    rd_en,
    input    wclk,
    input    wr_en,
    output [DATA_WIDTH_Q-1:0]  dout,
    output   empty,
    output   dout_valid,
    // output [$clog2(NUMWORDS*DATA_WIDTH_A/DATA_WIDTH_Q):0]  rdusedw,
    output   full
    // output [$clog2(NUMWORDS)-1:0]  wrusedw
	);
 localparam   USEDWS_WIDTH=$clog2(NUMWORDS);   
 localparam RDUSEDWS_WIDTH=$clog2(NUMWORDS*DATA_WIDTH_A/DATA_WIDTH_Q)+1;
 localparam WRUSEDWS_WIDTH=$clog2(NUMWORDS)+1;
 assign dout_valid = ~empty;
  dcfifo_mixed_widths  dcfifo_mixed_widths_component (
                .aclr (aclr),
                .data (din),
                .rdclk (rclk),
                .rdreq (rd_en),
                .wrclk (wclk),
                .wrreq (wr_en),
                .q (dout),
                .rdempty (empty),
                .rdfull (),
                .rdusedw (),
                .wrempty (),
                .wrfull (full),
                .wrusedw (),
                .eccstatus ());
    defparam
        dcfifo_mixed_widths_component.add_usedw_msb_bit  = "ON",
        dcfifo_mixed_widths_component.enable_ecc  = "FALSE",
        dcfifo_mixed_widths_component.intended_device_family  = "Agilex",
        dcfifo_mixed_widths_component.lpm_hint  = "RAM_BLOCK_TYPE=AUTO,DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT=TRUE",
        dcfifo_mixed_widths_component.lpm_numwords  = NUMWORDS,
        dcfifo_mixed_widths_component.lpm_showahead  = "ON",
        dcfifo_mixed_widths_component.lpm_type  = "dcfifo_mixed_widths",
        dcfifo_mixed_widths_component.lpm_width  = DATA_WIDTH_A,
        dcfifo_mixed_widths_component.lpm_widthu  = WRUSEDWS_WIDTH,
        dcfifo_mixed_widths_component.lpm_widthu_r  = RDUSEDWS_WIDTH,
        dcfifo_mixed_widths_component.lpm_width_r  = DATA_WIDTH_Q,
        dcfifo_mixed_widths_component.overflow_checking  = "ON",
        dcfifo_mixed_widths_component.rdsync_delaypipe  = 4,
        dcfifo_mixed_widths_component.read_aclr_synch  = "ON",
        dcfifo_mixed_widths_component.underflow_checking  = "ON",
        dcfifo_mixed_widths_component.use_eab  = "ON",
        dcfifo_mixed_widths_component.write_aclr_synch  = "ON",
        dcfifo_mixed_widths_component.wrsync_delaypipe  = 4;
endmodule
