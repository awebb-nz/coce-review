%% Analysis of cost of control task data 
% meant to be posted on MTurk
% task written in JsPsych, data printed in CSV form
% Throughout this entire script, task 1 is the easier task (detection) and
% task 2 is the harder task (combine)
%% Process raw jspsych text file data
clear all
cutoff = 80;
tasks = [categorical(cellstr('detection'));categorical(cellstr('combine')); categorical({'pswitch0.1'}); categorical({'pswitch0.9'})];
tasklabels = {'detection','combine','pswitch=0.1','pswitch0.9'};
hardtasks = [tasks(2) tasks(4)];

files = string(ls('./data')); files(1:2) = []; %trim directory entries
files = files(contains(files,'.mat'));
files = {'11.02.2020.mat','12.02.2020_trial.mat','13.02.2020_trial.mat'};
subjs = [];long_format = [];
for i = 1:length(files)
    file = files{i};
    raw =  load(['./data/'  file]);
    raw.Untitled.TOT = double(string(raw.Untitled.TOT));
    raw.Untitled.total_points = double(string(raw.Untitled.total_points));
    raw.Untitled.stimnum = double(string(raw.Untitled.total_points));
    raw.Untitled.prob_switch = double(string(raw.Untitled.prob_switch));
    raw.Untitled.rule = double(string(raw.Untitled.rule));
    %replace problem variables with doubles
    long_format = [long_format; raw.Untitled];
    %pull all the data into one long table
end
subjs = unique(long_format.subjnum(~isnan(long_format.subjnum)));

% process individual subjects, exclude subjects who are kicked out early,
% combine datasets into one big table
group = table; excluded = table;
for i = 1:length(subjs)
    subj = subjs(i);
    raw_data = long_format(long_format.subjnum == subj,:);
    [single,failed_counts] = make_data_table(raw_data);
    if single.failed %separate people who got kicked out early
        excluded = [excluded; failed_counts];
    else
        group = [group; single];
    end
end

n = height(group);
data = group;
nbackacc = data.nbackacc;
detectacc = data.detectacc;
nswitch1acc = data.nswitch1acc;
nswitch9acc = data.nswitch9acc;
task_progression = data.task_progression;
TOT = data.TOT;
detectrts = data.detectrts;
nbackrts = data.nbackrts;
nswitch9rts = data.nswitch9rts;
nswitch1rts = data.nswitch1rts;
perf_by_block = data.perf;
values = data.values;
BDM_rt = data.BDMrt;
version = data.version;
n1 = sum(version==1);
n2 = sum(version==2); %specific n's for graphing/useful to have

tasks_overall = [nanmean(data.detectacc,2) nanmean(data.nbackacc,2) nanmean(data.nswitch1acc,2) nanmean(data.nswitch9acc,2)];
tasks_rts = [nanmean(data.detectrts,2) nanmean(data.nbackrts,2) nanmean(data.nswitch1rts,2) nanmean(data.nswitch9rts,2)];

combineswitchrts = data.combineswitchrts;

combineswitchcosts = []; nswitchswitchcosts = [];
for row = 1:n
    combineswitchcosts = [combineswitchcosts; nanmean(data.combineswitchcosts{row})];
    nswitchswitchcosts = [nswitchswitchcosts; nanmean(data.allnswitchcosts{row})];
end

%% Plot some stuff
figure
subplot(1,2,1)
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
bar([nanmean(tasks_overall(:,1)) nanmean(tasks_overall(:,2)) nanmean(tasks_overall(:,3)) nanmean(tasks_overall(:,4))])
hold on
errorbar(1:4,[nanmean(tasks_overall(:,1)) nanmean(tasks_overall(:,2)) nanmean(tasks_overall(:,3)) nanmean(tasks_overall(:,4))],[nanstd(tasks_overall(:,1))/sqrt(n1) nanstd(tasks_overall(:,2))/sqrt(n1) nanstd(tasks_overall(:,3))/sqrt(n2) nanstd(tasks_overall(:,4))/sqrt(n2)],'k*','LineWidth',2)
xticklabels({'Detection','Combine','N-Switch p=0.1','N-Switch p=0.9'})
xtickangle(45)
ylim([50 100])
title(['Accuracy by task'])

