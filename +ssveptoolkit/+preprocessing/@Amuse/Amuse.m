classdef Amuse < ssveptoolkit.preprocessing.PreprocessingBase
    
    properties
        first;
        last;
        avgTime;
    end
    
    methods
        function AM = Amuse()
            AM.first = 2;
            AM.last = 256;
        end
        
        function out = process(AM,in )
            out = {};
            total = 0;
            for i=1:length(in)
                %                 i
                %                 in{i}.signal(end,:) = [];
                tic
                signal = in{i}.signal;
                %                 signal(end,:) = [];
                [W,~,yest] = AM.amuse(signal);
                signal = pinv(W(AM.first:AM.last,:))*yest(AM.first:AM.last,: );
                total = total + toc;
                in{i}.signal = signal;
                %                 out{i} = ssveptoolkit.util.Trial(signal,in{i}.label,in{i}.samplingRate,in{i}.subjectid);
            end
            out = in;
            %             total = toc;
            AM.avgTime = total/length(in);
        end
        
        function configInfo = getConfigInfo(AM)
            configInfo = sprintf('Amuse:\t%d-%d',AM.first,AM.last);
        end
        
        function time = getTime(AM)
            time = AM.avgTime;
        end
    end
    
    methods (Access = private)
        function [W,D1,y] = amuse(AM,X)
            % BSS using eigenvalue value decomposition
            % Program written by A. Cichocki and R. Szupiluk
            %
            % X [m x N] matrix of observed (measured) signals,
            % W separating matrix,
            % y estimated separated sources
            % p time delay used in computation of covariance matrices
            % optimal time-delay default p= 1
            %
            % First stage: Standard prewhitening
            
            [m,N]=size(X);
            if nargin==2,
                n=m; %
            end;
            
            Rxx=(X*X')/N;
            
            [Ux,Dx,Vx]=svd(Rxx);
            Dx=diag(Dx);
            % n=xxx;
            if n<m, % under assumption of additive white noise and
                %when the number of sources are known or can a priori estimated
                Dx=Dx-real((mean(Dx(n+1:m))));
                Q= diag(real(sqrt(1./Dx(1:n))))*Ux(:,1:n)';
                %
            else    % under assumption of no additive noise and when the
                % number of sources is unknown
                n=max(find(Dx>1e-199)); %Detection the number of sources
                Q= diag(real(sqrt(1./Dx(1:n))))*Ux(:,1:n)';
            end;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Second stage: Fast separation using sorting EVD
            % notation the same as used in the Chapter 4
            Xb=Q*X;
            p=1;
            % paramter p can take here value different than 1
            % for example -1 or 2.
            N=max(size(Xb));
            Xb=Xb-kron(mean(Xb')',ones(1,N));
            
            Rxbxbp=(Xb(:,1:N-1)*Xb(:,2:N)')/(N-1);
            Rxbxbp= Rxbxbp+Rxbxbp';
            [Vxb Dxb]=eig(Rxbxbp);
            [D1 perm]=sort(diag(Dxb));
            D1=flipud(D1);
            Vxb=Vxb(:,flipud(perm));
            W = Vxb'*Q;
            y = Vxb' * Xb;%change Xb instead of x1
        end
    end
    
    
    
end
