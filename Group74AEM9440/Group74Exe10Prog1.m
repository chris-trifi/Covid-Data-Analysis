%Trifinopoulos Christos
dataGR=readtable('FullEodyData.xlsx');
cases=table2array(dataGR(1:end,2));
day=string(table2array(dataGR(1:end,1)));
deaths=table2array(dataGR(1:end,5));
DailyNewHospitalizations=table2array(dataGR(1:end,54)); %data till 26/12
DailyTubed=table2array(dataGR(1:end,7));

x1=DailyTubed(559:648); %27/9-27/12
y1=deaths(559:648);
n=length(y1);


m=n-30; %we start from day 31 so we can go 30 days back within our range
x=zeros(m,30); %cells store DailyTubed for day #column before day #(row+30)
for i = 31:n
    x(i-30,:)=x1(i-30:i-1); %for day 31 we store DailyTubed of days (1,2...,30) in columns of row 1
end
x28=[1 x1(n-29:n)']; % for predicting deaths at 28/12
xM=x;
x=[ones(m,1) x]; 
y=y1(31:n);

[b,~,~,~,stats] = regress(y,x);
R=stats(1);
pred28a=x28*b; 
Radj=Rsquare(y,x,30,b);

%30 predictor variables for 60 observations are too many
%a good ratio is around 1:10 (one in ten rule)
%stepwise add variables with Rsquare(adjusted) as our criterion.
Rmax=0;
xoptimal=ones(m,1);
inmodel=zeros(31,1);
while 1
    progress=0; 
    k=length(find(inmodel));
    for i=2:31
        if (inmodel(i)==0)
            xtemp=[xoptimal x(:,i)]; %add predictor variables one by one
            [betas,~,~,~,~] =regress(y,xtemp);
            [~,Radj]= Rsquare(y,xtemp,k+1,betas);
            if Radj>Rmax
                Rmax=Radj;
                add=i;
                progress=1; %improvement has been made, continue iterating
            end
        end
    end
    if progress==1
        xoptimal=[xoptimal x(:,add)];
        inmodel(add)=1;
    else
        break
    end
    %{
    if (length(find(inmodel))>5) %limit the amount of predictors
        break
    end 
    %}
end

inmodel(1)=1;
[betas,~,~,~,~] =regress(y,xoptimal);
vars=find(inmodel);
pred28b =x28(inmodel==1)*betas;


%use in-built bidirectional stepwisefit that also takes into account statistical significance
[b,~,~,inmodel,stats] = stepwisefit(xM,y);
my=mean(y);
b0 = stats.intercept;
pred = x * ([b0;b].*[1 inmodel]');
eV = y-pred;
k1 = sum(inmodel);
R2 = 1-(sum(eV.^2))/(sum((y-my).^2));
adjR2 =1-((m-1)/(m-(k1+1)))*(sum(eV.^2))/(sum((y-my).^2));
pred28c=x28 * ([b0;b].*[1 inmodel]');

fprintf('\nUse daily tubed numbers to predict deaths\n')
fprintf('\nPredicted deaths for 28/12(30-variable model): %0.1f \n',pred28a)
fprintf('R-square adjusted for the model: %0.4f \n',Radj)
fprintf('\nPredicted deaths for 28/12(forward stepwise model): %0.1f \n',pred28b)
fprintf('R-square adjusted for the model: %0.4f \n',Rmax)
fprintf('\nPredicted deaths for 28/12(bidirectional stepwise model): %0.1f \n',pred28c)
fprintf('R-square adjusted for the model: %0.4f \n',adjR2)
fprintf('Actual deaths for 28/12: 61 \n')


[X,Y] = meshgrid(200:20:800,200:20:800);
betas=b(find(inmodel));%#ok<*FNDSB>);
Z = b0+betas(1)*X + betas(2)*Y;
surf(X,Y,Z)
colorbar
xlabel('tubed 11 days back')
ylabel('tubed 30 days back')
zlabel('predicted deaths')
title('two variable model visualization')

figure(2)
plot(x1)
hold on
plot(y1*10)
legend('daily tubed','daily deaths(*10)')
title('Greece(01/06/21-31/08/21)')

%the stepwise models gave a lower Rsquare value than the complete
%30 variable model.Because have too many predictors the high Rsquare value is propably a 
%result of overfitting and not an indicator of a good model. The fact that the two 
%stepwise models predicted the deaths at 28/12 better supports this claim.

%note: the reduced 15-variable model has still a 1:4 variable-observation 
%ratio which means it is also kinda problematic(overfitting is possible).The fact that it predicts 
%the deaths at 28/12 better than the 2 variable model doesn't prove it is better. 


