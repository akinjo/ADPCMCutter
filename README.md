# ADPCM Cutter

IMA ADPCA 形式で保存された wavファイルを分割するmatlabのプログラムです。

## mファイルの利用方法
matlabの関数として利用ください。以下の書式で利用できます。

`ADPCMCutter(srcFile)`  
`ADPCMCutter(srcFile,dstDir)`  
`ADPCMCutter(srcFile,dstDir,IntervalTime)`  
`ADPCMCutter(srcFile,[],IntervalTime)`  


## exeファイルの利用方法
exeファイルを使用する場合は MATLAB Runtime が必要になります。matlab R2013a 64bi ででコンパイルしてあります。下記のURLから Runtime をダウンロードしてインストールしてください。
http://jp.mathworks.com/products/compiler/mcr/

Runtime のインストール後 ADPCMCutter.exe に分割したいwavファイルをドラッグ&ドロップしてください。2時間間隔にwavファイルが分割されます。

## フォーマットエラーの修正
nAvgBytesPerSec の値が nSamplesPerSec / wSamplesPerBlock * nBlockAlign と一致しない場合には、nSamplesPerSec / wSamplesPerBlock * nBlockAlign の値に修正するようにしてあります。


