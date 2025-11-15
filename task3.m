%Task 3: Discrete-event simulation of the M/M/3 system
%This script performs 20 simulations of the three-machine production system via the DES function. 
% The average waiting time, average queue length and average profit are then reported for the default 24-hour payout boundary.
%The simulation is then repeated for payout boundaries of 10, 16, 24 and 30 hours. 
% The resulting profits are compared using box plots, which are saved as pictureTask3.png.
clear; clc; close all;

n = 20;

%% 20 replications with default parameters

avgWait_all  = zeros(n, 1);
avgQL_all    = zeros(n, 1);
profit_24_all = zeros(n, 1);

for r = 1:n
    [avgW, avgQ, prof] = DES();   % DES with all default parameters
    avgWait_all(r)   = avgW;
    avgQL_all(r)     = avgQ;
    profit_24_all(r) = prof;
end

meanWait  = mean(avgWait_all);
meanQL    = mean(avgQL_all);
meanProfit = mean(profit_24_all);

fprintf('  Average waiting time: %.4f minutes\n', meanWait);
fprintf('  Average queue length: %.4f\n', meanQL);
fprintf('  Average profit: %.2f euro\n\n', meanProfit);

% Comment:
% The average waiting time summarises how long products spend in the system
% from arrival to completion. The average queue length is the time‑average
% number of waiting jobs, obtained via the area under the queue‑length curve
% divided by the simulated time. The profit combines per‑job revenues and time‑based production
% costs of 1000 euro per hour.


%% We compare payout boundaries of 10, 16, 24 and 30 hours

pobHours = [10, 16, 24, 30];
nPOB     = numel(pobHours);
profitsPOB = zeros(n, nPOB);

for k = 1:nPOB
    POB_minutes = pobHours(k) * 60; % hours to minutes
    for r = 1:n
        % Here i call DES
        [~, ~, prof] = DES([], [], [], POB_minutes, [], [], []);
        profitsPOB(r, k) = prof;
    end
end


figure;
hold on;
% Boxplot implementation like in task2
for k = 1:nPOB
    data = profitsPOB(:, k);
    
    % Calculate statistics
    dataSorted = sort(data);
    n = length(data);
    q1Idx = floor(0.25 * (n + 1));
    q3Idx = floor(0.75 * (n + 1));
    Q1 = dataSorted(max(1, min(n, q1Idx)));
    Q3 = dataSorted(max(1, min(n, q3Idx)));
    med = median(data);
    IQR = Q3 - Q1;
    wlo = Q1 - 1.5 * IQR;
    whi = Q3 + 1.5 * IQR;
    
    % Draw box
    boxWidth = 0.4;
    xPos = k;
    rectangle('Position', [xPos - boxWidth/2, Q1, boxWidth, IQR], ...
              'FaceColor', [0.8 0.8 1], 'EdgeColor', 'k', 'LineWidth', 1.5);
    
    % Draw median line
    plot([xPos - boxWidth/2, xPos + boxWidth/2], [med, med], 'r-', 'LineWidth', 2);
    
    % Draw whiskers
    lowerWhisker = max(min(data), wlo);
    upperWhisker = min(max(data), whi);
    plot([xPos, xPos], [Q1, lowerWhisker], 'k-', 'LineWidth', 1.5);
    plot([xPos, xPos], [Q3, upperWhisker], 'k-', 'LineWidth', 1.5);
    plot([xPos - boxWidth/4, xPos + boxWidth/4], [lowerWhisker, lowerWhisker], 'k-', 'LineWidth', 1.5);
    plot([xPos - boxWidth/4, xPos + boxWidth/4], [upperWhisker, upperWhisker], 'k-', 'LineWidth', 1.5);
    
    % Draw outliers
    outliers = data(data < wlo | data > whi);
    if ~isempty(outliers)
        plot(xPos * ones(size(outliers)), outliers, 'r+', 'MarkerSize', 6);
    end
end

hold off;
xlim([0.5, nPOB + 0.5]);
set(gca, 'XTick', 1:nPOB, 'XTickLabel', {'10 h', '16 h', '24 h', '30 h'});
xlabel('Payout boundary (hours)');
ylabel('Profit per replication [euro]');
title('Profit distribution for different payout boundaries');
grid on;
saveas(gcf, 'pictureTask3.png');




%% Results summary:

% Across 20 replications with the default 24-hour payout boundary, the
% system produced an average waiting time of around 2.12 minutes.An average
% queue length of about 8.91 jobs and an average profit of around
% 1.10 million euro. The waiting time is far below the 24 hourly threshold,
% which means almost all jobs receive the higher payout.
%
% When comparing payout boundaries of 10, 16, 24 and 30 hours, the boxplot
% show a clear upward shift in profit as the boundary increases. A smaller
% boundary classifies more jobs as slow, reducing revenue, while a larger
% boundary allows more jobs to qualify for the higher payout. The lowest
% profits occur at 10 hours and the highest at 30 hours, with very little
% variation between runs, indicating stable system behaviour.


