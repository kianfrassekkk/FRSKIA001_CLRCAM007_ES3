
`timescale 1ns / 1ns
`include "TSC1.v"

module TSC1_tb;

  // Inputs
  reg clk; // Added clock signal
  reg reset;
  reg start;
  

  // Outputs
  output wire[1:0] state_out;
  output wire req_out;
  output wire rst_out;
  output wire rdy_out;
  output wire [7:0] dat_out;
  output wire [7:0] buffer_out_tail;
  output wire [7:0] buffer_out_head;
  output wire [31:0] TRIGTM;
  
 
 

  // Instantiate the Unit Under Test (UUT)
  TSC1 uut(
    clk, reset, start, state_out, req_out, rst_out, rdy_out, dat_out,
     buffer_out_tail, buffer_out_head , TRIGTM);

  initial begin
    // Initialize Inputs
    $dumpfile("TSC1_tb.vcd");
    $dumpvars(0, TSC1_tb); // Add hello_tb to waveform dump



    
    clk = 0;
    reset = 0;
    start = 0;

    #10

    reset = 1;

    #10

    reset = 0;

    #10 

    start = 1;

    #10

    start = 0;

    #500

    $display("test complete");
    $finish; // Added $finish to end the simulation
  end

  always begin
    #1 clk = ~clk; // Generate a clock signal with a period of 20ns
  end 

  always @(negedge clk) begin
    $display("buffer_out_tail: %h, buffer_out_head: %h, time %h", buffer_out_tail, buffer_out_head, TRIGTM); 
  end 
endmodule