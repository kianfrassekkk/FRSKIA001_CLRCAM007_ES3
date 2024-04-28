module TSC1_tb;

  reg [7:0] buffer [0:15];  // Ring buffer with 10 elements
  reg clk;
  reg reset;
  reg write_enable;
  reg [3:0] write_address;
  reg [7:0] write_data;
  wire [7:0] read_data;

  // Instantiate the TSC1 module
  TSC1 dut (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable),
    .write_address(write_address),
    .write_data(write_data),
    .read_data(read_data)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Reset generation
  initial begin
    reset = 1;
    #10 reset = 0;
  end

  // Test case 1: Write data to buffer
  initial begin
    write_enable = 1;
    write_address = 0;
    write_data = 8'hFF;
    #20;
    write_enable = 0;
    #10;
    $display("Read data at address 0: %h", read_data);
  end

  // Test case 2: Read data from buffer
  initial begin
    write_enable = 0;
    write_address = 0;
    write_data = 8'h00;
    #20;
    $display("Read data at address 0: %h", read_data);
  end

  // Add more test cases as needed

endmodule