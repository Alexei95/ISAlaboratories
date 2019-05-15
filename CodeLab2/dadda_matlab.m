close all
clear all
clc

folder = "C:/Users/colucci/Desktop/Comparisons_final_approx";
filetype = ".txt";
ambe_pos = 5;
dadda_pos = 11;

files_to_process = ls(folder + "/*" + filetype);
indexes = [str2num(files_to_process(:, ambe_pos)) str2num(files_to_process(:, dadda_pos))];
max_ = max(indexes);
max_ambe = max_(1) + 1;
max_dadda = max_(2) + 1;
figure('Name', 'AMBE and Dadda Analysis')
title('AMBE and Dadda Analysis')
for k=1:size(files_to_process, 1)
    file = files_to_process(k, :)
    index = [str2num(file(ambe_pos)) str2num(file(dadda_pos))];
    data = importdata(folder + "/" + file, ";");
    data_to_plot = data(:, end);
    max_ = max(data_to_plot)
    mean_ = mean(data_to_plot)
    var_ = var(data_to_plot)
    pd = fitdist(data_to_plot, 'Normal')
    subplot(max_ambe, max_dadda, k);
    plot(sort(data_to_plot), pdf(pd, sort(data_to_plot)), 'LineWidth', 1)
    title("Ambe: " + string(index(1)) + " Dadda: " + string(index(2)));
    ylabel('Normalized Probability');
    xlabel('Error');
    %figure
    %plot(data(1:10000, end))
end