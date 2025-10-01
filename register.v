// register.v
module register #(parameter W=8)(
  input  wire           clk,
  input  wire           rst,
  input  wire           we,
  input  wire [W-1:0]   d,
  output reg  [W-1:0]   q
);
  always @(posedge clk or posedge rst) begin
    if (rst) q <= {W{1'b0}};
    else if (we) q <= d;
  end
endmodule
