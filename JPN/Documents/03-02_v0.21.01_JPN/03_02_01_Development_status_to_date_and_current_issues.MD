# ◎今までの開発状況と現在の課題  

## ・最初にINOUE-FORTHの理解から始まった  
　INOUE-FORTHは日本で１９８０年代に出版された本「標準FORTH」が元になっております。開発のために、私は手入力でこの本からこのソースコードを書き写すことから始めました。  
　INOUE-FORTHは基本部分はMASM(Microsoft Macro Assembler)のアセンブラで、残りはFORTHのソースコードで記述されていました。そのため、FORTHがまだよくわかっていない初心者がこれらのソースコードから実行可能なFORTH処理系へと書き換えるのは非常に困難でした。    
　私は１９８０年代当時にこの本だけでそれぞれのFORTH処理系を作り上げた諸先輩方に尊敬の念を感じます。  
　結局、私はINOUE-FORTHを再現しようとしましたが、FORTHで記述されたソースコードをMASMのアセンブラに書き換えることができませんでした。私が見よう見まねで作成したアセンブラのソースコードではどうしてもエラーが多発し、結局私は開発の継続を断念しました。  
　ですが、私は井上さんの書かれた本である「標準FORTH」からたくさんのことを学びました。この本はFORTH言語について貴重な情報を教えてくれました。「FORTHのABC」に始まり、「FORTHシステムの内部構造」、「FORTHワード」、「FORTHプログラムの作り方」、「FORTH言語の拡張」、「FORTHシステムのインプリメンテーション」、そして「FORTH83（FORTH79とFORTH83との相違点）」など。この本がなければ次のFIG-FORTH(8086版)を理解することはできなかったでしょう。私にとって大切な教科書でした。私はそのことに感謝しています。  
　  
　文献「標準FORTH」については、詳しくは以下を参照ください（ただし、日本語のみで書かれた文献です）  
    
　　[Documents/01_01_Inoue-Forth_SorceCode](https://github.com/MIN0/ToUnderstandForth/tree/main/JPN/Documents/01_01_Inoue-Forth_SorceCode)
  
## ・次に、INOUE-FORTHの元となったFIG-FORTH（8086版）（インテル8086CPU版のソースコードで、すべてMASMで記述されていた）のPDF資料を見つけ、それ以降はFIG-FORTH（8086版）での開発に変更した。  
  
　まず、MASMだけで書かれており、これで初めてソースコードのコンパイル時に発生していたエラーメッセージが表示されなくなった。  
　次に、初期表示画面が正常に画面に現れ、キー入力後、ENTERキーの入力で実行結果が画面上に現れるようになった。  
　私はタイトルメッセージの表示ができるようになったのを確認して、それ以降の修正ではプログラムの名称を「ToUnderstandFORTH」に変更しました。以下は現在の表示画面です。  
　　  
```  
       ToUnderstandFORTH  (Fig-Forth X64) Rev 0.21.02  
　　　　＜ここでキー入力待ちとなる＞  
```  
  
　文献「FIG-FORTH（8086版）」については、詳しくは以下を参照ください（ただし、英語のみで書かれた文献です）  
  
　　[Documents/01_02_Fig-Forth_SorceCode](https://github.com/MIN0/ToUnderstandForth/tree/main/JPN/Documents/01_02_Fig-Forth_SorceCode/fig-forth_8086-8088_ver_10.pdf)  
  
  
  
## ・注意すべき点があります。現在はWindows11の環境で、Visual Studio 2022 + MASM（６４ビット）のDebugモードで開発しています。  
　Visual Studio 2022 のDebugモードなので、/Sourceにある1st_Driver10_FIXED.cppやMainEngine10_FIXED.asmから作成したProject10_FORTH_FULL_FIXED.exeは私が使っているパソコン上でしか動作しませんでした。他のPC上のVisual Studio 2022では動作しません。この記事を読んでいる方で動作を確認するときは、あなたのPCでVisual Studio 2022の環境を準備し、以下の手順でビルドを行い、デバッグを行う必要があります。  
  
## ＜参考例＞  
Visual Studio 2022でMASM(Microsoft Macro Assembler)を動かせるようにするには、Visual Studio 2022で新規プロジェクトを立ち上げてから以下の設定をおこなう必要があります。ここではプロジェクト名はToUnderstandFORT_v0.21.02とします。  
  
　１）画面右側の「ソリューションエクスプローラー」の左に三角形のマークがついたToUnderstandFORT_v0.21.02を右クリック  
　２）メニュー内の「ビルドの依存関係（B)」→「ビルドのカスタマイズ」で「MASM」と書かれたボックスをクリック、「OK」をクリックする。  
  
  
　　![Setup_screen_1-1](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-1.png)




  
　３）ソリューションエクスプローラーで「ソースファイル」を右クリック  
　４）現れたウインドウで「追加」→「既存の項目」→ディレクトリを選んで以下のファイルを追加していく。  
```  
       1st_Driver10_FIXED.cpp　　 　→C++で書かれたソースコード  
　　　　MainEngine10_FIXED.asm　　　→アセンブラ（インテルｘ６４）で書かれたソースコード  
```  
  
![Setup_screen_1-2](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-2.png)


　５）ソリューションエクスプローラーの「ソースファイル」に表示されているMainEngine9_FIXED.asmにカーソルを合わせて右クリック  
　６）「プロパティ」をクリックして、「構成プロパティ」「全般」で設定が完了すれば、次の７）の順番で実行します。    
```  
　　　　　　「ビルドから除外」で「いいえ」  
　　　　　　「項目の種類」で「Microsoft Macro Assembler」を選択、「OK」をクリックする。  
```  
  
![Setup_screen_1-3](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-3.png)  
  
![Setup_screen_1-4](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-4.png)  


  
  
　７）ビルド（ソリューションのビルド）→デバッグ（デバッグの開始）  
  
![Execution screen_1-5](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Execution%20screen_1-5.png)  
  
![Execution screen_1-6](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Execution%20screen_1-6.png)  

  
  
これで「 ToUnderstandFORTH  (Fig-Forth X64) Rev 0.21.02 」が画面に表示されれば成功です。  
  
  
[次のページへ ](./03_02_02_A_brief_description_of_ToUnderstandFORTH.MD)  
