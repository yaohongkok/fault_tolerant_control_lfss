function [ Gf,Gf_inc ] = calculate_Gf( A,B,C,H )
%CALCULATE_GF Summary of this function goes here
%   Detailed explanation goes here

[temp,m] = size(B);
n = temp/2;
s = sym('s');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the transfer matrix using symbolic computation
% Symbolic computation gives better representation of the roots
fprintf('Getting Raw Gf...\n');


Q = A - H*C;
[V,Diag] = eig(Q,'nobalance');
Bn = V\[B,-H];
Cn = C*V;
P = s*eye(2*n) - Diag;
P_inv = inv(P);
Gf = vpa(Cn*P_inv*Bn + [zeros(m) eye(m)]);
Gf_inc = zeros(m,2*m);

fprintf('Getting Num & Den of Raw Gf...\n');
tic
[Ng,Dg] = numden(Gf);
toc;

fprintf('Processing Raw Gf...\n');

isOpen = matlabpool('size') > 0;
if(~isOpen)
    matlabpool 2
end

parfor i =1:m
    fprintf('i = %d\n',i);
    Gf_row = sym(zeros(1,2*m));
    Gf_inc_row = zeros(1,2*m);
    Ng_row = Ng(i,:);
    Dg_row = Dg(i,:);
    
    for j = 1:1:2*m
        tic;
        %n_roots = double(solve(Ng(i,j)));
        %d_roots = double(solve(Dg(i,j)));
        
        %n_original = coeffs(Ng(i,j));
        %d_original = coeffs(Dg(i,j));
        
        n_roots = double(solve(Ng_row(j)));
        d_roots = double(solve(Dg_row(j)));
        
        n_original = coeffs(Ng_row(j));
        d_original = coeffs(Dg_row(j));
        
        % Remove large roots
        large_idx = abs(n_roots)>1e5*median(abs(n_roots));
        n_roots_new = n_roots;
        n_roots_new(large_idx) = [];
        n_new = coeffs(poly(diag(n_roots_new),s));
        
        % Remove large roots
        large_idx = abs(d_roots)>1e5*median(abs(d_roots));
        d_roots_new = d_roots;
        d_roots_new(large_idx) = [];
        d_new = coeffs(poly(diag(d_roots_new),s));
        
        % Get gain
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
        
        % Remove repeated roots
        if(abs(K)>1e-10)
            num_order = length(n_roots_new);
            num_root_cancel_idx = [];
            
            for k = 1:1:num_order
                roots_diff = abs(n_roots_new(k)-d_roots_new);
                first_idx = find(roots_diff<=(1e-5*abs(n_roots_new(k))),1);
                
                if(~isempty(first_idx))
                    num_root_cancel_idx = [num_root_cancel_idx k];
                    d_roots_new = [d_roots_new(1:first_idx-1);d_roots_new(first_idx+1:end)];
                end
            end
            
            n_roots_new(num_root_cancel_idx) = [];
            
            n_new_sim = coeffs(poly(diag(n_roots_new),s));
            n_new_sim = vpa(construct_poly(real(n_new_sim)));
            d_new_sim = coeffs(poly(diag(d_roots_new),s));
            d_new_sim = vpa(construct_poly(real(d_new_sim)));
            
            Gf_row(j) = K*n_new_sim/d_new_sim;
            Gf_inc_row(j) = 1;
            %Gf(i,j) = K*n_new_sim/d_new_sim;
            %Gf_inc(i,j) = 1;
        else
            %Gf(i,j) = 0;
            Gf_row(j) = 0;
        end
        %toc
        
        Gf(i,:) = Gf_row;
        Gf_inc(i,:) = Gf_inc_row;
        
    end
end

matlabpool close
save('Gf_raw','Gf','Gf_inc');

end

