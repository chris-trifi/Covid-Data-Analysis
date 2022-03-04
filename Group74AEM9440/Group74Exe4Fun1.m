%Trifinopoulos Christos
function [] = Group74Exe4Fun1(weekEU,countryEU,positivity_rateEU,level,country,fig)
n=length(positivity_rateEU);
weeks20=string(zeros(9,1));
week21=string(zeros(9,1));
WeeklyPos=zeros(9,2);

%create an array of strings with  all the weeks we need
for i = 1:9
   d=string(i+41);
   week20=strcat("2020-W",d);
   week21=strcat("2021-W",d);
   weeks20(i)=week20;
   weeks21(i)=week21;
end 

j=0;
k=0;
%iterate the data tables to extract the positivity rates for the specific
%weeks and store them in WeeklyPos
for i = 1:n
    if contains(countryEU(i),country) && level(i)=="national" %filter subnational data
        if contains(weekEU(i),weeks20)
            j=j+1;
            WeeklyPos(j,1)=positivity_rateEU(i);
        elseif contains(weekEU(i),weeks21)
            k=k+1;
            WeeklyPos(k,2)=positivity_rateEU(i);
        end       
    end
end


[h,p] = ttest2(WeeklyPos(:,1),WeeklyPos(:,2)); %test if they from populations with equal means.
if h==0
    fprintf('%s %s %f\n', country, ": ttest null hypothesis accepted with p=",p); %equal means.
elseif h==1
    fprintf('%s %s %f\n',country, ": ttest null hypothesis rejected with p=",p); %not equal means.
end

%create M=1000 bootstrap samples
M=1000;
bt=zeros(M,2); %for boxplots
btcomp=zeros(M,1); %for bootstrap comparison of mean values
comp=[WeeklyPos(:,1) ; WeeklyPos(:,2);];
for i=1:M
    R1 = unidrnd(j,j,1);
    R2 = unidrnd(k,k,1);
    R = unidrnd(j+k,j+k,1);
    xbV1 = WeeklyPos(R1,1);
    xbV2 = WeeklyPos(R2,2);
    xbV3=comp(R);
    new1=xbV3(1:j);
    new2=xbV3(j+1:j+k);
    bt(i,1) = mean(xbV1);
    bt(i,2) = mean(xbV2);
    btcomp(i) = mean(new1)-mean(new2);
end

m1=mean(WeeklyPos(:,1));
m2=mean(WeeklyPos(:,2));
ms=m1-m2;
btc=sort([btcomp ; ms]);
rank=find(btc==ms,1);
lower = prctile(btcomp,2.5); 
upper = prctile(btcomp,97.6); 

str=append(country,'(h=',string(h),')');

figure(fig-1)
histogram(btcomp)
xline(lower);
xline(upper);
xline(btc(rank),'--r','original sample');
xline(0,'-r');
title(str)



figure(fig)
boxplot(bt,{'2020','2021'})
title(str)
xlabel('Year')
ylabel('positivity rates(%)for weeks 42-50')

end

