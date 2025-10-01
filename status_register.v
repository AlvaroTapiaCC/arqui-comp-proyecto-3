// status_register.v
module status_register(
  input  wire       clk,
  input  wire       rst,
  input  wire       latch_en,
  input  wire [6:0] opcode_in,
  input  wire       z_in,
  input  wire       n_in,
  input  wire       c_in,
  input  wire       v_in,
  output reg  [6:0] last_opcode,
  output reg        z,
  output reg        n,
  output reg        c,
  output reg        v
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      z <= 1'b0;
      n <= 1'b0;
      c <= 1'b0;
      v <= 1'b0;
      last_opcode <= 7'd0;
    end else if (latch_en) begin
      z <= z_in;
      n <= n_in;
      c <= c_in;
      v <= v_in;
      last_opcode <= opcode_in;
    end
  end

endmodule