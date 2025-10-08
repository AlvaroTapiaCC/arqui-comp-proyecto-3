// data_memory.v (RAM 8b x 256)

module data_memory #(
  parameter AW = 8,           // ancho de dirección: 2^8 = 256 bytes
  parameter DW = 8            // ancho de dato
)(
  input  wire             clk,
  input  wire             we,       // write enable
  input  wire [AW-1:0]    addr,
  input  wire [DW-1:0]    wdata,
  output wire [DW-1:0]    rdata
);

  reg [DW-1:0] ram [0:(1<<AW)-1];

  initial $readmemb("data/mem.dat", ram);

  // write
  always @(posedge clk) begin
    if (we) begin
      ram[addr] <= wdata;
    end
  end

  // read
  assign rdata = ram[addr];

endmodule
