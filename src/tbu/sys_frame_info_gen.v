`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-21
//File name       :  sys_frame_info_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//
//
//
//-----------------------------------------------------------------------------
module sys_frame_info_gen #
(
    parameter SIM_TEST	=	1'b0,
    parameter CLK_SET   = 3'd1,
    parameter UL_DL_SET =	2'b00  
)
(

    input   wire           clk,
    input   wire           rst,         
    input   wire   [10:0]	 i_ref_frame_num        ,     
    input   wire   [22:0]	 i_ref_frame_cnt        ,
    input   wire   [22:0]	 i_set_frame_pos        ,  
           
    output	reg    [10:0]	 o_half_frame_num       ,
    output	reg    [9:0]	 o_frame_num            ,
    output	reg    [7:0]	 o_slot_num             ,
    output	reg    [3:0]	 o_symb_num             ,
    output	reg            o_half_frame_head      ,    
    output	reg            o_frame_head           ,    
    output	reg            o_slot_head            ,
    output	reg            o_symb_head            ,
    output  reg    [4:0]   o_10us_or_5us_num      ,
    output  reg            o_10us_or_5us_vld       
);

//--(那㊣?????豕那?5us,那㊣??3∟?豕那?5ms㏒?????slot2?那?????米?125us,??5??那?0.5ms-米迆辰???∩車車迆125us,??車角豕y??D?車迆125us)
        
//1ms,   110*(4096+288)+2*(4096+544)=491520  
//0.5ms 245760      
//4384
//4640
//4640+4384*13=61632,0.125390625us  
//4384*14=61376,0.1248697916us    
//---------------------------------------------------------------------------//
//---------------------------------
//--5MS PARAMETER  
//--491.52
	localparam  TIMER_SEL      =  0     ; //0-5us,1-10us; 
	localparam  MAX_TOTAL_5US  = 1000-1 ;  
	localparam  MAX_TOTAL_10US = 500-1  ;  
	localparam  MAX_A_LESS_5US   = 2455-1 ;//2456  
	localparam  MAX_A_MORE_5US   = 2457-1 ;//2458  
	localparam  MAX_A_LESS_10US  = 4915-1 ;//4916 
	localparam  MAX_A_MORE_10US  = 4914-1 ;//4915 
//--245.76	
	localparam  MAX_B_LESS_5US   = 1227-1 ;//1228 
	localparam  MAX_B_MORE_5US   = 1228-1 ;//1229 
	localparam  MAX_B_LESS_10US  = 2455-1 ;//2456 
	localparam  MAX_B_MORE_10US  = 2457-1 ;//2458 
  
//---------------------------------------------------------------------------//
//--122.88MHz                             
//--1s=122_880_000                                
	localparam  TIMER_1_10MS_VALUE = 23'd1228800 -1;  
	localparam  TIMER_1_80MS_VALUE = 26'd9830400 -1;
//--245.76MHz                                     
//--1s=245_760_000                                
	localparam  TIMER_2_10MS_VALUE = 23'd2457600 -1;
	localparam  TIMER_2_80MS_VALUE = 26'd19660800-1;   
//--491.52MHz                                     
//--1s=491_520_000                                
	localparam  TIMER_3_10MS_VALUE = 23'd4915200 -1;
	localparam  TIMER_3_80MS_VALUE = 26'd39321600-1;  
	
//--TDD: 10ms=20slot;	1slot=0.5ms 
//--TDD: 10ms=1228800, 122880=1ms,  61440=0.5ms;
//--TDD: 10ms=2457600, 245760=1ms, 122880=0.5ms;
//--TDD: 10ms=4915200, 491520=1ms, 245760=0.5ms;

//	localparam  TDD_1_SLOT_VALUE = 18'd61440 -1;
//	localparam  TDD_2_SLOT_VALUE = 18'd122880 -1;
//	localparam  TDD_3_SLOT_VALUE = 18'd245760 -1;

//1slot=0.125ms 
	localparam  TDD_1_SLOT_VALUE = 18'd15360 -1;
	localparam  TDD_2_SLOT_VALUE = 18'd30720 -1;
	localparam  TDD_3_SLOT_VALUE = 18'd61440 -1;


(*keep="true"*)reg  [5:0]       set_frame_head_10ms = 6'b000000;
(*keep="true"*)reg  [1:0]       set_frame_head_5ms  = 2'b00;
(*keep="true"*)reg	[1:0]		    slot_head = 2'b00;
wire				                    set_frame_head;
wire				                    set_half_frame_head;
reg		  [22:0]			            time_10ms_value ; 
reg		  [25:0]			            time_80ms_value ; 
reg                             set_frame_head_dly;
reg                             set_half_frame_head_dly;
reg     [22:0]                  set_frame_pos_10ms   ;
reg     [22:0]                  set_frame_pos_5ms    ;
reg     [17:0]                  slot_0_5ms_value ;
reg     [17:0]                  slot_0_125ms_value ;
reg     [17:0]                  slot_cnt = 18'd0;
reg     [ 7:0]                  slot_num = 8'd0;
reg     [14:0]                  symb_cnt = 15'd0;
reg     [14:0]                  symb_max = 15'd8895;
reg     [ 3:0]                  symb_num = 4'd0;
reg     [ 6:0]                  sym_1ms_cnt = 7'd0;
reg					                    symb_head = 1'd0;
reg     [10:0]                  half_frame = 11'd0;
reg     [9:0]                   frame_num = 10'd0;
reg     [ 7:0]                  set_slot_shift = 8'd0;
wire				                    set_slot_head;
reg     [ 7:0]                  set_symb_shift = 8'd0;
wire				                    set_symb_head;
                                
reg     [ 3:0]                  symb_num_dly = 4'd0;
reg     [ 7:0]                  slot_num_dly = 8'd0;
reg     			                  set_symb_head_sel = 1'b0;
reg     			                  set_slot_head_sel = 1'b0;
reg     [22:0]                  ref_frame_cnt;    
reg	    [7:0]     	            set_frame_shift=0;  
reg	    [7:0]     	            set_half_frame_shift=0;  
reg                             data_valid_region=0;
reg     [9:0]                   max_total                      ;
reg     [12:0]                  max_more                       ;
reg     [12:0]                  max_less                       ;
reg     [12:0]                  max_cnt                        ;
reg     [12:0]                  timer_cnt = 0                  ;
reg                             timer_vld                 = 0  ;
reg                             head_10us_or_5us          = 0  ;
reg                             set_frame_head_10ms_dl     = 0  ;
reg     [2:0]                   cycle_idx    = 'b0             ;
reg     [4:0]                   cnt_10us_or_5us_num       = 0  ;
reg     [7:0]                   time_pulse_shift          = 0  ;
wire                            pulse_10us_or_5us              ;
wire                            time_pulse                     ;


//  (* keep="true" *)    reg    [10:0]	 temp_set_frame_num_d1  ;
//  (* keep="true" *)    reg    [ 7:0]	 temp_set_slot_num_d1   ;
//  (* keep="true" *)    reg    [ 3:0]	 temp_set_symb_num_d1   ;
//  (* keep="true" *)    reg             temp_set_slot_head_d1  ;
//  (* keep="true" *)    reg             temp_set_symb_head_d1  ;
//  (* keep="true" *)    reg             temp_set_frame_head_d1 ;
//  (* keep="true" *)    reg    [10:0]	 temp_set_frame_num_d2  ;
//  (* keep="true" *)    reg    [ 7:0]	 temp_set_slot_num_d2   ;
//  (* keep="true" *)    reg    [ 3:0]	 temp_set_symb_num_d2   ;
//  (* keep="true" *)    reg             temp_set_slot_head_d2  ;
//  (* keep="true" *)    reg             temp_set_symb_head_d2  ;
//  (* keep="true" *)    reg             temp_set_frame_head_d2 ;

//---------------------------------------------------------------------------//
//--clk set
//--1=122.88, 2=245.76, 4=491.52 
  
always @ (clk)//10ms
begin
    if(CLK_SET==1 )    
        time_10ms_value  <= TIMER_1_10MS_VALUE;
    else if(CLK_SET==2)    
        time_10ms_value  <= TIMER_2_10MS_VALUE;   
    else   
        time_10ms_value  <= TIMER_3_10MS_VALUE;                
           

end   

always @ (clk)//80ms
begin
    if(CLK_SET==1 )    
        time_80ms_value  <= TIMER_1_80MS_VALUE;
    else if(CLK_SET==2)    
        time_80ms_value  <= TIMER_2_80MS_VALUE;   
    else   
        time_80ms_value  <= TIMER_3_80MS_VALUE;                

end  


//
//always @ (clk)//0.5ms
//begin
//    if(CLK_SET==1 )    
//        slot_0_5ms_value  <= TDD_1_SLOT_VALUE;
//    else if(CLK_SET==2)    
//        slot_0_5ms_value  <= TDD_2_SLOT_VALUE;   
//    else   
//        slot_0_5ms_value  <= TDD_3_SLOT_VALUE;                
//
//end 

//always @ (clk)//0.125ms
//begin
//    if(CLK_SET==1 )    
//        slot_0_125ms_value  <= TDD_1_SLOT_VALUE;
//    else if(CLK_SET==2)    
//        slot_0_125ms_value  <= TDD_2_SLOT_VALUE;   
//    else   
//        slot_0_125ms_value  <= TDD_3_SLOT_VALUE;                
//
//end 


//---------------------------------------------------------------------------//
//UL_DL_SET,1-up,0-dl;1-10ms,0-5ms
//UL_DL_SET,[1]-1-lower,0-higher;[0]-1-lower,0-higher
//---------------------------------------------------------------------------//
//--10ms
generate

if ( UL_DL_SET[1] == 1'b1 ) //uplink frame 10ms ------start low order
	begin : FRAME_10MS_LOWER         
	       always @ ( posedge clk)
            begin
                ref_frame_cnt <= i_ref_frame_cnt;
            end            
         always @ ( posedge clk)
            begin
                	if((i_set_frame_pos) == 23'd0)
//                		set_frame_pos_10ms <= time_10ms_value;//10ms 
                		set_frame_pos_10ms <= {1'd0,time_10ms_value[22:1]};//5ms                		
                	else
                		set_frame_pos_10ms <= i_set_frame_pos - 23'd1;
            end		
		     always @ ( posedge clk)
		     	begin
		     		if(i_ref_frame_cnt != ref_frame_cnt) 
         				if(i_ref_frame_cnt == set_frame_pos_10ms)
//         				if(i_ref_frame_cnt == set_frame_pos_10ms)
         					set_frame_head_10ms <= 6'b111111;
         				else
         					set_frame_head_10ms <= 6'b000000;
         		else
         		      set_frame_head_10ms <= 6'b000000;
		     	end	
	end  
	
else //if ( UL_DL_SET[1] == 1'b0 ) //downlink frame 10ms ------start high order
	begin : FRAME_10MS_HIGHER		
				always @ ( posedge clk)
            begin
            	set_frame_pos_10ms <= i_set_frame_pos ;
            end
   		 always @ ( posedge clk)
   		 	begin
   		 		if(i_ref_frame_cnt == time_10ms_value - set_frame_pos_10ms)
//  		 		if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} - set_frame_pos_10ms)
   		 			set_frame_head_10ms <= 6'b111111;
   		 		else
   		 			set_frame_head_10ms <= 6'b000000;
   		 	end	
	end 
//---------------------------------------------------------------------------//	
//---------------------------------------------------------------------------//
//--5ms
 if ( UL_DL_SET[0] == 1'b1 )//uplink frame 5ms ------start low order
	begin : FRAME_5MS_LOWER
	  
	      always @ ( posedge clk)
            begin
                ref_frame_cnt <= i_ref_frame_cnt;
            end
        always @ ( posedge clk)
            begin
                	if((i_set_frame_pos) == 23'd0)
                		set_frame_pos_5ms <= {1'd0,time_10ms_value[22:1]};//5ms
                	else
                		set_frame_pos_5ms <= i_set_frame_pos - 23'd1;
            end
	  	always @ ( posedge clk)
			  begin
		    	if(i_ref_frame_cnt != ref_frame_cnt)
        			if(i_ref_frame_cnt == set_frame_pos_5ms)
        				set_frame_head_5ms <= 2'b11;  
        			else if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} + set_frame_pos_5ms + 23'd1)//5ms 
        				set_frame_head_5ms <= 2'b11; 
        			else
        				set_frame_head_5ms <= 2'b00;
        		else
        		    set_frame_head_5ms <= 2'b00;
			end		
	end  
else//( UL_DL_SET[0] == 1'b0 ) // frame 5ms------start high order
	begin : FRAME_5MS_HIGHER
		
		always @ ( posedge clk)
       begin
           	set_frame_pos_5ms <= i_set_frame_pos;
       end
		always @ ( posedge clk)
			begin
				if(i_ref_frame_cnt == time_10ms_value - set_frame_pos_5ms)
					set_frame_head_5ms <= 2'b11;  
				else if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} - set_frame_pos_5ms)  //5ms  
					set_frame_head_5ms <= 2'b11; 
				else
					set_frame_head_5ms <= 2'b00;       
			end
		
	end 	
	
	
endgenerate

//---------------------------------------------------------------------------//
//--slot
//--slot_cnt
//--(℅?∩車～芍辰?3∟?豕2^23=8M,23=17+6)
//--(那㊣?????豕那?5us,那㊣??3∟?豕那?5ms㏒?????slot2?那?????米?125us,??5??那?0.5ms-米迆辰???∩車車迆125us,??車角豕y??D?車迆125us)
        
//1ms,   110*(4096+288)+2*(4096+544)=491520  
//0.5ms 245760      
//4384
//4640
//4640+4384*13=61632,0.125390625us  
//4384*14=61376,0.1248697916us    
//---------------------------------------------------------------------------//
   
//always @ (posedge clk)
//	begin
//		if(rst)
//			slot_cnt <= 18'b0;	
//		else if(set_frame_head_10ms[0])
//			slot_cnt <= 18'b1;
//		else if(slot_cnt == slot_0_125ms_value)//0.125ms;
//			slot_cnt <= 18'b0;
//		else
//			slot_cnt <= slot_cnt + 18'b1;
//	end
//--slot_num ++
always @ (posedge clk)
	begin
		if(set_frame_head_10ms[0])
			slot_num <= 8'd0;
		else if(symb_cnt == symb_max && symb_num == 4'd13)//0.125ms;
			 if(slot_num == 8'd79)
			 	  slot_num <= 8'd0;
			 else
			   	slot_num <= slot_num + 8'd1;
		else
			slot_num <= slot_num;
	end
	
always @ (posedge clk)//pulse
	begin
		slot_head[0] <= (symb_cnt == symb_max && symb_num == 4'd13);
		slot_head[1] <= (symb_cnt == symb_max && symb_num == 4'd13);
	end  
//------------------------
//1s      =491520000	
//1ms     =491520
//0.5ms   =245760
//0.125ms =61440=14sym
//1sym    =4388.571
//61440-13*4384-4096=352
//4096+288=4384
//4096+544=4640
//4096+352=4448
//544 288
//110*(4096+288)+2*(4096+544)=
//clk=122.88m
//1ms=2slot=122.88mhz	
//1ms=122880
//1ms=2slot=2*14sym=28symbol

//1ms,   110*(4096+288)+2*(4096+544)=491520
//0.125ms=61440

//clk=122.88m 
//--FFT-N+CP=N_OFDM
//normal cp=288
//long   cp=352
//1symbol=4388 =122880/28
//------------------------
//--1slot=0.5ms
//--4096+288=4384
//--4096+352=4448  
//--4096+544=4640  
//--4384*13+4448 =61440
//--2slot=122880


//clk=245.76m=2*(clk-122.88m )
//(4096+288)*2=8768
//(4096+352)*2=8896    
//8768*13+8896=122880
//------------------------

//---------------------------------------------------------------------------//
//--symbol
//--1ms=8*0.125=8*14sym=112sym


always @ (posedge clk)
	begin
		if(set_frame_head_10ms[1])
			sym_1ms_cnt <= 7'b0;
		else if(symb_cnt == symb_max)
			     if(sym_1ms_cnt == 7'd111)//8*14sym
			     	  sym_1ms_cnt <= 7'b0;
			     else
			     	  sym_1ms_cnt <= sym_1ms_cnt + 7'b1;
		else
			sym_1ms_cnt <= sym_1ms_cnt;
	end

generate
if ( CLK_SET ==2)
  begin
      always @ (posedge clk)
      	begin
      		if(sym_1ms_cnt == 7'd0 || sym_1ms_cnt == 7'd56 )
      			symb_max <= (4096+544)/2-1;//4640 -symbol:0,56 is long cp 
      		else                                     
      			symb_max <= (4096+288)/2-1;//4384 - 
      	end   
  end
else//( CLK_SET ==4)
  begin
      always @ (posedge clk)
      	begin
      		if(sym_1ms_cnt == 7'd0 || sym_1ms_cnt == 7'd56 )
      			symb_max <= (4096+544)-1;//4640 -symbol:0,56 is long cp 
      		else                                     
      			symb_max <= (4096+288)-1;//4384 - 
      	end   	
  end
endgenerate
	

always @ (posedge clk)
	begin
		if(rst )
			symb_cnt <= 15'b0;
		else if(slot_head[0] | set_frame_head_10ms[1])
			symb_cnt <= 15'b1;			
		else if(symb_cnt == symb_max)
			symb_cnt <= 15'b0;
		else
			symb_cnt <= symb_cnt + 15'b1;
	end
//--symb_num ++	
always @ (posedge clk)
	begin
		if(slot_head[0] | set_frame_head_10ms[1])
			symb_num <= 4'b0;
		else if(symb_cnt == symb_max)
			     if(symb_num == 4'd13)
			     	  symb_num <= 4'b0;
			     else
			     	  symb_num <= symb_num + 4'b1;
		else
			symb_num <= symb_num;
	end
	
always @ (posedge clk)
	begin
		symb_head <= (symb_cnt == symb_max);
	end
//---------------------------------------------------------------------------//
//--half_frame
always @ (posedge clk)
	begin
		if(rst)
			  half_frame <= 11'h7ff;//
		else if(set_frame_head_5ms[0])
				half_frame <= half_frame + 11'd1;//
		else
			  half_frame <= half_frame;
	end
//--frame
always @ (posedge clk)
	begin
		if(rst)
			  frame_num <= 10'h3FF;//
		else if( set_frame_head_10ms[2])
				frame_num <= frame_num + 10'd1;//
		else
			  frame_num <= frame_num;
	end


	
//always @ (posedge clk)
//	begin
//		if(symb_head | set_frame_head_10ms[3])
//			set_symb_shift <= 8'b1;
//		else if(|set_symb_shift)
//			set_symb_shift <= set_symb_shift + 8'b1;
//		else
//			set_symb_shift <= set_symb_shift;
//	end
//		
//assign set_symb_head = (symb_head | set_frame_head_10ms[3])? 1'b1 : |set_symb_shift;
 	
//always @ (posedge clk)
//	begin
//		if(slot_head[0] | set_frame_head_10ms[4])
//			set_slot_shift <= 8'b1;
//		else if(|set_slot_shift)
//			set_slot_shift <= set_slot_shift + 8'b1;
//		else
//			set_slot_shift <= set_slot_shift;
//	end
		
//assign set_slot_head = (slot_head[0] | set_frame_head_10ms[4]) ? 1'b1 : |set_slot_shift;

//always @ (posedge clk)
//	begin
//		if(rst)
//			data_valid_region<= 1'd0;
//		else if(set_frame_head_10ms[5])
//			data_valid_region<= 1'd1;
//		else
//			data_valid_region <= data_valid_region;
//	end
//	

always @ (posedge clk)
	begin
		slot_num_dly      <= slot_num;
		symb_num_dly      <= symb_num;

	end

always @ (posedge clk)
	begin
		set_slot_head_sel <= (slot_head[0] | set_frame_head_10ms[3]);
		set_symb_head_sel <= (symb_head    | set_frame_head_10ms[3]);
	end
	

 
always @ (posedge clk)
	begin
  	if(set_frame_head_10ms[4])
  		set_frame_shift <= 8'b1;
  	else if(|set_frame_shift)
  		set_frame_shift <= set_frame_shift + 8'b1;
  	else
  		set_frame_shift <= set_frame_shift;
	end
	
assign set_frame_head = set_frame_head_10ms[4] ? 1'b1 : |set_frame_shift;
	
	

always @ (posedge clk)
	begin
		set_frame_head_dly <= set_frame_head;
	end


always @ (posedge clk)
	begin
  	if(set_frame_head_5ms[1])
  		set_half_frame_shift <= 8'b1;
  	else if(|set_half_frame_shift)
  		set_half_frame_shift <= set_half_frame_shift + 8'b1;
  	else
  		set_half_frame_shift <= set_half_frame_shift;
	end
	
assign set_half_frame_head = set_frame_head_5ms[1] ? 1'b1 : |set_half_frame_shift;
	
	

always @ (posedge clk)
	begin
		set_half_frame_head_dly <= set_half_frame_head;
	end

//always @ (posedge clk)
//	begin
//    temp_set_frame_num_d1      <=    fram_num;
//    temp_set_slot_num_d1       <=    slot_num_dly;
//    temp_set_symb_num_d1       <=    symb_num_dly;
//    temp_set_frame_head_d1     <=    set_frame_head_dly;    
//    temp_set_slot_head_d1      <=    set_slot_head_sel&data_valid_region;
//    temp_set_symb_head_d1      <=    set_symb_head_sel&data_valid_region;
//	end
//always @ (posedge clk)
//	begin
//    temp_set_frame_num_d2      <=    temp_set_frame_num_d1   ;
//    temp_set_slot_num_d2       <=    temp_set_slot_num_d1    ;
//    temp_set_symb_num_d2       <=    temp_set_symb_num_d1    ;
//    temp_set_frame_head_d2     <=    temp_set_frame_head_d1  ;
//    temp_set_slot_head_d2      <=    temp_set_slot_head_d1   ;
//    temp_set_symb_head_d2      <=    temp_set_symb_head_d1   ;
//	end
//always @ (posedge clk)
//	begin
//    o_set_frame_num            <=    temp_set_frame_num_d2    ;
//    o_set_slot_num             <=    temp_set_slot_num_d2     ;
//    o_set_symb_num             <=    temp_set_symb_num_d2     ;
//    o_set_frame_head           <=    temp_set_frame_head_d2   ;
//    o_set_slot_head            <=    temp_set_slot_head_d2    ;
//    o_set_symb_head            <=    temp_set_symb_head_d2    ;
//	end		
	
//assign o_set_half_frame = half_frame;
//assign o_set_frame_num  = frame_num;
//assign o_set_slot_num   = slot_num_dly;
//assign o_set_slot_head  = set_slot_head_sel&data_valid_region;
//assign o_set_symb_num   = symb_num_dly;
//assign o_set_symb_head  = set_symb_head_sel&data_valid_region;	
//assign o_set_frame_head = set_frame_head_dly;
	
	
	
always @ (posedge clk)
	begin
      o_half_frame_num   <= half_frame;
      o_frame_num        <= frame_num;
      o_slot_num         <= slot_num_dly;
      o_symb_num         <= symb_num_dly;
      o_half_frame_head  <= set_half_frame_head_dly;      
      o_frame_head       <= set_frame_head_dly;      
      o_slot_head        <= set_slot_head_sel;
      o_symb_head        <= set_symb_head_sel;
	end	




//ila_tbu_info u_ila_tbu_info 
//(
//	.clk      (clk              ), // input wire clk
//	.probe0   (o_set_frame_head ), // input wire [0:0]  probe0  
//	.probe1   (o_set_slot_head  ), // input wire [0:0]  probe1 
//	.probe2   (o_set_symb_head  ), // input wire [0:0]  probe2 
//	.probe3   (o_set_symb_num   ), // input wire [3:0]  probe3 
//	.probe4   (o_set_slot_num   ), // input wire [7:0]  probe4 
//	.probe5   (o_set_frame_num  ) // input wire [10:0]  probe5
//);
//


//---------------------------------   
//--491.52
//---------------------------------   
//10us                                
//491520/100=4915.2                   
//                                    
//4384*112=491008,+256,+256=491520    
//112??﹞?o?㏒?110???y3㏒CP㏒?芍???3∟CP               	
//4096+544=4640                        
//4096+288=4384                       
//544-288=256                         
//---------------------------------   
//--5us                               
//2457.6*200=5us*200=1000us           
//cycle=5                             
//2457.6                              
//2455                                
//2456,,+1.6   max_less               
//2458,,-0.4   max_more               
//2458*4+2456=2457.6*5*2*2=49,152     
//---------------------------------   
//--10us                              
//4915.2*100=10us*100=1000us          
//cycle=5                             
//4915.2                              
//4915,,+0.2,  max_more              
//4916,,-0.8   max_less               
//4915*4+4916=4915.2*5*2=49,152       
//---------------------------------
//--5MS PARAMETER  
//	localparam  TIMER_SEL      =  0     ; //0-5us,1-10us; 
//	localparam  MAX_TOTAL_5US  = 1000-1 ;  
//	localparam  MAX_TOTAL_10US = 500-1  ;  
//	localparam  MAX_A_LESS_5US   = 2455-1 ;2456  
//	localparam  MAX_A_MORE_5US   = 2457-1 ;2458  
//	localparam  MAX_A_LESS_10US  = 4915-1 ;4916 
//	localparam  MAX_A_MORE_10US  = 4914-1 ;4915 

//---------------------------------     
//---------------------------------   
//--245.76
//---------------------------------                         
//---------------------------------  
//245760=1ms--5us 
//1us=245.760
//--5us--=1228.8                               
//245.760*5us*200=245760       
//cycle=5                             
//1228.8                                                          
//1228,,+0.8   max_less               
//1229,,-0.2   max_more               
//1229*4+1228 = 6144*5*2*2*2=245760    
//---------------------------------   
//245760=1ms--10us 
//1us=245.760
//--10us--=2457.6                              
//245.760*10us*100=245760         
//cycle=5                             
//2457.6                               
//2456,,+1.6,  max_less               
//2458,,-0.4   max_more                
//2458*4+2456 = 12288*5*2*2=245760     
//---------------------------------
//--5MS PARAMETER  
//	localparam  TIMER_SEL      =  0     ; //0-5us,1-10us; 
//	localparam  MAX_TOTAL_5US  = 1000-1 ;  
//	localparam  MAX_TOTAL_10US = 500-1  ;  
//	localparam  MAX_B_LESS_5US   = 1228-1 ;1228  
//	localparam  MAX_B_MORE_5US   = 1229-1 ;1229  
//	localparam  MAX_B_LESS_10US  = 2456-1 ;2456 
//	localparam  MAX_B_MORE_10US  = 2458-1 ;2458 


generate
if ( CLK_SET ==2)
  begin
    always @ (clk)//245.76
     begin
         if(TIMER_SEL==1 ) 
           begin   
             max_more  <= MAX_B_MORE_10US;
             max_less  <= MAX_B_LESS_10US;
           end
         else 
           begin         
             max_more  <= MAX_B_MORE_5US;
             max_less  <= MAX_B_LESS_5US; 
           end              
      end 
  end
else//( CLK_SET ==4)
  begin
    always @ (clk)//491.52
     begin
         if(TIMER_SEL==1 ) 
           begin   
             max_more  <= MAX_A_MORE_10US;
             max_less  <= MAX_A_LESS_10US;
           end
         else 
           begin         
             max_more  <= MAX_A_MORE_5US;
             max_less  <= MAX_A_LESS_5US; 
           end              
      end    	
  end
endgenerate



//always @ (clk)//
//begin
//    if(TIMER_SEL==1 )    
//        max_total  <= MAX_TOTAL_10US;
//    else                  
//        max_total  <= MAX_TOTAL_5US;
//end 


always @ (posedge clk)
    begin
        if(cycle_idx == 3'd0)
            max_cnt <= max_less;
        else
            max_cnt <= max_more;
    end
    
always @ (posedge clk)
    begin
        if(slot_head[1] | set_frame_head_10ms[5])
            cycle_idx <= 3'b0;
        else if(timer_vld)
            if(cycle_idx == 3'd4)
                cycle_idx <= 3'b0;
            else
                cycle_idx <= cycle_idx + 3'b1;
        else
            cycle_idx <= cycle_idx;
    end

always @ (posedge clk)
    begin
        if(slot_head[1] | set_frame_head_10ms[5])
            timer_cnt <= 13'b0;
        else if(timer_vld)
            timer_cnt <= 13'b0;
        else
            timer_cnt <= timer_cnt + 1;
    end

always @ (posedge clk)
    begin
        if(timer_cnt == max_cnt && cnt_10us_or_5us_num != 5'd24 )
              timer_vld <= 1'd1 ;
        else
              timer_vld <= 1'd0;
    end
    
always @ (posedge clk)
    begin
        head_10us_or_5us <= timer_vld;
    end


 
always @ (posedge clk)
    begin
        if(slot_head[1] | set_frame_head_10ms[5])
            cnt_10us_or_5us_num <= 5'b0;
        else if(timer_vld)
            if(cnt_10us_or_5us_num == 5'd24)
                cnt_10us_or_5us_num <= 5'b0;
            else 
                cnt_10us_or_5us_num <= cnt_10us_or_5us_num + 1'b1;
        else 
            cnt_10us_or_5us_num <= cnt_10us_or_5us_num ;
    end

//generate
//  if(MODE == 1'b0) begin  // i_sop's interval is an integer multiple of 10us
//    
//    always @ (posedge clk)
//        begin
//            head_10us_or_5us <= timer_vld;
//        end
//    
//  end
//  else begin  // i_sop's interval isn't an integer multiple of 10us
//    
//    always @ (posedge clk)
//        begin
//            head_10us_or_5us <= timer_vld && (cnt_10us_or_5us_num != max_total);  // keep count until next sop after the last 10us
//        end
//    
//  end
//endgenerate

    
always @ (posedge clk)
    begin
       set_frame_head_10ms_dl <= slot_head[1] | set_frame_head_10ms[5];
    end 

assign  pulse_10us_or_5us = head_10us_or_5us || set_frame_head_10ms_dl;

//always @ (posedge clk)
//    begin
//        if(pulse_10us_or_5us)
//            time_pulse_shift <= 8'b1;
//        else if(|time_pulse_shift)
//            time_pulse_shift <= time_pulse_shift + 8'b1;
//        else
//            time_pulse_shift <= time_pulse_shift;
//    end
//
//assign time_pulse = pulse_10us_or_5us ? 1'b1 : |time_pulse_shift;

always @ (posedge clk)
    begin
        o_10us_or_5us_num       <= cnt_10us_or_5us_num ;
        o_10us_or_5us_vld       <= pulse_10us_or_5us;
//      o_10us_or_5us_vld       <= time_pulse;
    end

























endmodule