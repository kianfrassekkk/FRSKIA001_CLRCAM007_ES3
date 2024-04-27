`timescale 1ns / 1ns
`include "TSC.v"

module TSC_tb;

  // Inputs
  reg A;
  reg clk; // Added clock signal

  // Outputs
  wire B;

  // Instantiate the Unit Under Test (UUT)
  TSC uut(A, B);

  initial begin
    // Initialize Inputs
    $dumpfile("TSC_tb.vcd");
    $dumpvars(0, TSC_tb); // Add hello_tb to waveform dump
    

    A = 0;
    clk = 0;
    #20;

    // Add stimulus here
    A = 1;
    #20;

    A = 0;
    #20;

    $display("test complete");
    $finish; // Added $finish to end the simulation
  end

  always begin
    #10 clk = ~clk; // Generate a clock signal with a period of 20ns
  end   
endmodule

