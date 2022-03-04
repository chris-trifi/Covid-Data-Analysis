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
      X1(j)=positivity_rate(i); %X1 gets filled with values for week1(="2020-W46")
  else if TF2(i)==1
      k=k+1;
      if positivity_rate(i)>100
          positivity_rate(i)=100;
      end
      X2(k)=positivity_rate(i); %X1 gets filled with values for week2(="2021-W46")
   end     
  end
end

xbV=zeros((k+j),1);
A=zeros((k+j),1); %combined sample of X1 and X2
for i=1:j
    A(i)=X1(i);
end
for i=1:k
    A(i+j)=X2(i);
end


M=1000; %number bootstrap samples to be created
totalMax1=zeros(M,1);
for i=1:M
    R1 = unidrnd(k+j,k+j,1);
    xbV = A(R1,1); %new combined sample
    newX1=sort(xbV(1:j)); %new(&sorted) X1 sample taken from the combined sample
    newX2=sort(xbV(j+1:j+k)); %new(&sorted) X2 sample taken from the combined sample
    max=0;
    for m= 1:j
        n=newX1(m);%value in position m
        pos1=m; %ran of n in X1(new X1 is sorted)
        temp=sort(vertcat(newX2,n)); 
        pos2=find(temp==n ,1); %rank of n in X2
        Fx1=pos1/j; %cdf at x=n of the new X1 sample
        Fx2=pos2/(k+1); %cdf at x=n of the new X2 sample
        dif=abs(Fx1-Fx2); %the absolute difference between the two cdfs
        if dif>max
            max=dif; %find the Kolmogorov-Smirnov statistic for bootstrap sample with number i
        end
    end  
    totalMax1(i)=max; %store the result for each bootstrap sample
end

M=1000; %number samples to be created
totalMax2=zeros(M,1);
size=10;
for i=1:M
    new = datasample(A,2*size,'Replace',false);
    newX1 =sort(new(1:size));
    newX2 =sort(new(size+1:end));
    max=0;
    for m=1:size
        n=newX1(m);
        pos1=m; 
        temp=sort(vertcat(newX2,n)); 
        pos2=find(temp==n ,1);
        Fx1=pos1/size; 
        Fx2=pos2/(size+1);
        dif=abs(Fx1-Fx2);
        if dif>max
            max=dif;
        end
    end  
    totalMax2(i)=max; %store the result for each bootstrap sample
end

max=0;
X1=sort(X1);  
Fx1=zeros(124,1);
Fx2=zeros(124,1);
dif=zeros(124,1);
for m= 1:124
   n=X1(m);%value in position m
   pos1=m;
   temp=sort(vertcat(X2,n)); 
   pos2=find(temp==n ,1);
   Fx1(m)=pos1/124; 
   Fx2(m)=pos2/(k+1); 
   dif(m)=abs(Fx1(m)-Fx2(m));
   if dif(m)>max
      max=dif(m); %find the Kolmogorov-Smirnov statistic for bootstrap sample with number i
   end
end  

figure(1)
plot(Fx1)
hold on
plot(Fx2)
plot(dif)
xline(find(dif==max),'--r');
title('Kolmogorov-Smirnov(original samples)')
legend('first sample cdf','second sample cdf','difference of cdfs','max difference')


%the null hypothesis can be rejected if max>c(a)*sqrt((k+j)/(k*j))for significance level a

c5=1.358; %for a=0.05 we have c=1.358
c10=1.224;
limit5=c5*sqrt((k+j)/(k*j));
limit10=c10*sqrt((k+j)/(k*j));

figure(2)
hist(totalMax1);
lower = prctile(totalMax1,5); 
xline(limit5,'--r','limit');
xline(lower);
xline(max,'--r','Original sample');
title("Kolmogorov-Smirnov statistic distribution bootstraped with replacement")

lower5 = prctile(totalMax2,5); 
lower10 = prctile(totalMax2,10); 

figure(3)
hist(totalMax2);
xline(lower5,':b');
xline(max,'--','Original sample');
xline(limit5,'--','limit');
title("Kolmogorov-Smirnov statistic distribution sampled without replacement")
legend('distribution','5th percentile')

figure(4)
hist(totalMax2);
xline(lower10,':r');
xline(max,'--','Original sample');
xline(limit10,'--','limit');
title("Kolmogorov-Smirnov statistic distribution sampled without replacement")
legend('distribution','10th percentile')

fprintf('\n5%% significance:\n')
if limit5<=lower5 %we test the null hypothesis at the 5% significance level
    fprintf('%s\n', "null hypothesis rejected(the two samples do not come from the same propability distribution")
else 
    fprintf('%s\n', "null hypothesis accepted(the two samples come from the same propability distribution")
end

fprintf('\n10%% significance:\n')
if limit10<=lower10 %we test the null hypothesis at the 5% significance level
    fprintf('%s\n', "null hypothesis rejected(the two samples do not come from the same propability distribution)")
else
    fprintf('%s\n', "null hypothesis accepted(the two samples come from the same propability distribution)")
end

