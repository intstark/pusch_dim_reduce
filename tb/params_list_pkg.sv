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


`ifndef PKG_DONE
   `define PKG_DONE
   `define SIM_PRJ
   package params_list_pkg;

      
      //Parameters that can be changed by customers (please use a non-zero positive integer value)
      localparam INITIAL_RESET_DURATION = 5000;
      localparam SIM_TIME = 2000000;
      localparam AUX_SIZE_BASIC_FRAME = 5;
      localparam MII_PACKET_SIZE = 1; //number of octets

      //Parameters that cannot be changed by customers
      //CDW = Core Data Width
      localparam CDW = 64;
      localparam MII_CYCLE = MII_PACKET_SIZE*2;
      localparam AUX_CYCLE = AUX_SIZE_BASIC_FRAME*180;
      localparam LEFTSHIFT = 0;
   endpackage
   
   import params_list_pkg::*;

`endif
