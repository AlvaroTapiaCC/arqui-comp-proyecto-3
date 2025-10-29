# FPGA top (Go Board prep)

Este directorio contiene un toplevel de FPGA (`top_fpga.v`) que:
- Instancia el core `computer`.
- Divide el reloj para una visualización humana.
- Sincroniza y extiende el reset.
- Mapea A_out[3:0] a `leds[3:0]`.
- Muestra B_out en decimal en dos dígitos 7-seg (`seg[6:0]`, `an[1:0]`).

Polaritades configurables por parámetros:
- `ACTIVE_LOW_SEG` y `ACTIVE_LOW_AN` (ajústalos según la Go Board).

## Cómo simular (RTL)

1. Asegúrate de que `instruction_memory` cargue un programa con `$readmemb("data/im.dat")` que haga el countdown 15→0 (o cualquier patrón visible).
2. Compila con iverilog incluyendo `../src/computer/*.v` y `fpga/top_fpga.v`.

## APIO (plantilla)

Inicializa el proyecto con la placa real para generar `apio.ini`:

```bash
apio init -b go-board   # o el ID exacto de la Go Board de Nandland
```

Luego ejecuta:

```bash
apio build
```

Asegúrate de:
- Mapear pines en un `.pcf` (plantilla sugerida en `fpga/constraints_go_board.pcf.sample`).
- Ajustar el nombre del top a `top_fpga` en la configuración de APIO.

## Archivo de constraints (PCF)

Completa los pines reales de tu placa en `constraints_go_board.pcf.sample` y renómbralo a `constraints.pcf`.

Señales esperadas del toplevel:
- Entrada de reloj: `clk_osc`
- Botón de reset: `btn_rst`
- LEDS (salida): `leds[3:0]`
- 7 segmentos (salida): `seg[6:0]` (a..g)
- Enable dígitos (salida): `an[1:0]` (dos dígitos)

## Notas
- El conteo 15→0 debe provenir del PROGRAMA en la ROM/IM del core, no cableado en Verilog.
- Si al compilar P&R en APIO hay warnings de timing, puedes aumentar el divisor `CPU_DIV` en `top_fpga.v` para bajar la frecuencia del core.
