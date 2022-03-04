%Trifinopoulos Christos
dataEU=readtable('ECDC-7Days-Testing.xlsx');
weekEU=table2array(dataEU(1:end,3));
countryEU=table2array(dataEU(1:end,1));
positivity_rateEU=table2array(dataEU(1:end,11));
level=table2array(dataEU(1:end,4)); 

countries=["Ireland","Italy","Latvia","Lithuania","Netherlands"];

fprintf('H0: Same positivity rate mean for 2020,W42-50 & 2021,W42-50 \n\n')
%test for all five countries
for i = 1:length(countries)
    Group74Exe4Fun1(weekEU,countryEU,positivity_rateEU,level,countries(i),2*i);
end


%the bootstrap test results are visualized and the results of the
%parametric testa appear on the title and the command window. The agreement
%of the two methods can be confirmed by the observation that the difference
%of means in the initial sample is within the 95% interval of the bootstrap
%samples for the countries that ttest null hypothesis was accepted.

%incomplete data for Latvia(bootstraped out of only 2 samples) may give
%inaccurate results. 

%For the bootstrap test, the null hypothesis is that for the given country, the mean of 
%the positivity rate is the same for the two periods(W42-50 of 2020 and w42-50 of 2021)

%the parametric test also assumes a normal distribution for the positivity
%rate and returns a decision on the same hypothesis

%I also bootstraped the positivity rate for each period individually and created
%boxplot to visualize their distributions.
