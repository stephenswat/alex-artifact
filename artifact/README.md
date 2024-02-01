# ALEX Artifact

Welcome to the artifact of ALEX, an Array Layout Evolution eXperiment. This
document describes the use of our artifact, which accompanies our paper *"Using
Evolutionary Algorithms to Find Cache-Friendly Generalized Morton Layouts for
Arrays"* in the International Conference of Performance Engineering (ICPE)
2024.

> **Note**: This README is a Markdown file. It is easiest to read in a
> Markdown-capable editor.

## Paper Summary

Our paper describes the idea that multi-dimensional arrays can be stored in far
more ways than the traditional (_canonical_) row-major and column-major
fashion. We detail a generalisation of the Morton layout, and we describe how
evolutionary algorithms can be used to find novel layouts to optimise cache
performance in a given application. To this end, we make the following
contributions:

1. We show that Morton-like array layouts can be implemented efficiently on
   modern commodity hardware.
2. We show that cache simulation can be used to find the fitness of a given
   array layout.
3. We show that evolutionary algorithms can efficiently find novel array
   layouts.
4. We show that the array layouts we find have good performance in real
   hardware.

## Hardware Requirements

In order to run this artifact, a CPU with the BMI2 instruction set extension is
required. This includes virtually all modern processors. In order to check
whether your CPU supports BMI2, you can run the following command on Linux:

```
cat /proc/cpuinfo | grep bmi2
```

The presence of BMI2 is sufficient to run the experiments, but in order to get
reasonable performance, the CPU should have a hardware implementation of BMI2's
`pdep` instruction, which is present on:

* All Intel CPUs supporting BMI2.
* AMD processors of the Zen 3 architecture and later (including Zen 3+, Zen 4,
  and Zen 5).

The evaluation of this artifact consists of several steps (steps 3A, 3B, 3C,
and 3D, detailed below; steps 1 and 2 are dependency management, so we do not
consider them reproduction as-is). The experiments conducted in our paper use
an AMD EPYC 7413 and an Intel Xeon E5-2660 v3. It is unlikely that reviewers
will have this exact hardware available; the degree to which each of the steps
can be reproduced with different hardware is detailed at the start of each
step.

## Artifact Structure

This artifact contains a number of files. The structure of the artifact, in
abstract terms, is as follows. We provide the following computational
artifacts:

* `SW-1`: Microcode simulation of the throughput of Morton layouts, as well as
  canonical row-major and column-major layouts. Used to generate `DATA-1` in
  step 3A.
* `SW-2`: Script to generate random array layouts for benchmarking. Used to
  generate `DATA-2`.
* `SW-3`: Benchmark of the performance of array layouts in a given application.
  Used to generate `DATA-3` from `DATA-2`, and `DATA-5` from `DATA-4`.
* `SW-4`: Evolutionary process through which we discover novel array layouts.
  Used to generate `DATA-4`.

And we provide the following data artifacts. For all these artifacts, the user
can reproduce them (sometimes deterministically), but we also provide the data
that we have used in our paper:

* `DATA-1`: A list of simulated throughput metrics for different array layouts
  for data of different dimensions as compiled by different compilers.
* `DATA-2`: A randomly generated list of access patterns to benchmark.
* `DATA-3`: Benchmark results on real hardware as well as simulation for the
  access patterns in `DATA-2`.
* `DATA-4`: The best access patterns discovered in our experiments with `SW-4`.
* `DATA-5`: Benchmark results (like `DATA-3`) of the access patterns in
  `DATA-4`.

The following is a graphical representation of the interplay between these
components:

![](img/graph.svg)

The following is an overview of the file system hierarchy of this artifact.
Files not mentioned here are not relevant to the artifact.

