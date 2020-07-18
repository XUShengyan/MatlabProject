clc,clear,close all;

% WebList
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
%% Timer setting
t = timer;
t.Name ='LV';
t.StartDelay = 1;
t.Period = 60;
t.ExecutionMode = 'fixedSpacing';
t.TasksToExecute =Inf;
t.TimerFcn =@(~,~)lvTask(WebSite);
%% Start Checking
start(t)
%% Stop Checking
stop(t) 
 
%%
function lvTask(WebSite)
    timeDelay = randi([1,3],1,size(WebSite,2));
    for i = 1: size(WebSite,2)
        try
            sourcefile{i}=webread(WebSite{i});
            pause(timeDelay(i));
        catch
            pause(15);
            sourcefile{i}=webread(WebSite{i});
        end            
    end
    fprintf(datestr(now,13));
    analysisWeb(sourcefile,WebSite)
end

function analysisWeb(sourcefile,WebSite)
    instockFlag =0;
    for i = 1: size(sourcefile,2)      
        flag = checkStock(sourcefile{i});
        if flag ==1 && i>2
        %if flag ==1
            if i==10 || i==11
                fprintf("InStockJM\n");
            else
                fprintf("InStock\n");
            end
            
            fprintf('%s',WebSite{i});
            fprintf("\n");
            instockFlag =instockFlag +1;
        end      
    end
   
    if instockFlag ==0
        fprintf('NO change');
        fprintf("\n");
    else
        msgbox('Caution!');
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