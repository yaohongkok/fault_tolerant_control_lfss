function [ Nn,Dn ] = adjust_symb_N_D( N,D )
%MIN_SYMB_MAT Summary of this function goes here
%   Detailed explanation goes here

[p,q] = size(N);

Nn = sym( zeros(p,q));
Dn = sym( zeros(p,q));
%s =sym('s');
for i = 1:1:p
    for j = 1:1:q
        nc = coeffs(N(i,j));
        dc = coeffs(D(i,j));
        log10_nc = double(log10(nc));
        log10_dc = double(log10(dc));
        arr = abs([log10_nc log10_dc]);
        
        mean_log10_nc_dc = round(mean(arr));

        nc = nc/10^mean_log10_nc_dc;
        Nn(i,j) = construct_poly(nc);
        
        dc = dc/10^mean_log10_nc_dc;
        Dn(i,j) = construct_poly(dc);
        
        %Nn(i,j) = vpa(n,dig);
        %Dn(i,j) = vpa(d,dig);
    end
end


end

