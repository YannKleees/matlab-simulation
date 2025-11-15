% Task 2  RR-interval analysis, cleaning and visualisation
% This script loads RR-interval data, removes implausible and statistical outliers,
% and visualises the original and cleaned signals using several distinct plots.

clear; clc; close all;

%% 1. Load data and basic exploration
load('dataTask2.mat');

N     = numel(RR);
RRmin = min(RR);
RRmax = max(RR);
RRmean = mean(RR);
RRmed  = median(RR);
RRstd  = std(RR);

fprintf('Number of RR intervals: %d\n', N);
fprintf('RR range: [%.4f, %.4f] s\n', RRmin, RRmax);
fprintf('RR mean: %.4f s\n', RRmean);
fprintf('RR median: %.4f s\n', RRmed);
fprintf('RR std: %.4f s\n', RRstd);
%% 2. Outlier detection and cleaning

% 1 Step I drop non‑positive values so the values that are impossible
idxPhys = RR <= 0;
RR1 = RR(~idxPhys);

% 2 Step I apply the IQR rule on remaining data
RRsorted = sort(RR1);
n1 = numel(RRsorted);
q1Idx = floor(0.25 * (n1 + 1));
q3Idx = floor(0.75 * (n1 + 1));
Q1 = RRsorted(max(1, min(n1, q1Idx)));
Q3 = RRsorted(max(1, min(n1, q3Idx)));
IQR = Q3 - Q1;
lowerFence = Q1 - 1.5 * IQR;
upperFence = Q3 + 1.5 * IQR;

fprintf('Q1 = %.4f s, Q3 = %.4f s, IQR = %.4f s\n', Q1, Q3, IQR);
fprintf('Lower fence = %.4f s, upper fence = %.4f s\n', lowerFence, upperFence);

% 3 Step I mark outliers in RR1 using IQR rule
idxIQR = (RR1 < lowerFence) | (RR1 > upperFence);

% 4 Step I combine both outlier types and create clean data
idxBad = (RR <= 0) | (RR < lowerFence) | (RR > upperFence);
RRclean = RR(~idxBad);

fprintf('The total outliers removed: %d (%.2f%% of data)\n', ...
    sum(idxBad), 100*sum(idxBad)/N);

% Statistics after I cleaned the data
RRc_min = min(RRclean);
RRc_max = max(RRclean);
RRc_mean = mean(RRclean);
RRc_med  = median(RRclean);
RRc_std  = std(RRclean);

fprintf('After cleaning:\n');
fprintf('RR range: [%.4f, %.4f] s\n', RRc_min, RRc_max);
fprintf('RR mean: %.4f s\n', RRc_mean);
fprintf('RR median: %.4f s\n', RRc_med);
fprintf('RR std: %.4f s\n', RRc_std);

% Justification:
% The original series contains extremely short intervals and very long
% intervals. Such values correspond to heart rates far above 300 beats
% per minute or prolonged pauses of many seconds and are very unlikely to represent true
% RR intervals in this Holter recording.

% Simple threshold-based R-peak detection can either miss beats, which produces artificially
% long RR intervals, or detect noise as extra peaks, which produces artificially short RR
% intervals. The histograms and time series plots confirm a heavy-tailed distribution with
% isolated extreme values.

% By removing all RR intervals outside [Q1 - 1.5*IQR, Q3 + 1.5*IQR] and all non-positive
% values, about 15.5 percent of the most extreme intervals are discarded. The median changes
% only slightly, while the standard deviation drops from 0.9007s
% to 0.2705s. This indicates that the plausible rhythm is preserved, but the extremes from detection errors are removed.

%% 3. Time-series visualisation
figure;
tiledlayout(2,1);

nexttile;
plot(RR, 'k-');
xlabel('Beat index');
ylabel('RR interval [s]');
title('RR intervals original with outliers');
grid on;

nexttile;
plot(RRclean, 'b-');
xlabel('Beat index after removing outliers');
ylabel('RR interval [s]');
title('RR intervals cleaned');
grid on;

% The time-series plot illustrates the isolated extreme RR intervals present in the original data, demonstrating a smoother and more consistent pattern once cleaned.
%% 4. Histogram visualisation
figure;
tiledlayout(1,2);

