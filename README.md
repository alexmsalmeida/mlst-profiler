# MLST-Profiler - Find ST profiles in metagenomes

This is a Snakemake workflow for annotating MLST profiles in metagenomic data. It uses [bowtie2](https://github.com/BenLangmead/bowtie2) to map metagenomic reads against an MLST database, followed by [MetaMLST](https://github.com/SegataLab/metamlst) to profile the species sequence types (STs).

## Installation

1. Install [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) and [snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) (tested v7.32.3)

2. Install [MetaMLST](https://github.com/SegataLab/metamlst) and index their database.

3. Clone this repository
```
git clone https://github.com/alexmsalmeida/mlst-profiler.git
```

## How to run

1. Edit the configuration file [`config/config.yml`](config/config.yml).
    - `input_file`: TSV file (no header) with paired-end FASTQ paths (first column forward path, second column reverse path).
    - `output_dir`: Output directory to store output files.
    - `metamlst_dir`: Location of the MetaMLST folder with the indexed database.

2. Run the pipeline on a cluster (e.g., SLURM)
```
snakemake --use-conda -k -j 25 --profile config/slurm --latency-wait 60
```

3. Output MLST files will be stored in the specified output directory. If there is only a `done.txt` file in the output, it means no confident ST profiles were detected.