* `alex/`: The source code (C++ and Python) of our evolutionary experiments and
  benchmarks.
  * `ales/`: The main Python source code. Contains `SW-3` and `SW-4`.
  * `caches/`: Cache configuration files for the processors used in our paper.
  * `core/`: The main C++ source code.
  * `extras/`: Extra scripts. Contains `SW-2` and plottng scripts.
  * `pyproject.toml`: Python project description and dependency list.
  * `poetry.lock`: Reified dependency list to ensure users get the exact same
    versions.
  * `build.py`: Additional Python packaging logic.
* `data/`: The data we have gathered in our experiments, and which we use to
  generate the plots in our paper.
  * `benchmark_input/`: Precursor to `DATA-5`, generated from `DATA-4`.
  * `benchmark_output/`: `DATA-5`.
  * `evolution_output/`: `DATA-4`.
  * `simulation_validation_input/`: `DATA-2`.
  * `simulation_validation_output/`: `DATA-3`.
  * `throughput_output/`: `DATA-1`.
  * `validation_data/`: Small input files used only for validation by the
    artifact authors.
* `img/`: Some images embedded in this README.
* `morton-throughput/`: Microcode analysis of the throughput of array layouts.
* `scripts/`: Additional scripts used by the artifact authors to ensure that
  the artifact works.
* `Dockerfile`: Machine-readable instructions for generating a Docker-based
  environment image.
* `.dockerignore`: List of files which do not need to be copied to the Docker
  image.
* `README.md`: You're reading it right now!

## Reproduction Procedure

### Outline

The procedure of preparing and building our code, as well as reproducing our
results, follows roughly the following steps. For each step, we denote the
approximate amount of time required in terms of human involvement as well as
computation.

### Step 1: Reproduction Environment

The initial step in using this artifact consists of setting up the environment
in which we will reproduce the results in the paper. We **strongly** recommend
using the Docker file provided with the artifact, but it is also possible to
run the procedure on bare metal. Keep in mind that using Docker makes it much
easier to ensure that the dependencies are the correct version!

> **Time estimate:** This step should take about 1 minute of human time and
> about 10 minutes of computer time (using Docker).

#### Using Docker

To build a Docker image from the specifications we provide, navigate to the
root directory of the artifact, and execute the following command:

```bash
docker build -t alex_artifact .
```

This will create a new Docker image known as `alex_artifact`. A container can
then be started from this image using the following command:

```bash
docker run -it alex_artifact
```

A shell will start in which all following steps should (hopefully) work out of
the box!

##### Getting files out of docker

When using Docker, files created are stored inside the Docker container. Files can be copied out of the container using the `docker cp` command:

```bash
docker cp [CONTAINER_ID]:/artifact/morton-throughput/out/plots/main.osaca.pdf test.pdf
```

#### Using a standalone machine

To ensure that our code works outside of Docker containers, we recommend having
the following dependencies installed. Names provided as the names of the
dependencies as they exist in the Debian package repositories:

* `gcc`
* `g++`
* `gcc-13`
* `g++-13`
* `python3`
* `python3-dev`
* `texlive-base`
* `texlive-latex-extra`
* `texlive-fonts-extra`
* `texlive-plain-generic`
* `cm-super`
* `clang++-15`
* `llvm-15`
* `dvipng`

We also require the Poetry package manager to be installed for Python.
Installation instructions for Poetry are available at
https://python-poetry.org/docs/.

The TeX dependencies can be skipped; to do so, take a look at the "LaTeX
Rendering Errors" topic in the "Troubleshooting" section.

### Step 2: Dependencies

The next step involves installing the Python dependencies. We use the _Poetry_
dependency manager for this.

> **Time estimate:** This step should take about 2 minutes of human time and
> about 5 minutes of computer time.

Our artifact contains two distinct software packages, each with its own
dependencies. The first package contains software `SW-1` and is used for step
3A. The second package contains software `SW-2`, `SW-3`, and `SW-4`, and is
used for steps 3B, 3C, and 3D.

#### Dependencies for Step 3A

To install the dependencies for step 3A, which uses `SW-1`, follow the
following commands (from the root of this artifact):

