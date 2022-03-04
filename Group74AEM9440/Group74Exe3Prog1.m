%Trifinopoulos Christos 
dataEU=readtable('ECDC-7Days-Testing.xlsx');
dataGR=readtable('FullEodyData.xlsx');

cases=table2array(dataGR(1:end,2));%GR
pcr=table2array(dataGR(1:end,45));%GR
rapid=table2array(dataGR(1:end,46));%GR
weekGR=table2array(dataGR(1:end,51));
weekEU=table2array(dataEU(1:end,3));
positivity_rateEU=table2array(dataEU(1:end,11));

%the following lines give us that for Latvia the peak was at 2021-W42
%{
countryEU=table2array(dataEU(1:end,1));
TF5= contains(countryEU,"Latvia");
max=0;
n=length(positivity_rateEU);
for i = 1:n
    if (TF5(i)==1 && positivity_rateEU(i)>max)
        max=positivity_rateEU(i);
        targetweek=weekEU(i);
    end
end
%}


e=zeros(42,2);
for i = 31:42
   d=string(i);
   week=strcat("2021-W",d);
   [GRpos,EUpos,isWithin,difference]=Group74Exe3Fun1(cases,pcr,rapid,weekGR,weekEU,positivity_rateEU,week);
   e(i,1)=GRpos;
   e(i,2)=EUpos;
end     

clf
plot(e,'-o');
legend('GR','EU')
xlabel('week');
ylabel('Positivity Rate(%)');
axis([31 42 0 inf]);


%Group74Exe3Fun1 returns the positivity rates of EU and GR for a given week

%isWithin is zero if the EU Rate is within the 95% interval GR positivity rate for that
%week and one otherwise

%difference returns the difference between the EU rate and the mean of the GR
%rate









