`timescale 1ns / 1ns
`include "adc.v"

module TSC1 (clk, reset, start, state_out, req_out, rst_out, rdy_out, dat_out, buffer_out_head, buffer_out_tail, TRIGTM);
  // Inputs
  input wire clk;        // Clock input
  input wire reset;      // Reset input
  input wire start;      // Start input



  // Outputs
  output reg req_out;    // Direction declaration for req_out
  output reg rst_out;    // Direction declaration for rst_out
  output reg rdy_out;    // Direction declaration for rdy_out
  output reg [7:0] dat_out;  // Direction declaration for dat_out
  output reg [7:0] buffer_out_head;  // Direction declaration for buffer_out0
  output reg [7:0] buffer_out_tail;  // Direction declaration for buffer_out1
  output reg [31:0] TRIGTM;  // Direction declaration for TRIGTM


  // Variables
  integer i = 0;
  integer head=15;
  integer tail= 0; 
  reg [7:0] buffer [0:31];  // Ring buffer with 10 elements
  reg [7:0] TRIGVl = 8'h9D;
  reg [31:0] timer = 32'h0000;

  // State machine
  `define STOP 2'b00     // Define STOP state as 2'b00
  `define READY 2'b01    // Define READY state as 2'b01
  `define RUNNING 2'b10  // Define RUNNING state as 2'b10
  `define triggered 2'b10  // Define RUNNING state as 2'b10

  // Signals
  reg req=0;
  reg rst=0;
  wire rdy;
  wire [7:0] dat;


  initial begin
    assign req_out = req;
    assign rst_out = rst;
    assign rdy_out = rdy;
    assign dat_out = dat;     
  end
  

  // Instantiate ADC module
  ADC adc_inst (
    .req(req),
    .rst(rst),
    .rdy(rdy),
    .dat(dat)
  );

  // Start the program 
  reg [1:0] state = `STOP;  // Register to hold the current state, initialized to STOP state
  output reg[1:0] state_out = 2'b00;  // Output register to display the current state, initialized to 2'b00

  always @(posedge reset) begin  // On positive edge of reset signal
    if ((state == `STOP) || (state == `RUNNING)) begin  // If the current state is STOP or RUNNING
      state = `READY;  // Change the state to READY
      rst = 1; // Resets the ADC
      // Reset the buffer
    end
  end

  always @(posedge start) begin  // On positive edge of start signal
    if (state == `READY) begin  // If the current state is READY
      state = `RUNNING;  // Change the state to RUNNING
      rst = 0; // Resets the ADC
    end
  end

  always @(posedge clk) begin  // On positive edge of clock signal
    timer++;  // Increment the timer
    
    state_out = state;  // Assign the current state to the output register
    if (state == `RUNNING) begin
      req = 1; // Request the ADC  
    end
  end

  always @(negedge clk) begin  // On negative edge of clock signal
    state_out = state;  // Assign the current state to the output register
    if (state == `RUNNING) begin
      req = 0; // Request the ADC 

      // Store the data in the ring buffer
      // output the buffers
      buffer_out_tail <= buffer[tail];
      buffer_out_head <= buffer[head];
      // Increment the head and tail pointers
      head = head + 1;
      tail = tail + 1;
      if (head == 32) begin
        head = 0;
      end
      if (tail == 32) begin
        tail = 0;
      end
      // Store the new data in the buffer
      buffer[tail] <= dat; 

      
      if (buffer_out_tail > TRIGVl) begin
        TRIGTM = timer;
        state = `triggered;
      end     
    end
  end

  
  
endmodule
