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
target2=["09/2021","10/2021","11/2021"];
TF1 = contains(day,target1);
TF2 = contains(day,target2);
a=find(TF1);
b=find(TF2);
c=length(a);
d=length(b);
deaths1=deaths(a); %#ok<*FNDSB>
deaths2=deaths(b);
rapid1=rapid(a);
rapid2=rapid(b);
pcr1=pcr(a);
pcr2=pcr(b);
cases1=cases(a);
cases2=cases(b);
positivity_rate1=zeros(c,1);
positivity_rate2=zeros(d,1);
positivity_rate1(1)=cases1(1)*100/(rapid1(1)+pcr1(1)-5069902-4450663);
positivity_rate2(1)=cases2(1)*100/(rapid2(1)+pcr2(1)-6220739-9299398);

for i= 2:c
    dailytests=pcr1(i)+rapid1(i)-pcr1(i-1)-rapid1(i-1);
    positivity_rate1(i)= cases1(i)*100/dailytests;
end

for i= 2:d
    dailytests=pcr2(i)+rapid2(i)-pcr2(i-1)-rapid2(i-1); 
    positivity_rate2(i)=cases2(i)*100/dailytests;
end   
    

past30_1=zeros(c-30,30); %stores the positivity rate of the past 30 days for each day (day31-day92)
for i = 31:c
  for j=1:30  
    past30_1(i-30,j)=positivity_rate1(i-j);  
  end 
end

past30_2=zeros(d-30,30); %stores the positivity rate of the past 30 days for each day (day31-day92)
for i = 31:d
  for j=1:30  
    past30_2(i-30,j)=positivity_rate2(i-j);  
  end 
end

%we have a matrix for each given period where the rows represent days and
%the columns store the positivity rate for x days before the day of the row
%where x is the number of the column. (row 1 represents day 31 so we can go back up to 30 days) 



y1=deaths1(31:c); 
x1=[ones(c-30,1) past30_1];
y2=deaths1(31:d); 
x2=[ones(d-30,1) past30_2];
bcoefs1 = regress(y1,x1);
bcoefs2 = regress(y2,x2);
[~,Radj1]= Rsquare(y1,x1,30,bcoefs1);
[~,Radj2]= Rsquare(y2,x2,30,bcoefs2);
%the coefficients are for the model going 30 days back without any
%dimension reduction

%PCA
cent1 = past30_1 - repmat(mean(past30_1),c-30,1); %subtract the mean of each column from each column(centering)
cent2 = past30_2 - repmat(mean(past30_2),d-30,1);
    
cov1= cov(cent1);  
cov2= cov(cent2); 

[eigvec1,eigval1] = eig(cov1);
[eigvec2,eigval2] = eig(cov2);
eigvec1=fliplr(eigvec1);
eigvec2=fliplr(eigvec2);
    
eigvalV1 = flipud(diag(eigval1)); 
eigvalV2 = flipud(diag(eigval2)); 

x=(1:30)';
clf
figure(1)
plot(x,eigvalV1,'ko-')
yline(mean(eigvalV1));
title('Scree Plot for first period')
xlabel('index')
ylabel('eigenvalue')

figure(2)
plot(x,eigvalV2,'ko-')
yline(mean(eigvalV2));
title('Scree Plot for second period')
xlabel('index')
ylabel('eigenvalue')

%get the new number of dimansions
dim1=length(find(eigvalV1>mean(eigvalV1)));
dim2=length(find(eigvalV2>mean(eigvalV2)));

coeff1 = pca(past30_1); %returns the eigenvectors I have already calculated
coeff2 = pca(past30_2);
pM1 = coeff1 (:,1:dim1); %chosen eigenvectors given by pca(X) for first period
pM2 = coeff2 (:,1:dim2); %chosen eigenvectors given by pca(X) for second period
temp= eigvec1;
pM3=temp(:,1:dim1); %chosen eigenvectors I calculated for first period

    

%calculate the new features
z1 = cent1*pM1;
z2 = cent2*pM2;
z3 = cent1*pM3;
%keep only the important ones
z1X =z1(:,1:dim1); 
z2X =z2(:,1:dim2);
z3X =z3(:,1:dim1);

x1=[ones(c-30,1) z1X];
x2=[ones(d-30,1) z2X];
x3=[ones(c-30,1) z3X];
bcoefs1d = regress(y1,x1);
bcoefs2d = regress(y2,x2);
bcoefs3d = regress(y1,x3);
[~,Radj1d]= Rsquare(y1,x1,dim1,bcoefs1d);
[~,Radj2d]= Rsquare(y2,x2,dim2,bcoefs2d);
[~,Radj3d]= Rsquare(y1,x3,dim1,bcoefs3d);


%observation: the matlab function pca(X) returns eigenvectors with reversed
%signs for even numbered columns(compared to the eigenvectors I calculated)
%but we get the same regression results Radj1d=Radj3d

fprintf('First period before dimension reduction: Radjusted=%0.4f\n',Radj1)
fprintf('First period after dimension reduction: Radjusted=%0.4f\n',Radj1d)
fprintf('Second period before dimension reduction: Radjusted=%0.4f\n',Radj2)
fprintf('Second period after dimension reduction: Radjusted=%0.4f\n',Radj2d)

%note: the observations in Exe9 showed that our data set is flawed and
%indicate that the good Rsquare values here are a result of noise fitting.
    
    
    