`timescale 1 ns / 1 ps
//----------------------------------------------------------------------------- 
//Copyright @2022 ,  zhongguancunchuangxinyuan. All rights reserved.
//Author(s)       :  zhangyunliang 
//Email           :  zhangyunliang@zgc-xnet.con
//Creation Date   :  2022-10-21
//File name       :  sys_frame_cpri_gen.v
//-----------------------------------------------------------------------------
//Detailed Description :                                                     
//o_10us_or_5us_num:time_offset_count[9:0] :5us计数范围0-999，范围0-5ms，用于提前调度;
//
//
//-----------------------------------------------------------------------------
module sys_frame_cpri_gen #
(
    parameter SIM_TEST	=	1'b0,
    parameter CLK_SET   = 3'd1,
    parameter UL_DL_SET =	2'b00  
)
(

    input   wire           clk,
    input   wire           rst,         
    input   wire           i_ref_cpri_head        ,         
    input   wire   [10:0]	 i_ref_frame_num        ,     
    input   wire   [22:0]	 i_ref_frame_cnt        ,
    input   wire   [22:0]	 i_set_frame_pos        ,  
           
    output	reg    [10:0]	 o_half_frame_num       ,
    output	reg    [9:0]	 o_frame_num            ,
    output	reg    [7:0]	 o_slot_num             ,
    output	reg    [3:0]	 o_symb_num             ,
    output	reg            o_half_frame_head      ,    
    output	reg            o_half_frame_last      ,    
    output	reg            o_frame_head           ,    
    output	reg            o_frame_last           ,    
    output	reg            o_slot_head            ,
    output	reg            o_symb_head            ,
    output  reg    [9:0]   o_10us_or_5us_num      ,
    output  reg            o_10us_or_5us_vld       
);

//--(时间精度是5us,时间长度是5ms，每个slot不是严格的125us,每个0.5ms-第一个大于125us,其余三个小于125us)
        
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
(*keep="true"*)reg  [4:0]       set_frame_head_5ms  = 5'b00000;
               reg              set_frame_last_10ms = 1'b0;
               reg              set_frame_last_5ms  = 1'b0;
wire				                    set_frame_head;
wire				                    set_frame_last;
wire				                    set_half_frame_head;
wire				                    set_half_frame_last;
wire				                    set_last_half_frame_last;
reg		  [22:0]			            time_10ms_value ; 
reg		  [25:0]			            time_80ms_value ; 
reg                             set_frame_head_dly;
reg                             set_frame_last_dly;
reg                             set_half_frame_head_dly;
reg                             set_half_frame_last_dly;
reg     [22:0]                  set_frame_pos_10ms   ;
reg     [22:0]                  set_frame_pos_5ms    ;
reg     [17:0]                  slot_0_5ms_value ;
reg     [17:0]                  slot_0_125ms_value ;
reg     [17:0]                  slot_cnt = 18'd0;
reg     [ 7:0]                  slot_num = 8'd0;
reg					                    slot_head = 1'd0;
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
reg	    [5:0]     	            set_frame_shift=0;  
reg	    [5:0]     	            set_frame_shift1=0;  
reg	    [5:0]     	            set_half_frame_shift=0;  
reg	    [5:0]     	            set_half_frame_shift1=0;  
reg                             data_valid_region=0;
reg     [9:0]                   max_total                      ;
reg     [12:0]                  max_more                       ;
reg     [12:0]                  max_less                       ;
reg     [12:0]                  max_cnt                        ;
reg     [12:0]                  timer_cnt = 0                  ;
reg                             timer_vld                 = 0  ;
reg                             head_10us_or_5us          = 0  ;
reg                             set_frame_head_5ms_dl     = 0  ;
reg     [ 2:0]                  cycle_idx    = 'b0             ;
reg     [ 9:0]                  cnt_10us_or_5us_num       = 0  ;
reg     [7:0]                   time_pulse_shift          = 0  ;
wire                            pulse_10us_or_5us              ;
wire                            time_pulse                     ;

reg     [10:0]	                temp_set_half_frame_num_d1     ;
reg     [9:0]	                  temp_set_frame_num_d1          ;
reg     [7:0]	                  temp_set_slot_num_d1           ;
reg     [3:0]	                  temp_set_symb_num_d1           ;
reg                             temp_set_half_frame_head_d1    ;
reg                             temp_set_frame_head_d1         ;
reg                             temp_set_slot_head_d1          ;
reg                             temp_set_symb_head_d1          ;
reg                             head_flag                      ;  
reg     [6:0]	                  head_cnt                       ;  
reg     [6:0]	                  set_frame_pos_d1               ;  
reg     [15:0]	                error_cnt                       ;  









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
        			if(i_ref_frame_cnt == set_frame_pos_5ms )
        				set_frame_head_5ms <= 5'b11111;  
        			else if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} + set_frame_pos_5ms + 23'd1)//5ms 
        				set_frame_head_5ms <= 5'b11111; 
        			else
        				set_frame_head_5ms <= 5'b00000;
        		else
        		    set_frame_head_5ms <= 5'b00000;
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
					set_frame_head_5ms <= 5'b11111;  
				else if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} - set_frame_pos_5ms)  //5ms  
					set_frame_head_5ms <= 5'b11111; 
				else
					set_frame_head_5ms <= 5'b00000;       
			end
		
	end 	

//////////////////////////////////////////////////////////////////////////////////////////////////////
//--last--10ms
if ( UL_DL_SET[1] == 1'b1 ) //uplink frame 10ms ------start low order
	begin : FRAME_10MS_LOWER_LAST         
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
         				if(i_ref_frame_cnt == set_frame_pos_10ms-7'd64)
//         				if(i_ref_frame_cnt == set_frame_pos_10ms)
         					set_frame_last_10ms <= 1'b1;
         				else
         					set_frame_last_10ms <= 1'b0;
         		else
         		      set_frame_last_10ms <= 1'b0;
		     	end	
	end  
	
else //if ( UL_DL_SET[1] == 1'b0 ) //downlink frame 10ms ------start high order
	begin : FRAME_10MS_HIGHER_LAST		
				always @ ( posedge clk)
            begin
            	set_frame_pos_10ms <= i_set_frame_pos ;
            end
   		 always @ ( posedge clk)
   		 	begin
   		 		if(i_ref_frame_cnt == time_10ms_value - set_frame_pos_10ms-7'd64)
//  		 		if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} - set_frame_pos_10ms)
   		 			set_frame_last_10ms <= 1'b1;
   		 		else
   		 			set_frame_last_10ms <= 1'b0;
   		 	end	
	end 	
//////////////////////////////////////////////////////////////////////////////////////////////////////
//--last--5ms
 if ( UL_DL_SET[0] == 1'b1 )//uplink frame 5ms ------start low order
	begin : FRAME_5MS_LOWER_LAST
	  
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
        			if(i_ref_frame_cnt == set_frame_pos_5ms-7'd64)
        				set_frame_last_5ms <= 1'b1;  
        			else if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} + set_frame_pos_5ms + 23'd1-7'd64)//5ms 
        				set_frame_last_5ms <= 1'b1; 
        			else
        				set_frame_last_5ms <= 1'b0;
        		else
        		    set_frame_last_5ms <= 1'b0;
			end		
	end  
else//( UL_DL_SET[0] == 1'b0 ) // frame 5ms------start high order
	begin : FRAME_5MS_HIGHER_LAST
		
		always @ ( posedge clk)
       begin
           	set_frame_pos_5ms <= i_set_frame_pos;
       end
		always @ ( posedge clk)
			begin
				if(i_ref_frame_cnt == time_10ms_value - set_frame_pos_5ms-7'd64)
					set_frame_last_5ms <= 1'b1;  
				else if(i_ref_frame_cnt == {1'd0,time_10ms_value[22:1]} - set_frame_pos_5ms-7'd64)  //5ms  
					set_frame_last_5ms <= 1'b1; 
				else
					set_frame_last_5ms <= 1'b0;       
			end
		
	end
///////////////////////////////////////////////////		
	
endgenerate

//---------------------------------------------------------------------------//
//--slot
//--slot_cnt
//--(最大搬移长度2^23=8M,23=17+6)
//--(时间精度是5us,时间长度是5ms，每个slot不是严格的125us,每个0.5ms-第一个大于125us,其余三个小于125us)
        
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
		slot_head <= (symb_cnt == symb_max && symb_num == 4'd13);
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
		else if(slot_head | set_frame_head_10ms[1])
			symb_cnt <= 15'b1;			
		else if(symb_cnt == symb_max)
			symb_cnt <= 15'b0;
		else
			symb_cnt <= symb_cnt + 15'b1;
	end
//--symb_num ++	
always @ (posedge clk)
	begin
		if(slot_head | set_frame_head_10ms[1])
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
//--  
always @ (posedge clk)
 set_frame_pos_d1 <= i_set_frame_pos[6:0];

always @ (posedge clk)
	begin
		if(rst)
			  head_cnt <= 7'd0;
		else if(i_ref_cpri_head)
				head_cnt <= 7'd1;			  		  
		else if(head_cnt ==set_frame_pos_d1-1'd1)
				head_cnt <= 7'd0;
		else if(head_cnt != 7'd0)
			  head_cnt <= head_cnt + 1'd1;
	end


always @ (posedge clk)
	begin
		if(head_cnt ==set_frame_pos_d1-1'd1)
			head_flag <= 1'b1;
		else
			head_flag <= 1'b0;
	end

always @ (posedge clk)
	begin
		if(rst)
			  half_frame <= 11'h7ff;//
		else if(head_flag)
				half_frame <= {i_ref_frame_num[9:0],1'd0};//			  		  
		else if(set_frame_head_5ms[0])
				half_frame <= half_frame + 11'd1  ;//
		else
			  half_frame <= half_frame;
	end
//--frame
always @ (posedge clk)
	begin
		if(rst)
			  frame_num <= 10'h3FF;//
		else if(head_flag)
			  frame_num <= i_ref_frame_num[9:0];					  
		else if( set_frame_head_10ms[2])
				frame_num <= frame_num + 10'd1;//
		else
			  frame_num <= frame_num;
	end

always @ (posedge clk)
	begin
		if(rst)
			  error_cnt <= 16'd0;
		else if(head_flag==set_frame_head_10ms[2])
			  error_cnt <= 16'd0;
		else
			  error_cnt <= error_cnt + 1'd1 ;
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
//		if(slot_head | set_frame_head_10ms[4])
//			set_slot_shift <= 8'b1;
//		else if(|set_slot_shift)
//			set_slot_shift <= set_slot_shift + 8'b1;
//		else
//			set_slot_shift <= set_slot_shift;
//	end
		
//assign set_slot_head = (slot_head | set_frame_head_10ms[4]) ? 1'b1 : |set_slot_shift;

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
		set_slot_head_sel <= (slot_head | set_frame_head_10ms[5]);
		set_symb_head_sel <= (symb_head | set_frame_head_10ms[5]);
	end
//---------------------------------------------------------------------------//
//--frame

//64clk,245.76,160ns=260.41666666666666666666666666667ns
always @ (posedge clk)
	begin
  	if(set_frame_head_10ms[5])
  		set_frame_shift <= 6'b1;
  	else if(|set_frame_shift)
  		set_frame_shift <= set_frame_shift + 6'b1;
  	else
  		set_frame_shift <= set_frame_shift;
	end
	
assign set_frame_head = set_frame_head_10ms[5] ? 1'b1 : |set_frame_shift;
	

	
always @ (posedge clk)
	begin
  	if(set_frame_last_10ms)
  		set_frame_shift1 <= 6'b1;
  	else if(|set_frame_shift1)
  		set_frame_shift1 <= set_frame_shift1 + 6'b1;
  	else
  		set_frame_shift1 <= set_frame_shift1;
	end	

assign set_frame_last = set_frame_last_10ms ? 1'b1 : |set_frame_shift1;

	

always @ (posedge clk)
	begin
		set_frame_head_dly <= set_frame_head;
		set_frame_last_dly <= set_frame_last;
	end

//---------------------------------------------------------------------------//
//--half_frame
always @ (posedge clk)
	begin
  	if(set_frame_head_5ms[1])
  		set_half_frame_shift <= 6'b1;
  	else if(|set_half_frame_shift)
  		set_half_frame_shift <= set_half_frame_shift + 6'b1;
  	else
  		set_half_frame_shift <= set_half_frame_shift;
	end
	
assign set_half_frame_head = set_frame_head_5ms[1] ? 1'b1 : |set_half_frame_shift;
	
	
always @ (posedge clk)
	begin
  	if(set_frame_last_5ms)
  		set_half_frame_shift1 <= 6'b1;
  	else if(|set_half_frame_shift1)
  		set_half_frame_shift1 <= set_half_frame_shift1 + 6'b1;
  	else
  		set_half_frame_shift1 <= set_half_frame_shift1;
	end	

assign set_half_frame_last = set_frame_last_5ms ? 1'b1 : |set_half_frame_shift1;
	

always @ (posedge clk)
	begin
		set_half_frame_head_dly <= set_half_frame_head;
		set_half_frame_last_dly <= set_half_frame_last;
	end

//---------------------------------------------------------------------------//

//always @ (posedge clk)
//	begin
//    temp_set_half_frame_num_d1      <=       half_frame;
//    temp_set_frame_num_d1           <=       frame_num;
//    temp_set_slot_num_d1            <=       slot_num_dly;
//    temp_set_symb_num_d1            <=       symb_num_dly;  
//    temp_set_half_frame_head_d1     <=       set_half_frame_head_dly;        
//    temp_set_frame_head_d1          <=       set_frame_head_dly;    
//    temp_set_slot_head_d1           <=       set_slot_head_sel;
//    temp_set_symb_head_d1           <=       set_symb_head_sel ;
//	end
//
//	
//always @ (posedge clk)
//	begin
//      o_half_frame_num              <=       temp_set_half_frame_num_d1    ;
//      o_frame_num                   <=       temp_set_frame_num_d1         ;
//      o_slot_num                    <=       temp_set_slot_num_d1          ;
//      o_symb_num                    <=       temp_set_symb_num_d1          ;
//      o_half_frame_head             <=       temp_set_half_frame_head_d1   ;
//      o_frame_head                  <=       temp_set_frame_head_d1        ;
//      o_slot_head                   <=       temp_set_slot_head_d1         ;
//      o_symb_head                   <=       temp_set_symb_head_d1         ;
//	end		

//---------------------------------------------------------------------------//


//always @ (posedge clk)
//	begin
//    o_set_frame_num            <=    temp_set_frame_num_d2    ;
//    o_set_slot_num             <=    temp_set_slot_num_d2     ;
//    o_set_symb_num             <=    temp_set_symb_num_d2     ;
//    o_set_frame_head           <=    temp_set_frame_head_d2   ;
//    o_set_slot_head            <=    temp_set_slot_head_d2    ;
//    o_set_symb_head            <=    temp_set_symb_head_d2    ;
//	end	
//---------------------------------------------------------------------------//
	
always @ (posedge clk)
	begin
      o_half_frame_num   <= half_frame;
      o_frame_num        <= frame_num ;
      o_slot_num         <= slot_num_dly;
      o_symb_num         <= symb_num_dly;
      o_half_frame_head  <= set_half_frame_head_dly;      
      o_half_frame_last  <= set_half_frame_last_dly;      
      o_frame_head       <= set_frame_head_dly;      
      o_frame_last       <= set_frame_last_dly;      
      o_slot_head        <= set_slot_head_sel;
      o_symb_head        <= set_symb_head_sel;
	end




//
//
//ila_tbu_info u_ila_tbu_rpt
//(
//	.clk      (clk              ), // input wire clk
//	.probe0   (o_frame_head     ), // input wire [0:0]  probe0  
//	.probe1   (o_slot_head      ), // input wire [0:0]  probe1 
//	.probe2   (o_symb_head      ), // input wire [0:0]  probe2 
//	.probe3   (o_symb_num       ), // input wire [3:0]  probe3 
//	.probe4   (o_slot_num       ), // input wire [7:0]  probe4 
//	.probe5   (o_frame_num      ) // input wire [10:0]  probe5
//);


















endmodule