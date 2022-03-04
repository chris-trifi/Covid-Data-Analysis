%Trifinopoulos Christos
data=readtable('ECDC-7Days-Testing.xlsx');
dates=table2array(data(1:end,3));
positivity_rate=table2array(data(1:end,11));
L = length(dates);
week1="2020-W46"; 
week2="2021-W46";

TF1 = contains(dates,week1);
TF2 = contains(dates,week2);
count1=sum(TF1==1);
count2=sum(TF2==1);
X1=zeros(count1,1);
X2=zeros(count2,1);
j=0 ; 
k=0 ;

%fill the X1,X2 arrays with the positivity rates of the corresponding weeks
for i=1:L
  if TF1(i)==1
      j=j+1;
      X1(j)=positivity_rate(i);
  else if TF2(i)==1
      k=k+1;
      if positivity_rate(i)>100
          positivity_rate(i)=10;
      end
      X2(k)=positivity_rate(i);
   end     
  end
end

%illustrating the data
figure(1);
histfit(X1,20,'Exponential');;
title("positivity rates distribution across europe for W46-2020")
figure(2);
histfit(X2,30,'Exponential');;
title("positivity rates distribution across europe for W46-2021")

%the histograms indicate that the distribution is exponential
pd1 = fitdist(X1,'Exponential');
h1 = chi2gof(X1,'CDF',pd1);
pd2 = fitdist(X2,'Exponential');
h2 = chi2gof(X2,'CDF',pd2);

pd2 = fitdist(X2,'Lognormal');
h2log = chi2gof(X2,'CDF',pd2);
pd2 = fitdist(X2,'Weibull');
h2wb = chi2gof(X2,'CDF',pd2);
pd2 = fitdist(X2,'Gamma');
h2gm = chi2gof(X2,'CDF',pd2);
pd2 = fitdist(X2,'Generalized Extreme Value');
h2gev = chi2gof(X2,'CDF',pd2);

fprintf('Hypothesis: Data for W46-2020 fits exponential distribution\nResult: %d\n',h1)
fprintf('Hypothesis: Data for W46-2021 fits exponential distribution\nResult: %d\n',h2)
fprintf('Hypothesis: Data for W46-2021 fits Lognormal distribution\nResult: %d\n',h2log)
fprintf('Hypothesis: Data for W46-2021 fits Weibull distribution\nResult: %d\n',h2wb)
fprintf('Hypothesis: Data for W46-2021 fits Gamma distribution\nResult: %d\n',h2gm)
fprintf('Hypothesis: Data for W46-2021 fits Generalized Extreme Value distribution\nResult: %d\n',h2gev)


[h,p] = kstest2(X1,X2);

if (h==1) %we test the null hypothesis at the 5% significance level
    fprintf('%s\n', "null hypothesis rejected(the two samples do not come from the same propability distribution")
else
    fprintf('%s\n', "null hypothesis accepted(the two samples come from the same propability distribution")
end


%in Group74Exe2Prog1 I implement a bootstrap test of the Kolmogorov-Smirnov
%test for the same data






