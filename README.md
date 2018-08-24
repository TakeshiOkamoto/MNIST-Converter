# Currently under construction (作成中)  
  
# MNIST-Converter
Reading and writing MNIST format file.  "mnistex.py" which reads that file with TensorFlow is attached.  
(MNIST形式ファイルの読み書き。そのファイルをTensorFlowで読み込む"mnistex.py"を付属。)  
  
<img src="https://github.com/TakeshiOkamoto/MNIST-Converter/blob/master/image.png">  
  
Since MNIST conversion and mnistex.py for TensorFlow are a set, You can instantly classify by CNN just by preparing images.   
(MNIST変換とTensorFlow用のmnistex.pyがセットになっているので、画像を用意するだけでCNNによるクラス分類が即座に可能です。)  
    
# How to use (mnistex.py)  
  
Let's try "THE MNIST DATABASE" which is classic with CNN at the beginning.  
(最初はCNNで定番の「THE MNIST DATABASE」を試しましょう。)  
  
Download MNIST DATABASE    
(MNIST DATABASEをダウンロードする)    
[http://yann.lecun.com/exdb/mnist/](http://yann.lecun.com/exdb/mnist/)

| FileName | Contents |
----|---- 
| train-images-idx3-ubyte.gz | train images |  
| train-labels-idx1-ubyte.gz | train labels |   
| t10k-images-idx3-ubyte.gz | test images |   
| t10k-labels-idx1-ubyte.gz | test labels |   
  
When expanded it will be the next file.  
(全て展開すると次のファイルになります。)  

| FileName | Contents |
----|---- 
| train-images-idx3-ubyte | train images |  
| train-labels-idx1-ubyte | train labels |   
| t10k-images-idx3-ubyte | test images |   
| t10k-labels-idx1-ubyte | test labels | 
  
Place the following files in the same folder.  
(次のファイルを同じフォルダに配置します。)

| FileName |
|----|
| train-images-idx3-ubyte |  
| train-labels-idx1-ubyte |  
| t10k-images-idx3-ubyte | 
| t10k-labels-idx1-ubyte | 
| mnistex.py | 
| ttest.ipynb | 

Just run test.ipynb with Jupyter Notebook.  
(後は、Jupyter Notebookでtest.ipynbを実行するだけです。)
  
# How to use (mnist.exe)  
  
There are two types of MNIST file,  "image" and "label". And that two are paired.  
(MNISTファイルには「画像」と「ラベル」の2種類の形式があります。そして、その2つはペアになっています。)
  
train data (訓練データ)   = train images + train labels  
test data  (テストデータ) = test images  + test labels  
  
The next is how to use mnist.exe.  
(次はmnist.exeの使い方です。)  

| operation | Contents |
----|---- 
| MNIST to IMAGE | train images |  
| IMAGE to MNIST | train labels |   
| LABEL to MNIST | test images |   
| t10k-labels-idx1-ubyte | test labels | 
  
















 




