rule fastqc:
    input:
        fastq="rawdata/TOG-course-{runs}-{lane}.fastq.bz2",
    output:
        "results/{pool}/TOG-course-{runs}-{lane}_fastqc.html"
    conda:
        "../envs/YMBS.yaml"
    shell:
        """
        fastqc {input} -o results/{wildcards.runs}
        """

rule AdapterRemoval:
    input:
        fastq1="rawdata/TOG-course-{runs}-R1.fastq.bz2",
        fastq2="rawdata/TOG-course-{runs}-R2.fastq.bz2",
    output:
        pair1 = "results/{runs}/{runs}.pair1.truncated.gz",
        pair2 = "results/{runs}/{runs}.pair2.truncated.gz",
    conda:
        "../envs/YMBS.yaml"
    shell:
        """
        AdapterRemoval --file1 {input.fastq1} --file2 {input.fastq1} --basename {wildcards.runs}/{wildcards.runs} --gzip
        """

rule QualityTrimming:
    input:
        pair1 = "results/{runs}/{runs}.pair1.truncated.gz",
        pair2 = "results/{runs}/{runs}.pair2.truncated.gz",
    output:
        R1 = "results/{runs}/{runs}.trim.R1.fastq.gz",
        R2 = "results/{runs}/{runs}.trim.R2.fastq.gz",
        singleton = "results/{runs}/{runs}.trim.singleton.gz",
    conda:
        "../envs/YMBS.yaml"
    shell:
        """
        sickle pe -f {input.pair1} -r {input.pair2} -t sanger -o {output.R1} -p {output.R2} -s {output.singleton} -g 
        """

rule ErrorCorrection:
    input:
        R1 = "results/{runs}/{runs}.trim.R1.fastq.gz",
        R2 = "results/{runs}/{runs}.trim.R2.fastq.gz",
    output:
        directory("results/{runs}/corrected")
    conda:
        "../envs/YMBS.yaml"
    shell:
        """
        spades.py -1 {input.R1} -2 {input.R2} --only-error-correction -o results/{wildcards.runs}
        """

rule MergingPESequences:
    input:
        R1="results/{runs}/corrected/{runs}.trim.R1.fastq.00.0_0.cor.fastq.gz",
        R2="results/{runs}/corrected/{runs}.trim.R2.fastq.00.0_0.cor.fastq.gz",
    output:
        fastq="results/{runs}/{runs}.merged.fastq",
    conda:
        "../envs/YMBS.yaml"
    log: "results/{runs}/{runs}_panda.log",
    shell:
        """
        pandaseq -f {input.R1} -r {input.R2} -g {log} -F -w {output.fastq} -o 20      
        """