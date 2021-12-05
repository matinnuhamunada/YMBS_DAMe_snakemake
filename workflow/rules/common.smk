import os
import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version

min_version("5.18.0")
__version__ = "0.1.0"

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
#singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####
configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

# set up sample for default case with fasta files provided
runs = (
    pd.read_csv(config["runs"], sep="\t", dtype={"runs": str})
    .set_index(["runs"], drop=False)
    .sort_index()
)


##### Helper functions #####
RUNS = runs.index.to_list()

# Helper for lamda function
#SAMPLES = {idx : idx for idx in STRAINS}

##### Wildcard constraints #####
wildcard_constraints:
    runs="|".join(RUNS),