#!/bin/bash

echo "4BL MOP PIPELINE"
echo "Directory" $1
echo "Number of .fast5 files in directory"
SUCH=${1}\/\*.fast5
find $SUCH -maxdepth 0 -type f | wc -l

#NanoPreprozess
cd master_of_pores/NanoPreprocess
echo "Running NanoPreprocess\n"
nextflow run nanopreprocess.nf -basecaller guppy -seqtype RNA -fast5 $SUCH -demultiplexing "OFF" -map_type "spliced" \
-mapper_opt "-uf -k14" -reference genome.fa.gz -mapper minimap2 -ref_type "genome" -filter nanofilt \
-filter_opt "-q 0 -headcrop 5 -tailcrop 3 -readtype 1D"
echo "NanoPreprocess completed\n"

#NanoTail
echo "Running NanoTail\n"
nextflow run nanotail.nf -input_folders "./NanoPreprocess/output/*" -nanopolish_opt "" -tailfindr_opt "" -reference "genome.fa.gz"
echo "NanoTail completed\n"

#NanoMod
echo "Running NanoMod\n"
nextflow run nanomod.nf -input_path "./NanoPreprocess/output/" -comparison "./comparison.tsv" -reference "genome.fa.gz" \
-tombo_opt "-num-bases 5" -epinano_opt ""
echo "NanoMod completed\n"
