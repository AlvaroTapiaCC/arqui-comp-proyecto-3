// data_memory.v - Memoria de datos de 8 bits (placeholder)
// Por ahora: 256 bytes, lectura combinacional, escritura sincrónica.
// Carga inicial desde mem.dat (si hay menos líneas, resto queda en X o se puede inicializar a 0 con un for opcional).

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

  initial begin
    $readmemb("data/mem.dat", ram); // ruta actualizada
    // Mensaje de depuración solo en simulación (Yosys define SYNTHESIS al sintetizar)
`ifndef SYNTHESIS
    $display("[DMEM] ram[0]=%b ram[1]=%b", ram[0], ram[1]);
`endif
  end

  // Escritura sincrónica
  always @(posedge clk) begin
    if (we) begin
      ram[addr] <= wdata;
    end
  end

  // Lectura combinacional (puedes cambiar a sincrónica según ISA)
  assign rdata = ram[addr];

endmodule
