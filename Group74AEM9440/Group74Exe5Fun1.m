%Trifinopoulos Christos
%returns positivity rate for weeks 38-50 of 2021 for a given country
function [WeeklyPos] = Group74Exe5Fun1(weekEU,countryEU,positivity_rateEU,level,country)


n=length(positivity_rateEU);
weeks21=string(zeros(13,1));
WeeklyPos=zeros(13,1);

%create an array of strings with  all the weeks we need
for i = 1:13
   d=string(i+37);
   weeks21(i)=strcat("2021-W",d);
end 

j=0;
%iterate the data tables to extract the positivity rates for the specific
%weeks and store them in WeeklyPos
for i = 1:n
    if contains(countryEU(i),country) && level(i)=="national" %filter subnational data
        if contains(weekEU(i),weeks21)
            j=j+1;
            WeeklyPos(j)=positivity_rateEU(i);
        end       
    end
end


end