nbins = 50;

nexttile;
histogram(RR, nbins);
xlabel('RR interval [s]');
ylabel('Count');
title('Original RR histogram');
grid on;

nexttile;
histogram(RRclean, nbins);
xlabel('RR interval [s]');
ylabel('Count');
title('Cleaned RR histogram');
grid on;
% The histograms show that the original data contains many extreme RR intervals, 
% whereas the cleaned data is distributed more evenly around normal heartbeat durations.

%% 5. Boxplot visualisation
figure;

% Original data boxplot
subplot(1,2,1);
RRsort_o = sort(RR);
n_o = length(RRsort_o);
q1i_o = floor(0.25*(n_o+1));
q3i_o = floor(0.75*(n_o+1));
Q1_o = RRsort_o(max(1,min(n_o,q1i_o)));
Q3_o = RRsort_o(max(1,min(n_o,q3i_o)));
med_o = median(RR);
IQR_o = Q3_o - Q1_o;
wlo_o = Q1_o - 1.5*IQR_o;
whi_o = Q3_o + 1.5*IQR_o;

% The box and whiskers are drawn for the original RR intervals.
rectangle('Position',[0.75,Q1_o,0.5,IQR_o], ...
          'FaceColor',[0.8 0.8 1],'EdgeColor','k','LineWidth',1.5);
hold on;
plot([0.75 1.25],[med_o med_o],'r-','LineWidth',2);
plot([1 1],[Q1_o max(min(RR),wlo_o)],'k-','LineWidth',1.5);
plot([1 1],[Q3_o min(max(RR),whi_o)],'k-','LineWidth',1.5);
plot([0.9 1.1],[max(min(RR),wlo_o) max(min(RR),wlo_o)],'k-','LineWidth',1.5);
plot([0.9 1.1],[min(max(RR),whi_o) min(max(RR),whi_o)],'k-','LineWidth',1.5);
outliers_o = RR(RR<wlo_o | RR>whi_o);
if ~isempty(outliers_o)
    plot(ones(size(outliers_o)), outliers_o,'r+','MarkerSize',6);
end
xlim([0.5 1.5]);
ylim([min(RR)-0.5 max(RR)+0.5]);
set(gca,'XTick',1,'XTickLabel',{'Original'});
ylabel('RR interval [s]');
title('Original');
grid on;
hold off;
subplot(1,2,2);
RRsort_c = sort(RRclean);
n_c = length(RRsort_c);
q1i_c = floor(0.25*(n_c+1));
q3i_c = floor(0.75*(n_c+1));
Q1_c = RRsort_c(max(1,min(n_c,q1i_c)));
Q3_c = RRsort_c(max(1,min(n_c,q3i_c)));
med_c = median(RRclean);
IQR_c = Q3_c - Q1_c;
wlo_c = Q1_c - 1.5*IQR_c;
whi_c = Q3_c + 1.5*IQR_c;

% I draw the box and whiskers plot for the cleaned data
rectangle('Position',[0.75,Q1_c,0.5,IQR_c], ...
          'FaceColor',[0.8 1 0.8],'EdgeColor','k','LineWidth',1.5);
hold on;
plot([0.75 1.25],[med_c med_c],'r-','LineWidth',2);
plot([1 1],[Q1_c max(min(RRclean),wlo_c)],'k-','LineWidth',1.5);
plot([1 1],[Q3_c min(max(RRclean),whi_c)],'k-','LineWidth',1.5);
plot([0.9 1.1],[max(min(RRclean),wlo_c) max(min(RRclean),wlo_c)],'k-','LineWidth',1.5);
plot([0.9 1.1],[min(max(RRclean),whi_c) min(max(RRclean),whi_c)],'k-','LineWidth',1.5);
outliers_c = RRclean(RRclean<wlo_c | RRclean>whi_c);
if ~isempty(outliers_c)
    plot(ones(size(outliers_c)), outliers_c,'r+','MarkerSize',6);
