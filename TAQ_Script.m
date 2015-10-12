%% Input variables
filename = 'ibm_taq_data_week.csv';	    %name of file to be read
samplingFreq = 1;           %units: seconds
variables={'PRICE
    '};   %Change these to the relevant headers required in the computations

% Open File
fid = fopen(filename);

% Get line (this should be the headers)
tline = fgetl(fid);
header = strsplit(tline,',');

% Find the corresponding reqDataIdx
reqDataIdx=zeros(1,size(variables,2)+2);
reqDataIdx(1,1)=find(strcmp(header,'DATE'));
reqDataIdx(1,2)=find(strcmp(header,'TIME_M'));
for i=1:size(variables,2)
    reqDataIdx(1,i+2) = find(strcmp(header,variables{i}));
end

clear i

% Get first line of data
tline = fgetl(fid);
fmtData=strsplit(tline,',','CollapseDelimiters', false);
% Get only required data
reqData=fmtData(reqDataIdx);

% Initalise dateNow and timeNow
targetDate= 0;
targetTime= 4*3600.00;

% Loop and get data
while (ischar(tline))    
    % Process input
    dateNow= str2num(reqData{1,1});
    tempTime = strsplit(reqData{1,2}, ':');
    tempTime(1,3:4)=strsplit(tempTime{1,3},'.');
    timeNow=str2num(tempTime{1})*3600+str2num(tempTime{2})*60+str2num(tempTime{3})+str2num(tempTime{4})/1000;
    
    % Create an empty list if the target date
    if(dateNow>targetDate)
        targetDate = dateNow;
        targetTime = targetTime+samplingFreq;
        dayList={};
        idx = 1;
    end
    
    % Test if the current time is more than the next time frame
    if (timeNow < targetTime)
        dayList(idx,:)=reqData;
        disp(['*',reqData{1},' ',reqData{2},' ',num2str(timeNow)])
    else
        idx=idx+1;
        dayList(idx,:)=reqData;
        disp(['-',reqData{1},' ',reqData{2},' ',num2str(timeNow)])
        if ((timeNow - targetTime)/samplingFreq <=1)
            targetTime=targetTime+samplingFreq;
        else
            targetTime=targetTime+samplingFreq+floor((timeNow - targetTime)/samplingFreq)*samplingFreq;
        end
    end
    
    % Write your own computations here

    % Read next line
    tline = fgetl(fid);
    fmtData=strsplit(tline,',','CollapseDelimiters', false);
    reqData=fmtData(reqDataIdx);
end