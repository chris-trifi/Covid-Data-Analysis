%Trifinopoulos Christos
dataEU=readtable('ECDC-7Days-Testing.xlsx');
dataGR=readtable('FullEodyData.xlsx');
weekEU=table2array(dataEU(1:end,3));
countryEU=table2array(dataEU(1:end,1));
positivity_rateEU=table2array(dataEU(1:end,11));
level=table2array(dataEU(1:end,4)); 

cases=table2array(dataGR(1:end,2));%GR
pcr=table2array(dataGR(1:end,45));%GR
rapid=table2array(dataGR(1:end,46));%GR
weekGR=table2array(dataGR(1:end,51)); %GR
EUpos=zeros(5,13);
countries=["Ireland","Italy","Latvia","Lithuania","Netherlands"];
[GRpos] = Group74Exe5Fun2(rapid,pcr,cases,weekGR); %returns an array with the positivity rate of GR for the 13 weeks
figure(1)
plot(GRpos-mean(GRpos),'-o');
title("POSITIVITY RATES(centered)")
xlabel("week(38-50)")
ylabel("positivity rate")
hold on
cor=zeros(5,1);

for i =1:5
    [WeeklyPos] = Group74Exe5Fun1(weekEU,countryEU,positivity_rateEU,level,countries(i));
    EUpos(i,:)=WeeklyPos;
    figure(1)
    plot(WeeklyPos-mean(WeeklyPos),'-o');
    [R1,P1,RL1,RU1] = corrcoef(WeeklyPos,GRpos,'Alpha',0.01);%correlation coefficient at a=0.01
    [R,P,RL,RU] = corrcoef(WeeklyPos,GRpos);%correlation coefficient at deafult a=0.05
    pvalue=P(1,2);
    upper=RU(1,2);%ci  
    lower=RL(1,2);%ci
    cor(i)=R(1,2);
    if pvalue<0.01 %test if p is low enough to reject the null hypothesis (H0= there is no significant correlation)
        result1="correlation is significant";
        result="correlation is significant";
    elseif pvalue>0.05
         result1="correlation is not significant";
         result="correlation is not significant";
    else 
        result1="correlation is not significant";
        result="correlation is significant";
    end
    %the null hypothesis is accepted when 0 is within the CI.
    fprintf('\n%s: Correlation coefficient= %0.4f\n', countries(i), cor(i))
    fprintf('0.05%%:%s, ci:(%0.4f,%0.4f)\n',result, lower,upper)
    fprintf('0.01%%:%s, ci:(%0.4f,%0.4f)\n',result1,RL1(1,2),RU1(1,2))
    fprintf('p-value=%0.4f\n',pvalue)
    xbV=zeros(13,2);
    total=zeros(1000,1);
    for m=1:1000
        R2 = unidrnd(13,13,1);
        xbV(:,1) = WeeklyPos(R2); 
        xbV(:,2) = GRpos(R2);
        [R3] = corrcoef(xbV(:,2),xbV(:,1)); 
        total(m)=R3(1,2);
    end
    figure(i+1)
    hist(total)
    lower = prctile(total,2.5);
    upper = prctile(total,97.6); 
    xline(lower); %visualise the CI
    xline(upper); %visualise the CI
    xline(0,'-r');
    title(countries(i))
end

figure(1)
legend("Greece","Ireland","Italy","Latvia","Lithuania","Netherlands")

%I present the results of the parametric tests in the terminal and the
%results of the bootstrap tests in the histograms of the correlation
%coefficient values. The two tests give aproximatelly equal results, as
%expected.







