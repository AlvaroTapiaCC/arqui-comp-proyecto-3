#!/bin/sh
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir;
export CURRENT_DEF='./tmp/floorplan/5-tapcell.def';
export CURRENT_NETLIST='./results/synthesis/computer.v';
export CURRENT_ODB='./tmp/floorplan/5-tapcell.odb';
export CURRENT_POWERED_NETLIST='0';
export CURRENT_SDC='./tmp/floorplan/3-initial_fp.sdc';
export DESIGN_NAME='computer';
export FP_PDN_CFG='openlane/scripts/openroad/pdn_cfg_lite.tcl';
export FP_PDN_CHECK_NODES='1';
export FP_PDN_ENABLE_GLOBAL_CONNECTIONS='1';
export FP_PDN_ENABLE_MACROS_GRID='1';
export FP_PDN_SKIPTRIM='0';
export GND_NET='VGND';
export LIB_TYPICAL='pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib';
export MAX_FANOUT_CONSTRAINT='10';
export MAX_TRANSITION_CONSTRAINT='0.75';
export MERGED_LEF='./tmp/merged.nom.lef';
export OUTPUT_CAP_LOAD='33.442';
export PACKAGED_SCRIPT_0='openlane/scripts/openroad/pdn.tcl';
export PACKAGED_SCRIPT_1='openlane/scripts/openroad/pdn_cfg_lite.tcl';
export PACKAGED_SCRIPT_2='openlane/scripts/openroad/common/io.tcl';
export PACKAGED_SCRIPT_3='./tmp/floorplan/3-initial_fp.sdc';
export PACKAGED_SCRIPT_4='openlane/scripts/openroad/common/set_global_connections.tcl';
export PROCESS_CORNER='nom';
export SAVE_DEF='./results/floorplan/computer.def';
export SAVE_NETLIST='./out.v';
export SAVE_ODB='./results/floorplan/computer.odb';
export SCRIPTS_DIR='openlane/scripts';
export STA_PRE_CTS='1';
export STD_CELL_GROUND_PINS='VGND VNB';
export STD_CELL_POWER_PINS='VPWR VPB';
export VDD_NET='VPWR';
TOOL_BIN=${TOOL_BIN:-openroad}
$TOOL_BIN -exit $PACKAGED_SCRIPT_0
