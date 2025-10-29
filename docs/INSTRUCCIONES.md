## Entrega Final — Comandos y dónde ejecutarlos

A continuación están los comandos exactos que debes ejecutar para la evaluación. Incluyen en qué máquina ejecutarlos (VM Linux vs. tu PC Windows) y qué verifica cada paso.

---

### 1) OpenLane (VM Linux) — Correr el flujo con TAG claro y ubicar artefactos

Ejecuta dentro de la VM estos comandos (uno por línea) para entrar al contenedor y correr el flujo desde allí:

```bash
cd /home/zerotoasic/asic_tools/openlane
export PDK_ROOT=/home/zerotoasic/asic_tools/pdk
export PDK=sky130A
make mount
```

Dentro del contenedor (verás un prompt tipo `root@...:/openlane#`), ejecuta en UNA línea cada comando:

```bash
flow.tcl -design /home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3 -tag computer_final -overwrite
exit
```

Luego, fuera del contenedor (VM), lista artefactos del TAG:

```bash
cd /home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3
ls runs/computer_final/results/final/gds/
ls runs/computer_final/results/final/verilog/gl/
ls -R runs/computer_final/reports
find runs/computer_final -type f \( -iname "metrics*.csv" -o -iname "*summary*.csv" -o -iname "metrics*.json" -o -iname "*summary*.json" \) -print
grep -R "WNS\|TNS" runs/computer_final/reports -n || true
grep -m1 DIEAREA runs/computer_final/results/final/def/computer.def || true
```
```

Qué valida cada comando:
- `./flow.tcl ...` corre síntesis, floorplan, PDN, placement, CTS, routing y signoff con tu `config.tcl` (ya configurado: DESIGN_NAME, CLOCK, VERILOG_FILES, `SYNTH_DEFINES="SYNTHESIS ASIC"`).
- `ls .../gds/` confirma la generación de `computer.gds` (artefacto a mostrar).
- `ls .../verilog/gl/` muestra el netlist final (útil para simulación GL o inspección).
- `metrics.csv` y los grep de STA te permiten responder preguntas del ayudante (área, #celdas, WNS/TNS, etc.).

Notas:
- No necesitas agregar archivos extra en la VM. La ROM de instrucciones para el demo (15→0) ya está embebida en `instruction_memory.v` bajo `ASIC` y la síntesis la toma gracias a `SYNTHESIS ASIC` del `config.tcl`.

---

### 2) APIO (Tu PC Windows, fuera de la VM) — Build y flash en la Go Board

Ejecuta en tu PC, dentro del entorno donde instalaste APIO, posicionándote en la raíz del repo del proyecto (la que contiene la carpeta `fpga/`):

```bat
:: (Windows / CMD o PowerShell) Ir al directorio del proyecto
cd C:\ruta\a\tu\proyecto\arqui-comp-proyecto-3

:: (Windows) Compilar bitstream usando tu constraints
:: -p apunta al archivo de pines (PCF) que definiste en tu PC
apio build --top-module top_fpga -p fpga\constraints.pcf

:: (Windows) Flashear la Go Board
apio upload
```

Qué valida cada comando:
- `apio build ...` sintetiza tu toplevel `top_fpga.v`, coloca y enruta, y genera el bitstream respetando tu `constraints.pcf` (pines de reloj, reset, LEDs y 7‑segmentos). El programa (15→0) se ejecuta a través del core; en FPGA puedes usar tu `data/im.dat` si ya lo tienes, o bien definir la macro `ASIC` en tu flujo de build si prefieres la ROM embebida.
- `apio upload` programa la FPGA (requiere driver USB correcto en Windows; si `apio drivers` falla por 429, instala WinUSB/libusbK con Zadig y vuelve a intentar).

Comportamiento esperado en la demostración:
- Los cuatro LEDs muestran en binario `A_out[3:0]` contando 15→0.
- El display 7‑segmentos muestra `B_out` en decimal. Ambos valores los produce el programa ejecutándose en el core (no cableado directo en Verilog).

---

### (Opcional) Verificación rápida en la VM (simulación RTL)

Si quieres validar la secuencia antes de flashear (no obligatorio para la entrega):

```bash
# (VM) Compilar y ejecutar un testbench RTL mínimo del conteo (comandos separados)
/home/zerotoasic/asic_tools/oss-cad-suite/bin/iverilog -g2012 -DSYNTHESIS -DASIC -o /tmp/rtl_countdown sim_rtl/tb_countdown.v src/computer/*.v
/home/zerotoasic/asic_tools/oss-cad-suite/bin/vvp /tmp/rtl_countdown | head -n 40
```

Esto imprime los primeros pasos del conteo (A y B bajando desde 15) usando la ROM ASIC embebida.

