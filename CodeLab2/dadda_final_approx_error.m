clear all
close all
clc

res_correct = importdata("../results_correct.txt");
file_names = ["dadda_4to2_layer2"
              "dadda_ambe"
              "dadda_ambe_4to2_layer2"
              "dadda_final_approx"
              "dadda_no_6LSB"
              "dadda_standard_no6LSB"];
titles = ["Fully-approximate architecture using 4-2 compressors"
          "Fully-approximate architecture using AMBE"
          "Fully-approximate architecture using AMBE & 4-2 compressors"
          "Final approximate Dadda architecture"
          "Manually-optimized Dadda architecture (no 6 LSBs)"
          "Standard Dadda architecture (no 6 LSBs)"];

dest_folder = "Images";
dest_filetype = ".png";
appendices = ["signal" "abs_error"];
folder = ".";
filetype = ".txt";
files_to_process = ls(folder + "/*" + filetype);
len = size(files_to_process, 1);

for i=1:len
    res_final = importdata(files_to_process(i, :));

    figure('units','normalized','outerposition',[0 0 1 1],"DefaultAxesFontSize", 24)
    xlabel("Time samples");
    ylabel("Bit value");
    title(titles(i, :));
    hold on
    plot(res_correct, "LineWidth", 2);
    hold on
    plot(res_final, "LineWidth", 2);
    legend("Exact", "Approximate");
    F = getframe(gcf);
    imwrite(F.cdata, dest_folder + "/" + file_names(i, :) + "_" + appendices(1) + dest_filetype);
    close(gcf);

    figure('units','normalized','outerposition',[0 0 1 1],"DefaultAxesFontSize", 24)
    plot(res_correct - res_final);
    close(gcf);

    figure('units','normalized','outerposition',[0 0 1 1],"DefaultAxesFontSize", 24)
    xlabel("Time samples");
    ylabel("Bit value");
    title(titles(i, :) + " Absolute Error");
    hold on
    plot(abs(res_correct - res_final), "LineWidth", 2);
    F = getframe(gcf);
    imwrite(F.cdata, dest_folder + "/" + file_names(i, :) + "_" + appendices(2) + dest_filetype);
    close(gcf);
end