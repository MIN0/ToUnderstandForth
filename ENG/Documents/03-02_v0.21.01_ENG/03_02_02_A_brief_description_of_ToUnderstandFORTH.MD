# A brief description of ToUnderstandFORTH  
  
Most of the literature I am aware of on FORTH was written around 1990, but some of it is still available. I will only give a brief description here, so please refer to that for more information.
  
### -Standard FORTH  
(Japanese only. Available from the Internet Library of Japanese Libraries. Registration is required for use.)
  
[click here to view the library's Japanese language screen](https://ndlsearch.ndl.go.jp/search?cs=bib&collapse=null&display=panel&from=0&size=20&amp;keyword=%E6%A8%99%E6%BA%96FORTH&f-ht=ndl&f-ht=library)    
  
[Click here to view the library's English screen](https://ndlsearch.ndl.go.jp/en/search?cs=bib&collapse=null&display=panel&from=0&size=20&keyword=forth+inoue&f-ht=ndl)  
  
  
### -[Starting FORTH ](https://www.forth.com/starting-forth/0-starting-forth/)  
(This is the web version, so you can read it in your language.)  
  
### -[A Beginner's Guide to Forth ](https://galileo.phys.virginia.edu/classes/551.jvn.fall01/primer.htm)  
(English only)  
<br>  
  
Also, there is a FORTH web developed for MSX (due to circumstances, it has now been moved on my GitHub).  
  
### -[H-FORTH_MSX ](https://github.com/MIN0/H-FORTH_MSX)  
(Japanese and English)  
<br>  
  
  
# Simple reverse Polish notation and word description  
## -Normal arithmetic operations are performed in Polish notation, as follows
````  
  5+4-3 = 6 
````  
However, this is not the case with the FORTH language.
  
## -FORTH language is done in reverse Polish notation, using a stack.
  
 Numerical operations with FORTH stack operations are as follows  
 (1) The numbers n1 and n2 are piled on the stack.  
 (2) The word "+" takes the numbers n1 and n2 and operates on them. The numbers n1 and n2 disappear from the stack.  
 (3) The numeric value n3 obtained by the word "+" operation is piled on the stack.
  
  
The figure shows the state of the stack at that time. When a number is added to the stack, it is placed on top of the highest number in the diagram, and that number becomes the highest value.
  
[!IMPORTANT]  
(Note 1) A parenthesis over a number indicates that it is the top of the stack.
(Note 2) ----- is the bottom of the stack, indicating that it will be empty when the entire stack is spit out.
(Note 3) The non-numeric "+", "-", and "*" here are called words. Words can define and execute the processing of data on the stack and various other processes.
  
  
a)  
  If `4 3 -`, the result is 4 minus 3 and the result is 1.  
  
````  
             (3)  
   (4)  -->   4   --> - -->  (1)  
  -----     -----           -----  
````  
  
b)  
  If `5 1 +`, then 5 and 1 are added and the result is 6.  
````   
             (1)  
   (5)  -->   5   --> + -->  (6)  
  -----     -----           -----  
````  
  
c)  
  If `5 4 3 - +`, the process runs from left to right. Three numbers are put on the stack. With the word `-`, the top stack is calculated from the second stack (4 minus 3), and the resulting number 1 is placed on the stack after the numbers 4 and 3 disappear. With the word "+", the top stack is calculated from the second stack (5 and 1 are added), and the resulting number 6 is added to the stack after the numbers 5 and 1 disappear. This is the same as the result of 5 + 4 - 3 in normal Polish notation.
  
````    
                       (5)  
             (4)        4              (9)  
   (3)  -->   3   -->   3   --> + -->   3   --> - -->  (6)  
  -----     -----     -----           -----           -----  
````  
  
But the explanation is difficult to understand, for example, the order of operations is reversed. I am also pondering whether a better explanation is possible.
<br>  
  
## -This is talking about some words of arithmetic operations, and the number of stacks consumed at runtime and the number of stacks built up afterwards varies from word to word.
FIG-FORTH uses the following presentation to aid understanding:" Strings written between "(" and ")" are treated as comments and not executed." The left side of " ---" represents the state of the stack before execution and the right side represents the state of the stack after execution.
  
   The state of the stack for `( n11 n12 n13 --- n21 n22 )` is as follows.
  
