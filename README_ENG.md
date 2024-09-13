# ToUnderstandForth  
# Experimental FORTH system to understand the FORTH language and its systems.  
  
「 日本語版はここをクリック」(README.md)   
  
This is a FORTH system for personal understanding. It is still in the process of being created.
I have saved the Intel 8086 source code (INOUE-FORTH and FIG-FORTH) in Documents that I used as a reference to create it. The first ToUnderstandForth was based on INOUE-FORTH created in the 1980's. It was developed by rewriting Intel's 8086 source code into Intel's 64-bit source code. FORTH format and assembler format, which caused some bugs. We are currently making corrections based on FIG-FORTH, which was written in assembler format only.

The ToUnderstandForth source code was divided into cpp and asm formats, and development was done in VisualStudio 2022 with MASM enabled. The EXE format file is also included in this issue; it was developed in debug mode of VisualStudio2022, and its operation was checked in debug mode. Although the execution result seems to be slightly different, the EXE format file can also be used to check the operation. However, there are still a few situations where the keyed-in FORTH program is executed and the output results are returned normally. I have added a note.

The source code I am creating is only basic functionality for the FORTH system. I have developed a basic FORTH system that works on an experimental basis and will work toward a more flexible FORTH system in the next development.

Translated with DeepL.com (free version)
