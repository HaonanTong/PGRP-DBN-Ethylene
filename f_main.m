function [] = f_main( tp_array )
% Example
% tp_array = [ 1, 2, 3, 4]
% for each nTF activated at time point 4 as target
% TF activated at time point 1, 2, 3, 4 as potential regulators

global outputDir

% Generate Folder
ntp = length(tp_array);
tartp = tp_array(end);
if ntp == 1 
    pRegtp_array = 1:tartp; % potential regulators are activated by tartp
    % if tp_array = 6, potential TF: 1 2 3 4 5
else
    pRegtp_array = tp_array(1:ntp);
    % if tp_array = [5 6], potential TF: [5, 6]
end

T_array = [.25, .5, 1 , 4, 12, 24 ];
% make dir
outputDir = 'A_Stage';
for i = 1 : ntp
    outputDir = strcat(outputDir,'%d');
    outputDir = sprintf(outputDir,tp_array(i));
end
mkdir(outputDir);

%% Locate Files
myDirTFs = './Data/TTFs/';
myFilesTFs = dir(fullfile(myDirTFs,'Ethylene-TFs-DEGs-time-Activation*.csv'));

myDirDEGs = './Data/TnTFs/';
myFilesDEGs = dir(fullfile(myDirDEGs,'Ethylene-nTFs-DEGs-time-Activation*.csv'));

%% Interpolation
% interpolate expression profiles into outputDir/interp folder
for i = 1 : length(myFilesTFs)
    f_interp(sprintf('%s%s',myDirTFs,myFilesTFs(i).name));
end

for i = 1 : length(myFilesDEGs)
    f_interp(sprintf('%s%s',myDirDEGs,myFilesDEGs(i).name));
end

%% Discretize
myDir_Interp = sprintf('./%s/Interp/',outputDir);
myFiles2 = dir(fullfile(myDir_Interp,'*.csv'));
n_levels = 3;

for i = 1 : length(myFiles2)
    csv = sprintf('%s%s',myDir_Interp,myFiles2(i).name);
    f_discritize( csv, n_levels );
end

%% Read Table
myDir_Dsc = strcat(myDir_Interp,'Dscrtz/');
T_table = cell(1,6);
TF_at = cell(1,6);
DEGs_at = cell(1,6);

for i = 1 : 6 %TFs
    % T4 TFs-DEGs-time-Activation4-up-Interp-Dscrtz.csv
%     Ethylene-nTFs-DEGs-time-Activation1-Interp-Dscrtz.csv
    csv = sprintf('%s%s',myDir_Dsc,sprintf('Ethylene-TFs-DEGs-time-Activation%d-Interp-Dscrtz.csv',i));
    T_table{i} = readtable(csv,'ReadRowNames',true,'ReadVariableNames',true);

    TF_at{i}.tp = i; %T4
    TF_at{i}.it = T_array(i)/.25 + 1; %IT17;
    TF_at{i}.dmtrx = table2array(T_table{i}); 
    TF_at{i}.table = T_table{i}; 
    TF_at{i}.ngenes = size( TF_at{i}.dmtrx , 1 );
    TF_at{i}.glist = T_table{i}.Properties.RowNames;
end

for i = 1 : 6 %DEGs
    % T4 TFs-DEGs-time-Activation4-up-Interp-Dscrtz.csv
    csv = sprintf('%s%s',myDir_Dsc,sprintf('Ethylene-nTFs-DEGs-time-Activation%d-Interp-Dscrtz.csv',i));
    T_table{i} = readtable(csv,'ReadRowNames',true,'ReadVariableNames',true);

    DEGs_at{i}.tp = i; 
    DEGs_at{i}.it = T_array(i)/.25 + 1; 
    DEGs_at{i}.dmtrx = table2array(T_table{i}); 
    DEGs_at{i}.table = T_table{i}; 
    DEGs_at{i}.ngenes = size( DEGs_at{i}.dmtrx , 1 );
    DEGs_at{i}.glist = T_table{i}.Properties.RowNames;
end

% Derive PPaMtrx
PoPaGList = [];
for i = 1 : ntp -1
    PoPaGList = [PoPaGList; TF_at{pRegtp_array(i)}.glist];
