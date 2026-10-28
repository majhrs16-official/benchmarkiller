# Benchmarkiller

Una herramienta de benchmarking experimental desarrollada en ensamblador puro (`nasm`) para medir rendimiento de ciclos, rendimiento de instrucciones y latencias de procesamiento a bajo nivel.

## Características Técnicas

* **Medición de ciclos de reloj:** Utiliza la instrucción de hardware `RDTSC` (Read Time-Stamp Counter) para capturar marcas de tiempo de alta precisión antes y después de bloques de ejecución críticos.
* **Aislamiento de rutinas:** Diseñado para evaluar la eficiencia de bucles cerrados, operaciones con registros y rutinas aritméticas sin sobrecarga de sistemas operativos ni tiempos de ejecución gestionados.
* **Estructura limpia:** Diseñado para compilarse y ejecutarse de manera nativa mediante scripts de automatización minimalistas.

## Estructura del Proyecto

```text
.
├── usr/
│   ├── src/          # Código fuente en ensamblador (benchmarkiller.asm, etc.)
│   └── bin/          # Directorio para binarios compilados (.gitkept)
├── bin/              # Scripts de compilación y ejecución (`build`, `benchmark`)
└── tmp/              # Archivos temporales de compilación y objetos

```

## Requisitos

* `nasm`
* `ld` (GNU Linker)

## Compilación y Ejecución

Para compilar y correr las pruebas de rendimiento:

```bash
./bin/build
./bin/benchmark

```

---

Licenciado bajo los términos de la **GNU General Public License v3.0**.
