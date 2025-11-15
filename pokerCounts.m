function patterns = pokerCounts(U)
% The function pokerCounts determines how frequently each of the seven poker patterns 
% occurs in consecutive groups of five observations.


    U = U(:).'; % Transform U into a row vector
    num = numel(U); % The total number of generated values
    G   = floor(num/5); % The number of groups is five digits

    patterns = zeros(1,7);

    for g = 1:G
        group = U(5*(g-1)+1:5*g);
        % Percentages map to the digits 0 to 9.
        d = floor(group * 10);

        % count occurrences of each digit
        counts = zeros(1,10);
        for i = 1:5
            counts(d(i)+1) = counts(d(i)+1) + 1;
        end

        % Only non-zero counts are included and they are sorted in descending order.
        cc = sort(counts(counts>0),'descend');

        if     isequal(cc,[1 1 1 1 1])
            patterns(1) = patterns(1) + 1;   % all different poker cards
        elseif isequal(cc,[2 1 1 1])
            patterns(2) = patterns(2) + 1;   % one pair poker cards
        elseif isequal(cc,[2 2 1])
            patterns(3) = patterns(3) + 1;   % two pairs poker cards
        elseif isequal(cc,[3 1 1])
            patterns(4) = patterns(4) + 1;   % three of a kind poker cards
        elseif isequal(cc,[3 2])
            patterns(5) = patterns(5) + 1;   % full house poker cards
        elseif isequal(cc,[4 1])
            patterns(6) = patterns(6) + 1;   % four of a kind poker cards
        elseif isequal(cc,[5])
            patterns(7) = patterns(7) + 1;   % five of a kind poker cards
        end
    end
end
