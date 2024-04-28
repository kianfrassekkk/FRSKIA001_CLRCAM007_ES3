module a (
    input wire on,
    output reg out
);

always @(posedge on or negedge on) begin
    out = on;
end

endmodule