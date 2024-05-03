import os

configfile: 'config/config.yml'
configfile: 'config/cluster.json'

cpus = config['bowtie2']['cores']

INPUT_FILE = config['input_file']
OUTPUT = config['output_dir']
METAMLST_DIR = config['metamlst_dir']

samp2paths = {}

with open(INPUT_FILE) as f:
    for line in f:
        cols = line.rstrip().split("\t")
        sample = os.path.basename(cols[0]).split("_1.fastq.gz")[0].split("_R1.fastq.gz")[0]
        samp2paths[sample] = [cols[0], cols[1]]

for sample in samp2paths:
    dirname = OUTPUT+"/"+sample+"/logs"
    if not os.path.exists(dirname):
        os.makedirs(dirname)

rule targets:
    input:
        expand(OUTPUT+"/{sample}/done.txt", sample=samp2paths.keys())
               
rule bowtie2:
    input:
        fwd = lambda wildcards: samp2paths[wildcards.sample][0],
        rev = lambda wildcards: samp2paths[wildcards.sample][1],
    output:
        temp(OUTPUT+"/{sample}/{sample}.bam")
    params:
        ref = METAMLST_DIR+"/bowtie_MmetaMLST"
    conda:
        "config/envs/metamlst.yml"
    resources:
        ncores = cpus
    shell:
        """
        bowtie2 -p {resources.ncores} --very-sensitive-local -a --no-unal -x {params.ref} -1 {input.fwd} -2 {input.rev} | samtools view -bS - > {output}
        """

rule metamlst_sample:
    input:
        OUTPUT+"/{sample}/{sample}.bam"
    output:
        bai = temp(OUTPUT+"/{sample}/{sample}.bai"),
        outfile = OUTPUT+"/{sample}/mlst_check.txt"
    params:
        mlst_script = METAMLST_DIR+"/metamlst.py",
        outfolder = OUTPUT+"/{sample}/"
    conda:
        "config/envs/metamlst.yml"
    shell:
        """
        python {params.mlst_script} -o {params.outfolder} {input}
        touch {output.outfile}
        """

rule metamlst_merge:
    input:
        OUTPUT+"/{sample}/mlst_check.txt"
    output:
        OUTPUT+"/{sample}/done.txt"
    params:
        mlst_script = METAMLST_DIR+"/metamlst-merge.py",
        nfo = OUTPUT+"/{sample}/"
    conda:
        "config/envs/metamlst.yml"
    shell:
        """
        python {params.mlst_script} {params.nfo}
        touch {output}
        """
