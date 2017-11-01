% f_main([1,2]);clc;close all;
% f_main([1,2,3]);clc;close all;
% f_main([1,2,3,4]);clc;close all;
% f_main([1,2,3,4,5]);clc;close all;
% f_main([5,6]);clc;close all;
%f_main([2,3,4,5]);clc;close all;
%f_main([3,4,5]);clc;close all;
%f_main([4,5]);clc;close all;
% target_12 = f_main([1,2]);clc;close all;

% trgt = f_main([1,2]);clc;close all;
% trgt = f_main([1,2,3]);clc;close all;
% trgt = f_main([1,2,3,4]);clc;close all;
% trgt = f_main([1,2,3,4,5]);clc;close all;
trgt = f_main([5,6]);clc;close all;

nTarget = length(trgt);


% T_OneParent = table('VariableNames',{'Source' 'Target' 'BDeu'});
% T_TwoParent = table('VariableNames',{'Source1' 'Source2' 'Target' 'BDeu'});
% T_ThreeParent = table('VariableNames',{'Source1' 'Source2' 'Source3' 'Target' 'BDeu'});

for t = 1 : nTarget
    target = trgt{t};
    % Generate T_OneParent
%     T_OneParent = table('VariableNames',{'Target' 'Source' 'BDeu'});
    Target = [];
    Source = [];
    BDeu = [];
    for comb = 1 : size(target.BDeu_Memory,2)
        if isempty(target.BDeu_Memory{1,comb})
                continue;
        end
        tSource = target.PoPaGList{target.BDeu_Memory{1,comb}.Indx};
        tBDeu = target.BDeu_Memory{1,comb}.BDeu;
        tTarget = target.name;
        Source = [Source ; tSource];
        Target = [Target ; tTarget];
        BDeu = [BDeu; tBDeu]; 
    end
    T_OneParent = table(Target,Source,BDeu);
    T_OneParent = sortrows(T_OneParent,'BDeu','descend'); % highest score at the top

    writetable(T_OneParent,sprintf('./Ethylene_Target/%s_1Parent.csv',target.name)...
        ,'WriteRowNames',true,'WriteVariableNames',true);
    
    % Generate T_TwoParent
    nPa = 2;
    Target = [];
    Source1 = [];
    Source2 = [];
    BDeu = [];
    for comb = 1 : size(target.BDeu_Memory,2)
        if isempty(target.BDeu_Memory{nPa,comb})
                continue;
        end
        
        indx = target.BDeu_Memory{nPa,comb}.Indx;
        tSource1 = target.PoPaGList{indx(nPa-1)};
        tSource2 = target.PoPaGList{indx(nPa)};
        tBDeu = target.BDeu_Memory{nPa,comb}.BDeu;
        tTarget = target.name;
        Source1 = [Source1 ; tSource1];
        Source2 = [Source2 ; tSource2];
        Target = [Target ; tTarget];
        BDeu = [BDeu; tBDeu]; 
    end
    T_TwoParent = table(Target,Source1,Source2,BDeu);
    T_TwoParent = sortrows(T_TwoParent,'BDeu','descend'); % highest score at the top
    
    writetable(T_TwoParent,sprintf('./Ethylene_Target/%s_2Parent.csv',target.name)...
            ,'WriteRowNames',true,'WriteVariableNames',true);
     
    % Generate T_ThreeParent
    nPa=3;
    Target = [];
    Source1 = [];
    Source2 = [];
    Source3 = [];
    BDeu = [];
    
    for comb = 1 : size(target.BDeu_Memory,2)
        if isempty(target.BDeu_Memory{nPa,comb})
                continue;
        end
%         TSource = target.PoPaGList(target.BDeu_Memory{2,comb}.Indx);
        
        indx = target.BDeu_Memory{nPa,comb}.Indx;
        tSource1 = target.PoPaGList{indx(nPa-2)};
        tSource2 = target.PoPaGList{indx(nPa-1)};
        tSource3 = target.PoPaGList{indx(nPa)};
        tBDeu = target.BDeu_Memory{nPa,comb}.BDeu;
        tTarget = target.name;
        Source1 = [Source1 ; tSource1];
        Source2 = [Source2 ; tSource2];
        Source3 = [Source3 ; tSource3];
        Target = [Target ; tTarget];
        BDeu = [BDeu; tBDeu]; 
    end
    T_ThreeParent = table(Target,Source1,Source2,Source3,BDeu);
    T_ThreeParent = sortrows(T_ThreeParent,'BDeu','descend'); % highest score at the top
    
    writetable(T_ThreeParent,sprintf('./Ethylene_Target/%s_3Parent.csv',target.name)...
            ,'WriteRowNames',true,'WriteVariableNames',true);
end