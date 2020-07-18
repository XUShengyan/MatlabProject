clc,clear,close all;

%% WebList, table type
clc,clear,close all;
projectDir = 'D:\matlabProject\web\WebTask\checkStock';
webSiteFileFullPath = fullfile(projectDir,'webSite.xlsx');
webSiteXlsx =readtable(webSiteFileFullPath);
WebSite = webSiteXlsx.Web;
stockInitial = webSiteXlsx.instockFlag;

%% setting timer
t = timer;
t.Name ='LV';
t.StartDelay = 1;
t.Period = 60;
t.ExecutionMode = 'fixedSpacing';
t.TasksToExecute =Inf;
t.TimerFcn =@(~,~)lvTask(WebSite,stockInitial);

%% Start Checking
start(t)

%% Stop Checking
stop(t) 

%% Mannual test
webSite{1} ='https://fr.louisvuitton.com/fra-fr/produits/pochette-accessoires-nm-monogram-005656';
webSite{2} = 'https://fr.louisvuitton.com/fra-fr/produits/mini-pochette-accessoires-monogram-001025';
lvTask(webSite,stockInitial)
% 

%% Old version, WebList, cell type
WebSite{1} = 'https://fr.louisvuitton.com/fra-fr/produits/sac-messenger-district-pm-damier-graphite-015389'; % unstable
WebSite{2} = 'https://fr.louisvuitton.com/fra-fr/produits/sac-avenue-sling-damier-graphite-nvprod110017v'; % alway 1
WebSite{3} = 'https://fr.louisvuitton.com/fra-fr/produits/cabas-carry-it-monogram-nvprod2010018v';
WebSite{4} = 'https://fr.louisvuitton.com/fra-fr/produits/pochette-metis-monogram-reverse-canvas-nvprod1770373v';
WebSite{5} = 'https://fr.louisvuitton.com/fra-fr/produits/pochette-favorite-mm-monogram-005658';
WebSite{6} = 'https://fr.louisvuitton.com/fra-fr/produits/pochette-favorite-mm-damier-ebene-008841';
WebSite{7} = 'https://fr.louisvuitton.com/fra-fr/produits/sac-seau-noe-bb-monogram-006406';
WebSite{8} = 'https://fr.louisvuitton.com/fra-fr/produits/sac-nano-speedy-monogram-010575';
WebSite{9} = 'https://fr.louisvuitton.com/fra-fr/produits/sac-messenger-district-pm-damier-ebene-015392';
WebSite{10} ='https://fr.louisvuitton.com/fra-fr/produits/pochette-accessoires-nm-monogram-005656';
WebSite{11} = 'https://fr.louisvuitton.com/fra-fr/produits/mini-pochette-accessoires-monogram-001025';


%% Function
function lvTask(webSite,stockInitial)
    webNum = length(webSite);
    timeDelay = randi([1,3],1,webNum);
    stockChangeFlag =zeros(1,webNum);
    for i = 1: webNum
        if i == 1 % Open first web
            fprintf('\n%s',datestr(now,13)); % print current time
            ie=actxserver('internetexplorer.application');
            ie.Navigate(webSite{i});
            while ~strcmp(ie.readystate,'READYSTATE_COMPLETE')
                    pause(0.01) 
            end
%             ie.visible = 1; 
            
            % get HTML source
            sourcefile=getWebSource(ie);
            % analysis source
            stockChangeFlag(i) = analysisWeb(sourcefile,webSite{i},stockInitial(i));
            
            pause(timeDelay(i));
        else
            ie.Navigate(webSite{i});       
            while ~strcmp(ie.readystate,'READYSTATE_COMPLETE')
                    pause(0.01) 
            end
            if (i ==11)
                a=1;
            end
            % get HTML source
            sourcefile=getWebSource(ie);
            % analysis source
            stockChangeFlag(i) = analysisWeb(sourcefile,webSite{i},stockInitial(i)); 
            
            pause(timeDelay(i));
        end    
       
      
    end
    if sum(stockChangeFlag) == 0
        fprintf(" NO change\n")
    end
    % Finish current task
    ie.Quit;
    delete(ie)
end

function source=getWebSource(ie)
    source = ie.Document.head.innerHtml; 
end

function flagChanged=analysisWeb(sourcefile,website,stockInitialFlag)     
    flag = checkStock(sourcefile);
    % flag =1 ,inStock ; flag = 0, OutOfStock
    if flag ~= stockInitialFlag     
        if flag ==1
            fprintf("\n InStock  ");
            fprintf(website);
            msgbox('Caution!');
            flagChanged = 1;
        else 
            fprintf("\n OutStock");
            fprintf(website);
            flagChanged = 1;
        end
    else
        flagChanged =0;% NO change
    end  
end

function flag = checkStock(htmlSource)
    % flag =1 ,inStock ; flag = 0, OutOfStock
    [data_token_addToCart,token_addToCart]=regexp(htmlSource,'"availability": ".*?"','match');
    [data_unableBuy,token_ableBuy]=regexp(data_token_addToCart,'OutOfStock','match');
    if isempty(data_unableBuy{1}) % empty 0 unable, Full 1 able
        flag =1;
    else
        flag =0;
    end
end

