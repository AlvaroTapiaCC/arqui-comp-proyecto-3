// alu.v
module alu(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [3:0] op,   // 0000=PASSA, 0001=PASSB, 0010=ADD, 0011=SUB,
                          // 0100=AND, 0101=OR, 0110=XOR, 0111=NOTA,
                          // 1000=SHL_A, 1001=SHR_A, 1010=INC_B
  output reg  [7:0] y,
  output wire z, n,
  output reg  c, v
);
  reg [8:0] tmp;

  always @* begin
    y = 8'h00; c = 1'b0; v = 1'b0;
    case (op)
      4'h0: y = a;                 // PASS A
      4'h1: y = b;                 // PASS B
      4'h2: begin                  // ADD
        tmp = {1'b0,a} + {1'b0,b};
        y   = tmp[7:0];
        c   = tmp[8];
        v   = (~(a[7]^b[7]) & (a[7]^y[7]));
      end
      4'h3: begin                  // SUB = a - b
        tmp = {1'b0,a} + {1'b0,~b} + 9'd1;
        y   = tmp[7:0];
        c   = tmp[8];              // ~borrow
        v   = ((a[7]^b[7]) & (a[7]^y[7]));
      end
      4'h4: y = a & b;             // AND
      4'h5: y = a | b;             // OR
      4'h6: y = a ^ b;             // XOR
      4'h7: y = ~a;                // NOT (sobre 'a')
      4'h8: begin                  // SHL (sobre 'a')
        y = {a[6:0],1'b0};
        c = a[7];
      end
      4'h9: begin                  // SHR (lógico, sobre 'a')
        y = {1'b0,a[7:1]};
        c = a[0];
      end
      4'hA: begin                  // INC B (usa 'b')
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
