// TSC simulation module

`define VALUE_COUNT 256
  
module ADC (
    input wire req,      // Request signal from TSC
    input wire rst,      // Reset signal for ADC
    output reg rdy,      // Ready signal to indicate completion
    output reg [7:0] dat // Data output from the array
);

  reg [0:7] adc_data [0:`VALUE_COUNT-1];
  
  integer fd, i, j;// File descriptor

  initial begin
    // Open the CSV file for reading (replace "adc_data.csv" with your actual filename)
    fd = $fopen("adc_data.csv", "r");
    
    // Check if file open was successful
    if (fd == -1) begin
      $display("Error opening file!");
      $finish;  // Exit simulation on error
    end
    
    // Loop through each element of the array
    for (i = 0; i < `VALUE_COUNT; i++) begin
      // Read a line from the file
      j = $fscanf(fd, "%h", adc_data[i]);
    end

    // Close the file
    $fclose(fd);
  end

  
  
  reg [7:0] idx = 0; // Index to access the array
  

always @(posedge req or negedge req or posedge rst) begin
    if (rst) begin
        // Reset the device
        rdy <= 0;
        dat <= 8'b00000000; // Reset data output
        idx <= 0; // Reset array index
    end else if (req) begin
        // Read data from the sample array using modular arithmetic
        dat <= adc_data[idx % `VALUE_COUNT]; // Wrap around if idx exceeds 15
        idx <= idx + 1;

        // Raise RDY line
        rdy <= 1;
    end else begin
        // Lower RDY line if not processing
        rdy <= 0;
    end
end

endmodule
