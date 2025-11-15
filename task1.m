% The Task 1 script performs three main tasks. 
% First, it uses the RNG_PCG function to generate 10000 random numbers uniformly distributed between 0 and 1. 
% Secondly, it applies a five-digit poker test to the generated values to evaluate their statistical properties. 
% Thirdly, it runs a chi-square test to determine whether the generator produces values consistent with a truly 
% uniform random sequence and passes the poker test.

%% Parameters for the PCG
a    = 846793005;
c    = 294755497;
seed = 19;
num  = 10000;

%% Task 1a
% Generate random numbers using our PC.
% the RNG_PCG function calls PCG_SSA function repeatedly to produce num uniformly distributed
% values in the interval [0,1). Each call updates the internal 32-bit LCG state and applies a 
% permutation to produce a 16-bit output. 
% This output is then scaled to the range [0, 1).

U = RNG_PCG(num, a, c, seed);
fprintf('We generated %d U[0,1) values.\n', num);
sz = size(U);
fprintf('The size of U is [%d %d].\n', sz(1), sz(2));
disp('First 10 U values:');
disp(U(1:10));
 
% For the poker test, we convert each U value into a digit from 0 to 9 by taking floor(U * 10).
% This converts continuous uniform values into discrete digits for pattern analysis.
digits = floor(U * 10);
disp('The first 20 digits used in the poker test:');
disp(digits(1:20));


%% Task 1b
% In the poker test, each five-digit group is assigned to one of seven patterns,
% and the frequency of each pattern's occurrence is counted.

patterns = pokerCounts(U);   

% Theoretical probabilities 
p = [0.3024, 0.5040, 0.1080, 0.0720, 0.0090, 0.0045, 0.0001];

% Number of five-digit hands
G = floor(num/5);

% Expected counts for each pattern under H0
expected = G * p;

disp('Poker pattern counts [all diff, 1 pair, 2 pairs, 3 of a kind, full house, 4 of a kind, 5 of a kind]:');
disp(patterns);
disp('Expected counts under H0:');
disp(expected);


%% Chi-square test on the poker patterns
% The chi-squared test checks whether the observed and expected counts match,
% rejecting the null hypothesis if the observed count exceeds the critical value.

alpha = 0.01; % alpha is the significance level
[R,critval,reject] = pokerChi2(patterns, alpha);

fprintf('Chi^2 statistic R = %.4f\n', R);
fprintf('Critical value for degrees of freedom of 6 and alpha which is %.3f is %.4f\n', alpha, critval);
if reject
    disp('if R > critical value we reject the null hypothesis H0.');
    disp('Interpretation: the observed poker pattern counts deviate strongly');
    disp('from what we would expect under i.i.d. U[0,1) which means that the generator looks bad in this test.');
else
    disp('if R <= critical value we do NOT reject the null hypothesis H0.');
    disp('So the observed poker pattern counts are compatible with');
    disp('what we expect under i.i.d. U[0,1) which means that the generator looks okay in this test.');
end
