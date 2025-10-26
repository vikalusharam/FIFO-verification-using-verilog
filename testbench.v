`timescale 1ns/1ps
module fifo_tb;

  localparam DEPTH = 16;
  localparam WIDTH = 8;
  localparam ADDR  = 4;

  reg clk, rst, wr_en, rd_en;
  reg  [WIDTH-1:0] data_in;
  wire [WIDTH-1:0] data_out;
  wire full, empty;

  fifo #(.DEPTH(DEPTH), .WIDTH(WIDTH), .ADDR(ADDR)) dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz clock

  // Test sequence
  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars();

    // Initial conditions
    rst = 0; wr_en = 0; rd_en = 0; data_in = 0;
    #10 rst = 1;        // Release reset (active-low reset = 0)
    #10 rst = 0;        // Apply reset
    #10 rst = 1;        // Normal operation

    // Write 16 elements into FIFO
    $display("Writing 16 elements...");
    repeat (16) begin
      @(posedge clk);
      if (!full) begin
        wr_en <= 1;
        data_in <= $random;
      end
    end
    @(posedge clk);
    wr_en <= 0;

    $display("FIFO is full, start reading 2 values and writing 2 more...");
    
    // When full, start 2 reads and 2 writes
    repeat (2) begin
      @(posedge clk);
      rd_en <= 1;
      wr_en <= 1;
      data_in <= $random;
    end

    // Stop operations
    @(posedge clk);
    wr_en <= 0;
    rd_en <= 0;

    // Read remaining data until empty
    $display("Reading remaining data...");
    while (!empty) begin
      @(posedge clk);
      rd_en <= 1;
    end
    rd_en <= 0;

    $display("Test completed.");
    #20 $finish;
  end

endmodule
