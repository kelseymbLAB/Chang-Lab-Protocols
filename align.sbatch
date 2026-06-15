#!/bin/bash
#SBATCH -p normal
#SBATCH --job-name=lgg_bt2_array
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --array=0-5
#SBATCH --output=lgg_bt2_%A_%a.out
#SBATCH --error=lgg_bt2_%A_%a.err

module load bowtie2
module load samtools

INDEX=/gs/gsfs0/users/kbledsoe/changlab/rna-seq/LGG_index
OUTDIR=bowtie2_output

mkdir -p ${OUTDIR}

FILES=(*_1.fastq.gz)

r1=${FILES[SLURM_ARRAY_TASK_ID]}
base=${r1%_1.fastq.gz}
r2=${base}_2.fastq.gz

echo "Processing ${base}"

bowtie2 \
  -x ${INDEX} \
  -1 ${r1} \
  -2 ${r2} \
  --very-sensitive \
  -p ${SLURM_CPUS_PER_TASK} \
  | samtools sort -@ ${SLURM_CPUS_PER_TASK} \
    -o ${OUTDIR}/${base}.bam

samtools index ${OUTDIR}/${base}.bam
