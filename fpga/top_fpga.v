// top_fpga.v - Toplevel para FPGA (sin dependencias de placa)
// - Instancia el core 'computer'
// - Divide reloj para hacerlo visible
// - Sincroniza y extiende reset
// - Mapea A_out[3:0] -> leds[3:0]
// - Muestra B_out en decimal en 2 dígitos 7-seg (tens/ones)

`timescale 1ns/1ps

module top_fpga #(
  parameter CLK_DIV_STEPS = 25_0000,   // ~2 kHz digit scan con 50 MHz (ajusta)
  parameter CPU_DIV       = 25_00000,  // ~1 Hz CPU clk con 50 MHz (ajusta)
  parameter ACTIVE_LOW_SEG = 1,        // 1: segmentos activos en 0
  parameter ACTIVE_LOW_AN  = 1         // 1: enable dígito activo en 0
)(
  input  wire clk_osc,     // reloj de la placa (p.ej. 50 MHz)
  input  wire btn_rst,     // botón de reset asíncrono
  output wire [3:0] leds,  // 4 leds para binario
  output wire [6:0] seg,   // segmentos a-g
  output wire [1:0] an     // habilitación dígitos 1..0 (dos dígitos)
);

  // Reset sincronizado con POR
  wire rst_sync;
  reset_sync #(.POR_CYCLES(1024)) U_RST (
    .clk(clk_osc), .arst(btn_rst), .srst(rst_sync)
  );

  // Reloj lento para el core (visibilidad humana)
  wire clk_cpu;
  clk_div_toggle #(.DIV(CPU_DIV)) U_DIV_CPU (
    .clk(clk_osc), .rst(rst_sync), .clk_out(clk_cpu)
  );

  // Señales del core
  wire [7:0] A_out, B_out;
  wire [6:0] last_opcode_out;
  wire [3:0] flags_out;

  // Instancia del core
  computer U_DUT (
    .clk(clk_cpu),
    .rst(rst_sync),
    .A_out(A_out),
    .B_out(B_out),
    .last_opcode_out(last_opcode_out),
    .flags_out(flags_out)
  );

  // LEDs binarios (4 bits LSB de A_out)
  assign leds = A_out[3:0];

  // Mostrar B_out en decimal (dos dígitos)
  wire [3:0] tens, ones;
  bin8_to_bcd2 U_BCD (
    .bin(B_out), .tens(tens), .ones(ones)
  );

  wire scan_tick;
  clk_div_pulse #(.DIV(CLK_DIV_STEPS)) U_SCAN_TK (
    .clk(clk_osc), .rst(rst_sync), .tick(scan_tick)
  );

  seven_seg_mux2 #(.ACTIVE_LOW_SEG(ACTIVE_LOW_SEG), .ACTIVE_LOW_AN(ACTIVE_LOW_AN)) U_7SEG (
    .clk(clk_osc), .rst(rst_sync), .tick(scan_tick),
    .digit1(tens), .digit0(ones),
    .seg(seg), .an(an)
  );

endmodule

// -----------------------
// Módulos auxiliares
// -----------------------

// reset_sync: sincroniza un reset asíncrono e incluye un POR simple de N ciclos
module reset_sync #(parameter integer POR_CYCLES = 1024) (
  input  wire clk,
  input  wire arst,   // asíncrono activo alto
  output wire srst    // síncrono activo alto
);
  reg [15:0] por_cnt = 0;
  reg por_active = 1'b1;
  always @(posedge clk or posedge arst) begin
    if (arst) begin
      por_cnt   <= 0;
      por_active<= 1'b1;
    end else begin
      if (por_cnt < POR_CYCLES) begin
        por_cnt    <= por_cnt + 1;
        por_active <= 1'b1;
      end else begin
        por_active <= 1'b0;
      end
    end
  end

  // doble FF para sincronizar el botón (metaestabilidad)
  reg s1=1'b1, s2=1'b1;
  always @(posedge clk or posedge arst) begin
    if (arst) begin s1<=1'b1; s2<=1'b1; end
    else begin s1<=por_active; s2<=s1; end
  end
  assign srst = s2;
endmodule

// clk_div_toggle: divide reloj generando un clock de salida con periodo ~2*DIV
module clk_div_toggle #(parameter integer DIV = 25_00000) (
  input  wire clk,
  input  wire rst,
  output reg  clk_out
);
  reg [$clog2(DIV)-1:0] cnt = 0;
  always @(posedge clk) begin
    if (rst) begin
      cnt <= 0;
      clk_out <= 1'b0;
    end else begin
      if (cnt == DIV-1) begin
        cnt <= 0;
        clk_out <= ~clk_out;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end
endmodule

// clk_div_pulse: genera un pulso "tick" cada DIV ciclos
module clk_div_pulse #(parameter integer DIV = 25_0000) (
  input  wire clk,
  input  wire rst,
  output reg  tick
);
  reg [$clog2(DIV)-1:0] cnt = 0;
  always @(posedge clk) begin
    if (rst) begin
      cnt  <= 0;
      tick <= 1'b0;
    end else begin
      if (cnt == DIV-1) begin
        cnt  <= 0;
        tick <= 1'b1;
      end else begin
        cnt  <= cnt + 1'b1;
        tick <= 1'b0;
      end
    end
  end
endmodule

// bin8_to_bcd2: convierte 0..99 a dos dígitos BCD (tens, ones); si >99, satura a 99
module bin8_to_bcd2(
  input  wire [7:0] bin,
  output reg  [3:0] tens,
  output reg  [3:0] ones
);
  integer i;
  reg [7:0] val;
  always @* begin
    val = bin;
    if (val > 8'd99) val = 8'd99;
    tens = 4'd0;
    ones = 4'd0;
    // División por 10 sencilla
    // Resta iterativa (suficiente para 0..99)
    tens = 4'd0;
    while (val >= 8'd10) begin
      val  = val - 8'd10;
      tens = tens + 1'b1;
    end
    ones = val[3:0];
  end
endmodule

// seven_seg_mux2: multiplexa dos dígitos (tens, ones) en 7 segmentos
module seven_seg_mux2 #(
  parameter ACTIVE_LOW_SEG = 1,
  parameter ACTIVE_LOW_AN  = 1
)(
  input  wire clk,
  input  wire rst,
  input  wire tick,         // pulso de cambio de dígito
  input  wire [3:0] digit1, // decenas
  input  wire [3:0] digit0, // unidades
  output reg  [6:0] seg,    // a..g
  output reg  [1:0] an      // en[1] decenas, en[0] unidades
);
  reg sel = 1'b0; // 0: unidades, 1: decenas
  always @(posedge clk) begin
    if (rst) sel <= 1'b0; else if (tick) sel <= ~sel;
  end

  wire [6:0] seg_u, seg_t;
  seven_seg_decode U_D0(.n(digit0), .seg(seg_u));
  seven_seg_decode U_D1(.n(digit1), .seg(seg_t));

  wire [6:0] seg_raw = sel ? seg_t : seg_u;

  always @* begin
    // Polaritad de segmentos
    seg = ACTIVE_LOW_SEG ? ~seg_raw : seg_raw;
    // Enable de dígitos
    case (sel)
      1'b0: an = (ACTIVE_LOW_AN ? 2'b10 : 2'b01); // unidades activas
      1'b1: an = (ACTIVE_LOW_AN ? 2'b01 : 2'b10); // decenas activas
    endcase
  end
endmodule

// seven_seg_decode: 0..9 a segmentos a..g (1=encendido en seg_raw)
module seven_seg_decode(
  input  wire [3:0] n,
  output reg  [6:0] seg
);
  always @* begin
    case (n)
      4'd0: seg = 7'b1111110;
      4'd1: seg = 7'b0110000;
      4'd2: seg = 7'b1101101;
      4'd3: seg = 7'b1111001;
      4'd4: seg = 7'b0110011;
      4'd5: seg = 7'b1011011;
      4'd6: seg = 7'b1011111;
      4'd7: seg = 7'b1110000;
      4'd8: seg = 7'b1111111;
      4'd9: seg = 7'b1111011;
      default: seg = 7'b0000001; // '-'
    endcase
  end
endmodule
