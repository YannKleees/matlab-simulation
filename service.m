function time = service()
    lambda = 2;
    U = rand();
    time = -1 * (1/lambda) * log(U);
end