subplot(1,2,2)
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
bar([nanmean(tasks_rts(:,1)) nanmean(tasks_rts(:,2)) nanmean(tasks_rts(:,3)) nanmean(tasks_rts(:,4))])
hold on
errorbar(1:4,[nanmean(tasks_rts(:,1)) nanmean(tasks_rts(:,2)) nanmean(tasks_rts(:,3)) nanmean(tasks_rts(:,4))],[nanstd(tasks_rts(:,1))/sqrt(n1) nanstd(tasks_rts(:,2))/sqrt(n1) nanstd(tasks_rts(:,3))/sqrt(n2) nanstd(tasks_rts(:,4))/sqrt(n2)],'k*','LineWidth',2)
xticklabels({'Detection','Combine','N-Switch p=0.1','N-Switch p=0.9'})
xtickangle(45)
title(['Mean log(RT) by task'])

figure
subplot(1,2,1)
ax = gca; fig = gcf;
passingnback = (perf_by_block>cutoff&(task_progression==tasks(2)|task_progression==tasks(4))); passingnback = [false(n,1) passingnback(:,1:end-1)]; %offset by 1
passingdetect = (perf_by_block>cutoff&(task_progression==tasks(1)|task_progression==tasks(3))); passingdetect = [false(n,1) passingdetect(:,1:end-1)]; %offset by 1
neither = ~passingnback&~passingdetect;

init = NaN(1,length(perf_by_block));
for j = 1:n
    hold on
    bluevalues = init;
    bluevalues(passingnback(j,:)) = values(j,passingnback(j,:));
    purplevalues = init;
    purplevalues(passingdetect(j,:)) = values(j,passingdetect(j,:));
    redvalues = init;
    redvalues(neither(j,:)) = values(j,neither(j,:));
    plot(bluevalues,'o','MarkerFaceColor','b')
    plot(purplevalues,'o','MarkerFaceColor','m')
    plot(redvalues,'o','MarkerFaceColor','r')
    bundle(j,:,1) = bluevalues; bundle(j,:,2) = purplevalues; bundle(j,:,3) = redvalues;
end

%errorbar(nanmean(values),nanstd(values)/sqrt(n),'k','LineWidth',2)
% too variable for now, too
% lines for later, too messy now given how few data points we have in each
% condition
% errorbar(nanmean(bundle(:,:,1),1),nanstd(bundle(:,:,1))/sqrt(n),'b','LineWidth',1)
% errorbar(nanmean(bundle(:,:,2),1),nanstd(bundle(:,:,2))/sqrt(n),'m','LineWidth',1)
% errorbar(nanmean(bundle(:,:,3),1),nanstd(bundle(:,:,3))/sqrt(n),'r','LineWidth',1)
fig.Color = 'w';
ax.FontSize = 12;
title(['Points by BDM round'])
xlabel('Block #')
ylabel('Points requested')
legend({'Passed Combine','Passed Detection','Did not Pass'},'Location','Best')

% RT plot same as ^
% RT plot for BDM request by passing/not passing round before
subplot(1,2,2)
ax = gca; fig = gcf;
init = NaN(1,length(perf_by_block));
for j = 1:n
    hold on
    bluevalues = init;
    bluevalues(passingnback(j,:)) = BDM_rt(j,passingnback(j,:));
    purplevalues = init;
    purplevalues(passingdetect(j,:)) = BDM_rt(j,passingdetect(j,:));
    redvalues = init;
    redvalues(neither(j,:)) = BDM_rt(j,neither(j,:));
    plot(bluevalues,'o','MarkerFaceColor','b')
    plot(purplevalues,'o','MarkerFaceColor','m')
    plot(redvalues,'o','MarkerFaceColor','r')
    bundle(j,:,1) = bluevalues; bundle(j,:,2) = purplevalues; bundle(j,:,3) = redvalues;
end

