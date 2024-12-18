# ToUnderstandForth  
# Experimental FORTH system to understand the FORTH language and its systems.  
[ Click here for English version](README_ENG.md)   
  
# FORTH言語とそのシステムを理解するためのFORTH実験システム。  
これは個人的な理解のためのFORTHシステムです。それはまだ作成途中のものです。
私はDocumentsの中に作成するのに参考になったIntelの８０８６のソースコード（INOUE-FORTHとFIG-FORTHの２種類）を保存しています。ToUnderstandForthは１９８０年代に作成されたINOUE-FORTHを基にしています。Intelの８０８６のソースコードをIntelの６４ビットのソースコードに書き換えて、VisualStudio2022で開発されました。INOUE-FORTHのソースコードはFORTH形式とアセンブラ形式に分かれていたので、いくつかのバグが発生してしまいました。現在、アセンブラ形式のみで書かれたFIG-FORTHを基に、FIG-FORTHのソースコードだけでは実行できなかったので数々の修正と拡張を行っています。

ToUnderstandForthのソースコードはcpp形式とasm形式に分かれ、開発はVisualStudio2022でMASMを有効にして開発しました。VisualStudio2022のデバッグモードで開発を行っており、動作確認はデバッグモードで行いました。EXEファイルの作成もできますが、それだと私のPC内にあるVisualStudio2022でしか動作できないようです。そのため誰でも動作確認ができるように、添付したcpp形式とasm形式のファイルからToUnderstandForthを実行するためのメモを追加しました。

私が作成しているソースコードは、FORTHシステムとしては基本的な機能だけでできています。今現在動作が確認されているのは、数値演算やメッセージの表示程度です。また、実行状況を調べるためのトレース機能を備えています。
私が今行っていることは、ToUnderstandForthの動作を理解するための基本的なFORTHシステムを開発することで、もしもFORTHに興味を持ってもらえたら成功だと思っています。次の開発では、より柔軟なFORTHシステムの開発を目指します。  
  
[最新のディレクトリ「03-02_v0.21.01」へ ](./JPN/Documents/03-02_v0.21.01_JPN)      
