`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2023 ,  All rights reserved.
//Creation Date   :  2024-03-06
//File name       :  cpri_tx_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------

//100*(150*256)*(96*64)-chip=1s
//10ms=80slot --> (150*256)*(96*64)=38400chip
//125us=1slot -->38400/80=480chip

module cpri_tx_gen_tb
(
    input   wire            clk            ,
    input   wire            rst            ,  

	  input   wire            i_sop          ,
	  input   wire  [63:0]    i_dat          ,
  
    output  reg             o_cpri_wen     ,
    output  reg  [6:0]      o_cpri_waddr   ,
    output  reg  [63:0]     o_cpri_wdata   ,
    output  reg             o_cpri_wlast      
);


reg        dat_vld;
reg [6:0]  dat_adr;
reg [63:0] dat_reg;
wire 		   dat_lst;

always @(posedge clk) begin 
		if(rst) begin 
			 dat_adr <= 'd96;	
	  end
	  else if(i_sop) begin 
	  	 dat_adr <= 0;	  
	  end
	  else if(dat_adr >= 'd96) begin 
			 dat_adr <= 'd96;
	  end
	  else begin 
	  	 dat_adr <= dat_adr + 1'b1;	  
	  end 
end 

  
always @(posedge clk) begin 
		if(rst) begin 
			 dat_vld <= 0;	
	  end
	  else if(i_sop) begin 
	  	 dat_vld <= 1'b1;	  
	  end
	  else if(dat_adr == 'd95) begin 
			 dat_vld <= 0;	
	  end
	  else ;
end   
  
always @(posedge clk) begin 
		if(rst) begin 
			 dat_reg <= 0;	
	  end
	  else begin 
	  	 dat_reg <= i_dat;	  
	  end
end    
  
assign dat_lst = ((dat_adr == 'd95) && dat_vld);
  
always @(posedge clk) begin 
 	  o_cpri_wen   <= dat_vld;	  
	  o_cpri_waddr <= dat_adr;	  
	  o_cpri_wdata <= dat_reg;	  
	  o_cpri_wlast <= dat_lst;	  
end    
           
                   
endmodule
