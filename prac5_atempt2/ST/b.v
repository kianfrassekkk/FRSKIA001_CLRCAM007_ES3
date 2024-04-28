`include "a.v"

module b (
    input wire clk,
    input wire go,
    output reg a_out
);

reg on;
wire out;

a i_a(on, out);

initial begin
    assign a_out = out;
end

always @(posedge clk or negedge clk) begin
    on = go & clk;
end

endmodule