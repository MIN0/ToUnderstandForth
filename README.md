# ToUnderstandForth  
# Experimental FORTH system to understand the FORTH language and its systems.  
  
[ Click here for English version](README_ENG.md)   
  
これは個人的な理解のためのFORTHシステムです。それはまだ作成途中のものです。  
私はDocumentsの中に作成する参考になったIntelの８０８６のソースコード（INOUE-FORTHとFIG-FORTHの２種類）を保存しています。最初に開発されたToUnderstandForthは１９８０年代に作成されたINOUE-FORTHを基にしています。Intelの８０８６のソースコードをIntelの６４ビットのソースコードに書き換えて開発されました。INOUE-FORTHのソースコードはFORTH形式とアセンブラ形式に分かれていたので、いくつかのバグが発生してしまいました。現在、アセンブラ形式のみで書かれたFIG-FORTHを基に修正を行っています。  
  
ToUnderstandForthのソースコードはcpp形式とasm形式に分かれ、開発はVisualStudio2022でMASMを有効にして開発しました。残念ながら私はそれらをEXE形式に変換できませんでした。VisualStudio2022のデバッグモードで開発を行っており、動作確認はデバッグモードで行いました。  
  
私が作成しているソースコードはFORTHシステムとしては基本的な機能のみです。私は実験的に動作するFORTHシステムを開発し、次の開発でより柔軟なFORTHシステムを目指します。  
