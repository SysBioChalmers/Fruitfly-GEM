%
% FILE NAME:    masterScriptFruitflyGEM.m
%
%
% PURPOSE: This script is for reconstruction of the Fruitfly-GEM, by using
%          the Human-GEM as template and taking into account specie-specific
%          pathways/reactions.
%
%
%          Annotation files in tsv format are also generated by
%          integrating human and fruitfly-specific annotation information.
%


%% Add path
addpath(genpath('../../Fruitfly-GEM/'));


%% Prepare Fruitfly ortholog pairs and species-specific network

% get ortholog pairs from human to fruitfly
fruitflyOrthologPairs = extractAllianceGenomeOrthologs('human2FruitflyOrthologs.json');

% load species-specific rxns and mets
rxnsToAdd = importTsvFile('fruitflySpecificRxns.tsv');
metsToAdd = importTsvFile('fruitflySpecificMets.tsv');


%% Generate Fruitfly-GEM
[fruitflyGEM, speciesSpecNetwork, gapfillNetwork]=updateAnimalGEM(...
    fruitflyOrthologPairs,rxnsToAdd,metsToAdd,'Fruitfly-GEM');


%% Update annotations
[rxnAssoc, metAssoc] = updateAnimalAnnotations(fruitflyGEM,rxnsToAdd,metsToAdd);


%% Save annotation into tsv files, and the model into mat, yml, and xml

% sanity check
if isequal(rxnAssoc.rxns, fruitflyGEM.rxns) && isequal(metAssoc.mets, fruitflyGEM.mets)
	fprintf('sanity check passed.\n');
    exportTsvFile(rxnAssoc,'../model/reactions.tsv');
    exportTsvFile(metAssoc,'../model/metabolites.tsv');
end

save('../model/Fruitfly-GEM.mat', 'fruitflyGEM');
exportYaml(fruitflyGEM, '../model/Fruitfly-GEM.yml');
exportModel(fruitflyGEM, '../model/Fruitfly-GEM.xml');

