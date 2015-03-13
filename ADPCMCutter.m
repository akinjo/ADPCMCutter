function ADPCMCutter(srcFile,dstDir,IntervalTime)
%
% この関数は、IMA ADPCM 形式のwavファイル(srcFile)を IntervalTime(時間) の間隔で分割して
% dstDirで指定したフォルダーに出力します。
%
%  ADPCMCutter(srcFile)
%  ADPCMCutter(srcFile,dstDir,)
%  ADPCMCutter(srcFile,dstDir,IntervalTime)
%  ADPCMCutter(srcFile,[],IntervalTime)
%

if ~exist('srcFile','var'),
    warning('分割対象のファイルを入力してください。');
    return;
end

if ~exist(srcFile,'file'),
    warning('分割対象のファイル%sは見つかりません。',srcFile);
    return;
end

if ~exist('dstDir','var') || isempty(dstDir),
    [dstDir,~,~] = fileparts(srcFile);
end

if ~exist('IntervalTime','var'),
    IntervalTime = 2;
end

fid = fopen(srcFile);
%% HEAD
L.HEAD1 = fread(fid,20,'*uint8');
if strcmp(char(L.HEAD1(1:4))','RIFF')  && strcmp(char(L.HEAD1(9:12))','WAVE')
    file_size      = typecast(L.HEAD1((5:8))','uint32');
    fmt_chank_size = typecast(L.HEAD1((17:20))','uint32');
    L.HEAD2 = fread(fid,fmt_chank_size,'*uint8');
    
    if L.HEAD2(1) ~= 17,
        warning('%sはIMA/DVI ADPCM形式ではありません。',srcFile);
        return;
    end
    
    data_header = fread(fid,8,'*uint8');
    data_chank_size = typecast(data_header((5:8))','uint32');
else
    warning('ヘッダー情報が壊れています。修正します。');
    [srcDir,~,~] =  fileparts(mfilename('fullpath'));
    L = load(fullfile(srcDir,'header.mat'));
    info = dir(srcFile);
    file_size = uint32(info.bytes - 8);
    fmt_chank_size = typecast(L.HEAD1((17:20))','uint32');
    fseek(fid,fmt_chank_size+8,0);
    data_header = zeros(8,1,'uint8');
    data_header(1:4) = 'data';
    data_chank_size = file_size - (length(L.HEAD1) + length(L.HEAD2));
end

nSamplesPerSec = double(typecast(L.HEAD2((5:8))','uint32'));
nBlockAlign = double(typecast(L.HEAD2((13:14))','uint16'));
% wBitsPerSample = double(typecast(L.HEAD2((15:16))','uint16'));
wSamplesPerBlock = double(typecast(L.HEAD2((19:20))','uint16'));

% nAvgBytesPerSecの値が間違っているので計算し直す。
% ADPCM の場合は 単純にサンプリング・レートをビット数で補正するだけじゃダメ
n = nSamplesPerSec / wSamplesPerBlock * nBlockAlign;
nAvgBytesPerSec = double(typecast(L.HEAD2(9:12)','uint32'));
if ~any(nAvgBytesPerSec == [ceil(n),floor(n)]),
    warning('nAvgBytesPerSec の値が nSamplesPerSec / wSamplesPerBlock * nBlockAlign と一致しません。');
    warning('nAvgBytesPerSec の値を nSamplesPerSec / wSamplesPerBlock * nBlockAlign の値に修正します。');
    L.HEAD2(9:12)= typecast(uint32(floor(n)),'uint8');
end


%%
SamplePerIntarvalTime = nSamplesPerSec * IntervalTime * 60 * 60;
nBlock = ceil(SamplePerIntarvalTime / wSamplesPerBlock);
data_size_intarval = nBlock * nBlockAlign;

[~,NAME,~] = fileparts(srcFile);

k = 0;
while 1
    data = fread(fid,data_size_intarval,'*uint8');
    dstFile = fullfile(dstDir,sprintf('%s.%02d.wav',NAME,k));
    if exist(dstFile,'file')
        fprintf('%s found & skip \n',dstFile);
        break;
    end
    fprintf('%s to %s\n',srcFile,dstFile);
    
    if isempty(data)
        break;
    end
    
    n = uint32(file_size - data_chank_size + length(data));
    L.HEAD1(5:8) = typecast(n,'uint8');
    data_header((5:8)) = typecast(uint32(length(data)),'uint8');
    
    fid2 = fopen(dstFile,'wb');
    fwrite(fid2,L.HEAD1,'uint8');
    fwrite(fid2,L.HEAD2,'uint8');
    fwrite(fid2,data_header,'uint8');
    fwrite(fid2,data(1:end),'uint8');
    fclose(fid2);
    
    if length(data) < data_size_intarval
        break;
    end
    k = k + 1;
end

fclose(fid);

end
