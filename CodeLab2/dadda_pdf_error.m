clear all
close all
clc

titles = ["Fully-approximate architecture using AMBE"
          "Fully-approximate architecture using AMBE & 4-2 compressors"
          "Fully-approximate architecture using 4-2 compressors"
          "Manually-optimized Dadda architecture (no 6 LSBs)"
          "Standard Dadda architecture (no 6 LSBs)"];
      
file_names = ["dadda_ambe"
              "dadda_ambe_4to2_layer2"
              "dadda_4to2_layer2"
              "dadda_no_6LSB"
              "dadda_standard_no6LSB"];
dest_folder = "Images";
dest_filetype = ".png";
         
folder = ".";
filetype = ".txt";
appendix = "pdf";
files_to_process = ls(folder + "/*" + filetype);
len = size(files_to_process, 1);

for i=1:len
    res_final = importdata(files_to_process(i, :));
    pd = fitdist(res_final(:, end), 'Normal');
    
    figure('units','normalized','outerposition',[0 0 1 1],"DefaultAxesFontSize", 24)
    xlabel("Errors");
    ylabel("Probability");
    title(titles(i, :) + " Error Distribution");
    hold on
    plot(sort(res_final(:, end)), pdf(pd, sort(res_final(:, end))), "LineWidth", 2);
    F = getframe(gcf);
    imwrite(F.cdata, dest_folder + "/" + file_names(i, :) + "_" + appendix + dest_filetype);
    close(gcf);
end