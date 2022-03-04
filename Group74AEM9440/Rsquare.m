function [R,Radj]= Rsquare(y,x,degrees,betas)
n=length(y); %the number of observations we got
k=degrees; %of freedom
adj=(n-1)/(n-k-1);
m=mean(y);

yfit = x*betas;
error = y - yfit; %vector containing errors between predicted and actual y values
SSR = sum(error.^2);
SST = sum((y-m).^2);

R=1-(SSR/SST);
Radj=1-(SSR/SST)*adj;

end