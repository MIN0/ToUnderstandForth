# ToUnderstandForth  
# Experimental FORTH system to understand the FORTH language and its systems.  
  
[ Click here for English version](README_ENG.md)   
  
# Experimental FORTH system to understand the FORTH language and its systems.  
これは個人的な理解のためのFORTHシステムです。それはまだ作成途中のものです。
私はDocumentsの中に作成するのに参考になったIntelの８０８６のソースコード（INOUE-FORTHとFIG-FORTHの２種類）を保存しています。ToUnderstandForthは１９８０年代に作成されたINOUE-FORTHを基にしています。Intelの８０８６のソースコードをIntelの６４ビットのソースコードに書き換えて、VisualStudio2022で開発されました。INOUE-FORTHのソースコードはFORTH形式とアセンブラ形式に分かれていたので、いくつかのバグが発生してしまいました。現在、アセンブラ形式のみで書かれたFIG-FORTHを基にが、それだけでは実行できなかったので数々の修正を行っています。

ToUnderstandForthのソースコードはcpp形式とasm形式に分かれ、開発はVisualStudio2022でMASMを有効にして開発しました。VisualStudio2022のデバッグモードで開発を行っており、動作確認はデバッグモードで行いました。EXEファイルの作成もできますが、私のPC内にあるVisualStudio2022でしか動作できないようです。そのため、添付したcpp形式とasm形式のファイルから実行するためのメモを追加しました。

私が作成しているソースコードはFORTHシステムとしては基本的な機能のみです。動作を確認できたのは私は実験的に動作する基本的なFORTHシステムを開発し、次の開発でより柔軟なFORTHシステムを目指します。
