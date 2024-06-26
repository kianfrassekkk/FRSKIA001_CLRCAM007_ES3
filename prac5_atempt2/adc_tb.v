// Test bench simulator for TSC

// set simulation time:
`timescale 1ns / 1ps

module ADC_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns

    // Signals
    reg req;
    reg rst;
    wire rdy;
    wire [7:0] dat;

    // Instantiate ADC module
    ADC adc_inst (
        .req(req),
        .rst(rst),
        .rdy(rdy),
        .dat(dat)
    );

    // Clock generation
    reg clk = 0;
  
    //always #((CLK_PERIOD / 2)) clk = ~clk;

    // Testbench logic
    initial begin
      integer i;
        // Reset ADC
      $display("Started");
        rst = 1;
        req = 0;
        #10; // Wait for 10 ns
        rst = 0;

        // Wait for a few microseconds
        #100;
      
      // read and display 10 values from ADC to see it is working
      for (i=0; i<10; i++)
        begin
          // Send REQ pulse to ADC to read next value
          req = 1;
          #5; // Pulse width of 5 ns
          req = 0;
          #5
          
          // display the value
          $display("rdy=%b data=%d",rdy,dat);
                    
        end
        
      #20
        
      
        // End simulation
        $finish;
    end

endmodule
