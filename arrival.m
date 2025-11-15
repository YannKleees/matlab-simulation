function time = arrival()
    lambda = 5.5;
    U = rand();
    time = -1 * (1/lambda) * log(U);
end