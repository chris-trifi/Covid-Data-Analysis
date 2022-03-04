%Trifinopoulos Christos
dataGR=readtable('FullEodyData.xlsx');
cases=table2array(dataGR(1:end,2));
pcr=table2array(dataGR(1:end,45));
rapid=table2array(dataGR(1:end,46));
day=string(table2array(dataGR(1:end,1)));
deaths=table2array(dataGR(1:end,5));
m=length(pcr);
%replace Nans with zeros so we can perform addition without losing data
for i=1:m
    if isnan(rapid(i))
        rapid(i)= 0;
    end
    if isnan(pcr(i))
        pcr(i)=0;
    end
end

target1=["06/2021","07/2021","08/2021"];
TF1 = contains(day,target1);
a=find(TF1);
c=length(a);
deaths1=deaths(a); 
rapid1=rapid(a);
pcr1=pcr(a);
cases1=cases(a);
positivity_rate1=zeros(c,1);
positivity_rate1(1)=cases1(1)*100/(rapid1(1)+pcr1(1)-5069902-4450663);

for i= 2:c
    dailytests=pcr1(i)+rapid1(i)-pcr1(i-1)-rapid1(i-1);
    positivity_rate1(i)= cases1(i)*100/dailytests;
end

past30_1=zeros(c-30,30); %stores the positivity rate of the past 30 days for each day (day31-day92)
for i = 31:c
  for j=1:30  
    past30_1(i-30,j)=positivity_rate1(i-j);  
  end 
end


past30_1=past30_1(1:60,:);
y=deaths1(31:c-2); 

%reduce dimensions(nescessary, we have more variables than
%observations
[coeff,~,~,~,explained] = pca(past30_1);
reduce=coeff(:,find(explained>mean(explained)));%#ok<FNDSB>
%reduce=coeff(:,[1;2;3;4;5;]);  %if we want to keep specific number
ReducedCoeffs=(past30_1)*reduce;



for k=1:2
    switch k
        case 1
           past=past30_1; %without dimension reduction
           p=30;
           fprintf('Without dimension reduction: \n')
        case 2
           past=ReducedCoeffs; %with dimension reduction
           p=length(reduce(1,:));
           fprintf('\nWith dimension reduction: \n')
    end  
    a=1;
    Rtrain=zeros(5,1);
    Rvalidate=zeros(5,1);
    for i=1:5
        validate=past(a:(12*i),:);
        yval=y(a:12*i);
        if i==1
            ytrain=y(13:60);
            train=past(13:60,:);
        elseif i==5
            ytrain=y(1:48);
            train=past(1:48,:);
        else
        ytrain=[y(1:a-1) ; y(12*i+1:60)];
        train=[past(1:a-1,:) ; past(12*i+1:60,:)];
        end
        a=12*i+1;
        train=[ones(48,1) train];
        validate=[ones(12,1) validate];
        [b,~,~,~,stats]=regress(ytrain,train);
        [R,Radj]= Rsquare(yval,validate,p,b);
        fprintf('%d\nTraining set Radjusted=%0.4f \nValidation set Radjusted=%0.4f \n',i,stats(1),Radj)
        figure(i+5*(k-1))
        plot(yval)
        hold on
        plot(validate*b)
        legend('actual','predicted')
    end
end

figure(11)
SevenDayAvg=zeros(60,1);
for i=31:c
    mean(positivity_rate1(i-6:i));
    SevenDayAvg(i)=mean(positivity_rate1(i-6:i));
end
plot(SevenDayAvg(31:c))
hold on
plot(positivity_rate1(31:c))
legend('average of past 7 days','daily value')
title('noise: high magnitude weekly spikes in positivity rate')

%Before dimension reduction we have too many predictor variables compared to our training set
%which means that we propably have overfitting.(For this reason we have
%high Rsquare values)
%We apply PCA analysis to reduce the number of dimensions to 7

%R-squared takes negative values for the validation set even when I apply dimension
%reduction(for 7 or even less principal components)
%the results indicate that the models are terrible at predicting the values
%of the testing set (worse than using its mean as our model).Since reducing dimension 
%didn't solve the problem there is an issue with our data set.

%Conclusion: The daily positivity rate is not a usefull predictor for the amount
%of deaths. The training set fits well only because it models the random
%noise. By plotting the positivity rate for the specific period we can
%observe an issue that might be causing this: There is a spike every seven
%days in the positivity rates(by examining the data closer we see that the
%amount of tests done every sunday-monday is very small so we get high positivity
%rates). Those spikes act as high-variance noise, since they provide no information
%that can help predict the deaths, significantly affecting the coefficients of
%our model. (The variance of the positivity rate is very low compared to the 
%variance caused by the weekly spikes)
