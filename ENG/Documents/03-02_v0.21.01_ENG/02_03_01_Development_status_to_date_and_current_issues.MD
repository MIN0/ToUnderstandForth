# ◎Development to date and current issues  

## First started with understanding INOUE-FORTH  
-INOUE-FORTH is based on the book “Standard FORTH” published in Japan in the 1980s. For development, I started by manually transcribing this source code from this book.  
-The basic part of INOUE-FORTH was written in MASM (Microsoft Macro Assembler) assembler and the rest in FORTH source code. Therefore, it was very difficult for beginners who were not yet familiar with FORTH to rewrite from these source codes to an executable FORTH processor.    
-I have a lot of respect for those who, back in the 1980s, created their own FORTH processor based on this book alone.  
-In the end, I tried to reproduce INOUE-FORTH, but I could not rewrite the source code written in FORTH into the MASM assembler. The assembler source code that I had created by imitation inevitably produced many errors, and in the end I gave up on continuing the development.  
-However, I learned a lot from the book “Standard FORTH” written by Mr. Inoue. This book gave me valuable information about the FORTH language. Starting with “The ABC's of FORTH,” the book also covers “Internal Structure of the FORTH System,” “FORTH Words,” “How to Create a FORTH Program,” “Extensions to the FORTH Language,” “Implementation of the FORTH System,” and “FORTH83 (Differences between FORTH79 and FORTH83). ),” etc. Without this book, I would not have been able to understand the next FIG-FORTH (8086 edition). It was an important textbook for me. I am grateful for that.  
  
-For more information about the document “Standard FORTH”, please refer to the following (however, this document is written only in Japanese)  
    
[Documents/01_01_Inoue-Forth_SorceCode](https://github.com/MIN0/ToUnderstandForth/tree/main/ENG/Documents/01_01_Inoue-Forth_SorceCode)  
  
## Next, we found a PDF document of FIG-FORTH (8086 version) (source code for Intel 8086 CPU version, written entirely in MASM), which was the original of INOUE-FORTH, and changed to development in FIG-FORTH (8086 version) after that.  
  
-First, it was written only in MASM, and for the first time, error messages that had occurred when compiling the source code were no longer displayed.  
-Second, the initial display screen appeared on the screen normally, and the execution result appeared on the screen after key input and ENTER key input.  
-I confirmed that the title message could now be displayed and changed the name of the program to “ToUnderstandFORTH” in subsequent modifications. Below is the current display screen.  
  
```  
       ToUnderstandFORTH (Fig-Forth X64) Rev 0.21.01  
       <  
```  
  
-For more information about the document “FIG-FORTH (8086 version)”, please refer to the following (however, the document is written only in English)  
  
[Documents/01_02_Fig-Forth_SorceCode](https://github.com/MIN0/ToUnderstandForth/tree/main/JPN/Documents/01_02_Fig-Forth_SorceCode) 
  
  
  
## There are some points to note. 
 I am currently developing in Windows 11 environment with Visual Studio 2022 + MASM (64 bit) in Debug mode.  
 Because of Visual Studio 2022's Debug mode, Project9_FORTH_FULL_FIXED.exe created from 1st_Driver9_FIXED.cpp and MainEngine9_FIXED.asm in /Source only worked on my computer. I could only run it on my PC. It does not work with Visual Studio 2022 on other PCs. If you are reading this article and want to check the operation, you need to prepare Visual Studio 2022 environment on your PC, build and debug it by following the steps below.  
  
## Reference Example.  
To make MASM (Microsoft Macro Assembler) work with Visual Studio 2022, you need to start a new project in Visual Studio 2022 and configure the following settings. In this example, the project name is Project9_FullTest_FIXED.  
  
 (1) Right-click on Project9_FullTest_FIXED, which is marked with a triangle to the left of the “Solution Explorer” on the right side of the screen.  
 (2) In the menu, go to “Build Dependencies (B)” -> “Customize Build” and click the box marked “MASM”, then click “OK”.  
  
  
![Setup_screen_1-1](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-1.png)




  
 3) Right-click on “Source Files” in the Solution Explorer.  
 4) In the window that appears, select “Add” -> “Existing Items” -> Directory and add the following files.  
```  
       1st_Driver9_FIXED.cpp → source code written in C++  
       MainEngine9_FIXED.asm → source code written in assembler (Intel x64)  
```  
  
![Setup_screen_1-2](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-2.png)


 5) Move the cursor to MainEngine9_FIXED.asm listed in “Source Files” in the Solution Explorer and right-click 
 6) Click on “Properties” and under “Configuration Properties” and “General  
```  
 Under “Exclude from Build,” ``No  
 Under ````Type of item''' select ```Microsoft Macro Assembler''' and click ```OK.  
```  
  
![Setup_screen_1-3](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-3.png)  
  
![Setup_screen_1-4](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Setup_screen_1-4.png)  


  
Once setup is complete, execute the following 7) in the following order  
  
 7) Build (build the solution) → Debug (start debugging)  
  
![Execution screen_1-5](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Execution%20screen _1-5.png)  
  
![Execution screen_1-6](https://github.com/MIN0/ToUnderstandForth/blob/main/JPN/Documents/03-02_v0.21.01_JPN/pict/Execution%20screen _1-6.png)  

  
  
If “ToUnderstandFORTH (Fig-Forth X64) Rev 0.21.01” now appears on the screen, you have succeeded.  
  
  
[Go to the next page ](./03_02_02_A_brief_description_of_ToUnderstandFORTH.MD)  

Translated with DeepL.com (free version)
