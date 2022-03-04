%Trifinopoulos Christos 
function [GRpos,EUpos,output3,output4] =Group74Exe3Fun1(cases,pcr,rapid,weekGR,weekEU,positivity_rateEU,week)
n=length(positivity_rateEU);
m=length(rapid);

%replace Nans with zeros so we can perform addition without losing data
for i=1:m
    if isnan(rapid(i))
        rapid(i)= 0;
    end
    if isnan(pcr(i))
        pcr(i)=0;
    end
end

for i=1:n
    if isnan(positivity_rateEU(i))
        positivity_rateEU(i)=0;
    end
end

%calculate EU positivity rate mean for given week
total=0;
div=0;
TF1 = contains(weekEU,week);
for i = 1:n
    if TF1(i)==1
        total=total+positivity_rateEU(i);
        div=div+1;
    end
end

if div==0
    error('no data for this week'); %avoid diviosion by zero
end

EUpos=total/div;  %weekly positivity rate for EU    

%calculate Positivity rate for Greece (daily&weekly)
total=0;
div=0;
dailytests=0;
dailycases=0;
dailyRates = zeros(7,0);
fprintf('%s\n', week);
TF2 = contains(weekGR,week);

for i = 1:m
    if TF2(i)==1
        dailytests=dailytests+pcr(i)+rapid(i)-pcr(i-1)-rapid(i-1);
        dailycases=dailycases+cases(i);
        positivity_rate_Today=dailycases*100/dailytests;%calculate positivity rate for a given day
        div=div+1;
        dailyRates(div)=positivity_rate_Today; %store the daily rate in the array 
    end
    if div == 7  %no week can have more than 7 days
        break  
    end
end

GRpos=sum(dailyRates)/div; %weekly positivity rate for Greece

%bootstrap calculation of 95% confidence interval for GR
M=1000;
n=div;
for j=1:M
    R = unidrnd(n,n,1);
    xbV = dailyRates(R);
    bt(j) = mean(xbV);
end
lower = prctile(bt,2.5);
upper = prctile(bt,97.6);


%check if EU mean is within the GR 95% confidence interval
if ( EUpos>lower && EUpos<upper )
    fprintf('%s\n', "there is no statistical significance in the difference between EU and GR rates")
    output3=1;
else
    fprintf('%s\n',"there is statistical significance in the difference between EU and GR rates")
    output3=0;
end
output4=GRpos-EUpos; %difference between GR and EU positivity rates

end

