% it's a script now deal with it
% function [] = preproc_wbr()
% Walter Reilly's spm preproc script, adapted from Maureen Ritchey

%====================================================================================
%			Specify Variables
%====================================================================================

%-- File Type
% Are you using DCM or NII files? If NII, they should be unprocessed
% .*\.nii files. Alternatively they can be a 4D .nii file (single file per
% run; can be .*\.nii or .*\.nii.gz, although gz files will be unzipped for
% SPM). 'DCM' or 'NII'. Note: this QA routine is NOT compatible with
% .img/.hdr. Please convert .img/.hdr to .nii prior to running routine.

fileType    = 'NII';

%-- Directory Information
% Paths to relevant directories.
% dataDir   = path to the directory that houses the MRI data
% scriptdir = path to directory housing this script (and auxiliary scripts)
% QAdir     = Name of output QA directory

dataDir     = '/home/wbreilly/sms_scan_crick/cluster_preproc_native_8_6_18/';
scriptdir   = '/home/wbreilly/parallel_sms_scan_batch_preproc'; % fileparts(mfilename('fullpath'));

% add spm to path
% this version hasn't been compiled yet
% addpath /home/wbreilly/matlab_toolboxes/spm12/
% this is a version jordan compiled. He edited something to do with
% implicit masking and a .mat default save format
addpath /group/dml/apps/spm12


%-- Info for Subjects
% Subject-specific information.
% subjects  = cellstring containing the subject IDs
% runs      = cellstring containg the IDs for each BOLD time series
%
% Assumes that all files have unique filenames that can be identified with
% a combination of the cell strings above. For example, bold files NEED to
% look something like:
%   /dataDir/sub-001/func/sub-001_encoding_run-001_bold.nii
%   /dataDir/sub-001/func/sub-001_encoding_run-002_bold.nii
%   /dataDir/sub-001/func/sub-001_retrieval_run-001_bold.nii
%   /dataDir/sub-001/func/sub-001_retrieval_run-002_bold.nii
%
%  See BIDS format

subjects    = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's015' 's016' 's018' 's019'  's020' 's022' 's023' 's024' 's025' 's027' 's028' 's029' 's030' 's032' 's033' 's034' 's035' 's036' 's037' 's038' 's039'}; %
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  

%-- Auto-accept
% Do you want to run all the way through without asking for user input?
% if 0: will prompt you to take action;
% if 1: skips realignment and ArtRepair if already run, overwrites output files
auto_accept = 1;

% coreg flag. if 0 don't coregister 
coreg_flag = 1;


%====================================================================================
%			Routine (DO NOT EDIT BELOW THIS BOX!!)
%====================================================================================

%-- Clean up

clc
fprintf('Initializing and checking paths.\n')

%-- Add paths
addpath(genpath(fullfile(scriptdir, 'functions')));
if exist(fullfile(scriptdir, 'vendor'),'dir')
    addpath(genpath(fullfile(scriptdir, 'vendor')));
end

%-- Check for required functions

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

fprintf('Running preproc script')

%% parallel
% start the matlabpool with maximum available workers
% control how many workers by setting ntasks in your sbatch script
pc = parcluster('single_nose');
poolobj = parpool(pc, 2);
% poolobj = parpool(pc, str2num(getenv('SLURM_NTASKS_PER_NODE')));

%%
    
    %--Loop over subjects
parfor i = 1:2 %length(subjects)
    
    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);
    
    %%% Alternatively, if there is an initializeVars script set up, call that
    %%% see https://github.com/ritcheym/fmri_misc/tree/master/batch_system    
    %     b = initializeVars(subjects,i);
    
     % Define variables for individual subjects - QA General
    b.scriptdir   = scriptdir;
    b.auto_accept = auto_accept;
    b.messages    = sprintf('Messages for subject %s:\n', subjects{i});
    
    % Initialize diary for saving output
    diaryname = fullfile(b.dataDir, 'normalized_preproc_diary_output.txt');
    diary(diaryname);
    
    % Convert dicom images or find nifti images
    if strcmp(fileType, 'DCM')
        fprintf('--Converting DCM files to NII format--\n')
        [b] = convert_dicom(b);
        fprintf('------------------------------------------------------------\n')
        fprintf('\n')
    elseif strcmp(fileType, 'NII')
        fprintf('--Finding NII files (no DCM conversion required)--\n')
        [b] = find_nii(b);
        fprintf('------------------------------------------------------------\n')
        fprintf('\n')
    else
        error('Specify a valid fileType (''DCM'' or ''NII'')');
    end
    
%     set origin in mprage to AC
%     fprintf('Set origin to AC!')
%     [b] = set_origin(b);
%     fprintf('------------------------------------------------------------\n')
%     fprintf('\n')     

%     % run slice time correction
%     fprintf('--Running slicetime correction--\n')
%     [b] = slicetime_correct(b);
%     fprintf('------------------------------------------------------------\n')
%     fprintf('\n')
%    
%     % Run realignment
%     fprintf('--Realigning and reslicing images using spm_realign and spm_reslice--\n')
%     [b] = batch_spm_realign(b);
%     fprintf('------------------------------------------------------------\n')
%     fprintf('\n')
    
%     Run coregistration (estimate)
    if coreg_flag
        fprintf('--Coregistering images--\n')
        [b] = coregister_estimate(b);
        fprintf('------------------------------------------------------------\n')
        fprintf('\n')
    else
        fprintf('--Skipping coregistration--\n')
        fprintf('------------------------------------------------------------\n')
        fprintf('\n')
    end
    
%     Run normalization estimate
%     fprintf('--Normalize estimating--\n')
%     [b] = normalize_estimate(b);
%     fprintf('------------------------------------------------------------\n')
%     fprintf('\n')
%     
%     % Run normalization write
%     fprintf('--Normalize writing--\n')
%     [b] = normalize_write(b);
%     fprintf('------------------------------------------------------------\n')
%     fprintf('\n')
    
    % Run smooth
    fprintf('--Smoothing--\n')
    [b] = smooth_wbr(b);
    fprintf('------------------------------------------------------------\n')
    fprintf('\n')
    
end % i (subjects)

fprintf('Done preproc script\n')
diary off
delete(gcp('nocreate'))
exit
