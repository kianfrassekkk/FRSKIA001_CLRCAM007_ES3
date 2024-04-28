`timescale 1ns / 1ps
`include "b.v"

module tb;

  // Inputs
  reg go;
  reg clk;

  // Outputs
  output wire a_out;

  // Instantiate the Unit Under Test (UUT)
  b uut(clk, go, a_out);

  initial begin
    // Initialize Inputs
    $dumpfile("tb.vcd");
    $dumpvars(0, tb); // Add hello_tb to waveform dump

    clk = 0;
    go = 0;
    #2
    go = 1;
    #2
    go = 0;
    #2
    go = 1;
    #2

    $display("test complete");
    $finish; // Added $finish to end the simulation
  end
    always begin
        #1 clk = ~clk;
    end 
endmodule
