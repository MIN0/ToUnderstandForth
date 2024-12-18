# ToUnderstandForth  
# Experimental FORTH system to understand the FORTH language and its systems.  
  
[ 日本語版はここをクリック](README.md)   
  
This is a FORTH system for personal understanding. It is still in the process of being created.
I have saved Intel's 8086 source code (INOUE-FORTH and FIG-FORTH) in Documents that I used as a reference to create ToUnderstandForth is based on INOUE-FORTH created in the 1980s. It was developed in VisualStudio 2022 by rewriting Intel's 8086 source code to Intel's 64-bit source code.The INOUE-FORTH source code was split into FORTH and assembler formats, which caused some bugs The source code of INOUE-FORTH was divided into FORTH and assembler formats, which caused some bugs. Now, based on FIG-FORTH written only in assembler format, numerous fixes and extensions have been made since it was not possible to run the FIG-FORTH source code alone.

The source code of ToUnderstandForth is divided into cpp and asm formats, and development was done in VisualStudio2022 with MASM enabled. I can create an EXE file, but it seems to work only with VisualStudio2022 in my PC. Therefore, I added a note to run ToUnderstandForth from the attached cpp and asm format files so that anyone can check the operation.

The source code I am creating is made up of only basic functionality for the FORTH system. The only things that have been confirmed to work at this time are numerical operations and message display. It also has a trace function to examine execution status.
What I am doing now is to develop a basic FORTH system to understand how ToUnderstandForth works, and if it gets people interested in FORTH, I consider it a success. The next development will be to develop a more flexible FORTH system.  
    
[Go to latest directory “03-02_v0.21.01”](./JPN/Documents/03-02_v0.21.01_ENG)  
  
Translated with DeepL.com (free version)
