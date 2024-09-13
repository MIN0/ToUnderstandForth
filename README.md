# ToUnderstandForth  
# Experimental FORTH system to understand the FORTH language and its systems.  
  
[ Click here for English version](README_ENG.md)   
  
これは個人的な理解のためのFORTHシステムです。それはまだ作成途中のものです。
私はDocumentsの中に作成する参考になったIntelの８０８６のソースコード（INOUE-FORTHとFIG-FORTHの２種類）を保存しています。最初に開発されたToUnderstandForthは１９８０年代に作成されたINOUE-FORTHを基にしています。Intelの８０８６のソースコードをIntelの６４ビットのソースコードに書き換えて開発されました。INOUE-FORTHのソースコードはFORTH形式とアセンブラ形式に分かれていたので、いくつかのバグが発生してしまいました。現在、アセンブラ形式のみで書かれたFIG-FORTHを基に修正を行っています。

ToUnderstandForthのソースコードはcpp形式とasm形式に分かれ、開発はVisualStudio2022でMASMを有効にして開発しました。今回はEXE形式のファイルも掲載しています。VisualStudio2022のデバッグモードで開発を行っており、動作確認はデバッグモードで行いました。若干実行結果が異なるようですが、EXE形式のファイルも動作確認ができます。ただし、キー入力したFORTHプログラムを実行して正常に出力結果が返ってくるのはまだ少ない状況です。私はメモを追加しました。

私が作成しているソースコードはFORTHシステムとしては基本的な機能のみです。私は実験的に動作する基本的なFORTHシステムを開発し、次の開発でより柔軟なFORTHシステムを目指します。