```bash
cd morton-throughput
poetry install --no-root
```

#### Dependencies for Step 3B, 3C, and 3D

To install the dependencies for step 3B, 3C, and 3D, which use `SW-2`, `SW-3`,
and `SW-4`, follow the following commands (from the root of this artifact):

```bash
cd alex
poetry install
```

Note that unline the dependencies for step 3A, this step does _not_ use the
`--no-root` flag.

The environment should be updated to include the `LD_LIBRARY_PATH`; we are
working on finding a more sustainable solution to this problem, but for now we
recommend running the following command:

```bash
export LD_LIBRARY_PATH=$(poetry run python -c "import cachesim; import pathlib; print(pathlib.Path(cachesim.backend.__file__).parent)"):${LD_LIBRARY_PATH:-}
```

### Step 3: Reproducing the Results

This step contains the actual reproduction of the results presented in our
paper. There are four sets of results to reproduce. These steps are presented
in the same order in which they are presented in the paper. Step 3D also
depends on step 3C, but the input and output files for each step as we have
used them in our paper is included in the `data/` directory, so these steps can
be executed in any order.

#### Step 3A: Morton Layout Throughput

This step confirm that computing a Morton layout, which involves a lot of bit
twiddling is almost as computationally efficient as a traditional row-major or
column-major layout. That is to say, the cost of computing the indices is not
much higher. We show this using microcode analysers like OSACA and LLVM-MCA.

> **Time estimate:** This step should take approximately 2 minute of human time
> and no more than 5 minutes of compute time.

##### Reproducibility

This step can be **deterministically** reproduced on **any hardware**. This
step is **not sensitive** to resource contention, and can be run on
non-dedicated hardware.

##### Input and Output

This step uses no input files, but it does use some code. This step produces a
CSV file that contains tuples of microcode analyser (OSACA or LLVM-MCA),
microarchitecture, compiler, array layout, number of dimensions in the array,
and reciprocal throughput of the array index calculation. In addition, it
produces a plot which matches Figure 3 in our paper.

##### Instructions

This step uses Snakemake, a workflow manager. To execute the step, simply run
the following (from the root of the artifact directory, or `/artifact/` in the
Docker image):

```bash
cd morton-throughput
poetry run snakemake -c [NUMBER OF CORES]
```

Snakemake will handle the invocation of the microcode simulation, the data
aggregation, and the plotting.

##### Data Visualisation

The resulting figure is created as part of the Snakemake invocation. It can be
found in the `morton-throughput/out/plots/main.osaca.pdf`. This is Figure 3 in
our paper.

#### Step 3B: Validation of Simulation

In this step, we aim to establish a correlation between our fitness function
(which is based on simulation) and the run-time of a kernel under a given array
layout. For this, we use a list of randomly generated array layouts, and we run
both a simulation and a benchmark on each of these layouts.

> **Time estimate:** This step should take about 10 minutes of human time, and
> about 4 hours of compute time for a full reproduction. A quick reproduction
> should take no more than 10 minutes of compute time.

##### Reproducibility

This step uses a randomly generated file
`data/simulation_validation_input/bench_fitness_input.csv`. The file used in
our paper is provided, but a functionally similar file can also be generated
using our artifact; a freshly generated file will generate similar results, but
they will not be identical.

The simulated fitness values can be **deterministically** reproduced on **any
BMI2-capable x86 CPU**.

The benchmarked execution times are **non-deterministically** (due to
experimental noise) reproducible only on the exact processor models used in the
paper. These processors are modelled using the YAML files in the `alex/caches/`
directory. It is possible to create a custom configuration for the hardware
available to the reviewer. We will do our best to provide cache configurations
for any x86 CPU upon request.

The benchmarking part of this step is **sensitive** to resource contention, and
should be run on an exclusive machine if possible to reduce noise.

##### Input and Output

This step uses the randomly generated array layouts in
`data/simulation_validation_input/bench_fitness_input.csv`. It produces files
like:

