function U = RNG_PCG(num, a, c, seed)
    % The function RNG_PCG  generates a number of U[0, 1) values by 
    % repeatedly applying the PCG_SSA step
    U = zeros(1, num);          % row vector
    n = seed;
    for k = 1:num
        [Z, n] = PCG_SSA(n, a, c);
        U(k) = double(Z) / 2^16;
    end
end
