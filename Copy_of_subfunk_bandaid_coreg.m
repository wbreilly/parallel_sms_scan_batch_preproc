function [b] = Copy_of_subfunk_bandaid_coreg(b)

% mean image as the reference 
path1 = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/fir_data_10_26_18/';
path2 = sprintf('Rifa_1/meanslicetime_%s.Rifa_1.bold.nii', b.curSubj);
ref_img = fullfile(path1, b.curSubj, path2);

%loop through masks
for irun=1:2
    matlabbatch{irun}.spm.spatial.coreg.write.ref = cellstr(ref_img);
    matlabbatch{irun}.spm.spatial.coreg.write.source = b.allfiles{irun};
    matlabbatch{irun}.spm.spatial.coreg.write.roptions.interp = 0;
    matlabbatch{irun}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{irun}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{irun}.spm.spatial.coreg.write.roptions.prefix = 'coreg_';
end



%run
spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);



end