* `data/simulation_validation_input/bench_fitness_output_AMD_EPYC_7413.csv`
* `data/simulation_validation_input/bench_fitness_output_Intel_Xeon_E5-2660_v3.csv`


##### Instructions

First, we have to obtain a random list of array layouts. Evaluators may choose
to use the file provided (see the *Input and Output* section). Those with
limited time can also use
`data/simulation_validation_input/bench_fitness_input_small.csv`, which
contains far fewer access patterns to test; this won't reproduce the plots in
our paper, but it will prove that the artifact runs. Evaluators may also choose
to generate a new input file as follows:

```bash
cd alex
poetry run python extras/generate_bench_input.py -n 100 -o bench_fitness_input.csv
```

This generates 100 random layouts for each access pattern. A quicker evaluation
can be done by lowering the number passed to the `-n` flag.

The experiments can then be run as follows:

```bash
poetry run alex-bench -c caches/AMD_EPYC_7413.yaml -i bench_fitness_input.csv -o bench_fitness_output_AMD_EPYC_7413.csv
```

Note that the `caches/AMD_EPYC_7413.yaml` file should match the cache hierarchy
of the CPU on which the code is run; otherwise, the results will not be
reliable.

These instructions can be repeated arbitrarily many times on different CPU
models.

##### Data Visualisation

To plot the data generated in this step, we use a script with the following
invocation:

```bash
poetry run python extras/plot_bench_results.py \
        -i CPU_NAME_1:FILE_FOR_CPU_1.csv \
        -i CPU_NAME_2:FILE_FOR_CPU_2.csv \
        ...
        -i CPU_NAME_N:FILE_FOR_CPU_N.csv \
        -o output_plot_3B.pdf
```

Note that this script also works for a single CPU model and corresponding data
file.

For example, to generate Figure 4 from our paper, run the following command:

```bash
poetry run python extras/plot_bench_results.py \
        -i AMD_EPYC_7413:../data/simulation_validation_output/bench_fitness_output_AMD_EPYC_7413.csv \
        -i Intel_Xeon_E5-2660_v3:../data/simulation_validation_output/bench_fitness_output_Intel_Xeon_E5-2660_v3.csv
        -o Figure4.pdf
```

The text output of this command gives the contents of Table 2.

#### Step 3C: Evolution Experiments

In this step, we validate how well an evolutionary algorithm can find novel
array layouts, with the fitness function defined by our simulation-based
approach.

> **Time estimate:** This step should take about 10 minutes of human time, and
> about two days of compute time. A quicker reproduction can be done in about
> an hour of compute time.

##### Reproducibility

This step can be **non-deterministically** reproduced on **any BMI2-capable x86
CPU**. Since genetic algorithms are inherently random, variations in results
are expected upon reproduction.

This step is **not sensitive** to resource contention, and can be run on
non-dedicated hardware.

##### Input and Output

This step takes no input. It produces a number of log- and ranking files. The
log files describe the evolution over time, and the ranking files describe the
fittest individuals resulting from the experiment. The output files as we use
them in our paper are in `data/evolution_output/`. One pair of log and ranking
files is generated for each tuple of access pattern, array size, and CPU model.

##### Instructions

To run an evolution experiment, we use the following command:

```bash
poetry run alex-evolve -c CACHE_MODEL -b BITS1:...:BITSN -t PATTERN -g NUM_GENERATIONS -l LOG_FILE -r RANKING_FILE
```

Where `CACHE_MODEL` is one of the cache hierarchy YAML files in `caches`,
`BITS1:...:BITSN` is the number of bits in each dimension of the array size,
e.g. `10:10` denotes a two-dimensional 1024x1024 array and `4:4:5` denotes a
three-dimensional 16x16x32 array. `PATTERN` is one of `MMijk`, `MMikj`,
`MMTijk`, `MMTikj`, `Jacobi2D`, `Himeno`, `Cholesky`, `Crout`.

