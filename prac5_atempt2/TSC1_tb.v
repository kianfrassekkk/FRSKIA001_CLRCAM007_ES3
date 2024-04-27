`timescale 1ns / 1ns
`include "TSC1.v"

module TSC1_tb;

  // Inputs
  reg A;
  reg clk; // Added clock signal
  reg reset;

  // Outputs
  wire B;

  // Instantiate the Unit Under Test (UUT)
  TSC1 uut(A, clk, reset, B);

  initial begin
    // Initialize Inputs
    $dumpfile("TSC1_tb.vcd");
    $dumpvars(0, TSC1_tb); // Add hello_tb to waveform dump

    clk = 0;
    A = 0;
    reset = 0;
    
    #20;

    // Add stimulus here
    A = 1;
    #20;

    A = 0;
    reset = 1;
    #20;

    $display("test complete");
    $finish; // Added $finish to end the simulation
  end

  always begin
    #10 clk = ~clk; // Generate a clock signal with a period of 20ns
  end 
endmodule
