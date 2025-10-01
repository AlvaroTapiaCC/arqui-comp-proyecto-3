# Arquitectura de Computadores: Proyecto 2

Este proyecto utiliza un `Makefile` para automatizar la simulación y síntesis del diseño en Verilog.

### Archivos del Proyecto

* `computer.v`, `testbench.v`, etc.: Los archivos fuente en Verilog para el diseño y su banco de pruebas.
* `yosys.tcl`: El script para la síntesis lógica.
* `Makefile`: El script principal para ejecutar todos los comandos.

### Cómo Ejecutar

Utiliza los siguientes comandos en tu terminal:

| Comando | Descripción |
|---|---|
| `make build` | Compila los archivos en Verilog. |
| `make run` | Ejecuta la simulación. |
| `make wave` | Abre las formas de onda con GTKWave. |
| `make synth` | Ejecuta la síntesis lógica. |
| `make clean` | Elimina todos los archivos generados. |

### Código Ejemplo en im.dat
```
110000011: B=A+3  
101000110: A=A+6  
010010000: B=A-B  
001100000: A=A and B
```
