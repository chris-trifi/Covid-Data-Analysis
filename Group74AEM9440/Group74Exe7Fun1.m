%Trifinopoulos Christos
function [best_delay20,best_delay21] = Group74Exe7Fun1(pos20,deaths20,pos21,deaths21)
%linear regression

a="here";

errors=zeros(11,1);
predicted_deaths=zeros(11,1);
rmse=zeros(5,1);
d=deaths20(6:16);
for i=1:5 %iterate for each delay scenario
   model=fitlm(pos20(6-i:16-i),d); %create regression model for corresponding delay
   betas=table2array(model.Coefficients); %get model coefficients
   for j= 6:16
    predicted_deaths(j-5)=betas(1,1)+betas(2,1)*pos20(j-i); %the two betas are b0 and b1.
   end
   figure(i)
   plot(predicted_deaths)
   hold on
   plot(d)
   errors=d-predicted_deaths;
   plot(errors)
   rmse(i)=sqrt((1/9)*sum(errors.^2) );
   legend("predicted deaths","real deaths", "error");
   t=strcat("delay =",string(i));
   title(t)
end
best_delay20=find(rmse==min(rmse));

d=deaths21(6:16);
for i=1:5
   model=fitlm(pos21(6-i:16-i),d);
   betas=table2array(model.Coefficients);
   for j= 6:16
    predicted_deaths(j-5)=betas(1,1)+betas(2,1)*pos21(j-i); 
   end
   figure(i+5)
   plot(predicted_deaths)
   hold on
   plot(d)
   errors=d-predicted_deaths;
   plot(errors)
   rmse(i)=sqrt((1/9)*sum(errors.^2) );
   legend("predicted deaths","real deaths", "error");
   t=strcat("delay =",string(i));
   title(t)
end
best_delay21=find(rmse==min(rmse));
end