end
target = cell(1,DEGs_at{tartp}.ngenes);
npRtp = length(pRegtp_array);
PPaMtrx = [];
for i = 1 : (npRtp-1)
    if isempty(PPaMtrx)
        A.matrix = TF_at{pRegtp_array(i)}.dmtrx;
        A.at = TF_at{pRegtp_array(i)}.it;
        B.matrix = TF_at{pRegtp_array(i+1)}.dmtrx;
        B.at = TF_at{pRegtp_array(i+1)}.it;
        [ PPaMtrx ] = f_alignment( A, B, 0 );
    else
        B.matrix = TF_at{pRegtp_array(i+1)}.dmtrx;
        B.at = TF_at{pRegtp_array(i+1)}.it;
        [ PPaMtrx ] = f_alignment( PPaMtrx, B, 0 );
    end
end

if npRtp == 1
    PPaMtrx.matrix = TF_at{pRegtp_array}.dmtrx;
    PPaMtrx.at = TF_at{pRegtp_array}.it;
end

rmax = 3;
ESS = 1E-10;
for i = 1 : length(target) % for each potential target
    % alignment potential regulator
    Atarget = DEGs_at{tartp}.dmtrx(i,:);
    B.matrix = Atarget;
    B.at = TF_at{tartp}.it;
    ADM = f_alignment(PPaMtrx, B, 0);
    % get topology
    [ topologyi, ~ ] = f_getTopology( ADM.matrix, n_levels, rmax, ESS ); 
    target{i}.name = DEGs_at{tartp}.glist{i};
    target{i}.indx = topologyi.indx;
    target{i}.BDeu = topologyi.BDeu;
    target{i}.Pa = PoPaGList(target{i}.indx);
    target{i}.PoPaGList = PoPaGList;
end

%% Analysis
BDeu = zeros(DEGs_at{tartp}.ngenes,1);
for i = 1 : TF_at{tartp}.ngenes % for each potential target
    BDeu(i) = target{i}.BDeu;
end

% BDeu_max = max(BDeu);
% indx = find(abs(BDeu-BDeu_max) < .1 ); % corresponds to strongest causal relationship;
% nl = length(indx); % # of structure s.t. has highest score.
% DBN_target = cell(1,nl);
% for i = 1 : nl
%    DBN_target{1,i} = target{1,indx(i)};
% end
% fprintf('Totally have %d sub-structure\n',length(DBN_target));

% for i = 1 : length(DBN_target)
%    fprintf('-----------------------\n');
%    fprintf('structure: %d\n',i);
%    fprintf('Regulators:\n');
%    disp(DBN_target{i}.Pa);
%    fprintf('Target: %s\n',DBN_target{i}.name);
%    fprintf('BDeu score: %G\n',DBN_target{i}.BDeu);  
% end

%% grep structure.
structure = cell(1,length(target));
for i = 1 : length(target)
    structure{i} = [ target{i}.Pa ; target{i}.name ]; % last one is target;
end

% output expression profiles.
T = readtable('Profiles-ANan-DEGs-Filtered.csv','ReadVariableNames',true,'ReadRowNames',true);
for i = 1 : length(target)
    sub_T = T(structure{i},:);
    
    writetable(sub_T,sprintf('./%s/Sub_Table%d.csv',outputDir,i)...
        ,'WriteRowNames',true,'WriteVariableNames',true);
end

% Visulization
% myFiles = dir(fullfile(outputDir,'/Sub_Table*.csv')); %gets all wav files in struct
% for i = 1 : length(myFiles)
%     csv = sprintf('%s/%s',outputDir,myFiles(i).name);
%     f_plotTable3( csv, [], 'Normalized' );
% end

%% output file for cytoscape
% iteration 30 targets, output file for cytoscape
ntargets = length(target);
% T_cytoscape = table('VariableNames',{'Source' 'Target' 'BDeu'});
Source = [];
Target = [];
BDeu = [];
for i = 1 : ntargets
    tSource = target{i}.Pa;
    nPa = length(tSource);
    tTarget = [];
    for j = 1 : nPa
        tTarget = [tTarget;cellstr(target{i}.name)];
    end             
    tBDeu = target{i}.BDeu * ones(nPa,1);    
    Source = [Source ; tSource];
    Target = [Target ; tTarget];
    BDeu = [BDeu; tBDeu];
end
%%
[TSource,~] = f_tranlate(Source,'./ORF_Translation/table_mapping.csv');
[TTarget,~] = f_tranlate(Target,'./ORF_Translation/table_mapping.csv');
T_cytoscape = table(Source,Target,BDeu,TSource,TTarget);
T_cytoscape_sort = sortrows(T_cytoscape,'BDeu','descend'); % highest score at the top

writetable(T_cytoscape_sort,sprintf('./%s/Network_Cytoscape.csv',outputDir)...
        ,'WriteRowNames',true,'WriteVariableNames',true);


