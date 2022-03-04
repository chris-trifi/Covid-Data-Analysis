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

X=zeros(13,2);
Y=zeros(13,2);
X(:,1) = Group74Exe5Fun2(rapid,pcr,cases,weekGR);
X(:,2)=X(:,1);
Y(:,1) = Group74Exe5Fun1(weekEU,countryEU,positivity_rateEU,level,"Ireland");
Y(:,2) = Group74Exe5Fun1(weekEU,countryEU,positivity_rateEU,level,"Lithuania");

comp=zeros(26,2); %in 1:13 we store the first sample and in 14:26 the second
for i=1:13 %pairs for Ireland
    comp(i,1)=X(i,1);%GR
    comp(i,2)=Y(i,1);
end
for i=1:13 %pairs for Lithuania
    comp(i+13,1)=X(i,2);%GR
    comp(i+13,2)=Y(i,2);
end

dif=zeros(1000,1);
xbV=zeros(26,2);
Rc1=zeros(1000,1);
Rc2=zeros(1000,1);
for i=1:1000
    R1 = unidrnd(26,26,1);
    xbV(:,1) = comp(R1,1); 
    xbV(:,2) = comp(R1,2); %for the same R1 so we keep the pairs together
    new1=xbV(1:13,:); %new for Ireland/GR
    new2=xbV(14:26,:); %new for Lithuania/GR
    R1 = corrcoef(new1(:,2),new1(:,1)); 
    R2 = corrcoef(new2(:,2),new2(:,1));
    Rc1(i)=R1(1,2);
    Rc2(i)=R2(1,2);
    dif(i)=Rc1(i)-Rc2(i);
end


lower = prctile(dif,2.5); 
upper = prctile(dif,97.6); 
r1=corrcoef(Y(:,1),X(:,1)); %Ireland
r2=corrcoef(Y(:,2),X(:,1)); %Lithuania
r=r1(1,2)-r2(1,2);
dif2=sort([dif ; r]);
rank=find(dif2==r,1);

figure(1)
histogram(dif)
xline(lower);
xline(upper);
xline(dif2(rank),'--r','original sample');
xline(0,'-r');
title('distribution of difference between the two correlation coefficients')


if (lower<dif2(rank) && upper>dif2(rank))
    fprintf('%s\n', 'Difference is NOT statistically significant at 5%')
else
    fprintf('%s\n', 'Difference is statistically significant at 5%')
end





























