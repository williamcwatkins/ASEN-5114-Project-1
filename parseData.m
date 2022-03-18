function [Data,FileName,DataNumInfo] = parseData()
%PARSEDATA Summary of this function goes here
%   Detailed explanation goes here

CurrDir = pwd; % Finds current directory

fileInfo = dir(fullfile(CurrDir,'Data','SpinModule*'));

for i = 1:length(fileInfo)
    Data{i} = load(fullfile(fileInfo(i).folder, fileInfo(i).name));
    Data{i} = Data{i}(1:end-1,:);
    FileName{i} = fileInfo(i).name;
    
    underInd = strfind(FileName{i},'_');
    FreqStartChar = FileName{i}(underInd(2)+1:underInd(3)-1);
    FreqEndChar = FileName{i}(underInd(3)+1:underInd(4)-1);
    AmpChar = FileName{i}(underInd(4)+1:underInd(5)-1);
    StepChar = FileName{i}(underInd(5)+1:end);
    
    unitInd = strfind(FreqStartChar,'H');
    FreqStartChar = FreqStartChar(1:unitInd-1);
    
        pInd = strfind(FreqStartChar,'p');
        if isempty(pInd)
            FreqStart = str2num(FreqStartChar);
        else
            FreqStartChar = strcat(FreqStartChar(1:pInd-1),'.',FreqStartChar(pInd+1:end));
            FreqStart = str2num(FreqStartChar);
        end
    
    unitInd = strfind(FreqEndChar,'H');
    FreqEndChar = FreqEndChar(1:unitInd-1);
    
        pInd = strfind(FreqEndChar,'p');
        if isempty(pInd)
            FreqEnd = str2num(FreqEndChar);
        else
            FreqEndChar = strcat(FreqEndChar(1:pInd-1),'.',FreqEndChar(pInd+1:end));
            FreqEnd = str2num(FreqEndChar);
        end

    
    unitInd = strfind(AmpChar,'A');
    AmpChar = AmpChar(1:unitInd-1);
    
        pInd = strfind(AmpChar,'p');
        if isempty(pInd)
            Amp = str2num(AmpChar);
        else
            AmpChar = strcat(AmpChar(1:pInd-1),'.',AmpChar(pInd+1:end));
            Amp = str2num(AmpChar);
        end

    
    unitInd = strfind(StepChar,'S');
    StepChar = StepChar(1:unitInd-1);
    Step = str2num(StepChar);
    
    DataNumInfo{i} = [FreqStart;FreqEnd;Amp;Step];
    
end

end

