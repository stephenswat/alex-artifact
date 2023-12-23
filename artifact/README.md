# ALEX Artifact

Welcome to the artifact of ALEX, an Array Layout Evolution eXperiment. This
document describes the use of our artifact, 

## Paper Summary

## Artifact Structure

* `alex/`: The source code (C++ and Python) of our experiments.
  * `hi/`
* `data/`: The data we have gathered in our experiments, and which we use to
  generate the plots in our paper.
* `Dockerfile`: Machine-readable instructions for generating a Docker-based
  environment image.
* `.dockerignore`: List of files which do not need to be copied to the Docker
  image.
* `README.md`: You're reading it right now!

More abstractly, we provide the following computational artifacts:

* `SW-1`: Microcode simulation of the throughput of Morton layouts, as well as
  canonical row-major and column-major layouts. Used to generate `DATA-1`
* `SW-2`: Script to generate random array layouts for benchmarking. Used to
  generate `DATA-2`.
* `SW-3`: Benchmark of the performance of array layouts in a given application.
  Used to generate `DATA-3` from `DATA-2` and `DATA-5` from `DATA-4`.
* `SW-4`: Evolutionary process through which we discover novel array layouts.
  Used to generate `DATA-4`.



![](img/graph.svg)

## Reproduction Procedure

### Outline

The procedure of preparing and building our code, as well as reproducing our
results, follows roughly the following steps. For each step, we denote the
approximate amount of time required in terms of human involvement as well as
computation.

### Step 1: Reproduction Environment

The initial step in using this artifact consists of setting up the 

> **Time estimate:** This step should take about 1 minute of human time and
> about 10 minutes of computer time (using Docker).

#### Using Docker

#### Using a standalone machine

### Step 2: Dependencies

The next step involves installing the Python dependencies. We use the _Poetry_
dependency manager for this.

> **Time estimate:** This step should take about 1 minute of human time and
> about 5 minutes of computer time.



### Step 3: Reproducing the Results


#### Step 3A: Validation of Simulation


#### Step 3B: Evolution Experiments


#### Step 3C: 


## Reference Machines


## Troubleshooting
