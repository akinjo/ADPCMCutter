srcFile = '2014_09_22_C_noair-air.wav';
mkdir 'IntervalTime1';
mkdir 'IntervalTime2';

ADPCMCutter(srcFile,'IntervalTime1',1);
ADPCMCutter(srcFile,'IntervalTime2',2);

%%
% 1時間毎に分割したファイルと2時間毎に分割したファイルの比較を行う。
% 1時間毎に分割ファイルの2つ目と2時間毎に分割したファイルの後半が
% audioread で比較して同じであれば正しく分割されてとしている。

Y1_0 = audioread('IntervalTime1\2014_09_22_C_noair-air.00.wav');
Y1_1 = audioread('IntervalTime1\2014_09_22_C_noair-air.01.wav');
Y2_0 = audioread('IntervalTime2\2014_09_22_C_noair-air.00.wav');

%%
l1_0 = length(Y1_0);
l1_1 = length(Y1_1);
l2_0 = length(Y2_0);

if all(Y2_0(1:l1_0) == Y1_0)
    fprintf('前半の一時間は一致しています。\n');
end

m = min(l2_0 - l1_0,l1_1);
if all(Y2_0(l1+1:end) == Y1_1(1:m))
    fprintf('後半の一時間は一致しています。\n');
end
