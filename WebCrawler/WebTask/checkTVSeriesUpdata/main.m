clc,clear,close all;

% WebList
WebSite{1} = 'https://chinaq.me/kr200620/'; % unstable
WebSite{1} ='https://chinaq.me/kr/';

%%
%{
    Run manually
%}
WebSite{1} = 'https://chinaq.me/kr200620/'; % unstable
WebSite{2} ='https://chinaq.me/kr/';
timeDelay = randi([1,2],1,size(WebSite,2));
options = weboptions('CharacterEncoding','UTF-8');
 for i = 1: size(WebSite,2)
        try
            sourcefile{i}=webread(WebSite{i},options);
            pause(timeDelay(i));
        catch
            pause(15);
            sourcefile{i}=webread(WebSite{i},options);
        end            
 end
%
% <div class="title sizing">便利店新星</div>
[data1,token1] = regexp(sourcefile{2},'(?<li class="sizing">)*?(<div class="title sizing">便利店新星</div>).*?(</li>)','match');
[data2,token2] = regexp(data1{1},'(第)\d*(集)','match');
[data3,token3] = regexp(data2{1},'\d','match');

%
keyWords ='便利店新星';
info = getInfoFromSource(sourcefile{2},keyWords);

%%
%{
    Run automatically
%}
%% Timer setting
t = timer;
t.Name ='TV series updata check';
t.StartDelay = 1;
t.Period = 60*5;
t.ExecutionMode = 'fixedSpacing';
t.TasksToExecute =Inf;
t.TimerFcn =@(~,~)webTask(WebSite);

%% Start Checking
start(t)
 
%% Stop Checking
stop(t)


%%
function webTask(WebSite)
    options = weboptions('CharacterEncoding','UTF-8');
    try
        sourcefile{1}=webread(WebSite{1}, options );   
    catch
        pause(15);
        sourcefile{1}=webread(WebSite{1}, options );
    end   
    fprintf('\n');
    fprintf(datestr(now,13));
    
    keyWords ='虽然是神经病但没关系'; 
    num = 10;
    info = getInfoFromSource(sourcefile{1},keyWords);
    if str2num(info{1}) > num
        fprintf('updata');
        msgbox('Caution!');
    else
        fprintf('NO change');
    end
    
end


function info = getInfoFromSource(htmlSource,keyWords)
    expressionMatrix = ['(?<li class="sizing">)*?(<div class="title sizing">',keyWords,'</div>).*?(</li>)'];
    expression = join(expressionMatrix);
    [data1,token1] = regexp(htmlSource, expression,'match');
    [data2,token2] = regexp(data1{1},'(第)\d*(集)','match');
    [info,token3] = regexp(data2{1},'\d*','match');
   
end