module TSC1 (Clk, reset , B);

  
 
  input Clk;
  input reset;


  output B;


  assign B = Clk;

  reg B_reg;
  
  always @(posedge Clk or posedge reset) begin
    if (reset)
      B_reg = 0;
    else if (1)
      B_reg = 0;
  end
  
  assign B = B_reg;
endmodule 

