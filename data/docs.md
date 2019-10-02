Two-step pipeline:

1. STAR alignment
2. RSEM quantification

Genome reference: hg38_no_alt
Annotation: Gencode v23

STAR alignment:

```
{star} \
--runThreadN {threads} \
--genomeDir {genomedir} \
--readFilesIn {f1} {f2} \
--readFilesCommand zcat \
--outFileNamePrefix {prefix} \
--outSAMtype None \
--outSAMunmapped Within \
--quantMode TranscriptomeSAM \
--outSAMattributes NH HI AS NM MD \
--outFilterType BySJout \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04 \
--alignIntronMin 20 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000 \
--alignSJoverhangMin 8 \
--alignSJDBoverhangMin 1 \
--sjdbScore 1 \
--limitBAMsortRAM 50000000000
```

RSEM quantification:

```
{calcexp} \
--paired-end \
--no-bam-output \
--quiet \
--no-qualities \
-p {threads} \
--forward-prob 0.5 \
--seed-length 25 \
--fragment-length-mean -1.0 \
--bam {bam} {genomedir} {prefix}
```
