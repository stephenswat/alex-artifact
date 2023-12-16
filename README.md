# ALEX Artifact Builder

This repository builds a computational artifact for
[ALEX](https://github.com/stephenswat/alex).

## Outline

This repository performs the following steps:

1. Downloading the source code;
2. Anonymizing all source and data;
3. Packing the artifact into a tarball;
4. (Optionally) testing the newly created artifact.

The artifact created should contain:

1. The ALEX code itself;
2. Data used in the paper;
3. Documentation for using the artifact;
4. Infrastructure for running the artifact in Docker.

## Usage

To create a new artifact, simply run the following command:

```
$ ./build_artifact TAG
```

Where `TAG` has to be a valid git tag, a branch name, or a commit hash.

To test an artifact, run the following command:

```
$ ./test_artifact alex-artifact-main-20231215T1308Z.tar.gz
```

Of course, sustitute the name of your newly created artifact file.
