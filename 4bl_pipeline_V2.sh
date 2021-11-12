#!/bin/bash

##### Variables #####
#Run Options for NanoPreprocess, NanoTail and NanoMod [RUN / SKIP]
NPREP=RUN
NTAIL=RUN
NMOD=RUN

#Run in interactive mode [Y / NO]
IMODE=NO

#NanoPreprocess
#Algorithm to perform the basecalling. guppy or albacore are supported. [albacore / guppy]
BC=guppy

#Sequence type. [RNA / DNA]
ST=RNA

#Demultiplexing algorithm to be used. [OFF / deeplexicon / guppy / guppy-readucks]
DM=OFF

#Spliced - recommended for genome mapping - or unspliced - recommended for transcriptome mapping. [spliced / unspliced]
SP=spliced

#Command line options of the mapping algorithm.
MAP="-uf -k14"

#File in fasta format. [Reference_file.fa]
REF=genome.fa.gz

#Mapping algorithm. [minimap2 / graphmap / graphmap2]
MAPR=minimap2

#Specify if the reference is a genome or a transcriptome. [genome / transcriptome]
RT=genome

#Program to filter fastq files. [nanofilt / OFF]
FLT=nanofilt

#Command line options of the filtering program.
FOPT="-q 0 -headcrop 5 -tailcrop 3 -readtype 1D"

#NanoTail
#input_folders path to the folders produced by NanoPreprocessing step.
INF="./NanoPreprocess/output/*"

#nanopolish_opt options for the nanopolish program
NOPT=""

#tailfindr_opt options for the tailfindr program
TFDR=""

#NanoMod
#input_path path to the folders produced by NanoPreprocessing step.
INP="./NanoPreprocess/output/"

#comparison tab separated text file containing the list of comparison.
COMP="./comparison.tsv"

#tombo_opt options for tombo
TOM="-num-bases 5"

#epinano_opt options for epinano
EPI=""

printf "**************************\n*                        *\n*    4BL MOP PIPELINE    *\n"
printf "*                        *\n**************************\n"

if [ -x nextflow ]
then
	printf "Directory" $1
	printf "Number of .fast5 files in directory"
	SUCH=${1}\/\*.fast5
	find $SUCH -maxdepth 0 -type f | wc -l

	#NanoPreprozess
	cd master_of_pores/NanoPreprocess
	if [ $NPREP = "RUN" ]
	then
		printf "Running NanoPreprocess\n"
		nextflow run nanopreprocess.nf -basecaller $BC -seqtype $ST -fast5 $SUCH -demultiplexing $DM -map_type $SP \
		-mapper_opt $MAP -reference $REF -mapper $MAPR -ref_type $RT -filter $FLT -filter_opt $FOPT
		printf "NanoPreprocess completed\n"
	else
		printf "Preprocessing skiped.\n"
	fi

	#NanoTail
	if [ $NTAIL = "RUN" ]
	then
		printf "Running NanoTail\n"
		nextflow run nanotail.nf -input_folders $INF -nanopolish_opt $NOPT -tailfindr_opt $TFDR -reference $REF
		printf "NanoTail completed\n"
	else
		printf "NanoTail skiped.\n"
	fi

	#NanoMod
	if [ $NMOD = "RUN" ]
	then
		printf "Running NanoMod\n"
		nextflow run nanomod.nf -input_path $INP -comparison $COMP -reference $REF -tombo_opt $TOM -epinano_opt $EPI
		printf "NanoMod completed\n"
	else
		printf "NanoMod skiped.\n"
	fi
else
	printf "Master of Pores is not installed on Your system.\n"
fi