errorbar(nanmean(BDM_rt),nanstd(BDM_rt)/sqrt(n),'k','LineWidth',2)
% lines for later, too messy now given how few data points we have in each
% condition
% errorbar(nanmean(bundle(:,:,1),1),nanstd(bundle(:,:,1))/sqrt(n),'b','LineWidth',1)
% errorbar(nanmean(bundle(:,:,2),1),nanstd(bundle(:,:,2))/sqrt(n),'m','LineWidth',1)
% errorbar(nanmean(bundle(:,:,3),1),nanstd(bundle(:,:,3))/sqrt(n),'r','LineWidth',1)
fig.Color = 'w';
ax.FontSize = 12;
title('RT by BDM round')
xlabel('Block #')
ylabel('RT of decision')
legend({'Passed Hard','Passed Easy','Did not Pass'},'Location','Best')

%just check out subject BDM strategy
figure
subplot(1,2,1)
for i = 1:n
    scatter(1:24,values(i,:),'o','Filled')
    hold on
end
title('Mean fair wage per subject per block')
fig = gcf; ax = gca;
fig.Color = 'w';
ax.FontSize = 12;

subplot(1,2,2)
for i = 1:n
    if group.version(i) == 1
        color = 'r';
    else
        color = 'b';
    end
    scatter(1:24,values(i,:),['o' color],'Filled')
    hold on
end
title('Mean fair wage per subject per block')
legend('Exp 1','Exp 2')
fig = gcf; ax = gca;
fig.Color = 'w';
ax.FontSize = 12;

figure
subplot(1,2,1)
ax = gca; fig = gcf;
hold on
for i = 1:n
    plot(nbackacc(i,:),'ro')
    plot(nswitch9acc(i,:),'bo')
end
errorbar(nanmean(nbackacc),nanstd(nbackacc)/sqrt(n1),'r','LineWidth',1)
errorbar(nanmean(nswitch9acc),nanstd(nswitch9acc)/sqrt(n2),'b','LineWidth',1)
title('Hard Learning Curves (accuracy)')
fig.Color = 'w';
ax.FontSize = 12;
xlabel('Block #')
ylabel('Accuracy')

subplot(1,2,2)
ax = gca; fig = gcf;
hold on
for i = 1:n
    plot(nbackrts(i,:),'ro')
    plot(nswitch9rts(i,:),'bo')
end
errorbar(nanmean(nbackrts),nanstd(nbackrts)/sqrt(n1),'k','LineWidth',1)
errorbar(nanmean(nswitch9rts),nanstd(nswitch9rts)/sqrt(n2),'k','LineWidth',1)
title('Hard Learning Curves (reaction times)')
fig.Color = 'w';
ax.FontSize = 12;
xlabel('Block #')
ylabel('Mean log(RT) (ms)')

figure
for row = 1:n
    init = NaN(12,1);
    init(data.offers(row,:)>data.values(row,:)) = data.offers(row,data.offers(row,:)>data.values(row,:));
    init(data.values(row,:)>data.offers(row,:)) = 1;
    y = init;
    x = [NaN perf_by_block(row,1:end-1)]';
    matrix = sortrows([y,x],1);
    plot(matrix(:,1),matrix(:,2),'o')
    hold on
end
ax = gca; fig = gcf;
title('Performance by BDM offer')
fig.Color = 'w';
ax.FontSize = 12;
xlabel('BDM points at stake')
ylabel('Accuracy')

% BDM points by accuracy
figure
subplot(3,2,1)
for row = 1:n
    next_trial = find(task_progression(row,:)==tasks(2))+1;
    y = nbackacc(row,~isnan(nbackacc(row,:)));
    y(next_trial==length(task_progression(row,:))+1) = []; %prune lists the same way as below
    next_trial(next_trial == length(task_progression(row,:))+1) = []; %outside the index, 13th block of 12
    matrix = sortrows([y',values(row,next_trial)'],1);
    plot(matrix(:,1),matrix(:,2),'o')
    hold on
end
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
xlim([50 100])
ylim([1 5.1])
title('BDM value by prev. combine accuracy')
ylabel('BDM points')
xlabel('Accuracy')

