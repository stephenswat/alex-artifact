#!/bin/bash

set -e
set -o pipefail
set -u

(
    cd alex
    poetry install
    export LD_LIBRARY_PATH=$(poetry run python -c "import cachesim; import pathlib; print(pathlib.Path(cachesim.backend.__file__).parent)"):${LD_LIBRARY_PATH:-}
    poetry run alex-bench -c caches/Intel_Xeon_E5_2660_v3.yaml -i ../data/validation_data/bench_input.csv -o $(mktemp -d)/validation_bench_out.csv
    poetry run alex-evolve -c caches/Intel_Xeon_E5_2660_v3.yaml -b 2:2 -t MMijk
    poetry run python extras/generate_bench_input.py -n 10 -o $(mktemp -d)/benchmark_input.csv
    poetry run python extras/plot_bench_results.py \
        -i AMD_EPYC_7413:../data/simulation_validation_output/bench_fitness_output_AMD_EPYC_7413.csv \
        -i Intel_Xeon_E5-2660_v3:../data/simulation_validation_output/bench_fitness_output_Intel_Xeon_E5-2660_v3.csv \
        -o $(mktemp -d)/plot1a.pdf
    poetry run python extras/plot_bench_results.py \
        -i AMD_EPYC_7413:../data/simulation_validation_output/bench_fitness_output_AMD_EPYC_7413.csv \
        -o $(mktemp -d)/plot1b.pdf
    poetry run python extras/plot_evolution.py -i ../data/evolution_output -o $(mktemp -d)/plot2.pdf
    poetry run python extras/plot_violin.py -i ../data/evolution_output -o $(mktemp -d)/plot3.pdf
    poetry run python extras/extract_winning_layouts.py -i ../data/evolution_output -o $(mktemp -d)/out.csv -c AMD_EPYC_7413
)

(
    cd morton-throughput
    poetry install --no-root
    poetry run snakemake -c all
)

echo "The artifact appears functional!"