For example, to run a 5-generation experiment on 128x128 ijk-order matrix
multiplication for the AMD EPYC 7413, run the following command (the output
won't be very interesting because the array size is small):

```bash
poetry run alex-evolve -c caches/AMD_EPYC_7413.yaml -b 7:7 -t MMijk -g 5 -l MMijk-9_9-0-AMD_EPYC_7413-log.csv -r MMijk-9_9-0-AMD_EPYC_7413-ranking.csv
```

Our paper contains 32 total experiments, which can be replicated using the
following bash script:

```bash
mkdir out
PATTERNS=( MMijk,11:11 MMikj,11:11 MMTijk,11:11 MMTikj,11:11 Jacobi2D,15:15 Himeno,10:9:9 Cholesky,12:12 Crout,12:12 )
CPUS=( AMD_EPYC_7413 Intel_Xeon_E5_2660_v3 )
IFS=" "

for p in $PATTERNS; do
    for c in $CPUS; do
        IFS=","
        set -- ${p}
        PATTERN=$1
        SIZE=$2
        echo "Running experiment ${PATTERN}:${SIZE}"
        poetry run alex-evolve -c caches/${c}.yaml -b ${SIZE} -t $PATTERN -g 21 -v \
            -r out/${PATTERN}-${SIZE//":"/"_"}-0-${CPU}-ranking.csv \
            -l out/${PATTERN}-${SIZE//":"/"_"}-0-${CPU}-log.csv \
            -j $(nproc)
        IFS=" "
    done
done
```

Note that the file names should be in this format, as we will be globbing on
this pattern in the visualisation and in the next step.

To shorten the reproduction procedure, we recommend decreasing the number of
generations (the `-g` flag), reducing the sizes of the arrays (e.g. reduce the
bit counts after the patterns in `${PATTERNS}`), or reducing the number of
experiments by removing patterns or CPU models.

##### Data Visualisation

To create Figure 5 from our paper, run the following command:

```bash
poetry run python extras/plot_violin.py -i ../data/evolution_output/ -o Figure5.pdf
```

Note that the `-i` flag takes a directory. This directory can be changed to a
directory full of files generated in this step.

To create Figure 6, run the following command:

```bash
poetry run python extras/plot_evolution.py -i ../data/evolution_output/ -o Figure6.pdf
```

#### Step 3D: Validation of Evolution

In the final step, we aim to validate that the array layouts found in step 3C
actually perform well on real hardware. To this end, we run benchmarks on them
and compare them to canonical array layouts.

> **Time estimate:** This step takes approximately 10 minutes of human time and
> about an hour of compute time.

##### Reproducibility

The results of this step can be **non-deterministically** reproduced due to
noise. Reproduction using the input files we provide is possible only with the
exact same hardware, but the output of step 3C can be used as input for this
file.

The benchmarking part of this step is **sensitive** to resource contention, and
should be run on an exclusive machine if possible to reduce noise.

##### Input and Output

This step takes as input a directory containing ranking files as produced in
step 3D. Equivalently, a directory such as `data/evolution_output/` can be
used.

From this directory, we will select the best-performing layouts for each access
pattern, as well as the canonical layouts. Examples of such files are given in
`data/benchmark_input/`.

We then benchmark these layouts, producing a file with runtime statistics. The
files we produce in these benchmarks can be found in `data/benchmark_output/`.

##### Instructions

First, we will distill the data in our evolution output (from step 3C) into a
single file. To do so, run the following command:

```bash
poetry run python extras/extract_winning_layouts.py -i DATA_DIR -o OUT.csv -c CPU_NAME
```

For the data we provide, data can be generated for both CPU models as follows:

```bash
poetry run python extras/extract_winning_layouts.py -i ../data/evolution_output -o data_AMD_EPYC_7413.csv -c AMD_EPYC_7413
poetry run python extras/extract_winning_layouts.py -i ../data/evolution_output -o data_Intel_Xeon_E5-2660_v3.csv -c Intel_Xeon_E5-2660_v3
```

This produces the same files (but perhaps in different order) as found in
`data/benchmark_input/`.

Next, we can benchmark these files, skipping the simulation part:

```bash
poetry run alex-bench \
  -c caches/CACHE_MODEL.yaml \
  --no-simulate \
  -i INPUT_FILE.csv \
  -o OUTPUT_FILE.csv
```

For example, to benchmark the data provided with this artifact:

```bash
poetry run alex-bench -c caches/Intel_Xeon_E5_2660_v3.yaml --no-simulate -i ../data/benchmark_input/bench_winners_input_Intel_Xeon_E5-2660_v3.csv -o bench_winners_output_Intel_Xeon_E5-2660_v3.csv
poetry run alex-bench -c caches/AMD_EPYC_7413.yaml --no-simulate -i ../data/benchmark_input/bench_winners_input_AMD_EPYC_7413.csv -o bench_winners_output_AMD_EPYC_7413.csv
```

This produces the files in `data/benchmark_output`.

##### Data Visualisation

This step produces no figures, but it produces Table 3. This table is generated
by hand. For each tuple of CPU model and access pattern, we find the
corresponding entries in the benchmark output file. We then select the best of
the two canonical array layouts (where all zeros are adjacent and all ones are
adjacent) as well as the evolved layout (the layout where zeros and ones are
mixed). We then compute the speedup by diving the runtime of the best canonical
layout by the evolved layout.

For example, consider the following table (taken from
`data/benchmark_output/bench_winners_output_AMD_EPYC_7413.csv`):

```
pattern,layout,fitness,runtime,runtime_dev
MMijk,"1,0,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,0,0,0,0,0",0.0,9576154947.3,42804640.195274875
MMijk,"0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1",0.0,37713347264.2,241606148.67090166
MMijk,"1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0",0.0,38798147612.7,44476549.88786639
```

Here, the second and third row are the canonical layouts. The lowest runtime of
these (the second-to-last column) is 37,713,347,264.2 nanoseconds. The evolved
layout is the first row, with a runtime of 9,576,154,947.3 nanoseconds. The
speedup, therefore, is a factor 3.93, or an improvement of 293%, as listed in
Table 3.

### Postamble

All results, tables, and plots in our table are now reproduced.

## Troubleshooting

We have made every effort to ensure that this artifact is well-documented and
easy to use. It is always possible, however, that issues may pop up during the
artifact evaluation process. We invite the evaluators to contact us with any
questions or problems, and we will do our best to resolve the issues as quickly
as possible.

### Shared Library Loading Error

In case the following error occurs:

```
ImportError: backend.cpython-311-x86_64-linux-gnu.so: cannot open shared object file: No such file or directory
```

It is likely the `LD_LIBRARY_PATH` is not properly set. Refer to step 2 for
setting this environment variable.

### LaTeX Rendering Errors

We use the LaTeX rendering functionality in matplotlib to make our plots look
nice. However, this introduces additional moving pieces, and requires LaTeX to
be installed. A particularly strange LaTeX error is the following:

```
ValueError: tfm checksum mismatch: b'ntxsy7'
```

If this happens, the plot will fail. It is easiest to then add the `--no-tex`
flag, which disables the TeX rendering and uses matplotlib's built-in
rendering. The plots will not look the same in terms of fonts and spacing, but
the data will be identical.

If a TeX error occurs during step 3A, the easiest way to fix this is to replace
the line saying:

```
"text.usetex": True,
```

At the top of the file `morton-throughput/scripts/make_plot.py` to read:

```
"text.usetex": False,
```

We apologise for this inconvenience and are working on a more reliable way of
solving this problem.

### EOFError: Ran out of input

Rarely, step 3A may return an error "EOFError: Ran out of input". We are
unaware of the cause of this error, but it can usually be resolved by cleaning
the generated files and restarting the procedure. We apologise for the
inconvenience.
