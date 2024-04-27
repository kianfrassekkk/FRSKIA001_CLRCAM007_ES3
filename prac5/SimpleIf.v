module SimpleIf (
  input wire clk,
  input reg a,
  input reg b,
  output reg out
);

  always @(posedge clk) begin
    if (a > b) begin
      out <= 1'b1; // Output high if a is greater than b
    end else begin
      out <= 1'b0; // Output low otherwise
    end
  end
endmodule
