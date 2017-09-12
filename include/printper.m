function msgL = printper(i,N,msgL)

per=100;
M=N/per;
if i<=M+1
if i/floor(M)==1 && i~=1  
  len = toc;
  fprintf('\t estimate total time needed: %d seconds\t\n',floor(len*per));
  fprintf('\t\t\t');
elseif i==1
    tic;
end
end

if mod(i,floor(M))==0 || i==N
    back = strcat(repmat('\b',1,msgL));
    fprintf(back);
    msg = strcat(num2str(floor(i/(M)*100/per)),'%%\tprocessing\n');
    msgL = length(char(msg))-3;
    fprintf(msg);
    if i==N
        fprintf('\n\t\tfinish!\n');
    end
    
end