// data_memory.v (RAM 8b x 256)

module data_memory #(
  parameter AW = 8,
  parameter DW = 8
)(
  input  wire             clk,
  input  wire             we,
  input  wire [AW-1:0]    addr,
  input  wire [DW-1:0]    wdata,
  output wire [DW-1:0]    rdata
);

  reg [DW-1:0] mem [0:(1<<AW)-1];

  initial $readmemb("data/mem.dat", mem);

  // write
  always @(posedge clk) if (we) mem[addr] <= wdata;

`ifdef SYNTHESIS
  // lectura registrada (reduce MUX gigante al mapear)
  reg [DW-1:0] r_q;
  always @(posedge clk) r_q <= mem[addr];
  assign rdata = r_q;
`else
  // lectura combinacional en simulación (ciclo cero)
  assign rdata = mem[addr];
`endif

endmodule
