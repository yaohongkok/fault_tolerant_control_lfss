function [ Nn,Dn,Nn_roots,Dn_roots,Km ] = simplify_rat_poly_matrix( N,D )
%SIMPLIFY_RAT_POLY Summary of this function goes here
%   Detailed explanation goes here

[p,q] = size(N);
Nn = sym(zeros(p,q));
Dn = sym(zeros(p,q));
Nn_roots = cell(p,q);
Dn_roots = cell(p,q);
Km = zeros(p,q);

isOpen = matlabpool('size') > 0;
if(~isOpen)
    matlabpool 2
end

for i = 1:p
    Nn_row = sym(zeros(1,q));
    Dn_row = sym(zeros(1,q));
    Nn_roots_row = cell(1,q);
    Dn_roots_row = cell(1,q);
    Km_row = zeros(1,q);
    N_row = N(i,:);
    D_row = D(i,:);
    
    fprintf('i = %d\n',i);
    for j = 1:1:q
        n_original = coeffs(N_row(j));
        if(isempty(n_original))
            n_original = sym(0);
        end
        d_original = coeffs(D_row(j));
        
        num_roots = [];
        den_roots = [];
        if(length(n_original)>1)
            num_roots = double(solve(N_row(j)));
        end
        if(length(d_original)>1)
            den_roots = double(solve(D_row(j)));
        end
        
        % Remove large roots
        large_idx = abs(num_roots)>1e5*median(abs(num_roots));
        num_roots(large_idx) = [];
        n_new = coeffs(construct_poly_roots( num_roots ));
        
        large_idx = abs(den_roots)>1e5*median(abs(den_roots));
        den_roots(large_idx) = [];
        d_new = coeffs(construct_poly_roots( den_roots ));

        % Calculate gain K
        lnn = length(n_new);
        ldn = length(d_new);
        Kn = n_original(1:lnn)./n_new;
        Kd = d_original(1:ldn)./d_new;
        if(length(d_new)>=length(n_new))
            K = median(double(Kn./Kd(1:lnn)));
        else
            K = median(double(Kn(1:ldn)./Kd));
        end
        
        if(abs(imag(K))>1e-6)
            error('Large imaginary numbers...\n');
        else
            K = real(K);
        end
        
        Km_row(j) = K;
        
        % Remove repeated roots
        if(abs(K)>1e-10)
            num_order = length(num_roots);
            num_root_cancel_idx = [];
            
            for k = 1:1:num_order
                roots_diff = abs(num_roots(k)-den_roots);
                first_idx = find(roots_diff<=(1e-5*abs(num_roots(k))),1);
                
                if(~isempty(first_idx))
                    num_root_cancel_idx = [num_root_cancel_idx k];
                    den_roots(first_idx) = [];
                end
            end
            
            num_roots(num_root_cancel_idx) = [];
            
            Nn_roots_row{j} = num_roots;
            Dn_roots_row{j} = den_roots;
            %Nn_roots{i,j} = num_roots;
            %Dn_roots{i,j} = den_roots;
            
            n_new_sim = coeffs(construct_poly_roots( num_roots ));
            Nn_row(j) = K*vpa(construct_poly(real(n_new_sim)));
            %Nn(i,j) = K*vpa(construct_poly(real(n_new_sim)));
            d_new_sim = coeffs(construct_poly_roots( den_roots ));
            Dn_row(j) = vpa(construct_poly(real(d_new_sim)));
            %Dn(i,j) = vpa(construct_poly(real(d_new_sim)));
            
        else
            Nn_roots_row{j} = [];
            Dn_roots_row{j} = [];
            Nn_row(j) = 0;
            Dn_row(j) = 1;
            Km_row(j) = 0;
            %Nn(i,j) = 0;
            %Dn(i,j) = 1;
            
            %Nn_roots{i,j} = [];
            %Dn_roots{i,j} = [];
        end
        
        Km(i,:) = Km_row;
        Nn_roots(i,:) = Nn_roots_row;
        Dn_roots(i,:) = Dn_roots_row;
        Nn(i,:) = Nn_row;
        Dn(i,:) = Dn_row;
    end
    
end

matlabpool close

end

