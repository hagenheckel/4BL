#!/bin/bash

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
