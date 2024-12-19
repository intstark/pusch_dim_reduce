
module register_shift # (
    parameter WIDTH = 1,
    parameter DEPTH = 1
)(
    input                                           clk                     ,
    input          [WIDTH-1: 0]                     in                      ,
    output         [WIDTH-1: 0]                     out                      
);

integer i;
reg [WIDTH-1:0] shift_reg [DEPTH-1:0] = '{default:0};

always @ (posedge clk)begin
    shift_reg[0] <= in;
    for(i=1;i<DEPTH;i=i+1)begin
        shift_reg[i] <= shift_reg[i-1];
    end  
end                                    



assign out = shift_reg[DEPTH-1];


endmodule