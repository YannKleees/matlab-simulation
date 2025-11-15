function [Z,n] = PCG_SSA(n,a,c)
% The PCG_SSA function is one step of a 32-bit PCG with a random shift and a 16-bit output.
% It uses the 3 most significant bits to decide how many least significant bits 
% to drop, then keeps exactly 16 bits.

    n = uint32(n);
    a = uint32(a);
    c = uint32(c);

    % 32‑bit LCG step with proper modulo arithmetic
    n = mod(uint64(a) * uint64(n) + uint64(c), uint64(2^32));
    n = uint32(n);

    % 3 MSBs in {0,...,7} -> how many least significant bits to drop
    extraShift = bitshift(n, -29);          % 3 MSBs

    % Drop extraShift LSBs
    shifted = bitshift(n, -double(extraShift));

    % Keep exactly 16 lower bits of the shifted value
    Z = uint16(bitand(shifted, uint32(65535)));
end
