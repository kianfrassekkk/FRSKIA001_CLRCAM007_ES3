`timescale 1ps / 1ps
`include "TSC.v"

module TSC_tb;

  // Inputs
  reg clk; // Added clock signal
  reg reset;
  reg start;
  reg SBF;
//   reg SBF;

  // Outputs
  output wire [2:0] state;

  output wire adc_request_out;
  output wire adc_ready_out;
  output wire [7:0] adc_data_out;

  output wire [4:0] read_ptr_out;
  output wire [4:0] write_ptr_out;
  output wire [7:0] ring_buffer_read_ptr;
  output wire [7:0] ring_buffer_write_ptr;

  output wire [4:0] remaining_values_out;

  output wire TRD_out;
  output wire SD_out;
  output wire CD_out;

  // Instantiate the Unit Under Test (UUT)
  TSC uut(
    clk, 
    reset, 
    start, 
    SBF,
    state, 
    adc_request_out, 
    adc_ready_out,
    adc_data_out,
    read_ptr_out,
    write_ptr_out,
    ring_buffer_read_ptr,
    ring_buffer_write_ptr,
    remaining_values_out,
    TRD_out,
    SD_out,
    CD_out
    );

  initial begin
    // Initialize Inputs
    $dumpfile("TSC_tb.vcd");
    $dumpvars(0, TSC_tb); // Add hello_tb to waveform dump

    clk = 0;
    reset = 0;
    start = 0;
    SBF = 0;
    // SBF = 0;
    #4
    reset = 1;
    #4
    reset = 0;
    #4
    start = 1;
    #4
    start = 0;
    #2000; 

    $display("test complete");

    $finish; // Added $finish to end the simulation
  end

  always begin
    #2 clk = ~clk; // Generate a clock signal with a period of 20ns
    if (clk) 
    $display("ring_buffer_read_ptr[%d] = %d\tring_buffer_write_ptr[%d] = %d",read_ptr_out,ring_buffer_read_ptr,write_ptr_out,ring_buffer_write_ptr);
  end

  always @(posedge TRD_out) begin
    #20 
    SBF = 1;
    #2
    SBF = 0;
  end
endmodule
