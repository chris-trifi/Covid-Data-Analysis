%Trifinopoulos Christos
%returns GR positivity rate for weeks 38-50 of 2021
function [GRpos] = Group74Exe5Fun2(rapid,pcr,cases,weekGR)

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
%calculate Positivity rate for Greece (daily&weekly)
weeks=string(zeros(13,1));
GRpos=zeros(13,1);

for i = 1:13
   d=string(i+37);
   weeks(i)=strcat("2021-W",d);
end 

for j= 1:13 %repeat for weeks 38-50
    dailyRates = zeros(7,0); %initialize the array to store this weeks' daily positivity rates
    dailytests=0;
    dailycases=0;
    div=1;
    for i = 1:m   %iterate all rows to keep the days belonging to this week 
        if contains(weekGR(i),weeks(j))
            dailytests=dailytests+pcr(i)+rapid(i)-pcr(i-1)-rapid(i-1);
            dailycases=dailycases+cases(i);
            positivity_rate_Today=dailycases*100/dailytests; %calculate positivity rate for a given day
            div=div+1;
            dailyRates(div)=positivity_rate_Today; %store the daily rate in the array 
            div=div+1;
        end
        if div == 7  %no week can have more than 7 days
            break  
        end
    end
    if div == 0  %don't divide by zero
            continue  
    end
    GRpos(j)=sum((dailyRates)/div); %positivity rate for week (j+37)
end









end

