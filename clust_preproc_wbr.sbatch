#!/bin/bash -l 
#
#SBATCH --job-name=test_preproc_8_6_18
#SBATCH --output=/home/wbreilly/parallel_sms_scan_batch_preproc/logs/test_preproc_8_6_18.%j.%N.out
#SBATCH --error=/home/wbreilly/parallel_sms_scan_batch_preproc/logs/test_preproc_8_6_18.%j.%N.err
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=2
#SBATCH --time=5-00:00:00
#SBATCH --mem-per-cpu=3000 # 3gb % spm max mem set at 2.1gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wbreilly@ucdavis.edu

# updated to -c changed matlab scripts to reflect new directory structure

date 
hostname
module load matlab # load matlab module 

matlab -nodisplay < cluster_parallel_preproc_wbr.m # run matlab script # added srun