end
xlim([0.5 1.5]);
ylim([min(RRclean)-0.5 max(RRclean)+0.5]);
set(gca,'XTick',1,'XTickLabel',{'Cleaned'});
ylabel('RR interval [s]');
title('Cleaned');
grid on;
hold off;

sgtitle('Boxplots of original and cleaned RR intervals');
% The cleaned boxplot shows a narrower range of RR intervals, with extreme outliers removed.
%% 6. Poincaré plot
figure;
tiledlayout(1,2);

nexttile;
plot(RR(1:end-1), RR(2:end), 'k.');
xlabel('RR_n [s]');
ylabel('RR_{n+1} [s]');
title('Poincaré plot (original)');
grid on;

nexttile;
plot(RRclean(1:end-1), RRclean(2:end), 'b.');
xlabel('RR_n [s]');
ylabel('RR_{n+1} [s]');
title('Poincaré plot (cleaned)');
grid on;

% The original Poincaré plot shows many distant points with extreme RR values, 
% whereas the cleaned plot forms a compact cluster reflecting normal beat-to-beat variability.

%% 7. Empirical CDF comparison
figure;
RR_ecdf  = sort(RR);
F_orig   = (1:numel(RR_ecdf)) / numel(RR_ecdf);
RRc_ecdf = sort(RRclean);
F_clean  = (1:numel(RRc_ecdf)) / numel(RRc_ecdf);

plot(RR_ecdf, F_orig, 'k-', 'LineWidth', 1.2);
hold on;
plot(RRc_ecdf, F_clean, 'b-', 'LineWidth', 1.2);
hold off;
xlabel('RR interval [s]');
ylabel('Empirical CDF');
legend('Original','Cleaned','Location','southeast');
title('Empirical CDF of original and cleaned RR intervals');
grid on;

% The original CDF stretches further to the right due to very long RR intervals, 
% while the cleaned CDF rises faster because the extreme tail has been removed.





%% RESULTS SUMMARY

% The dataset contains 5,160 RR intervals from patient 15 of the SHDB Holter database. 
% The raw data range extends from 0.0100 to 18.5933 seconds, with mean, median and standard deviation values of 1.0270, 0.8250 and 0.9007 seconds, respectively. 
% These values indicate a highly skewed distribution, with several extreme intervals that are unlikely to represent real heartbeats.
%
% Because the R-peaks were detected using a thresholding technique unrealistic 
% RR intervals may appear. Very short intervals usually indicate false detections caused by 
% noise being misinterpreted as heartbeats. Conversely, very long intervals are typically produced 
% when the detector misses true R-peaks. These effects can be confirmed by the time-series plot. 
% This shows isolated spikes far from the main rhythm and the histogram displays 
% A long right tail extending beyond 10 seconds.
%
% These artefacts were identified and removed using the Tukey interquartile range method. 
% With Q1 = 0.7500s and Q3 = 1.1350s, the interquartile range was found to be 0.3850s. 
% This yields lower and upper fences of 0.1725 and 1.7125s respectively. All RR intervals outside this range, 
% together with any non-positive values, were treated as implausible and removed. A total of 800 values were excluded.
%
% After cleaning, the RR intervals fell within the range of 0.1750 to 1.7100 s, with a mean value of 0.9399 s. 
% seconds, a median of 0.83 s and a reduced standard deviation of 0.27 s. The small 
% change in the median, but a large reduction in the standard deviation, indicates that the central rhythm 
% was preserved, with only the extreme values removed.
%
% The different visualisations reinforce this conclusion. 
% - The time-series plots clearly show the disappearance of extreme spikes after cleaning.
% - The histograms show that the cleaned distribution is centred and plausible, with no long tail. 
% - The box plots highlight the reduction in outliers and the tighter IQR range. 
% - The Poincaré plot changes from a set of scattered distant points to a compact cluster, indicating that beat-to-beat variability 
% becomes more realistic once artefacts have been removed. 
% - Finally, the empirical CDF shows that the original distribution extends far to the right due to the presence of extreme values. 
% In contrast, the cleaned CDF rises quickly because the heavy tail is no longer present.
%
% Together, these analyses demonstrate that the removed values are indeed outliers caused by detection 
% rather than genuine behaviour.