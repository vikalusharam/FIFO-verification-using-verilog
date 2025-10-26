module fifo #(
  parameter DEPTH = 16,
  parameter WIDTH = 8,
  parameter ADDR = 4
)(
  input clk,
  input rst,
  input wr_en,
  input rd_en,
  input [WIDTH-1:0] data_in,
  output reg [WIDTH-1:0] data_out,
  output full,
  output empty
);
  
  reg [ADDR:0] wr_ptr,rd_ptr;
   reg [WIDTH-1:0] mem [DEPTH-1:0];
  integer i;
  
  // write logic 
  always@(posedge clk ) begin
    if(!rst) begin
      for(i=0; i<DEPTH;i=i+1) begin
        mem[i]=0;
    end
      wr_ptr<=0;
    end
    else if(wr_en && !full) begin
      mem[wr_ptr[ADDR-1:0]]<=data_in;
      wr_ptr<=wr_ptr+1;
    end
    
  end
  
  // read logic
  always@(posedge clk) begin
    if(!rst) begin
      data_out<=0;
      rd_ptr<=0;
    end
    else if(rd_en && !empty) begin
      data_out<=mem[rd_ptr[ADDR-1:0]];
      rd_ptr<= rd_ptr+1;
    end
  end
  // full and empty
  assign empty =(wr_ptr == rd_ptr);
  assign full = (wr_ptr[ADDR-1:0] == rd_ptr[ADDR-1:0]) &&
    (wr_ptr[ADDR] != rd_ptr[ADDR]);
  
endmodule
