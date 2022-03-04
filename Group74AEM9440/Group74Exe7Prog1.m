%Trifinopoulos Christos
data=readtable('deaths.xlsx');
datapos=readtable('ECDC-7Days-Testing.xlsx');
weeks=table2array(data(3002:3109,3));
posweek=table2array(datapos(6577:6666,3));
deathsLVA=table2array(data(3002:3109,6));
positivity_rateLVA=table2array(datapos(6577:6666,11));
n=length(deathsLVA);
m=length(positivity_rateLVA);

for i=1:m
    if isnan(positivity_rateLVA(i))
        positivity_rateLVA(i)=0;
    end
end

%I choose weeks 14-30
weeks20=string(zeros(16,1));
weeks21=string(zeros(16,1));
pos20=(zeros(16,1));
pos21=(zeros(16,1));
deaths20=(zeros(16,1));
deaths21=(zeros(16,1));

for i = 1:16
   b=string(i+13);
   weeks20(i)=strcat("2020-W",b);
   weeks21(i)=strcat("2021-W",b);
   deaths20(i)=deathsLVA(i+13);
   deaths21(i)=deathsLVA(i+66);
   pos20(i)=positivity_rateLVA(i+13);
   pos21(i)=positivity_rateLVA(i+53);
end
[best_delay20,best_delay21] = Group74Exe7Fun1(pos20,deaths20,pos21,deaths21);

fprintf('The best delay for the first interval is %d week(s).\n',best_delay20)
fprintf('The best delay for the second interval is %d week(s).',best_delay21)

figure(11)
plot(deaths20)
hold on
plot(pos20*100)
title(2020)
legend("deaths","positivity rate(*100)")
figure(12)
plot(deaths21)
hold on
plot(pos21*100)
title(2021)
legend("deaths","positivity rate(*100)")

%{
figure(13)
scatter(deaths20,pos20);
ylabel("positivity rate(%)")
xlabel("deaths")
title(2020)
figure(14)
scatter(deaths21,pos21);
ylabel("positivity rate(%)")
xlabel("deaths")
title(2021)
%}















