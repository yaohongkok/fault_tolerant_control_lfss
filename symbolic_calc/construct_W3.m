function [ W,N_roots,D_roots,Km] = construct_W3( Gf)
%CONSTRUCT_W Summary of this function goes here
%   Detailed explanation goes here

if(exist('W_raw.mat','file')==2)
    load('W_raw.mat');
else
    [m,temp] = size(Gf);
    %s = sym('s');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate the null space of of Gf
    W = sym(zeros(m));
    fprintf('Computing nullspace of Gf...\n');
    tic
    for i = 1:1:m
        G_dil = [Gf(:,i) Gf(:,i+m)];
        Qt = null(G_dil.');        % ' is hermitian & .' is transpose
        
        j = 1;
        rank_inc = 0;
        while (j<=m-2 && rank_inc==0)
            wr= Qt(:,j).';
            
            if (double(rank([wr;W]))> double(rank(W)))
                rank_inc = 1;
                W(i,:)= wr;
            else
                if(j == m-2)
                    W(i,:) = wr;
                end
            end
            j = j + 1;
        end
    end
    toc
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % W typically may not be proper and stable
    % To be implementable, W is required to be proper
    % To be robust against disturbance, W is required to be stable
    save('temp','W');
    [N,D]= numden(W);
    
    
    PN = sym(zeros(m));         % Compensation transfer matrix numerator
    PD = sym(ones(m));          % Compensation transfer matrix denominator
    
    PN_order = zeros(1,m);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Search for unstable roots and add it to numerator of the compensation
    % transfer matrix. This ensure W(s) is stable.
    fprintf('Creating compensator for unstable roots...\n');
    for i = 1:1:m
        
        comp_roots = [];
        
        for j = 1:1:m
            d_co = coeffs(D(i,j));
            if(length(d_co)>1)
                D_roots = double(solve(D(i,j)));
                D_roots_unstable = D_roots(D_roots>=0);
                
                for k = 1:1:length(D_roots_unstable)
                    if (abs(D_roots_unstable(k))>1e3)
                        limit = D_roots_unstable(k)*1e-5;
                    else
                        limit = 1e-5;
                    end
                    comp_idx = find(abs(comp_roots - D_roots_unstable(k))<limit);
                    self_idx = find(abs(D_roots_unstable - D_roots_unstable(k))<limit);
                    
                    l_c = length(comp_idx);
                    l_s = length(self_idx);
                    
                    if(l_s>l_c)
                        comp_roots = [comp_roots;D_roots_unstable(k)*ones(l_s-l_c)];
                    end
                end
            end
        end
        
        %comp_roots
        PN_order(i) = length(comp_roots);
        PN(i,i) = construct_poly_roots(comp_roots);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Next, we need to make the transfer matrix. First, determine the order of
    % the numerator and denominator.
    fprintf('Creating compensator to ensure W(s) is proper...\n');
    N_order = zeros(m);
    D_order = zeros(m);
    
    for i = 1:1:m
        for j = 1:1:m
            Npolyarr = sym2poly(N(i,j));
            Dpolyarr = sym2poly(D(i,j));
            
            N_order(i,j) = length(Npolyarr)-1;
            D_order(i,j) = length(Dpolyarr)-1;
        end
    end
    
    rat_order = N_order-D_order;
    
    % Make W(s) proper by putting random stable roots in the denominator
    for i = 1:1:m
        row_order_large = sum(rat_order(i,:)>0)~=0;
        
        additional_order = 0;
        % if numerator order larger than denominator
        if(row_order_large == 1)
            additional_order = max(rat_order(i,:));
        end
        
        root_arr = -2*rand(1,additional_order+ PN_order(i))-5;
        PD(i,i) = construct_poly_roots(root_arr);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute M and the Inc(M)
    P = PN./PD;
    % Simplify W (by removing the same roots on the numerator and denominator)
    W = P*W;
    [N,D]= numden(W);
    fprintf('Simplifying W(s)...\n');
    [ N,D,N_roots,D_roots,Km] = simplify_rat_poly_matrix( N,D );
    W = N./D;
    
    % Check if there is any positive roots in W(s)
    for i = 1:1:m
        for j =1:1:m
            if(any( D_roots{i,j}>=0))
                i,j
                D_roots{i,j}
                error('Found positive roots in W(s)...\n');
            end
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    save('W_raw','W','N_roots','D_roots','Km');
end


end

