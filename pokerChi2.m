function [R,critval,reject] = pokerChi2(patterns,alpha)
% So the function computes the chi-squared statistic and 
% critical value for testing poker patterns, 
% and decides whether to reject the null hypothesis.

    patterns = double(patterns(:)');
    N = sum(patterns);
    % Theoretical probabilities for each poker pattern under H0
    p = [0.3024, 0.5040, 0.1080, 0.0720, 0.0090, 0.0045, 0.0001];
    expected = N * p;
    % Chi-square statistic
    R = sum((patterns - expected).^2 ./ expected);
    df = 6;
    % I try to use chi2inv from the toolbox but if not available 
    % I use a simple implementation that i did myself
    if exist('chi2inv','file') == 2
        critval = chi2inv(1 - alpha, df);
    else
        critval = chi2inv_simple(1 - alpha, df);
    end
    % We reject H0 if R exceeds the critical value
    reject = (R > critval);
end


% chi-square inverse without the toolbox
function x = chi2inv_simple(p, df)
%Computes an approximate inverse chi-squared 
% cumulative distribution function using bisection

    if p <= 0
        x = 0;
        return;
    elseif p >= 1
        x = Inf;
        return;
    end

    lower = 0; %this is the lower bound for the search
    upper = df + 10*sqrt(df) + 50; % this is the upper bound for the search

    for iter = 1:60
        mid = (lower + upper) / 2;
        cdf = gammainc(mid/2, df/2, 'lower');

        if cdf < p
            lower = mid;
        else
            upper = mid;
        end
    end

    x = (lower + upper) / 2;
end
