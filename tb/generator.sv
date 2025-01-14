// (C) 2001-2023 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module generator 
#(
   parameter DATA_SIZE    = 32,
   parameter READYMAPSZ   = 8,
   parameter READY_SZ     = DATA_SIZE/READYMAPSZ,
   parameter INVT_RDY     = 0,
   parameter VALIDOUT_WD  = INVT_RDY ? DATA_SIZE : READY_SZ,
   parameter PATTERN      = 16'hABBA,
   parameter CHKGEN       = 0,
   parameter CYCLE        = 4,        //must match to corresponding checker CYCLE value
   parameter EN_SYNCH     = 1
)
(
   input                          clk,
   input                          reset_n,
   input  logic                   start,
   input  logic [READY_SZ-1:0]    ready,
   input                          tx_hfp,
   input  logic [7:0]             tx_x,
   input  logic [6:0]             tx_seq,
   input  logic                   previntf_done,
   output logic                   count_reached,
   output logic [31:0]            counter, //Max of 2^32 -1 clock cycle transmission.
   output logic [DATA_SIZE-1:0]   data,
   output logic [VALIDOUT_WD-1:0] valid
);

   // *******************************************************************
   //                        Local Parameter
   // *******************************************************************
   localparam               PATTERN_INIT_WD = DATA_SIZE/16;
   localparam               DATA_WD         = (DATA_SIZE >  1) ? DATA_SIZE     : 32;
   localparam [DATA_WD-1:0] PATTERN_INIT    = (DATA_SIZE >  1) ? ((DATA_SIZE > 16) ? {4{PATTERN[15:0]}} : {DATA_SIZE{1'b0}}) : {2{PATTERN[15:0]}}; 

   // *******************************************************************
   //                         Function
   // *******************************************************************
   function automatic logic [DATA_SIZE-1:0] datamask_byte;
      input logic [(DATA_SIZE-1):0] datain;
      input logic [(READY_SZ-1) :0] valid;

      for (int i = 0; i < READY_SZ; i++) begin
         datamask_byte[i*READYMAPSZ +: READYMAPSZ] = datain[i*READYMAPSZ +: READYMAPSZ] & {READYMAPSZ{valid[i]}};
      end
   endfunction

   // *******************************************************************
   //                         Signals
   // *******************************************************************
   logic                    strt;
   logic      [DATA_WD-1:0] dta;
   logic      [DATA_WD-1:0] dta_big;
   logic                    ready_gate;
   logic                    start_sync;
   logic                    reset_n_sync;
   logic                    fst_iq;
   
   // *******************************************************************
   //                         Synchronization
   // *******************************************************************
   generate if (EN_SYNCH) begin: gen_start_sync_en
      alt_cpri_std_synchronizer_nocut start_synch
      (
         .clk     (clk),
         .reset_n (reset_n),
         .din     (start),
         .dout    (start_sync)
      );

      alt_cpri_reset_synchronizer_nocut reset_n_synch 
      (
         .clk     (clk),
         .reset_n (reset_n),
         .rst_out (reset_n_sync)
      );
   end else begin : gen_start_sync_dis
      assign start_sync   = start;
      assign reset_n_sync = reset_n;
   end 
   endgenerate

   // *******************************************************************
   //                         Main
   // *******************************************************************
   (* keep *) logic [63:0] cm_data;
	(* keep *) logic [63:0] cm_valid;
   (* keep *) logic [63:0] iq_ramp;
   (* keep *) logic [63:0] iq_ramp_reverse;
   logic [13:0] ramp_data;


   always_ff @( posedge clk ) begin : iq_ramp_pattern
      if(reset_n_sync == 1'b0)
         ramp_data <= 16'd0;
      else if(tx_seq <= 6)
         ramp_data <= 14'(tx_x);
      else if(tx_hfp)
         ramp_data <= 16'd0;
      else
         ramp_data <= ramp_data + 16'd4;
   end

   //assign iq_ramp =  (tx_x==0) ? 64'h0807060504030201 : {16'(ramp_data+3), 16'(ramp_data+2), 16'(ramp_data+1), ramp_data};


   assign iq_ramp = (tx_seq >= 3 && tx_seq <= 14) ? 64'h0807060504030201 : 
                    (tx_seq >=15 && tx_seq <= 26) ? 64'h0000000000000000 : 
                    (tx_seq >=27 && tx_seq <= 38) ? 64'h0807060504030201 : 
                    (tx_seq >=39 && tx_seq <= 50) ? 64'h0000000000000000 : 
                    (tx_seq >=51 && tx_seq <= 62) ? 64'h0807060504030201 : 
                    (tx_seq >=63 && tx_seq <= 74) ? 64'h0000000000000000 : 
                    (tx_seq >=75 && tx_seq <= 86) ? 64'h0807060504030201 : 
                    64'h0000000000000000;



   assign cm_data =  (tx_x==81 ) ? 64'h5100_0000_0000_0000 : 
                     (tx_x==144) ? 64'h9000_0000_0000_0000 : 
                     (tx_x==145) ? 64'h9100_0000_0000_0000 : 
                     (tx_x==208) ? 64'hD000_0000_0000_0000 : 
                     (tx_x==209) ? 64'hD100_0000_0000_0000 : 
                     64'd0;
   assign cm_valid = (tx_x==81 ) ? {VALIDOUT_WD{1'b1}} : 
                     (tx_x==144) ? {VALIDOUT_WD{1'b1}} : 
                     (tx_x==145) ? {VALIDOUT_WD{1'b1}} : 
                     (tx_x==208) ? {VALIDOUT_WD{1'b1}} : 
                     (tx_x==209) ? {VALIDOUT_WD{1'b1}} : 
                     {VALIDOUT_WD{1'b0}};
							

   always_comb begin : reverse_byte
      for (int i = 0; i < 8; i++) begin
         iq_ramp_reverse[i*8 +: 8] = iq_ramp[8*(7-i) +: 8];
      end
   end



   generate if (INVT_RDY) begin : gen_ready_inv
      assign ready_gate = ~(|ready);
   end else begin: gen_ready_normal
      assign ready_gate = (|ready);
   end
   endgenerate

   assign   fst_iq= (tx_seq==2) ? 1'b1 : 1'b0;

   always_ff @(posedge clk) begin
      if(reset_n_sync == 1'b0) begin
         valid <= {VALIDOUT_WD{1'b0}};
         data  <= {DATA_SIZE{1'b0}};
      end else begin
         if(start_sync && previntf_done) begin
            if (ready_gate) begin
               if(fst_iq)begin
                  data  <= 64'hFFFF_FFFF_FFFF_FFFF;
                  valid <= {VALIDOUT_WD{1'b1}};
               end else begin
                  data  <= iq_ramp;
                  valid <= {VALIDOUT_WD{1'b1}};
               end
            end else begin
               data  <= cm_data; 
               valid <= cm_valid;
            end
         end
      end
   end




endmodule