% same thing as above, accuracy by BDM, but for n-switch
subplot(3,2,2)
for row = 1:n
    next_trial = find(task_progression(row,:)==tasks(4))+1;
    y = nswitch9acc(row,~isnan(nswitch9acc(row,:)));
    y(next_trial==length(task_progression(row,:))+1) = []; %prune lists the same way as below
    next_trial(next_trial == length(task_progression(row,:))+1) = []; %outside the index, 13th block of 12
    matrix = sortrows([y',values(row,next_trial)'],1);
    plot(matrix(:,1),matrix(:,2),'o')
    hold on
end
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
xlim([50 100])
ylim([1 5.1])
title('BDM value by prev. p(switch)=0.9 accuracy')
ylabel('BDM points')
xlabel('Accuracy')

% plot combine mean RT switch cost effect on  (all task switches, regardless of task identity)
subplot(3,2,3)
for row = 1:n
    next_trial = find(task_progression(row,:)==tasks(2))+1;
    y = nanmean(data.combineswitchcosts{row}(task_progression(row,:)==tasks(2))',2);
    y(next_trial==length(task_progression(row,:))+1) = []; %prune lists the same way as below
    next_trial(next_trial == length(task_progression(row,:))+1) = []; %outside the index, 13th block of 12
    matrix = sortrows([y,values(row,next_trial)'],1);
    plot(matrix(:,1),matrix(:,2),'o')
    hold on
end
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
ylim([1 5.1])
title('BDM value by prev. task switch cost (combine)')
ylabel('BDM points')
xlabel('Mean Switch Cost (RT in msec) within Combine')

%plot switch costs in n-switch 0.9 vs. bdm points requested next
subplot(3,2,4)
for row = 1:n
    next_trial = find(task_progression(row,:)==tasks(4))+1;
    y = nanmean(data.allnswitchcosts{row}(task_progression(row,:)==tasks(4))',2);
    y(next_trial==length(task_progression(row,:))+1) = []; %prune lists the same way as below
    next_trial(next_trial == length(task_progression(row,:))+1) = []; %outside the index, 13th block of 12
    matrix = sortrows([y,values(row,next_trial)'],1);
    plot(matrix(:,1),matrix(:,2),'o')
    hold on
end
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
ylim([1 5.1])
title('BDM value by prev.task switch cost (n-switch)')
ylabel('BDM points')
xlabel('Mean Switch Cost (RT in msec) within n-switch p = 0.9')

subplot(3,2,5)
% plot combine n-back hits versus BDM points requested
for row = 1:n
    next_trial = find(task_progression(row,:)==tasks(2))+1;
    y = data.nbackmatches{row};
    y(next_trial==length(task_progression(row,:))+1) = []; %prune lists the same way as below
    next_trial(next_trial == length(task_progression(row,:))+1) = []; %outside the index, 13th block of 12
    matrix = sortrows([y',values(row,next_trial)'],1);
    if ~isempty(matrix) %weed out subjects with 0 combine rounds
        plot(matrix(:,1),matrix(:,2),'o')
    end
    hold on
end
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
ylim([1 5.1])
title('BDM value by prev. nback matches (combine)')
ylabel('BDM points')
xlabel('# of N-Back matches within Combine')

%plot BDM request by previous task switches within pswitch 0.9
subplot(3,2,6)
for i=1:n
    task_list = data.task_progression(i,:);
    if ismember(categorical({'pswitch0.9'}),task_list) %version 2
        hard = find(ismember(task_list,categorical({'pswitch0.9'})));
        next = hard+1;
        l = length(task_list);
        y = values(i,next(next~=(l+1)));
        x = data.nswitches(i,hard(hard~=l)); %exclude last trial for sizing reasons
        plot(x,y,'o');
        hold on
    end
end
title('BDM value by prev. # switches')
ylabel('BDM points')
xlabel('# of switches in last block')
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
ylim([1 5.1])

%plot BDM request by previous offer
figure
subplot(1,2,1)
for row = 1:n
    y = data.offers(row,:)';
    x = [NaN data.values(row,2:end)]';
    matrix = sortrows([y,x],1);
    plot(matrix(:,1),matrix(:,2),'o')
    hold on
end
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
title('BDM value by prev. computer offer')
ylim([1 5.1])
ylabel('BDM points')
xlabel('Last offer')

subplot(1,2,2)
%plot mean BDM points by passing or failing hard task
%incorporate n-switch here
BDM_smush = [];
for row = 1:n
    passing = [perf_by_block(row,:)>=cutoff];
    not = [perf_by_block(row,:)<cutoff]; 
    task_list = data.task_progression(row,:);
    hard = ismember(task_list,hardtasks);
    BDM_smush = [BDM_smush; nanmean(values(find(passing&hard)+1)) nanmean(values(find(not&hard)+1))];
    scatter(ones(sum(passing&hard),1),values(find(passing&hard)+1),'k','o')
    hold on
    scatter(2.*ones(sum(hard&not),1),values(find(hard&not)+1),'k','o')
end
bar(nanmean(BDM_smush))
errorbar(1:2,nanmean(BDM_smush),nanstd(BDM_smush)/sqrt(n),'ko','LineWidth',1)
ylabel('Mean BDM points requested')
xticks([1 2])
xticklabels({'Passed hard','Failed hard'})
title('Mean BDM points requested by grade on hard tasks')
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;

figure
hold on
for row = 1:n
    plot(combineswitchcosts(row,:),'k*')
end
errorbar(nanmean(combineswitchcosts),nanstd(combineswitchcosts)/sqrt(n),'k*','LineWidth',2)
xlabel('Task Switched To')
xticklabels({'Detection','Combine'})
xticks([1 2])
ylabel('Switch Cost (RT in msec)')
title('Mean Switch Cost (RT) within Combine')
xlim([0.5 2.5])
ax = gca; fig = gcf;
fig.Color = 'w'; ax.FontSize = 12;

%sanity check that tasks take the same amount of time
figure
subplot(1,2,1)
y = TOT(task_progression==tasks(1));
x = TOT(task_progression==tasks(2));
scatter(ones(length(y),1),y)
hold on
scatter(2*ones(length(x),1),x)
errorbar(1:2,[mean(y) mean(x)],[std(y)/sqrt(length(y)) std(x)/sqrt(length(x))],'ko')
xlim([0.75 2.25])
ylabel('Time on task (seconds)')
xticks([1 2])
xticklabels({'Detection','Combine'})
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;

subplot(1,2,2)
y = sum(sum(task_progression==tasks(1)));
x = sum(sum(task_progression==tasks(2)));
w = sum(sum(task_progression==tasks(3)));
z = sum(sum(task_progression==tasks(4)));
bar([y,x,w,z])
xticklabels({'detection','combine','n-switch,p0.1','n-switchp0.9'})
ax = gca; fig = gcf;
fig.Color = 'w';
ax.FontSize = 12;
title('# times each task completed across subjects')
ylabel('Count')

%plot late responses/changed responses by task
figure
subplot(1,2,1)
for task = 1:length(tasks)
    bar(task,nanmean(data.lateresponse(data.task_progression==tasks(task))))
    scatter(task*ones(sum(sum(data.task_progression==tasks(task))),1),data.lateresponse(data.task_progression==tasks(task)))
    hold on
end
ax = gca; fig = gcf;
xticks(1:length(tasks))
xticklabels(tasklabels)
xtickangle(45)
ylabel('mean late responses')
ax.FontSize = 12;
fig.Color = 'w';

%% why high dropout rates?

figure
subplot(1,2,1)
bar([sum(excluded.values(excluded.exp_version==1,1:4)) 0 n1])
labels = [excluded.labels(1,1:4) ' ' 'finished'];
xticklabels([labels])
title('Dropout over course of experiment 1')
ylabel('n')
ax = gca; fig = gcf;
ax.FontSize = 14;
fig.Color = 'w';

subplot(1,2,2)
bar([sum(excluded.values(excluded.exp_version==2,1:4)) 0 n2])
labels = [excluded.labels(1,1:4) ' ' 'finished'];
xticklabels([labels])
title('Dropout over course of experiment 2')
ylabel('n')
ax = gca; fig = gcf;
ax.FontSize = 14;
fig.Color = 'w';




