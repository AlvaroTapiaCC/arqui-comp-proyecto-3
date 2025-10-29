# config.tcl — OpenLane config para el core de 8 bits
# Diseño top
set ::env(DESIGN_NAME) computer

# Archivos Verilog (usa rutas absolutas a tu repo)
set ::env(VERILOG_FILES) "\
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/alu.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/computer.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/control_unit.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/data_memory.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/instruction_memory.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/mux_data.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/mux2.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/muxA.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/muxB.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/pc.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/register.v \
/home/zerotoasic/Documents/proyecto3/arqui-comp-proyecto-3/src/computer/status_register.v"

# Reloj
set ::env(CLOCK_PORT) "clk"
# Periodo en ns (20.0 ns = 50 MHz). Ajusta si necesitas otra frecuencia objetivo.
set ::env(CLOCK_PERIOD) "20.0"

# Definiciones para síntesis (activa ramas `SYNTHESIS` y `ASIC` en tu RTL)
set ::env(SYNTH_DEFINES) "SYNTHESIS ASIC"

# Parámetros de floorplan/placement (ajustes para evitar error de PDN)
# Utilización objetivo del core (porcentaje de área ocupada por celdas)
set ::env(FP_CORE_UTIL) 25
# Densidad objetivo del placer global
set ::env(PL_TARGET_DENSITY) 0.25

# Fijar un tamaño mínimo para que quepa la malla de potencia (ajustable)
set ::env(DIE_AREA)  "0 0 300 300"
set ::env(CORE_AREA) "10 10 290 290"

# (Opcional) Usar una configuración de PDN más ligera si aún falla por pitch
# set ::env(PDN_CFG) $::env(SCRIPTS_DIR)/openroad/pdn_cfg_lite.tcl

# (Opcional) Desactiva checks avanzados si dan guerra en iteraciones iniciales
# set ::env(RUN_KLAYOUT) 0
# set ::env(RUN_CVC) 0

# (Opcional) Si usas un SDC propio, podrías indicarlo:
# set ::env(SDC_FILE) "$::env(OPENLANE_ROOT)/scripts/base.sdc"