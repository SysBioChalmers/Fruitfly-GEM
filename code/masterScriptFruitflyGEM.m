%
% FILE NAME:    masterScriptFruitflyGEM.m
%
%
% PURPOSE: This script is for reconstruction of the Fruitfly-GEM, by using
%          the Human-GEM as template and taking into account specie-specific
%          pathways/reactions.
%
%


%% Load Human-GEM as template
load('Human-GEM.mat');


% convert gene identifiers from Ensembl ids to gene symbols
[grRules,genes,rxnGeneMat] = translateGrRules(ihuman.grRules,'Name','ENSG');
ihuman.grRules    = grRules;
ihuman.genes      = genes;
ihuman.rxnGeneMat = rxnGeneMat;



%% Use MA reactions identifiers 

% load reaction annotaiton files
rxnAssoc = jsondecode(fileread('humanGEMRxnAssoc.JSON'));

%replace reaction identifiers with MA ids if available
ind = getNonEmptyList(rxnAssoc.rxnMAID);
ihuman.rxns(ind) = rxnAssoc.rxnMAID(ind);



%% Generate Fruitfly-GEM by using Human-GEM as template

% get ortholog pairs from human to worm
fruitflyOrthologPairs = extractAllianceGenomeOrthologs('human2FruitflyOrthologs.json');
fruitflyGEM = getModelFromOrthology(ihuman, fruitflyOrthologPairs);



%% Incorporate species-specific reactions

% get metabolic networks based on the KEGG annoation using RAVEN function
KEGG_human=getKEGGModelForOrganism('hsa');
KEGG_fruitfly=getKEGGModelForOrganism('dme');

% remove reactions shared with human
FruitflySpecificRxns=setdiff(KEGG_fruitfly.rxns,KEGG_human.rxns);

% remove reactions included in Human-GEM
FruitflySpecificRxns=setdiff(FruitflySpecificRxns,rxnAssoc.rxnKEGGID);


% get species-specific network for manual inspection and then
% organize species-specific pathways into two tsv files:
fruitflySpecificNetwork=removeReactions(KEGG_fruitfly,...
    setdiff(KEGG_fruitfly.rxns,FruitflySpecificRxns), true, true, true);

% "fruitflySpecificMets.tsv" contains species-specific metabolites
metsToAdd = importTsvFile('fruitflySpecificMets.tsv');

% "fruitflySpecificRxns.tsv" contains species-specific reactions
rxnsToAdd = importTsvFile('fruitflySpecificRxns.tsv');
rxnsToAdd.subSystems = cellfun(@(s) {{s}}, rxnsToAdd.subSystems);

% integrate fruitfly-specific metabolic network
[fruitflyGEM, modelChanges] = addMetabolicNetwork(fruitflyGEM, rxnsToAdd, metsToAdd);


%% Gap-filling for biomass formation
[fruitflyGEM, gapfillNetwork]=gapfill4EssentialTasks(fruitflyGEM,ihuman);
% Added 39 reactions for gap-filling


%% Save the model into mat, yml, and xml

fruitflyGEM.id = 'Fruitfly-GEM';
save('../model/Fruitfly-GEM.mat', 'fruitflyGEM');
writeHumanYaml(fruitflyGEM, '../model/Fruitfly-GEM.mat');
exportModel(fruitflyGEM, '../model/Fruitfly-GEM.xml');

