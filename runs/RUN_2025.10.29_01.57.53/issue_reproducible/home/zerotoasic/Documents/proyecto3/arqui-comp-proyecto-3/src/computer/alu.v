// alu.v
module alu(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [3:0] op,   // 0:PASSA 1:PASSB 2:ADD 3:SUB 4:AND 5:OR 6:XOR 7:NOT 8:SHL 9:SHR A:INC
  output reg  [7:0] y,
  output wire z, n,
  output reg  c, v
);
  reg [8:0] tmp;

  always @* begin
    y = 8'h00; c = 1'b0; v = 1'b0;
    case (op)
  4'h0: y = a;
  4'h1: y = b;
  4'h2: begin
        tmp = {1'b0,a} + {1'b0,b};
        y   = tmp[7:0];
        c   = tmp[8];
        v   = (~(a[7]^b[7]) & (a[7]^y[7]));
      end
  4'h3: begin
        tmp = {1'b0,a} + {1'b0,~b} + 9'd1;
        y   = tmp[7:0];
        c   = tmp[8];              // ~borrow
        v   = ((a[7]^b[7]) & (a[7]^y[7]));
      end
  4'h4: y = a & b;
  4'h5: y = a | b;
  4'h6: y = a ^ b;
  4'h7: y = ~a;
  4'h8: begin
        y = {a[6:0],1'b0};
        c = a[7];
      end
  4'h9: begin
        y = {1'b0,a[7:1]};
        c = a[0];
      end
  4'hA: begin
        tmp = {1'b0,b} + 9'd1;
        y   = tmp[7:0];
        c   = tmp[8];
        v   = (~b[7]) & y[7];
      end
      default: y = 8'h00;
    endcase
  end

  assign z = (y == 8'h00);
  assign n = y[7];
endmodule
