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
)

(
    cd morton-throughput
    poetry install --no-root
    poetry run snakemake -c all
)

echo "The artifact appears functional!"
