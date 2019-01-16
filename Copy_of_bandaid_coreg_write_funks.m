% reslice, threshold, rename, each subjects' masks
clear all
clc


dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/cluster_preproc_native_8_6_18_tmaps/';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/singletrial_4_rsatoolbox';
subjects    = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019'  's020'...
               's022' 's023' 's024' 's025' 's027' 's028' 's029' 's030' 's032' 's033' 's034' 's035' 's036' 's037' ...
               's038' 's039' 's040' 's041' 's042' 's043'}; 

runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  




% Loop over subjects
parfor isub = 1:length(subjects)
%     check that grabbing right files
    b.curSubj   = subjects{isub};
    b.dataDir   = fullfile(dataDir, b.curSubj);
    b.runs      = runs;
    
    b.dir1 = fullfile(b.dataDir, 'tmap_4_rsa_singletrial');
    b.dir2 = fullfile(b.dataDir, 'SVDP_tmaps_4_rsa');
    
    b.rundir(1).sfiles = spm_select('ExtFPListRec', b.dir1, '.*\.nii');
    fprintf('%02d:   %0.0f normalized files found.\n', 1, length(b.rundir(1).sfiles))
    
    b.rundir(2).sfiles = spm_select('ExtFPListRec', b.dir2, '.*\.nii');
    fprintf('%02d:   %0.0f normalized files found.\n', 2, length(b.rundir(2).sfiles))
    
    
    b.allfiles = {};
    for i = 1:2
        b.allfiles{i} = cellstr(b.rundir(i).sfiles); 
    end
    
    [b] = Copy_of_subfunk_bandaid_coreg(b);
    
%     % mean image as the reference 
%     path1 = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/fir_data_10_26_18/';
%     path2 = sprintf('Rifa_1/meanslicetime_%s.Rifa_1.bold.nii', b.curSubj);
%     ref_img = fullfile(path1, b.curSubj, path2);
%     
%     %loop through masks
%     for irun=1:9
%         matlabbatch{irun}.spm.spatial.coreg.write.ref = cellstr(ref_img);
%         matlabbatch{irun}.spm.spatial.coreg.write.source = b.allfiles{irun};
%         matlabbatch{irun}.spm.spatial.coreg.write.roptions.interp = 0;
%         matlabbatch{irun}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
%         matlabbatch{irun}.spm.spatial.coreg.write.roptions.mask = 0;
%         matlabbatch{irun}.spm.spatial.coreg.write.roptions.prefix = 'coreg_';
%     end
%     
% 
%     
%     %run
%     spm('defaults','fmri');
%     spm_jobman('initcfg');
%     spm_jobman('run',matlabbatch);
     
end % end isubd

% y = {};
% for iroi = 1:size(b.masks,1)
%     [x,y{iroi},z] = fileparts(b.masks{iroi,:});
% end
