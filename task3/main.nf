params.reads1 = "SRR2584863_1.fastq"
params.reads2 = "SRR2584863_2.fastq"
params.ref    = "GCF_000005845.2_ASM584v2_genomic.fna"

process FASTQC {
    input:
    path reads

    output:
    path "*"

    script:
    """
    fastqc $reads
    """
}

process BWA_MEM {

    input:
    path ref
    path r1
    path r2

    output:
    path "sample.sam"

    script:
    """
    bwa index $ref

    bwa mem $ref $r1 $r2 > sample.sam
    """
}

process SAMTOOLS_FLAGSTAT {
    input:
    path sam

    output:
    path "flagstat.txt"

    script:
    """
    samtools view -bS $sam | samtools flagstat - > flagstat.txt
    """
}

process QC_CHECK {

    input:
    path flagstat
    path parser

    output:
    path "qc_result.txt"

    script:
    """
    P=\$(python3 $parser $flagstat)

    echo "Mapped: \$P %"

    RESULT=\$(echo "\$P > 90" | bc -l)

    if [ "\$RESULT" -eq 1 ]
    then
        echo "OK" > qc_result.txt
    else
        echo "not OK" > qc_result.txt
    fi
    """
}

process SORT_BAM {
    input:
    path sam

    output:
    path "sorted.bam"

    script:
    """
    samtools view -bS $sam | samtools sort -o sorted.bam
    """
}

process FREEBAYES {
    input:
    path ref
    path bam

    output:
    path "variants.vcf"

    script:
    """
    freebayes -f $ref $bam > variants.vcf
    """
}

workflow {

    reads1_ch = Channel.fromPath(params.reads1)
    reads2_ch = Channel.fromPath(params.reads2)
    ref_ch    = Channel.fromPath(params.ref)
    parser_ch = Channel.fromPath("parse_flagstat.py")

    FASTQC(reads1_ch)

    bwa_out = BWA_MEM(ref_ch, reads1_ch, reads2_ch)

    flagstat = SAMTOOLS_FLAGSTAT(bwa_out)

    QC_CHECK(flagstat, parser_ch)

    sorted = SORT_BAM(bwa_out)

    FREEBAYES(ref_ch, sorted)
}