````    
      (n13)  
       n12   
       n11  
      -----     
At runtime, numbers are taken from the stack in the order n13 --> n12 --> n11.
````  
  
````  
      (n22)   
       n21  
      -----     
After execution, the numbers are stacked on the stack in the order n21 --> n22.
````  
<br>  
  
When defining a new word, use the word ":" and the word ";" to define it. For example, when defining word 2SUB1, which subtracts two numbers on the stack and leaves the value on the stack, it can be written as follows
  
    `: 2SUB1 ( n1 n2 --- n3 ) - ;`  
<br>

The relationship between the values n1, n2, and n3 here is `n3 = n1 - n2`.
  
  
# Try to move ToUnderstandFORTH.
  
## Let's move it  
-The available PC is Windows. Referring to "Development to date and current issues," start Visual Studio 2022 and click on "Start Debugging (S). After a short time, the command prompt appears and waits for key input after displaying the initial message of FORTH.
-Keystroke the FORTH word in a row there, and press ENTER at the end.
-Keyed FORTH word sequence is executed and the word sequence is executed, including displaying characters on the screen.
-When execution of all keyed-in FORTH word strings is completed, "OK" is displayed on the screen. If an error occurs in the middle of the execution, some message is displayed and "OK" is usually displayed on the screen.
<br>  
  
  
For example, the following is a numerical calculation using "+", "-", and "*".
"."(dot) displays the calculated results on the screen.
Calculations here are done in reverse Polish notation, not the usual Polish notation.
    
  `4 5 + . [ENTER]           --> 9 OK `   Add 4 and 5 
  `3 4 5 + - . [ENTER]       --> -6 OK`   Add 4 and 5. Then subtract the result from 3.
  `2 3 4 5 + - * . [ENTER]   --> -12 OK`  Add 4 and 5, subtract the result from 3. Then multiply 2 by the result.
    
<br>  
  
# Words currently confirmed to run successfully in ToUnderstandFORTH  
  
So far, the words that can be successfully executed are as follows
  
 (1) Numerical values, "+", "-", "*", "."(dot) are used, normal results are displayed.
````  
        Example:  
              Enter          : 1 2 + . [enter]    
              Output contents: 3 OK  
````  
  
 (2) The string is displayed on the screen.
````  
              Enter         : ." Hello!" [enter]   
              Output content: Hello!   
````  
  
 (3) The words `TRACE_ON` and `TRACE_OFF` are newly created words that toggle "display/not display" of the currently executed word name, registers in use, and other information on the screen.
````  
              Enter           : TRACE_ON 1 . TRACE_OFF [enter]   
　　　         Output contents: (see Note 4)  
````  
> [!IMPORTANT]  
> (Note 4) (Too much to display on the screen, so I will omit it, but `1 . ` is parsed by each word (WORD, INTERPRET, etc.) and the status of execution is displayed)  
  
The information displayed in TRACE_ON is displayed with the position of the first character of the line shifted to the left or right depending on the depth of the word being executed. When a word is executed, the registered internal words are executed one after another. At that time, the displayed first character position is shifted one character to the right, and when the execution of the internal word is completed, the displayed first character position is shifted one character to the left. For your reference.
  
# Example of display when an error occurs  
ToUnderstandFORTH is still under development. The following is one such example.
  
 (1) When registering a new word in the dictionary (executing a FORTH statement surrounded by ":" and ";"), an exception error is displayed because for some reason ToUnderstandFORTH accesses an address other than the range of addresses it reserves during processing. The process is reset and returns to the initial state.
```  
            Enter          :         : TEST_NAME 1 2 + . ; [enter]   
　　　　　　 Output contents:  
                       WORD_POINTER_ADDRESS(R8): : =2032203120454d2f  
                       WRITE_REGISTER_NUMBER(R9): : =103  
                       7ff7b6ac2bb0 = 7ff7b6ac8e27  
                       7ff7b6adc000 = 7ff7b6af5fdf  
                       BREAK_POINT_Stack 1st : =7ff7b6ac721f  
                       BREAK_POINT_Stack 2nd : =4e5f54534554203a  
                       break_point_number : =10403  
                       PUSH 'Y' KEY TO COLD START  
```  
  
[Go to the next page ](./03_02_03_Process_flow_of_ToUnderstandFORTH.MD)
