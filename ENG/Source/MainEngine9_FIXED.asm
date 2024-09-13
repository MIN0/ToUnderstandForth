; １）最も最初にC++ファイルが実行される。その中で、以下が実行されて、ASMファイルが呼び出される。
;   Call_Rtn = TestProc(&c);
; ２）ASMファイルでは、最初に.CODEの一番最初のプロシジャーであるTestProcの先頭のアドレス（ ORIG:: ）から実行が始まる。
; ３）ASMファイルでFORTH処理系が実行される。
; ４）文字の入出力／ファイルの入出力／キー入力の確認／トレースモードのオンオフ／実行の終了を実行する場合はASMの処理を終了して、C++に戻る。
; ５）C++でのTestProc(&c)が終了したので、&Cを確認して指定された処理を行う。
; ６）処理が完了したので、今度は次の処理を行い、ASMファイルが呼び出される。
;   C_Rtn = call_C_exit(&c);
; ７）ASMファイルでは、.CODE内のプロシジャーであるTestProcの先頭のアドレス（ ORIG:: ）から実行が始まる。






;
;
includelib kernel32.lib
includelib user32.lib
;includelib libcmt.lib
includelib legacy_stdio_definitions.lib

; 外部関数の宣言
; Windows の関数
EXTERN MessageBeep: PROC
EXTERN MessageBoxA: PROC
; C ランタイムライブラリの関数
EXTERN printf_s: PROC
EXTERN getchar: PROC

; まだ実験中なのでここは整理できていない
EXTERN _getwch: PROC
EXTERN _putwch: PROC
EXTERN _getch: PROC
EXTERN _putch: PROC
EXTERN printf: PROC
;EXTERN sprintf_s: PROC
EXTERN scanf_s: PROC
EXTERN fputc: PROC
EXTERN _getch: PROC
EXTERN fopen_s: PROC
EXTERN fclose: PROC
EXTERN fprintf_s: PROC



; 例
;mymacro MACRO  value:REQ, reg:=<AX>, options:VARARG
;        LOCAL  returnval
;        .
;        .
;        .
;        ENDM

MACRO_NEXT1_1   MACRO

;; ****FORTH_INNER_INTERPRETER****
;
;NEXT1:
    mov [save_r8],R8  ; display Regs.
    mov [save_r9],R9  ; display Regs.

;       lea r8,SEE_THIS_WORD
       mov r8,[rsi]
;       mov [SEE_THIS_WORD],r8
       mov r9,[SEE_THIS_WORD_ptr]

;
; レジスタのオーバーフローチェック
         PUSH R8
         PUSH R9
         MOV R8,R9
         MOV R9,101H
         CALL CHECK_MEM_WRITE
         POP R9
         POP R8
;
       mov [r9],r8

    mov R9,[save_r9]  ; display Regs.
    mov R8,[save_r8]  ; display Regs.

    ENDM



MACRO_NEXT_1 MACRO

;NEXT:
    mov [save_r8],R8  ; display Regs.
    mov [save_r9],R9  ; display Regs.

       mov r8,[rsi]
       mov r9,[SEE_THIS_WORD_ptr]
;
; レジスタのオーバーフローチェック
    mov [save_r8_2],R8  ; display Regs.
    mov [save_r9_2],R9  ; display Regs.
         MOV R8,R9
         MOV R9,102H
         CALL CHECK_MEM_WRITE
    mov R9,[save_r9_2]  ; display Regs.
    mov R8,[save_r8_2]  ; display Regs.
;
       mov [r9],r8

    mov R9,[save_r9]  ; display Regs.
    mov R8,[save_r8]  ; display Regs.


    ENDM



MACRO_NEXT_2 MACRO

; このマクロがある場所は NEXT1_9: の近くにあります。

;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ FORTH_INNER_INTERPRETER_SKIP01

       call myFunc
       call myFunc2



FORTH_INNER_INTERPRETER_SKIP01:

;
; レジスタのオーバーフローチェック
         PUSH R8
         PUSH R9
         MOV R8,RBX
         MOV R9,103H
         CALL CHECK_MEM_WRITE
         POP R9
         POP R8


    ENDM





; 以下の内容はFIG-FORTHのものをそのまま使用している。

;; ASM86 VER 1.0 SOURCE: FORTH.A86 Fig Forth 8080/88 Ver 1.0  PAGE2
;
;       RELEASE & VERSION NUMBERS
;
FIGREL  EQU     0       ; FIG RELEASE #
FIGREV  EQU     1       ; FIG REVISION #
USRVER  EQU     0       ; USER VERSION #
;
;       ASCII CHARACTERS USED
;
ABL     EQU     20H     ; SPACE
ACR     EQU     0DH     ; CARRIAGE RETURN
ADOT    EQU     02EH    ; PERIOD
BELL    EQU     07H     ; (^G)
BSIN    EQU     5FH     ; INPUT DELETE CHAR
BSOUT   EQU     08H     ; OUTPUT BACKSPACE (^H)
DLE     EQU     10H     ; (^P)
LF      EQU     0AH     ; LINE FEED
FF      EQU     0CH     ; FORM FEED (^L)


;       MEMORY ALLOCATION
;
EM      EQU     4000H   ; END OF MEMORY + 1
NSCR    EQU     1       ; NO. 1024 BYTE SCREENS
KBBUF   EQU     128     ; DATA BYTES PER DISK BUF
US      EQU     4QH     ; USER VARIABLES SPACE
RTS     EQU     0A0H    ; RETURN STK & TERM BUF.
;
CO      EQU     KBBUF-4 ; DISK 3UFFER +4 YYTSS
NBUF    EQU     NSCR*1024/KBBUF     ; N3. OF 3LFFEXS
BUF1    EQU     EM-CO*NBUF          ; FIZST DISK BUF
;INITR0  EQU     BUF1-US            ; (R0)
;INITS0  EQU     INITR0-RTS          ; (S0)



;*********メモリマップ（最初の絶対番地の考え方）
;
;
;0100H 辞書
;　　　辞書の終わり
;      DP　辞書の終わり+1
;
;
;S0_TOP =     UP-800
;INITS0 =     S0_TOP ;本当にいいんだろうか？
;INITR0 =     UP-2   ;本当にいいんだろうか？
;UP     =     FIRST - 60
;FIRST  =     LIMIT - BFLEN * 2 (_BUFF) 
;             LIMIT - BFLEN * 1  
;LIMIT  =     8000H




.LISTALL
.data



DATA_START:

SCANPROMPT      BYTE    "Enter a number: ", 0
SCANPROMPT_error      BYTE    "An error occurred (press any key to continue execution)", 0
SCANPROMPT_stop      BYTE    "Stop:REC/BLK : ", 0
SCANFORMAT      BYTE    "%d", 0
;PRINTFORMAT     BYTE    "number=%c, str=%s", 0Dh, 0Ah, 0
PRINTFORMAT1     BYTE    "%c", 0
;PRINTFORMAT2     BYTE    "%c", 0Dh, 0Ah, 0
PRINTFORMAT2     BYTE    "%c => ", 0
PRINTFORMAT3     BYTE    "%c", 0
PRINTFORMAT4     BYTE    "%c - ", 0
PRINTFORMAT5     BYTE    0Dh, 0Ah, 0
HELLOSTR        BYTE    "Hello!", 0
;MSGTITLE        BYTE    "Sample2", 0

CIN_SCAN_VAL      BYTE   0
CIN_SCAN_FORMAT   BYTE   "%s",0
COUT_PRINT_VAL    BYTE   0
COUT_PRINT_FORMAT BYTE   "%s",0
;POUT_FP_PTR       
key_w_plus    BYTE   "w+",0 ;1d9h  ; READ ONLY
FILE_NAME       BYTE    "fseek.out",0
;STR_FORMAT      BYTE    "%s",0
fb_File     BYTE    100 dup (5Ah)
;fb_File         BYTE    255 dup (5Ah)
ptr_fb_File         QWORD    fb_File
;stream         QWORD    0
;line           BYTE     81 dup (00h)
;SCANPROMPT_03f     BYTE    "%s",0
SCANPROMPT_03f     BYTE    "%c",0
SCANPROMPT_03      BYTE    "The fseek begins here: This is the file 'fseek.out'.", 0Dh, 0Ah,0



WORD_SCANVAL      QWORD    0
WORD_NAME_LIT            BYTE    "WORD=LIT:",0
WORD_NAME_@            BYTE    "WORD=@:",0
WORD_NAME_PLUS           BYTE    "WORD=+:",0
WORD_NAME_DOUSE          BYTE    "WORD=DO-USER:",0
WORD_NAME_DOCON          BYTE    "WORD=DO-CONSOLE:",0
WORD_NAME_DOVAR          BYTE    "WORD=DO-VARIABLE:",0
WORD_NAME_BREAK_POINT    BYTE    "WORD=BREAK_POINT:",0
WORD_NAME_Register       BYTE    "WORD=Registers:",0
WORD_NAME_0BRAN           BYTE    "WORD=0BRANCH (STACK VALUE not eq 0):",0
WORD_NAME_BRAN           BYTE    "WORD=BRANCH or 0BRANCH (STACK VALUE == 0):",0




DUMMY                   BYTE     "WORK_BREAK_POINT_RAX",0
WORK_BREAK_POINT_RAX     QWORD   1
WORK_BREAK_POINT_RBX     QWORD   1
WORK_BREAK_POINT_NUMBER     QWORD   99H

buf_WORK_BREAK_POINT_RAX        qword   0
buf_WORK_BREAK_POINT_RBX        qword   0
buf_WORK_BREAK_POINT_R10        qword   0
buf_WORK_BREAK_POINT_R11        qword   0

WORD__ADDRESS_SEARCH_RSI        QWORD   0
WORD__ADDRESS_SEARCH_RDI        QWORD   0
WORD__ADDRESS_SEARCH_RCX        QWORD   0



PRT_FORM_Param                  BYTE    " %s : =%llx", 0Dh, 0Ah, 0
PRT_FORM_MESSAGE                  BYTE    " %s ", 0Dh, 0Ah, 0
PRT_FORM_FROM_TO                  BYTE    " %llx = %llx ", 0Dh, 0Ah, 0
WORD_NAME_BREAK_POINT_RAX       BYTE    "BREAK_POINT_Stack 1st",0
WORD_NAME_BREAK_POINT_RBX       BYTE    "BREAK_POINT_Stack 2nd",0
WORD_NAME_BREAK_POINT_NUMBER    BYTE    "BREAK_POINT_NUMBER",0
WORD_NAME_BREAK_POINT_MESSAGE    BYTE    "PUSH 'Y' KEY TO COLD START",0
WORD_NAME_BREAK_POINT_R8       BYTE    "WORD_POINTER_ADDRESS(R8): ",0
WORD_NAME_BREAK_POINT_R9       BYTE    "WRITE_REGISTER_NUMBER(R9): ",0

PRT_FORM_OF_SERCH_WORD        BYTE    " %s = %llx ", 0Dh, 0Ah, 0
WORD_ADDR_OF_SERCH_WORD       BYTE    "WORD_ADDR_OF_SERCH_WORD: ",0
PRT_FORM_OF_SERCH_WORD_ERROR        BYTE    " *** ERROR OCCUREED *** ", 0Dh, 0Ah, 0



;WORD_Reg_PRINTFORMAT     BYTE    "[rsp]:64*1024 [rbp]:32*1024 [rsi];16*1024 [rdx]:8*1024 rsp:64 rbp:32 rsi:16 rdx:8 rcx:4 rbx:2 rax:1"
;WORD_rax_PRINTFORMAT     BYTE    " %s RAX: I64u=%I64u", 0Dh, 0Ah, 0
WORD_rax_PRINTFORMAT     BYTE    " %s RAX: =%llx", 0Dh, 0Ah, 0
WORD_rbx_PRINTFORMAT     BYTE    " %s RBX: =%llx", 0Dh, 0Ah, 0
WORD_rcx_PRINTFORMAT     BYTE    " %s RCX: =%llx", 0Dh, 0Ah, 0
WORD_rdx_PRINTFORMAT     BYTE    " %s RDX: =%llx", 0Dh, 0Ah, 0
WORD_rsi_PRINTFORMAT     BYTE    " %s RSI: =%llx", 0Dh, 0Ah, 0
WORD_rbp_PRINTFORMAT     BYTE    " %s RBP: =%llx", 0Dh, 0Ah, 0
WORD_rsp_PRINTFORMAT     BYTE    " %s RSP: =%llx", 0Dh, 0Ah, 0
WORD_rdx2_PRINTFORMAT     BYTE    " %s [RDX]: =%llx", 0Dh, 0Ah, 0
WORD_rsi2_PRINTFORMAT     BYTE    " %s [RSI]: =%llx", 0Dh, 0Ah, 0
WORD_rbp2_PRINTFORMAT     BYTE    " %s [RBP]: =%llx", 0Dh, 0Ah, 0
WORD_rsp2_PRINTFORMAT     BYTE    " %s [RDX]: =%llx", 0Dh, 0Ah, 0






TEST1        BYTE    "S", 0
SEE_THIS_WORD DQ 0
DEBUG_DUMP_LEVEL  DW 0         ; トレース情報を表示するときのレベルの深さによって、最初に出力するスペースの数を指示する
DEBUG_DUMP_LEVEL2 DW 0
SCAN_VAL_20H DW 20h

save_rax     QWORD   1111h
save_rbx     QWORD   2222h
save_rcx     QWORD   3333h
save_rdx     QWORD   4444h
save_rsi     QWORD   5555h
save_rbp     QWORD   6666h
save_r8      QWORD   7777h
save_r9      QWORD   8888h
save_r8_2      QWORD   7777h
save_r9_2      QWORD   8888h
save_r10     QWORD   9999h
save_r11     QWORD   0AAAAh
save_rsp     QWORD   0BBBBh

save_rax_3     QWORD   1111h
save_rbx_3     QWORD   2222h
save_rcx_3     QWORD   3333h
save_rdx_3     QWORD   4444h
save_rsi_3     QWORD   5555h
save_rbp_3     QWORD   6666h
save_r8_3      QWORD   7777h
save_r9_3     QWORD   8888h
save_r10_3     QWORD   9999h
save_r11_3     QWORD   0AAAAh

save_r9_4     QWORD   8888h



call_C_entry_save_rax qword 0   ; r10= 000001
call_C_entry_save_rbx qword 0   ; r10= 000010
call_C_entry_save_rcx qword 0   ; r10= 000100
call_C_entry_save_rdx qword 0   ; r10= 001000
call_C_entry_save_rsi qword 0   ; r10= 010000
call_C_entry_save_rbp qword 0   ; r10= 100000
call_C_entry_save_r8  qword 0   ; display Regs.
call_C_entry_save_r9  qword 0   ; display Regs.
call_C_entry_save_r10 qword 0   ; display Regs.
call_C_entry_save_r11 qword 0   ; display Regs.
call_C_entry_save_rsp qword 0   ; display Regs.


RET_call_C_entry_save_rsp qword 0
RET_call_C_entry_save_rbp qword 0
RET_call_C_entry_save_rcx qword 0

PTR_STACK       QWORD   STACK_TOP
EXECUTE_SEE_THIS_WORD_ptr         QWORD   EXECUTE_SEE_THIS_WORD
EXECUTE_SEE_THIS_WORD             QWORD   0


save_reg_ADR_TIB   QWORD   0
check_dat_ADR_TIB   QWORD   0

addr_STACK_BOTOM   QWORD   0

ERR_myFunc_PROC_01 DB 'myFunc PROC: The seventh bit on both ends of the NFA was not 1.'
ERR_myFunc_PROC_02 DB 'myFunc PROC: The length of the NFA word name is more than 32 bytes.'
ERR_myFunc_PROC_03 DB 'myFunc PROC: This is an unregistered word name.'

CHECK_ADDR_NEW     QWORD  12345678H
CHECK_ADDR_OLD     QWORD  87654321H




;; FIG-FORTH parameters

EPRINT DQ  0


;; DISK INTERFACE WORD

; DOUBLE DENSITY 8" FLOPPY CAPACITIES (1D ???)
SPT2   EQU  52  ; SECTERS PER TRACK
TRKS2  EQU  77  ; NUMBER OF TRACKS
SPDRV2 EQU  SPT2*TRKS2  ; SECTORS/DRIVE

; SINGLE DENSITY 8" FLOPPY CAPACITIES (1S ???)
SPT1   EQU  26  ; SECTERS PER TRACK
TRKS1  EQU  77  ; NUMBER OF TRACKS
SPDRV1 EQU  SPT1*TRKS1  ; SECTORS/DRIVE

BPS    EQU  128 ; BYTES PER SECTOR
MXDRV  EQU  2   ; MAX # DRIVES

;----------------------------------------------

DCBIOS_SELECT_DISK    DB 0
DCBIOS_SET_TRACK      DB 0
DCBIOS_SET_SECTOR     DB 0
DCBIOS_SET_DMA_OFFSET DB 0



; ****USER_VALIABLE****

 DB '****MASTER_USER_VALIABLE****'


UVR:
         DQ 0AAAAH      ; not used
         DQ 0      ; not used
         DQ 0      ; not used
;ADR_S0:
         DQ INITS0 ; S0
;ADR_R0:
         DQ INITR0 ; R0
         DQ INITS0 ; TIB
         DQ 31     ; _WIDTH
         DQ 0      ; WARNING
         DQ FREE_AREA_START ;INITDP ; FENCE
         DQ FREE_AREA_START ;INITDP ; DP
                   ; ＤＰは辞書の現在位置を表すユーザー変数
                   ; 　HEREはDPの内容を示す。
                   ; 　
         DQ FORTH6 ; VOC-LINK
         DQ 0      ; BLK
                   ; 　ＢＬＫはインタプリタが入力文字列として処理しつつあるディスクのブロックナンバーを持つユーザー変数
                   ; 　WORDのBLKはそのユーザー変数のアドレスを返す。
                   ; 　インタプリタがコンソールから入力文字列を受け取っている場合にはＢＬＫの内容は０である。
         DQ 0      ; >IN
         DQ 0      ; OUTT
         DQ 0      ; SCR
         DQ 0      ; OFSET
         DQ QWORD PTR FORTH4 ; CONTEXT
         DQ QWORD PTR FORTH4 ; CURRENT
         DQ 0      ; STATE  ; 実行時は０、コンパイル中の時は０以外
;         DQ -1      ; STATE  ; テストのためコンパイル中の時とした→今は実行中で行っている
         DQ 10     ; BASE
         DQ -1     ; DPL
         DQ 0      ; _FLD
         DQ 0      ; CSP
                   ; 　？ＣＳＰは：によってユーザー変数ＣＳＰ(CURRENT STACK POINTER)に格納されたスタック・ポインタと現在のスタック・ポインタの値が等しいかどうかを検査するためのWORDである。
                   ; 　（等しくなければコンパイルの過程に誤りがあり、スタックに何か残っているか、使いすぎている）
         DQ 0      ; R#
         DQ 0      ; HLD


 DB '****USER_VALIABLE****'




;UP:
;         DQ _UP
_UP:
         DQ 0AAAAH      ; not used
         DQ 0      ; not used
         DQ 0      ; not used
ADR_S0:
         DQ INITS0 ; S0
ADR_R0:
         DQ INITR0 ; R0
ADR_TIB:
         DQ INITS0 ; TIB
         DQ 31     ; _WIDTH
         DQ 0      ; WARNING
         DQ FREE_AREA_START ;INITDP ; FENCE
         DQ FREE_AREA_START ;INITDP ; DP
         DQ FORTH6 ; VOC-LINK
         DQ 0      ; BLK
         DQ 0      ; IN
         DQ 0      ; OUTT
         DQ 0      ; SCR
         DQ 0      ; OFSET
         DQ QWORD PTR FORTH4 ; CONTEXT
         DQ QWORD PTR FORTH4 ; CURRENT
;STATE:
;         DQ 0      ; STATE  ; 実行時は０、コンパイル中の時は０以外
         DQ -1      ; STATE  ; テストのためコンパイル中の時とした
         DQ 10     ; BASE
         DQ -1     ; DPL
         DQ 0      ; _FLD
         DQ 0      ; CSP
         DQ 0      ; R#
         DQ 0      ; HLD


  ;_USE DQ FIRST
  ;_PREV DQ FIRST
  ;_DISK_ERROR DQ 0









; ************* WORDS OF USER VARIABLES *********

; S0  ; 
;  OK!
S09:
 DB 82H
 DB 'S'
 DB '0'+80H
 DQ FORTH79STD9      ;LATESTのアドレス
S0:
 DQ DOUSE
 DQ 03*8      ; the data of STATE
;


; R0  ; 
;  OK!
R09:
 DB 82H
 DB 'R'
 DB '0'+80H
 DQ S09      ;LATESTのアドレス
R0:
 DQ DOUSE
 DQ 04*8      ; the data of STATE
;


; TIB  ; 
;  OK!
TIB9:
 DB 83H
 DB 'TI'
 DB 'B'+80H
 DQ R09      ;LATESTのアドレス
TIB:
 DQ DOUSE
 DQ 05*8      ; the data of STATE
;


; WIDTH  ; 
;  OK!
_WIDTH9:
 DB 85H
 DB 'WIDT'
 DB 'H'+80H
 DQ TIB9      ;LATESTのアドレス
_WIDTH:
 DQ DOUSE
 DQ 06*8      ; the data of STATE
;


; WARNING  ; 
;  OK!
WARNING9:
 DB 87H
 DB 'WARNIN'
 DB 'G'+80H
 DQ _WIDTH9      ;LATESTのアドレス
WARNING:
 DQ DOUSE
 DQ 07*8      ; the data of STATE
;


; FENCE  ; 
;  OK!
FENCE9:
 DB 85H
 DB 'FENC'
 DB 'E'+80H
 DQ WARNING9      ;LATESTのアドレス
FENCE:
 DQ DOUSE
 DQ 08*8      ; the data of STATE
;


; DP  ; 
;  OK!
DP9:
 DB 82H
 DB 'D'
 DB 'P'+80H
 DQ FENCE9      ;LATESTのアドレス
DP:
 DQ DOUSE
 DQ 09*8      ; the data of STATE
;


; VOC-LINK  ; 
;  OK!
VOCLINK9:
 DB 88H
 DB 'VOC-LIN'
 DB 'K'+80H
 DQ DP9      ;LATESTのアドレス
VOCLINK:
 DQ DOUSE
 DQ 10*8      ; the data of STATE
;


; BLK  ; 
;  OK!
BLK9:
 DB 83H
 DB 'BL'
 DB 'K'+80H
 DQ VOCLINK9      ;LATESTのアドレス
BLK:
 DQ DOUSE
 DQ 11*8      ; the data of STATE
;


; IN  ; 
; FIGではただのINと書かれているようだけど？INにしていいのかな？
INN9:
 DB 82H
 DB 'I'
 DB 'N'+80H
 DQ BLK9      ;LATESTのアドレス
INN:
 DQ DOUSE
 DQ 12*8      ; the data of STATE
;


; OUT  ; 
;  OK!
OUTT9:
 DB 83H
 DB 'OU'
 DB 'T'+80H
 DQ INN9      ;LATESTのアドレス
OUTT:
 DQ DOUSE
 DQ 13*8      ; the data of STATE
;


; SCR  ; 
;  OK!
SCR9:
 DB 83H
 DB 'SC'
 DB 'R'+80H
 DQ OUTT9      ;LATESTのアドレス
SCR:
 DQ DOUSE
 DQ 14*8      ; the data of STATE
;


; OFSET  ; 
OFSET9:
 DB 85H
 DB 'DRIV'
 DB 'E'+80H
 DQ SCR9      ;LATESTのアドレス
OFSET:
 DQ DOUSE
 DQ 15*8      ; the data of STATE
;


; CONTEXT  ; 
;  OK!
CONTEXT9:
 DB 87H
 DB 'CONTEX'
 DB 'T'+80H
 DQ OFSET9      ;LATESTのアドレス
CONTEXT:
 DQ DOUSE
 DQ 16*8      ; the data of STATE
;


; CURRENT  ; 
;  OK!
CURRENT9:
 DB 87H
 DB 'CURREN'
 DB 'T'+80H
 DQ CONTEXT9      ;LATESTのアドレス
CURRENT:
 DQ DOUSE
 DQ 17*8      ; the data of STATE
;



; STATE  ; 実行時は０、コンパイル中の時は０以外
;  OK!
STATE9:
 DB 85H
 DB 'STAT'
 DB 'E'+80H
 DQ CURRENT9      ;LATESTのアドレス
STATE:
 DQ DOUSE
 DQ 18*8      ; the data of STATE
;


; BASE  ; 
;  OK!
BASE9:
 DB 84H
 DB 'BAS'
 DB 'E'+80H
 DQ STATE9      ;LATESTのアドレス
; DQ CURRENT9      ;LATESTのアドレス
BASE:
 DQ DOUSE
 DQ 19*8      ; the data of STATE
;


; DPL  ;
;  OK!
DPL9:
 DB 83H
 DB 'DP'
 DB 'L'+80H
 DQ BASE9      ;LATESTのアドレス
DPL:
 DQ DOUSE
 DQ 20*8      ; the data of STATE
;


; FLD  ; 
;  OK!
_FLD9:
 DB 83H
 DB 'FL'
 DB 'D'+80H
 DQ DPL9      ;LATESTのアドレス
_FLD:
 DQ DOUSE
 DQ 21*8      ; the data of STATE
;


; CSP  ; 
;  OK!
CSP9:
 DB 83H
 DB 'CS'
 DB 'P'+80H
 DQ _FLD9      ;LATESTのアドレス
CSP:
 DQ DOUSE
 DQ 22*8      ; the data of STATE
;

;   ＃　→　PCP=parallel cross pattern

; R#  ; 
;  OK!
R_PCP9:
 DB 85H
 DB 'R_PC'
 DB 'P'+80H
 DQ CSP9      ;LATESTのアドレス
R_PCP:
 DQ DOUSE
 DQ 23*8      ; the data of STATE
;


; HLD  ; 
;  OK!
HLD9:
 DB 83H
 DB 'HL'
 DB 'D'+80H
 DQ R_PCP9      ;LATESTのアドレス
HLD:
 DQ DOUSE
 DQ 24*8      ; the data of STATE
;


;************ CONSTANT ************
; ORIGIN  ; 
ORIGIN9:
 DB 86H
 DB 'ORIGI'
 DB 'N'+80H
 DQ HLD9      ;LATESTのアドレス
ORIGIN:
 DQ DOCON  ; CONSTANT
; DQ 100H      ; the data of STATE
 DQ ORIG
;

; B/BUF  ; 
B_BUF9:
 DB 85H
 DB 'B/BU'
 DB 'F'+80H
 DQ ORIGIN9      ;LATESTのアドレス
B_BUF:
 DQ DOCON  ; CONSTANT
 DQ KBBUF      ; the data of STATE
;

; BFLEN  ; 
BFLEN9:
 DB 85H
 DB 'BFLE'
 DB 'N'+80H
 DQ B_BUF9      ;LATESTのアドレス
BFLEN:
 DQ DOCON  ; CONSTANT
 DQ 404H      ; the data of STATE
;

; LIMIT  ; 
LIMIT9:
 DB 85H
 DB 'LIMI'
 DB 'T'+80H
 DQ BFLEN9      ;LATESTのアドレス
LIMIT:
 DQ DOCON  ; CONSTANT
 DQ SYS_LIMIT      ; the data of STATE
;

; FIRST  ; 
;  OK!
FIRST9:
 DB 85H
 DB 'FIRS'
 DB 'T'+80H
 DQ LIMIT9      ;LATESTのアドレス
FIRST:
 DQ DOCON  ; CONSTANT
 DQ SYS_FIRST      ; the data of STATE  FIG:BUF1
;

; UP  ; 
UP9:
 DB 82H
 DB 'U'
 DB 'P'+80H
 DQ FIRST9      ;LATESTのアドレス
UP:
 DQ DOCON  ; CONSTANT
 DQ _UP     ; the data of STATE
;

; BL  ; 
_BL9:
 DB 82H
 DB 'B'
 DB 'L'+80H
; DQ UP9      ;LATESTのアドレス
 DQ UP9      ;LATESTのアドレス
_BL:
 DQ DOCON  ; CONSTANT
 DQ 20H      ; the data of STATE
;

; C/L  ; 
CSLL9:
 DB 83H
 DB 'C/'
 DB 'L'+80H
 DQ _BL9      ;LATESTのアドレス
CSLL:
 DQ DOCON  ; CONSTANT
 DQ 40H      ; the data of STATE
;

; 0  ; 
_0_9:
 DB 81H
 DB '0'+80H
 DQ CSLL9      ;LATESTのアドレス
_0:
 DQ DOCON  ; CONSTANT
 DQ 0      ; the data of STATE
;

; 1  ; 
_1_9:
 DB 81H
 DB '1'+80H
 DQ _0_9      ;LATESTのアドレス
_1:
 DQ DOCON  ; CONSTANT
 DQ 1      ; the data of STATE
;

; 2  ; 
_2_9:
 DB 81H
 DB '2'+80H
 DQ _1_9      ;LATESTのアドレス
_2:
 DQ DOCON  ; CONSTANT
 DQ 2      ; the data of STATE
;

; 3  ; 
_3_9:
 DB 81H
 DB '3'+80H
 DQ _2_9      ;LATESTのアドレス
_3:
 DQ DOCON  ; CONSTANT
 DQ 3      ; the data of STATE
;

; -1  ; 
MINS1_9:
 DB 82H
 DB '-'
 DB '1'+80H
 DQ _3_9      ;LATESTのアドレス
MINS1:
 DQ DOCON  ; CONSTANT
 DQ -1      ; the data of STATE
;

; TIBLEN  ; 
TIBLEN9:
 DB 86H
 DB 'TIBLE'
 DB 'N'+80H
 DQ MINS1_9      ;LATESTのアドレス
TIBLEN:
 DQ DOCON  ; CONSTANT
 DQ 50H      ; the data of STATE
;

; MSGSCR  ; 
MSGSCR9:
 DB 86H
 DB 'MSGSC'
 DB 'R'+80H
 DQ TIBLEN9      ;LATESTのアドレス
MSGSCR:
 DQ DOCON  ; CONSTANT
 DQ 3      ; the data of STATE
;

; SEC/BLK  ; 
SPBLK9:
 DB 87H
 DB 'SEC/BL'
 DB 'K'+80H
 DQ MSGSCR9      ;LATESTのアドレス
SPBLK:
 DQ DOCON  ; CONSTANT
 DQ KBBUF/BPS      ; the data of STATE
;


; #BUFF  ; 
NOBUF9:
 DB 85H
 DB '#BUF'
 DB 'F'+80H
 DQ SPBLK9      ;LATESTのアドレス
NOBUF:
 DQ DOCON  ; CONSTANT
 DQ NBUF      ; the data of STATE
;






;********** VOCABUKARY *****************



; FORTH
FORTH9:
 DB 0C5H
 DB 'FORT'
 DB 'H'+80H
;; DQ 0               ; 次のアドレスはないから0を置いている。正しいだろうか？
 DQ NOBUF9
FORTH:
 DQ DODOE
 DQ DOVOC
 DB 081H
 DB 0A0H
FORTH4::             ; 変数LATESTの示すアドレスはここ
 DQ _OFFSET9
FORTH6::
 DQ 0 ;Address = 0

;




;********** Variables *****************

; USE  ; 
USE9:
 DB 83H
 DB 'US'
 DB 'E'+80H
 DQ FORTH9      ; #BUFF  LATESTのアドレス
USE:
 DQ DOVAR  ; CONSTANT
 DQ SYS_FIRST      ; the data of STATE
;
PREV9:
 DB 84H
 DB 'PRE'
 DB 'V'+80H
 DQ USE9      ;LATESTのアドレス
PREV:
 DQ DOVAR  ; VARIABLE
 DQ SYS_FIRST      ; the data of STATE


; DISK_ERROR
DSKERR9:
 DB 8AH
 DB 'DISK-ERRO'
 DB 'R'+80H
 DQ PREV9      ;LATESTのアドレス
DSKERR:
DSKERR2 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE

;
PFLAG9:    ; プリンターフラグ　 ０ならばプリンターに出力しない。
 DB 85H
 DB 'PFLA'
 DB 'G'+80H
 DQ DSKERR9      ;LATESTのアドレス
PFLAG:
 DQ DOVAR  ; VARIABLE
 DQ 1      ; the data of STATE


;
TRACE_SET9:    ; 0以外の時に実行されたワードを画面に表示する。
 DB 89H
 DB 'TRACE_SE'
 DB 'T'+80H
; DQ INTR_PROC9      ;LATESTのアドレス
 DQ PFLAG9 
TRACE_SET:
 DQ DOVAR  ; VARIABLE
 DQ 1      ; the data of STATE


; DRIVE
DRIVE9:    ; プリンターフラグ　0の時は接続されていない
 DB 85H
 DB 'DRIV'
 DB 'E'+80H
 DQ TRACE_SET9      ;LATESTのアドレス
DRIVE:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE


; SEC
SEC9:    ; プリンターフラグ　0の時は接続されていない
 DB 83H
 DB 'SE'
 DB 'C'+80H
 DQ DRIVE9      ;LATESTのアドレス
SEC:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE


; TRACK
TRACK9:    ; プリンターフラグ　0の時は接続されていない
 DB 85H
 DB 'TRAC'
 DB 'K'+80H
 DQ SEC9      ;LATESTのアドレス
TRACK:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE


; DENSITY
DENSTY9:    ; プリンターフラグ　0の時は接続されていない
 DB 87H
 DB 'DENSIT'
 DB 'Y'+80H
 DQ TRACK9      ;LATESTのアドレス
DENSTY:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE



;
Q_WORD_STATE9:    ; 
 DB 8BH
 DB '?WORD_STAT'
 DB 'E'+80H
 DQ DENSTY9
Q_WORD_STATE:
 DQ DOVAR  ; VARIABLE
 DQ 1      ; the data of STATE
;


;
FILE_INPUT_NOW9:    ; 
 DB 8EH
 DB 'FILE_INPUT_NO'
 DB 'W'+80H
 DQ Q_WORD_STATE9
FILE_INPUT_NOW:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE
;



;
_OFFSET9:    ; プリンターフラグ　0の時は接続されていない
 DB 86H
 DB 'OFFSE'
 DB 'T'+80H
; DQ DENSTY9      ;LATESTのアドレス
 DQ FILE_INPUT_NOW9
_OFFSET:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE










; ******FREE AREA*************
;

AREA_OF_SO   EQU   3000H
KBBUF        EQU   128

  BYTE  "FREE_AREA_START"

FREE_AREA_START:
  QWORD AREA_OF_SO DUP (089ABCDEFH)


INITS0::
  BYTE   (3BA0H - 3B00H)*4 DUP (12H)
INITR0::
  BYTE   (3BE0H - 3BA0H)*4 DUP (34H)

  BYTE   "ThisIsTheStartPointOfINITS0="
  QWORD  INITS0
  BYTE   "ThisIsTheStartPointOfINITR0="
  QWORD  INITR0
  BYTE   "EndOfLine"




TEST2 DWORD ?

STACK_AREA      QWORD   100 dup (?)
STACK_TOP       QWORD   ?

RBP_STACK_TOP       QWORD   ?
RBP_STACK_AREA      QWORD   100 dup (?)

SEE_THIS_WORD_STACK_TOP   QWORD   ?
SEE_THIS_WORD_STACK_AREA  QWORD  100 dup (?)
SEE_THIS_WORD_ptr         QWORD   ?




SYS_FIRST:  ; <--same as BUF1
  BYTE KBBUF DUP (01H)  ; #0 KBBUF
  BYTE     4 DUP (02H)  ; #0 CO = KBBUF + 4
  BYTE KBBUF DUP (11H)  ; #1 KBBUF
  BYTE     4 DUP (12H)  ; #1 CO = KBBUF + 4
  BYTE KBBUF DUP (21H)  ; #2 KBBUF
  BYTE     4 DUP (22H)  ; #2 CO = KBBUF + 4
  BYTE KBBUF DUP (31H)  ; #3 KBBUF
  BYTE     4 DUP (32H)  ; #3 CO = KBBUF + 4
  BYTE KBBUF DUP (41H)  ; #4 KBBUF
  BYTE     4 DUP (42H)  ; #4 CO = KBBUF + 4
  BYTE KBBUF DUP (51H)  ; #5 KBBUF
  BYTE     4 DUP (52H)  ; #5 CO = KBBUF + 4
  BYTE KBBUF DUP (61H)  ; #6 KBBUF
  BYTE     4 DUP (62H)  ; #6 CO = KBBUF + 4
  BYTE KBBUF DUP (71H)  ; #7 KBBUF
  BYTE     4 DUP (72H)  ; #7 CO = KBBUF + 4

; ******LIMIT DATA AREA*******



SYS_LIMIT:  ; same as EM







.code

TestProc proc



ORIG::
   NOP


;; 20240515 add "set call_C_entry"

   mov [call_C_entry_save_rax],rax
   mov [RET_call_C_entry_save_rcx],rcx

 ;  mov rax,RBP_STACK_TOP
   mov [RET_call_C_entry_save_rbp],rbp

    xchg rax,rsp
    mov [RET_call_C_entry_save_rsp],rax
    mov rax,[PTR_STACK]  ;           ここでスタックポインタを退避エリアに変更する。
    xchg rax,rsp
   mov rax,[RET_call_C_entry_save_rsp]
;    念のためにRAXに取り出したが、起動したときのリターンスタックRET_call_C_entry_save_rspの値を使うことはあるだろうか？



;; 20240515 add call call_C_entry



 JMP CLD9
 NOP
 JMP WRM






; ****FORTH_INNER_INTERPRETER****

NEXT1:

    MACRO_NEXT1_1

    JMP NEXT1_9


DPUSH: PUSH RDX
APUSH: PUSH RAX
NEXT:

    MACRO_NEXT_1

       LODSQ            ; RAX <- (RIP == RSI)  

;                      ; RIP <- RIP+8
;　  動作：[RSI]の内容8バイトをRAXに読み込み、
;          DF=1の時は、RSIを8減らす。
;          DF=0の時は、RSIを8増やす。
;　　影響を受けるフラグ：なし
       MOV   RBX,RAX         ;
NEXT1_9: MOV RDX,RBX
; INC   RDX             ; SET W
       ADD RDX,8

       MACRO_NEXT_2
;

       JMP   QWORD PTR [RBX] ; JUMP TO (IP)
 






; ****FORTH_DICTIONARY****


; TRACE_ON   
TRACE_ON9:
 DB 88H
 DB 'TRACE_O'
 DB 'N'+80H
 DQ 0          ; end of dictionary
TRACE_ON:
 DQ DOCOL
 DQ _LIT, 1
; DQ TRACE_SET
; DQ STORE  ; !
 DQ TRACE_ON_OFF
 DQ SEMIS

; TRACE_OFF   
TRACE_OFF9:
 DB 89H
 DB 'TRACE_OF'
 DB 'F'+80H
 DQ TRACE_ON9
TRACE_OFF:
 DQ DOCOL
 DQ _LIT, 0
; DQ TRACE_SET
; DQ STORE  ; !
 DQ TRACE_ON_OFF
 DQ SEMIS
;


;;
;Q_WORD_STATE9:    ; 
; DB 8EH
; DB 'USE_KCOMP_WOR'
; DB 'D'+80H
; DQ TRACE_OFF9      ;LATESTのアドレス
;Q_WORD_STATE:
; DQ DOVAR  ; VARIABLE
; DQ 1      ; the data of STATE

 




; DUMP_BREAK_POINT
; この前のワードでスタック上に出力するレジスタの設定を行う
; 例） DQ 64+32+16+8+1         ; display  Regs.
DUMP_BREAK_POINT9:
 DB 90H
 DB 'DUMP_BREAK_POIN'
 DB 'T'+80H
; DQ Q_WORD_STATE9
 DQ TRACE_OFF9
DUMP_BREAK_POINT:
 DQ DUMP_BREAK_POINT_2
DUMP_BREAK_POINT_2:

 POP R11
 lea r10,WORD_NAME_Register
 call dumpReg
 JMP NEXT


 
; <BUILDS  
BUILD9:
 DB 87H
 DB '<BUILD'
 DB 'S'+80H
 DQ DUMP_BREAK_POINT9
BUILD:
 DQ DOCOL
 DQ _0
 DQ CON
 DQ SEMIS

 
; +ORIGN   
PORIG9:
 DB 86H
 DB '+ORIG'
 DB 'N'+80H
 DQ BUILD9
PORIG:
 DQ DOCOL
 DQ _LIT
 DQ ORIG
 DQ PLUS
 DQ SEMIS

 
; B/SCR   
BSCR9:
 DB 85H
 DB 'B/SC'
 DB 'R'+80H
 DQ PORIG9
BSCR:
 DQ DOCON
 DQ 400H/KBBUF


; IMMEDIATE 
; TOGGLで最新のワードのイミーディエイトフラグ（NFAの先頭アドレスの６ビット目）を反転させる。
IMMEDIATE9:
 DB 89H
 DB 'IMMEDIAT'
 DB 'E'+80H
 DQ BSCR9
IMMEDIATE:
 DQ DOCOL
 DQ LATEST  ; 最新ワードの先頭アドレス
 DQ _LIT, 40H  ; ６ビット目に１
 DQ TOGGL  ; ビット反転 ( a n --- )　ａ：最新ワードの先頭アドレス　ｎ：６ビット目に１
 DQ SEMIS



; CR   
_CR9:
 DB 82H
 DB 'C'
 DB 'R'+80H
 DQ IMMEDIATE9
_CR:
 DQ CR_2
CR_2:
 JMP PCR




; MINUS
; OK -->なかったので追加した。
MINUS9:
 DB 85H
 DB 'MINU'
 DB 'S'+80H
 DQ _CR9
MINUS:
 DQ MINUS_2
MINUS_2:
 POP RAX
 NEG RAX
 JMP APUSH

; DMINUS
; OK -->なかったので追加した。
DMINUS9:
 DB 86H
 DB 'DMINU'
 DB 'S'+80H
 DQ MINUS9
DMINUS:
 DQ DMINUS_2
DMINUS_2:
 POP RBX
 POP RCX
 SUB RAX,RAX
 MOV RDX,RAX
 SUB RDX,RCX
 SBB RAX,RBX
 JMP DPUSH



; 2@
; OK -->なかったので追加した。
TAT9:
 DB 82H
 DB '2'
 DB '@'+80H
 DQ DMINUS9
TAT:
 DQ TAT_2
TAT_2:
 POP RBX
 MOV RAX,[RBX]
 MOV RDX,8[RBX]
 JMP DPUSH




; 2!
; OK -->なかったので追加した。
TSTOR9:
 DB 82H
 DB '2'
 DB '!'+80H
 DQ TAT9
TSTOR:
 DQ TSTOR_2
TSTOR_2:
 POP RBX
 POP RAX
 MOV [RBX],RAX
 POP RAX
 MOV 8[RBX],RAX
 JMP NEXT


; NOOP
; OK -->なかったので追加した。
NOOP9:
 DB 84H
 DB 'NOO'
 DB 'P'+80H
 DQ TSTOR9
NOOP:
; DQ 2DUP_2
;2DUP_2:
; POP RAX
; POP RDX
; PUSH RDX
; PUSH RAX
; JMP DPUSH
 DQ DOCOL
 DQ SEMIS



; 
; BREAK_POINT
BREAK_POINT9:
 DB 8BH
 DB 'BREAK_POIN'
 DB 'T'+80H
; DQ 0 ; end of dictionary
 DQ NOOP9
BREAK_POINT:
 DQ BREAK_POINT_2
BREAK_POINT_2:


;  ここ、何をやっているのかわからなくなってきた。この外部レジスタは退避用？→修正済み

; １）RAX,RBXの退避
 mov  [buf_WORK_BREAK_POINT_RAX],rax
 mov  [buf_WORK_BREAK_POINT_RBX],rbx
 mov  [buf_WORK_BREAK_POINT_R10],r10
 mov  [buf_WORK_BREAK_POINT_R11],r11

; ２）スタックに積まれているワード／数値を退避用ワークエリアに保存する
 POP  RAX
 POP  RBX
 MOV  [WORK_BREAK_POINT_RAX],RAX
 MOV  [WORK_BREAK_POINT_RBX],RBX
 PUSH RBX
 PUSH RAX

; ３）次のワードに書かれているBREAK_POINTの識別番号を保存する。
 MOV  RAX,[RSI]
 MOV  [WORK_BREAK_POINT_NUMBER],RAX
 ADD  RSI,8


; ４）TRACE_SETの内容が０だったら何も表示しない。スキップする。
 MOV R10,[TRACE_SET+8]
 MOV R10,[R10]
 OR R10,R10

; ６）４）で判断して、TRACE_SETの内容が０だったら次の７）をスキップする
 JZ BREAK_POINT_SKIP01


; ７）画面に表示されるレジスタの種類を設定、表示する。
;
 mov r11,4+2+1         ; display RAX reg.
; lea r10,WORD_NAME_BREAK_POINT
 call dumpParam


; ８）終了する（次へジャンプする）
BREAK_POINT_SKIP01:

; ９）PFINDで見つけたワードのアドレスとその前のワードのアドレス
 MOV R10,[CHECK_ADDR_OLD]
 MOV R11,[CHECK_ADDR_NEW]

; ５）RAX,RBXの復帰
 mov  r11,[buf_WORK_BREAK_POINT_R11]
 mov  r10,[buf_WORK_BREAK_POINT_R10]
 mov  rbx,[buf_WORK_BREAK_POINT_RBX]
 mov  rax,[buf_WORK_BREAK_POINT_RAX]



  JMP NEXT   ; ここに Visual Studioのブレークポイントを設定する

; 使い方：
;  実行時にブレークポイントを設定したい場所に以下の行を挿入する。２行目にはそこが何番目のブレークポイントであるかを設定すること。
;
; 例）「   DQ BREAK_POINT 」
;     「   DQ 5           」  ←ここの５は FINDに設定した例として 「5) FINDの先頭」 の番号を表す。

;
;  以下のパラメーターのうちのパラメーターＢ）からが表示されます。
;     A) DUMMY                     BYTE    "WORK_BREAK_POINT_RAX",0
;     B) WORK_BREAK_POINT_RAX      QWORD   1　　　１番目にスタックに積まれた値
;     C) WORK_BREAK_POINT_RBX      QWORD   1　　　２番目にスタックに積まれた値
;     D) WORK_BREAK_POINT_NUMBER   QWORD   99H　　何も変化がなければ、初期値の９９Ｈのままとなる。

; 現在設定しているブレークポイントのナンバーと内容
;  1) ENCLOSE
;  2) (FIND)の先頭
;  3) (FIND)のAGAINの前
;  4) WORDの先頭で、コンパイル時であるときの最初で
;  5) SCR#326-2  FINDの先頭
;  6) SCR#326-2  FINDの中で、(FIND)のすぐあと
;  9)            FINDの中で、(FIND)の前で
; 19) WORDの最後で、SEMISの前で
; 21) QUITの中で、[COMPILE]＋[ の後のRP!の後で
; 22) EMITのCOUTの前で
; 31) EXPECTの中で、KEYを実行した後で
; 44) DEFINITIONSの最初で
; 45) FINDのWORDの後で
; 50) KEYの最初で、CINの前で
; 51) ABORTの中で、[COMPILE]＋FORTH の前で
; 52) ABORTの中で、DEFINITIONの後で、QUIT の前で
; 55)            FINDの中で、最後のSEMISの前で
; 70) [COMPILE]のFINDの後で
;100) R/Wの中で、; DQ REC/BLK  -->定数かな？なんにせよ、ここの操作でR/Wするセクタアドレスと数を求めなくてはならない。








; LIT
_LIT9:
 DB 83H
 DB 'LI'
 DB 'T'+80H
; DQ 0 ; end of dictionary
 DQ BREAK_POINT9
_LIT:
; DQ $+8
 DQ _LIT_2
_LIT_2:
 LODSQ

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_LIT
 call dumpReg

 JMP APUSH

; EXECUTE
EXEC9:
 DB 87H
 DB 'EXECUT'
 DB 'E'+80H
 DQ _LIT9
EXEC:
; DQ $+8
 DQ EXEC_2
EXEC_2:
 POP RBX


;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ EXEC__SKIP02

 mov r11,2+1         ; display  Regs. RAX,RBX
 lea r10,WORD_NAME_LIT
 call dumpReg
 ;
 mov r11,4+2+1         ; display RAX reg.
; lea r10,WORD_NAME_BREAK_POINT
 call dumpParam

EXEC__SKIP02:

   mov [EXECUTE_SEE_THIS_WORD],rbx
   lea r10,EXECUTE_SEE_THIS_WORD
;   mov [EXECUTE_SEE_THIS_WORD_ptr],r10
;   lea r10,[EXECUTE_SEE_THIS_WORD_ptr]
   mov R9,[SEE_THIS_WORD_ptr]
   mov [SEE_THIS_WORD_ptr],r10
;   call myFunc
   mov [SEE_THIS_WORD_ptr],r9

; ４）もしもEXECUTEで実行するワードがBYEならTRACE_SETの内容を０にする
;   （TRACE_SETの内容が１でBYEを実行しようとするとエラーが発生したため。）

 MOV R11,BYE
 CMP R10,R11
 JNE EXEC_SKIP01

    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 XOR R9,R9
 MOV [R8],R9
    mov R8,[save_r8]  ; display Regs.

EXEC_SKIP01:
 JMP NEXT1




; BRANCH
BRAN9:
 DB 86H
 DB 'BRANC'
 DB 'H'+80H
 DQ EXEC9
BRAN:
; DQ $+8
 DQ BRAN_2
BRAN_2:
B1: ADD RSI,[RSI]


;WORD_Reg_PRINTFORMAT     BYTE    "[rsp]:64*1024 [rbp]:32*1024 [rsi];16*1024 [rdx]:8*1024 rsp:64 rbp:32 rsi:16 rdx:8 rcx:4 rbx:2 rax:1"
 mov r11,64+32+16+8+1         ; display  Regs.
 lea r10,WORD_NAME_BRAN
 call dumpReg

 JMP NEXT

; 0BRANCH
ZBRAN9:
 DB 87H
 DB '0BRANC'
 DB 'H'+80H
 DQ BRAN9
ZBRAN:
; DQ $+8
 DQ ZBRAN_2
ZBRAN_2:
 POP RAX
 OR RAX,RAX
 JZ B1
; INC RSI
; INC RSI
 ADD RSI,8


;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ ZBRAN_SKIP01

; ２）スタックに積まれているワード／数値を退避用ワークエリアに保存する
 POP  RAX
 POP  RBX
 MOV  [WORK_BREAK_POINT_RAX],RAX
 MOV  [WORK_BREAK_POINT_RBX],RBX
 PUSH RBX
 PUSH RAX

 mov r11,2+1         ; display  Regs.
 lea r10,WORD_NAME_0BRAN
 call dumpParam

ZBRAN_SKIP01:
 JMP NEXT

; (LOOP)
XLOOP9:
 DB 86H
 DB '(LOOP'
 DB ')'+80H
 DQ ZBRAN9
XLOOP:
; DQ $+8
 DQ XLOOP_2
XLOOP_2:
 MOV RBX,1
L1: ADD [RBP],RBX
 MOV RAX,[RBP]
 SUB RAX,[RBP+8]
 XOR RAX,RBX      ; 現在のアドレスと終了時のアドレスの差が負となるならＢ１へジャンプ。等しいか超えてしまったらそのまま通過。
 JS B1            ; SF (Sign Flag)
                  ; The Sign Flag (SF) is set (1) when the result of an operation is negative. Otherwise (positive result), it is cleared (0).
 ADD RBP,16
; INC ESI
; INC ESI
 ADD RSI,8
;WORD_Reg_PRINTFORMAT     BYTE    "[rsp]:64*1024 [rbp]:32*1024 [rsi];16*1024 [rdx]:8*1024 rsp:64 rbp:32 rsi:16 rdx:8 rcx:4 rbx:2 rax:1"


 mov r11,64+32+16+8+1         ; display  Regs.
 lea r10,WORD_NAME_LIT
 call dumpReg

 JMP NEXT

; (+LOOP)
XPLOO9:
 DB 87H
 DB '(+LOOP'
 DB ')'+80H
 DQ XLOOP9
XPLOO:
; DQ $+8
 DQ XPLOO_2
XPLOO_2:
 POP RBX
 JMP L1

; (DO)
XDO9:
 DB 84H
 DB '(DO'
 DB ')'+80H
 DQ XPLOO9
XDO:
; DQ $+8
 DQ XDO_2
XDO_2:
 POP RDX
 POP RAX
 XCHG RBP,RSP
 PUSH RAX
 PUSH RDX
 XCHG RBP,RSP
;WORD_Reg_PRINTFORMAT     BYTE    "[rsp]:64*1024 [rbp]:32*1024 [rsi];16*1024 [rdx]:8*1024 rsp:64 rbp:32 rsi:16 rdx:8 rcx:4 rbx:2 rax:1"


 mov r11,64+32+16+8+1         ; display  Regs.
 lea r10,WORD_NAME_LIT
 call dumpReg



 JMP NEXT

; AND
;  OK!
ANDD9:
 DB 83H
 DB 'AN'
 DB 'D'+80H
 DQ XDO9
ANDD:
; DQ $+8
 DQ ANDD_2
ANDD_2:
 POP RAX
 POP RBX
 AND RAX,RBX
 JMP APUSH

; OR
;  OK!
ORR9:
 DB 82H
 DB 'O'
 DB 'R'+80H
 DQ ANDD9
ORR:
; DQ $+8
 DQ ORR_2
ORR_2:
 POP RAX
 POP RBX
 OR RAX,RBX
 JMP APUSH

; XOR
;  OK!
XORR9:
 DB 83H
 DB 'XO'
 DB 'R'+80H
 DQ ORR9
XORR:
; DQ $+8
 DQ XORR_2
XORR_2:
 POP RAX
 POP RBX
 XOR RAX,RBX
 JMP APUSH

; SP@
;  OK!
SPAT9:
 DB 83H
 DB 'SP'
 DB '@'+80H
 DQ XORR9
SPAT:
; DQ $+8
 DQ SPAT_2
SPAT_2:
 MOV RAX,RSP
 JMP APUSH

; SP!  ; パラメータスタックポインタを変数Ｓ０の値に初期化する  ; パラメータスタックポインタを変数Ｓ０の値に初期化する
;  OK!
SPST09:
 DB 83H
 DB 'SP'
 DB '!'+80H
 DQ SPAT9    ; SP@9
SPST0:
; DQ $+8
 DQ SPST0_2
SPST0_2:
; XOR RBX,RBX
 MOV RBX,_UP
; MOV RSP,[RBX+6]  ; USER VAL =S0 #06 
 MOV RSP,[RBX+24]  ; USER VAL =S0 #06 (3*8)
; MOV RSP,[RBX+ADR_S0-UP]  ; USER VAL =S0
 JMP NEXT

; RP@
;  OK!
RPAT9:
 DB 83H
 DB 'RP'
 DB '@'+80H
 DQ SPST09
RPAT:
; DQ $+8
 DQ RPAT_2
RPAT_2:
MOV RAX,RBP
 JMP APUSH

; RP!
;  OK!
RPST09:
 DB 83H
 DB 'RP'
 DB '!'+80H
 DQ RPAT9
RPST0:
; DQ $+8
 DQ RPST0_2
RPST0_2:
 MOV RBX,_UP
 MOV RBP,[RBX+32] ; MOV [R0] TO RBP
 JMP NEXT

; ;S
;  OK!
SEMIS9:
 DB 82H
 DB ';'
 DB 'S'+80H
 DQ RPST09
SEMIS:
; DQ $+8
 DQ SEMIS_2  ; こちらがワードの通常の終了処理

SEMIS_3:  ; (;CODE)でワードを終了するとDOCOLが１回余分に使われるため、
          ; TRACE表示が狂ってしまう。そのためにSEMIS_3ではTRACE表示の
          ; カウントを１回多めに減らしている。
; DQ $+8
 DQ SEMIS_31


SEMIS_31:
 SUB [DEBUG_DUMP_LEVEL],1
 sub [SEE_THIS_WORD_ptr],8

SEMIS_2:
 SUB [DEBUG_DUMP_LEVEL],1
 sub [SEE_THIS_WORD_ptr],8

 MOV RSI,[RBP]
; INC BP
; INC BP
 ADD RBP,8
 JMP NEXT

; >R
;  OK!
TOR9:
 DB 82H
 DB '>'
 DB 'R'+80H
 DQ SEMIS9
TOR:
; DQ $+8
 DQ TOR_2
TOR_2:
 POP RBX
; DEC BP
; DEC BP
 SUB RBP,8
 MOV [RBP],RBX
 JMP NEXT

; R>
;  OK!
FROMR9:
 DB 82H
 DB 'R'
 DB '>'+80H
 DQ TOR9
FROMR:
; DQ $+8
 DQ FROMR_2
FROMR_2:
 MOV RAX,[RBP]
; INC BP
; INC BP
 ADD RBP,8
 JMP APUSH

; R@
;  OK
RAT9:
 DB 82H
 DB 'R'
 DB '@'+80H
 DQ FROMR9
RAT:
; DQ $+8
 DQ RAT_2
RAT_2:
 MOV RAX,[RBP]
 JMP APUSH

; 0=
;  OK!
ZEQU9:
 DB 82H
 DB '0'
 DB '='+80H
 DQ RAT9
ZEQU:
; DQ $+8
 DQ ZEQU_2
ZEQU_2:
 POP RAX
 OR RAX,RAX
 MOV RAX,1
; JZ $+3
 JZ ZEQU2
 DEC RAX    ;ここは１でよい
ZEQU2:
 JMP APUSH

; 0<
;  OK!
ZLESS9:
 DB 82H
 DB '0'
 DB '<'+80H
 DQ ZEQU9
ZLESS:
; DQ $+8
 DQ ZLESS_2
ZLESS_2:
 POP RAX
 OR RAX,RAX
 MOV RAX,1
; JS $+3
 JS ZLESS2
 DEC RAX    ;ここは１でよい
ZLESS2:
 JMP APUSH

; +
;  OK!
PLUS9:
 DB 81H
 DB '+'+80H
 DQ ZLESS9
PLUS:
; DQ $+8
 DQ PLUS_2
PLUS_2:
 POP RAX
 POP RBX
 ADD RAX,RBX
; ここは本当にこれでいいかわからない
;　RAXをBIT15に合わせてビット拡張するべきか？

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_PLUS
 call dumpReg

 JMP APUSH

; -  ( n1 n2 --- n1-n2 )
;  OK! FIGでの MINUSとは違うので注意！
SUBB9:
 DB 81H
 DB '-'+80H
 DQ PLUS9
SUBB:
; DQ $+8
 DQ SUBB_2
SUBB_2:
 POP RDX
 POP RAX
 SUB RAX,RDX
 JMP APUSH



; D+
;  OK!
DPLUS9:
 DB 82H
 DB 'D'
 DB '+'+80H
 DQ SUBB9
DPLUS:
; DQ $+8
 DQ DPLUS_2
DPLUS_2:
 POP RAX
 POP RDX
 POP RBX
 POP RCX
 ADD RDX,RCX
 ADC RAX,RBX
 JMP DPUSH

; DMINUS
;  間違えてた。FIGに合わせた。FIGでは DMINUS
DMINU9:
 DB 86H
 DB 'DMINU'
 DB 'S'+80H
 DQ DPLUS9
DMINU:
; DQ $+8
 DQ DMINU_2
DMINU_2:
 POP RBX
 POP RCX
 SUB RAX,RAX
 MOV RDX,RAX
 SUB RDX,RCX
 SBB RAX,RBX
 JMP DPUSH

; OVER
;  OK!
OVER9:
 DB 84H
 DB 'OVE'
 DB 'R'+80H
 DQ DMINU9
OVER:
; DQ $+8
 DQ OVER_2
OVER_2:
 POP RDX
 POP RAX
 PUSH RAX
 JMP DPUSH

; DROP
;  OK!
DROP9:
 DB 84H
 DB 'DRO'
 DB 'P'+80H
 DQ OVER9
DROP:
; DQ $+8
 DQ DROP_2
DROP_2:
 POP RAX
 JMP NEXT

; SWAP
;  OK!
SWAP9:
 DB 84H
 DB 'SWA'
 DB 'P'+80H
 DQ DROP9
SWAP:
; DQ $+8
 DQ SWAP_2
SWAP_2:
 POP RDX
 POP RAX
 JMP DPUSH

; DUP
;  OK!
DUPE9:
 DB 83H
 DB 'DU'
 DB 'P'+80H
 DQ SWAP9
DUPE:
; DQ $+8
 DQ DUPE_2
DUPE_2:
 POP RAX
 PUSH RAX
 JMP APUSH

; ROT
;  OK!
ROT9:
 DB 83H
 DB 'RO'
 DB 'T'+80H
 DQ DUPE9
ROT:
; DQ $+8
 DQ ROT_2
ROT_2:
 POP RDX
 POP RBX
 POP RAX
 PUSH RBX
 JMP DPUSH

; U*
;  OK!
USTAR9:
 DB 82H
 DB 'U'
 DB '*'+80H
 DQ ROT9
USTAR:
; DQ $+8
 DQ USTAR_2
USTAR_2:
 POP RAX
 POP RBX
 MUL RBX
 XCHG RAX,RDX
 JMP DPUSH

; U/
;  OK!
USLAS9:
 DB 82H
 DB 'U'
 DB '/'+80H
 DQ USTAR9
USLAS:
; DQ $+8
 DQ USLAS_2
USLAS_2:
 POP RBX
 POP RDX
 POP RAX
 CMP RDX,RBX
 JNB U1
 DIV RBX
 JMP DPUSH
U1: MOV RAX,-1
 MOV RDX,RAX
 JMP DPUSH

; 2/
TDIV9:
 DB 82H
 DB '2'
 DB '/'+80H
 DQ USLAS9
TDIV:
; DQ $+8
 DQ TDIV_2
TDIV_2:
 POP RAX
 SAR RAX,1
 JMP APUSH

; 8/
EDIV9:
 DB 82H
 DB '8'
 DB '/'+80H
 DQ TDIV9
EDIV:
; DQ $+8
 DQ EDIV_2
EDIV_2:
 POP RAX
 SAR RAX,3
 JMP APUSH

; TOGGLE
TOGGL9:
 DB 86H
 DB 'TOGGL'
 DB 'E'+80H
 DQ EDIV9
TOGGL:
; DQ $+8
 DQ TOGGL_2
TOGGL_2:
 POP RAX
 POP RBX
 XOR [RBX],AL
 JMP NEXT

; @
;  OK!
ATT_9:
 DB 81H
 DB '@'+80H
 DQ TOGGL9
ATT:
; DQ $+8
 DQ ATT_2
ATT_2:
 POP RBX
; XOR RAX,RAX
; ??これでいいのだろうか？
 MOV RAX,[RBX]  ; ここは悩むところ

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_@
 call dumpReg

 JMP APUSH

; !
STORE_9:
 DB 81H
 DB '!'+80H
 DQ ATT_9
STORE:
; DQ $+8
 DQ STORE_2
STORE_2:
 POP RBX
 POP RAX
 MOV [RBX],RAX
 JMP NEXT



; C!
;  OK!
CSTOR9:
 DB 82H
 DB 'C'
 DB '!'+80H
 DQ STORE_9
CSTOR:
; DQ $+8
 DQ CSTOR_2
CSTOR_2:
 POP RBX
 POP RAX
 MOV [RBX],AL   ; ここは８ビット以外を０にするべきだろうか？

 mov r11,2+1         ; display  Regs.
 lea r10,WORD_NAME_LIT
 call dumpReg

 JMP NEXT

; :
;  OK!
COLON9:
 DB 0C1H
 DB ':'+80H
 DQ CSTOR9
COLON:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 224H

 DQ QEXEC ; ?EXEC
 DQ SCSP    ; !CSP ; !CSP
 DQ CURRENT ; CURRENT
 DQ ATT ; @  FETCH
 DQ CONTEXT ; CONTEXT
 DQ STORE ; !
 DQ CREATE    ; CREATE
 DQ RBRAC ; ]
 DQ PSCOD ; (;CODE)
DOCOL:

add [DEBUG_DUMP_LEVEL],1

add [SEE_THIS_WORD_ptr],8

 SUB RBP,8      ; RP  <-RP+8
 MOV [RBP],RSI  ; [RP]<-IP リターンスタックにPUSH
 MOV RSI,RDX    ; IP  <-RDX 次のワードのアドレスをIPに
 JMP NEXT

; CONSTANT
;  OK!
CON9:
 DB 88H
 DB 'CONSTAN'
 DB 'T'+80H
 DQ COLON9
CON:
 DQ DOCOL
 DQ CREATE    ; CREATE
 DQ SMUDG ; SMUDGE
 DQ COMMA ; ,
 DQ PSCOD ; (;CODE)
DOCON::
; INC RDX
; ADD RDX,8
 MOV RBX,RDX
 MOV RAX,[RBX]

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_DOCON
 call dumpReg

 JMP APUSH

; VARIABLE
;  OK!
VAR9:
 DB 88H
 DB 'VARIABL'
 DB 'E'+80H
 DQ CON9
VAR:
 DQ DOCOL
; DQ ZERO ; 0

; 一行抹消。まだよくVARを理解できてないが、VARの宣言の時に値も定義するようだ。コンパイル時はCONと同じ。実行時は変数のアドレスをPUSHする。
; DQ _0
 DQ CON ; CONSTANT
 DQ PSCOD ; (;CODE)
DOVAR::
 PUSH RDX

 
;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ DOVAR_SKIP01

mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_DOVAR
 call dumpReg

DOVAR_SKIP01:
 JMP NEXT




; USER
USER9:
 DB 84H
 DB 'USE'
 DB 'R'+80H
 DQ VAR9
USER:
 DQ DOCOL
 DQ CON ; CONSTANT
 DQ PSCOD ; (;CODE)
DOUSE::
 MOV RBX,RDX
 MOV RBX,[RBX]
 MOV RDI,_UP
 LEA RAX,[RBX+RDI]
; MOV RAX,[RBX+RDI]

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_DOUSE
 call dumpReg

 JMP APUSH


; DOES>
; ここはだいぶ違っている。FIGに従ってみては？研究の必要アリ！
DOES9:
 DB 0C5H
 DB 'DOES'
 DB '>'+80H
 DQ USER9
DOES:
 DQ DOCOL
 DQ FROMR
 DQ LATEST
 DQ PFA
 DQ STORE
 DQ PSCOD
DODOE::
 XCHG RBP,RSP
 PUSH RSI
 XCHG RBP,RSP
 MOV RBX,RDX
 MOV RSI,[RBX]
 ADD RDX,8
 PUSH RDX
 JMP NEXT





; FILL  ( a n b --- )
;  0K!
_FILL9:
 DB 84H
 DB 'FIL'
 DB 'L'+80H
 DQ DOES9
_FILL:
; DQ $+8
 DQ _FILL_2
_FILL_2:
 POP RAX
 POP RCX
 POP RDI
 CLD        ; clear direction flag.　ストリング命令はSI，DIをインクリメントする．
 REP STOSB  ; alの値を[edi]に代入し、ediの値を1増減させる
 JMP NEXT



; CREATE
CREATE9:
 DB 86H
 DB 'CREAT'
 DB 'E'+80H
 DQ _FILL9
CREATE:
 DQ DOCOL
; これ以降修正。FIGに従い、(CREATE)に飛ばないでここで処理を行う。
 DQ DFIND
 DQ ZBRAN
CREATE_AFT_IF:
 DQ CREATE_AFT_THEN - CREATE_AFT_IF
 DQ DROP
 DQ NFA
 DQ IDDOT
 DQ _LIT,4
 DQ MESSAGE
 DQ SPACE
CREATE_AFT_THEN:
 DQ HERE
 DQ DUPE
 DQ CAT
 DQ _WIDTH
 DQ ATT
 DQ MIN
 DQ _1PL
 DQ ALLOT
 DQ DUPE
 DQ _LIT, 0A0H
 DQ TOGGL  ; ビット反転 ( a n --- )　ａ：最新ワードの先頭アドレス　ｎ：６、７ビット目に１
 DQ HERE
 DQ _1
 DQ SUBB
 DQ _LIT, 080H
 DQ TOGGL  ; ビット反転 ( a n --- )　ａ：最新ワードの先頭アドレス　ｎ：７ビット目に１
 DQ LATEST
 DQ COMMA
 DQ CURRENT
 DQ ATT
 DQ STORE
 DQ HERE
 DQ _2PL
 DQ COMMA
 DQ SEMIS




; WARM STATE VECTOR COMES HERE

WRM: MOV RSI,OFFSET WRM1
 JMP NEXT
WRM1:
 DQ WARM

; WARM
WARM9:
 DB 84H
 DB 'WAR'
 DB 'M'+80H
 DQ CREATE9
WARM:
 DQ DOCOL
 DQ MTBUF ; EMPTY-BUFFERS
 DQ ABORT ; ABORT





; COLD STATE VECTOR COMES HERE

CLD9::

 CLD                 ; Clears the DF flag in the EFLAGS register. 

;; SET TRACE SETTING PARAM from CPP

 mov r8,[rcx + 16]  ; r8: Display Trace WORD name  0:OFF else:ON
 lea r9,TRACE_SET   ; r9: Address of the first parameter of WORD “TRACE_SET (variable)”
 mov [r9 + 8],r8    ;     WORD「TRACE_SET（変数）」の第１パラメータのアドレス
 


 MOV RSI,OFFSET CLD1 ; SET UP IP
 MOV RSP,QWORD PTR ADR_S0 ; SET UP SP
   sub     rsp, 28h
 MOV RBP,QWORD PTR ADR_R0 ; SET UP RP


; 変数TIBが書き変わったらnopに進む（そこにブレイクポイントを設定すること）。
 mov [save_reg_ADR_TIB],rax
 mov rax,[ADR_TIB]
 mov rax,[rax]
 MOV [check_dat_ADR_TIB],rax
 mov rax,[save_reg_ADR_TIB]

; 最初のスタックのアドレスを保存する。トレースのため。
 mov [addr_STACK_BOTOM],rsp

; 
 lea rax, SEE_THIS_WORD_STACK_TOP
 mov [SEE_THIS_WORD_ptr],rax

 JMP NEXT
CLD1:
 DQ COLD

; COLD
COLD9:
 DB 84H
 DB 'COL'
 DB 'D'+80H
 DQ WARM9
COLD:
 DQ DOCOL

;; ここから実験のために実験用のワードが並んでいる。最終的に削除する予定。
;; From here the words for the experiment are lined up for the experiment. Will be removed eventually.

; COUTのテスト→成功
; DQ _LIT, 43H
; DQ COUT

;; CINのテスト
; DQ CIN
; DQ CIN
; DQ BYE
;;

; DQ BREAK_POINT
; DQ 42H
;

 DQ SERCH_WORD
; DQ TRACE_ON
; DQ TRACE_OFF

; DQ BYE

;; DQ _1
;; DQ INTR_PROC  ; ; INTERNAL_PROCESSING   ( --- a ) DOVAR  WORDワードにおいて初期化時や内部処理時は１で、端末キーボードから入力バッファ上に転送された文字列の処理時は０となる。
;; DQ STORE

;; End of experiment


 DQ F_OPEN     ; ここでエラーが発生する。FOPENできない。20240607

 DQ _LIT,1
 DQ PFLAG
 DQ STORE

 DQ CONTEXT
 DQ ATT  ; @  FETCH
 DQ ATT  ; @  FETCH



 DQ _LIT
 DQ UVR ; set user variables
; DQ _LIT, UP,ATT
 DQ UP
; DQ _LIT,50H
 DQ _LIT,200      ; UPからの変数の個数２５個✖８Byte=200　→再確認した。問題なし。
 DQ _CMOVE
 DQ MTBUF ; EMPTY-BUFFERS
 DQ ABORT ; ABORT





; KEY
;  ok!
_KEY9:
 DB 83H
 DB 'KE'
 DB 'Y'+80H
 DQ COLD9
_KEY:
; DQ DOCOL

; DQ BREAK_POINT
; DQ 50H

; FIGに合わせて修正
; DQ CIN
 DQ KEY_2
KEY_2:
 JMP PKEY
;
; DQ SEMIS


; ?TERMINAL
;  ok!
QTERM9:
 DB 89H
 DB '?TERMINA'
 DB 'L'+80H
 DQ _KEY9
QTERM:
 DQ QTERM_2
QTERM_2:
 JMP PQTER



; EMIT    ( 0 --- )
                    ; TOSにある文字コードを出力印字する。
EMIT9:
 DB 84H
 DB 'EMI'
 DB 'T'+80H
 DQ QTERM9
EMIT:
 DQ DOCOL
 DQ PEMIT
 DQ _1, OUTT
 DQ PSTOR
 DQ SEMIS





; READ-REC
RREC9:
 DB 88H
 DB 'READ-RE'
 DB 'C'+80H
 DQ EMIT9
RREC:
 DQ DOCOL
 DQ READ
 DQ SEMIS

; WRITE-REC
WREC9:
 DB 89H
 DB 'WRITE-RE'
 DB 'C'+80H
 DQ RREC9
WREC:
 DQ DOCOL
 DQ WRITE
 DQ SEMIS



; *****MS-DOS INTERFACE *****
; CTST
; 
CTST9:
 DB 84H
 DB 'CTS'
 DB 'T'+80H
 DQ WREC9
CTST:
; DQ $+8
 DQ CTST_2
CTST_2:
; MOV AH,0BH
; INT 21H
; AND AX,1

;fopen_sの参考書式
;errno_t fopen_s(
;   FILE** pFile,            -> lea     rcx,ptr_fb_File
;   const char *filename,    -> lea     rdx,FILE_NAME
;   const char *mode         -> lea     r8,key_w_plus
;);
; 返り値：オープンしたストリームを制御するオブジェクトへのポインタを返す。オープン操作が失敗したとき、空ポインタを返す。

; -->これらの実験の結果、入出力処理はc++側で行うこととなった。
; -->As a result of these experiments, the input/output processing will be done on the c++ side.

 mov rdx,6          ; 6:

 call TO_CPP_IO

   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
   ;           999:EXIT SYSTEM
   ; output - rax:Output value  (not used)

;;   p->SCANVAL = key_state*0x100+c;
;;    AH:key_state, AL:c　


 JMP APUSH

 




; CIN
; 
CIN9:
 DB 83H
 DB 'CI'
 DB 'N'+80H
 DQ CTST9
CIN:
; DQ $+8
 DQ CIN_2
CIN_2:
; call get_char



; mov rax,123h
 mov rdx,1          ; 1:CIN

 call TO_CPP_IO

   ; input  - rax:Input value (not used)
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
   ;           999:EXIT SYSTEM
   ; output - rax:Output value


 JMP APUSH


; COUT
; 
COUT9:
 DB 84H
 DB 'COU'
 DB 'T'+80H
 DQ CIN9
COUT:
; DQ $+8
 DQ COUT_2
COUT_2:
; POP RDX
; MOV AH,2
; INT 21H

 pop rax

; call put_char

; mov rax,123h
 mov rdx,2          ; 2:COUT

 call TO_CPP_IO

   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
   ;           999:EXIT SYSTEM
   ; output - rax:Output value  (not used)

 JMP NEXT


; F_OPEN
; 
F_OPEN9:
 DB 86H
 DB 'F_OPE'
 DB 'N'+80H
 DQ COUT9
F_OPEN:
; DQ $+8
 DQ F_OPEN_2
F_OPEN_2:
; POP RDX
; MOV AH,2
; INT 21H

 pop rax

; call put_char

; mov rax,123h
 mov rdx,4          ; 4:F_OPEN

 call TO_CPP_IO

   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
  ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
  ;           999:EXIT SYSTEM
   ; output - rax:Output value  (not used);

 JMP NEXT

 
; F_CLOSE
; 
F_CLOSE9:
 DB 87H
 DB 'F_CLOS'
 DB 'E'+80H
 DQ F_OPEN9
F_CLOSE:
; DQ $+8
 DQ F_CLOSE_2
F_CLOSE_2:
; call get_char

; mov     rcx,[ptr_fb_File]
; call    fclose
;; 返り値：ストリームのクローズに成功したときは0を返し、何らかのエラーを検出したときEOFを返す。
; JMP NEXT


 mov rdx,5          ; 5:F_CLOSE

 call TO_CPP_IO

   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
   ;           999:EXIT SYSTEM
   ; output - rax:Output value  (not used)

 JMP NEXT



; INOUE-FORTHのPOUTを名称変更する。
; rename POUT of INOUE-FORTH.
;   F_OUT <-- POUT
F_OUT9:
 DB 85H
 DB 'F_OU'
 DB 'T'+80H
 DQ F_CLOSE9
F_OUT:
; DQ $+8
 DQ F_OUT_2
F_OUT_2:
; POP RDX
; MOV AH,5
; INT 21H

 pop rax

; mov rax,123h
 mov rdx,3          ; 3:F_COUT

 call TO_CPP_IO

 JMP NEXT


; INOUE-FORTHのPOUTを名称変更する。
; rename POUT of INOUE-FORTH.
;   F_IN <-- PIN
F_IN9:
 DB 84H
 DB 'F_I'
 DB 'N'+80H
 DQ F_OUT9
F_IN:
; DQ $+8
 DQ F_IN_2
F_IN_2:

; mov rax,123h
 mov rdx,7          ; 7:F_IN

 call TO_CPP_IO

 JMP APUSH






TO_CPP_IO:

 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx],rax
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value  p->SCANVAL  -->[rcx +  0]
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
   ;           999:EXIT SYSTEM
   ; output - rax:Output value  p->SCANVAL  -->[rcx +  0]

 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov RAX,[rcx+ 0]
 
 ret






; TRACE_ON_OFF
; 
TRACE_ON_OFF9:
 DB 8CH
 DB 'TRACE_ON_OF'
 DB 'F'+80H
 DQ F_IN9
TRACE_ON_OFF:
; DQ $+8
 DQ TRACE_ON_OFF_2
TRACE_ON_OFF_2:
; POP RDX
; MOV AH,2
; INT 21H

 pop rax  ; RAX=0:OFF =ELSE(実際は1):ON

; call put_char

; mov rax,123h
 mov rdx,8          ; 8:TRACE_ON_OFF

 call TO_CPP_IO

   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ;             6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT
   ;             7:F_CIN
   ;             8:TRACE_ON_OFF
   ;           999:EXIT SYSTEM
   ; output - rax:Output value  (not used)

 JMP NEXT





; READとWRITEはまだ実験していない。
; read and write have not been experimented with yet.

; READ
READ9:
 DB 84H
 DB 'REA'
 DB 'D'+80H
 DQ F_OUT9
READ:
; DQ $+8
 DQ READ_2
READ_2:
 POP RDX
 POP RCX
 POP RBX
 POP RAX
 PUSH RBP
 PUSH RSI
 INT 25H
 POP RAX
 POP RSI
 POP RBP
 JMP APUSH

; WRITE
WRITE9:
 DB 85H
 DB 'WRIT'
 DB 'E'+80H
 DQ READ9
WRITE:
; DQ $+8
 DQ WRITE_2
WRITE_2:
 POP RDX
 POP RCX
 POP RBX
 POP RAX
 PUSH RBP
 PUSH RSI
 INT 26H
 POP RAX
 POP RSI
 POP RBP
 JMP APUSH

;END CLD9


















ENCLOSE9:
;  written in FORTH ok??
 DB 87H
 DB 'ENCLOS'
 DB 'E'+80H
 DQ WRITE9
ENCLOSE:
 DQ ENCLOSE_2
ENCLOSE_2:
 POP RAX
 POP RBX
 PUSH RBX
; XOR RAX,RAX
; MOV AL,DL
 MOV AH,0
 MOV RDX,-1
 DEC RBX

; SCAN TO FIRST NON-TERMINATION
;
ENCL1:
 INC RBX
 INC RDX
 CMP AL,[RBX]
 JZ ENCL1
 PUSH RDX
 CMP AH,[RBX]
 JNZ ENCL2

; FOUND NULL BEFORE FIRST NON-TERMINATION
;
 MOV RAX,RDX
 INC RDX
 JMP DPUSH

; FOUND FIRST TEXT CHAR, COUNT THE CHARACTERS
;
ENCL2:
 INC RBX
 INC RDX
 CMP AL,[RBX]
 JZ ENCL4
 CMP AH,[RBX]
 JNZ ENCL2

; FOUND NULL AT END OF TEXT
;
ENCL3:
 MOV RAX,RDX
 JMP DPUSH

; FOUND TERMINATOR CHARACTER
;
ENCL4:
 MOV RAX,RDX
 INC RAX
 JMP DPUSH




; (FIND)  ( a1 a2 --- a / ff ;
;  written in FORTH ok??
; a1:top address of text string to be tested for matching
; a2:name field address at which dictionary seaching is started
; a :compilation address of the word found
; ff:unfound, false flag )
PFIND9:
 DB 86H
 DB '(FIND'
 DB ')'+80H
 DQ ENCLOSE9
PFIND:
 DQ PFIND_2
PFIND_2:
 POP RBX
 POP RCX
 XOR RAX,RAX
;

;SEARCH LOOP
PFIN1:

;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ PFIND_SKIP01

 PUSH RBX
 PUSH RCX
 PUSH RDX

    sub     rsp, 28h

    MOV     R8,RBX
    LEA     rdx,WORD_ADDR_OF_SERCH_WORD
    lea     rcx, PRT_FORM_OF_SERCH_WORD

    call    printf

    add     rsp, 28h


 POP RDX
 POP RCX
 POP RBX

PFIND_SKIP01:

; INC RCX

; 最初にWORD名の文字数を比較する
 MOV RDI,RCX
 XOR RAX,RAX
 MOV AL,[RBX]
 MOV DL,AL
 XOR AL,[RDI]
 AND AL,3FH
 JNZ PFIN5      ; LENGTH DIFFER

; LENGTH MATCH, CHECK EACH CHARACTER IN NAME
; (RBX == LFA - 1)
PFIN2:
 INC RBX        ; RBX == LFA
 INC RDI        ; RDI == LFA
 MOV AL,[RBX]
 XOR AL,[RDI]
 CMP AX,80H
 JG PFIN6      ; NO MATCH
 JB PFIN2      ; MATCH SO FAR, LOOP

PFIN4:
; FOUND END OF MATCH
;; ADD BX,5 ; BX = PFA
 ADD RBX,8*2+1  ; RBX === PFA
 PUSH RBX       ; (S3) <= PFA
 MOV [CHECK_ADDR_NEW],RBX

 JMP NEXT


; NO NAME FIELD MATCH, TRY ANOTHER
;
; GET NEXT LINK FIELD ADDR
; (ZERO = FIRST WORD OF DICTIONARY)
;
PFIN5:
 INC RBX  ; フラグは変化なし

 XOR RAX,RAX
 MOV AL,[RBX]
 AND AL,80H
 JNZ PFIN6
 JMP PFIN5


PFIN6:
 INC RBX
; R11: <- CHECK THIS REGISTER DATA WHEN DEBUG.
 MOV R11,RBX
;
 MOV RBX,[RBX]
 OR RBX,RBX
 JZ PFIN_61
 MOV R10,ORIG
 CMP RBX,R10
 JL PFIN_63
 MOV R10,CODE_END
 CMP RBX,R10
 JLE PFIN1

PFIN_63:
 MOV R10,UVR
 CMP RBX,R10
 JL PFIN_62_2
 MOV R10,SYS_LIMIT
 CMP RBX,R10
 JG PFIN_62_3

 JMP PFIN1
;
;
;
PFIN_62_1:
 MOV RAX,0
 JMP PFIN_62
PFIN_62_2:
 MOV RAX,1
 JMP PFIN_62
PFIN_62_3:
 MOV RAX,2
 JMP PFIN_62

;
;; エラーによる実行終了
PFIN_62:

;
; レジスタのオーバーフローチェック
         PUSH R8
         PUSH R9
         MOV R8,RBX
         MOV R9,0FF0100H
         CALL CHECK_MEM_WRITE
         POP R9
         POP R8
;
; XOR RAX,RAX
 MOV [RAX],RAX
;
;
PFIN_61:
 MOV RAX,0
 JMP APUSH



; -FIND  ; ( --- a ) でいいのだろうか？
DFIND9:
 DB 85H
 DB 'DFIN'
 DB 'D'+80H
 DQ PFIND9
DFIND:
 DQ DOCOL
 DQ _BL

 DQ BREAK_POINT
 DQ 10401H

 DQ _WORD

 DQ BREAK_POINT
 DQ 10402H

; DQ HERE
 DQ CONTEXT
 DQ ATT
 DQ ATT

 DQ BREAK_POINT
 DQ 104039H

 DQ PFIND

 DQ BREAK_POINT
 DQ 10403H

 DQ DUPE
 DQ ZEQU
 DQ ZBRAN
DFIND_AFT_IF:
 DQ DFIND_AFT_THEN - DFIND_AFT_IF

 DQ BREAK_POINT
 DQ 10404H

 DQ DROP
 DQ HERE
 DQ LATEST
 DQ PFIND

 DQ BREAK_POINT
 DQ 10405H

DFIND_AFT_THEN:
 DQ SEMIS


; (ABORT)
PABOR9:
 DB 87H
 DB '(ABORT'
 DB ')'+80H
 DQ DFIND9
PABOR:
 DQ DOCOL
 DQ ABORT
 DQ SEMIS


;  OK!
; DIGIT
DIGIT9:
 DB 85H
 DB 'DIGI'
 DB 'T'+80H
 DQ PABOR9
DIGIT:
 DQ DIGIT_2
DIGIT_2:
 POP RDX
 POP RAX
 SUB AL,'0'
 JB DIGI2
 CMP AL,9
 JBE DIGI1
 SUB AL,7
 CMP AL,10
 JB DIGI2

DIGI1:
 CMP AL,DL
 JAE DIGI2
 SUB RDX,RDX
 MOV DL,AL
 MOV AL,1  ; TRUE FLAG
 JMP DPUSH

; NUMBER ERROR
;
DIGI2:
 SUB RAX,RAX
 JMP APUSH






; +!
;  written in ASM ok?? ４行で書けている！
PSTOR9:
 DB 82H
 DB '+'
 DB '!'+80H
 DQ DIGIT9
PSTOR:
 DQ PSTOR_2
PSTOR_2:
 POP RBX
 POP RAX
 ADD [RBX],RAX
 JMP NEXT



; ERASE
;  OK!
ERASE9:
 DB 85H
 DB 'ERAS'
 DB 'E'+80H
 DQ PSTOR9
ERASE:
 DQ DOCOL
 DQ _0
 DQ _FILL
 DQ SEMIS

; BLANKS
;  OK!
BLANKS9:
 DB 86H
 DB 'BLANK'
 DB 'S'+80H
 DQ ERASE9
BLANKS:
 DQ DOCOL
 DQ _BL
 DQ _FILL
 DQ SEMIS

; <ROT
YROT9:
 DB 84H
 DB '<RO'
 DB 'T'+80H
 DQ BLANKS9
YROT:
 DQ DOCOL
 DQ ROT
 DQ ROT
 DQ SEMIS

; C@
;  OK!
CAT9:
 DB 82H
 DB 'C'
 DB '@'+80H
 DQ YROT9
CAT:
 DQ CAT_2
CAT_2:

 POP RBX
 XOR RAX,RAX   ; これ重要！


;
; レジスタのオーバーフローチェック
         PUSH R8
         PUSH R9
         MOV R8,RBX
         MOV R9,103H
         CALL CHECK_MEM_WRITE
         POP R9
         POP R8
;


 MOV AL,[RBX]

 push rax

 mov r11,2+1         ; display  Regs.
 lea r10,WORD_NAME_LIT
 call dumpReg

 pop rax

 JMP APUSH



; CMOVE
_CMOVE9:
 DB 85H
 DB 'CMOV'
 DB 'E'+80H
 DQ CAT9
_CMOVE:
 DQ CMOVE_2
CMOVE_2:
 CLD
 MOV RBX,RSI
 POP RCX
 POP RDI
 POP RSI
 REP MOVSB
 MOV RSI,RBX
 JMP NEXT



; <CMOVE  ( a1 a2 n --- )  a1からa2へnバイトの転送を行うが、番地の高い方から低い方へ向かって順に転送を行う
YCMOVE9:
 DB 86H
 DB '<CMOV'
 DB 'E'+80H
 DQ _CMOVE9
YCMOVE:
 DQ DOCOL
 DQ SWAP  ; ( a1 n a2 )
 DQ OVER  ; ( a1 n a2 n )
 DQ PLUS  ; ( a1 n a2+n )
 DQ _1MN  ; ( a1 n a2+n-1 )
 DQ YROT    ; <ROT ( n1 n2 n3 -- n3 n1 n2 )
            ;( a2+n-1 a1 n )
 DQ OVER    ;( a2+n-1 a1 n a1 )
 DQ PLUS    ;( a2+n-1 a1 a1+n )
 DQ _1MN    ;( a2+n-1 a1 a1+n-1 )
 DQ XDO   ; DO ( n1 n2 --- )  n1:インデックスの最終の限度値、n2:インデックスの初期値
          ; ( a2+n-1 )  DO( n1:a1 n2:a1+n-1)
YCMOVE_AFT_DO:
 DQ IDO   ; ( a2+n-1 現在のIの値 )  DO( n1:a1 n2:a1+n-1)
 DQ CAT   ; C@ ( a --- b )  TOSが示すアドレスにある１バイトのデータをTOSにのせる。
          ; ( a2+n-1 Iが示していたアドレスの値（１バイト） )
 DQ OVER  ; ( a2+n-1 Iが示していたアドレスの値（１バイト） a2+n-1 )
 DQ CSTOR ; c! ( b a --- ) １バイトのデータbをTOSが示すアドレスに格納する。
          ;  ( a2+n-1 )
 DQ _1MN  ;  ( a2+n-1-1 )
 DQ MINS1 ;  ( a2+n-1-1 -1 )
 DQ XPLOO    ; +LOOP ( n --- ) 実行ごとに繰り返し条件のためのインデックスの増減値nをスタックから取り出す。
             ; ( a2+n-1-1 ) →転送先の最終アドレスー１（１減らしたアドレス値）で、ループのはじまりからIDOの状態( a2+n-1を-1する 現在のI-1の値 )で繰り返す。
YCMOVE_AFT_PLOOP:
 DQ YCMOVE_AFT_DO - YCMOVE_AFT_PLOOP
 DQ DROP  ; () →入力時のスタックの値をすべて消費された。
 DQ SEMIS

; NOT
_NOT9:
 DB 83H
 DB 'NO'
 DB 'T'+80H
 DQ YCMOVE9
_NOT:
 DQ DOCOL
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ SEMIS

; =
;  OK!
_EQ9:
 DB 81H
 DB '='+80H
 DQ _NOT9
_EQ:
 DQ DOCOL
 DQ SUBB
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ SEMIS

; <>
NTEQ9:
 DB 82H
 DB '<'
 DB '>'+80H
 DQ _EQ9
NTEQ:
 DQ DOCOL
 DQ _EQ
 DQ _NOT
 DQ SEMIS

; <
; FIGにならってワード名を_DIGITからLESSに直そう。
LESS9:
 DB 81H
 DB '<'+80H
 DQ NTEQ9
LESS:
 DQ DOCOL
 DQ SUBB
 DQ ZLESS  ; 0<
 DQ SEMIS

; >
;  OK!
GREAT9:
 DB 81H
 DB '>'+80H
 DQ LESS9
GREAT:
 DQ DOCOL
 DQ SWAP
 DQ LESS
 DQ SEMIS

; U<
USMR9:
 DB 82H
 DB 'U'
 DB '<'+80H
 DQ GREAT9
USMR:
 DQ DOCOL
 DQ TDUP
 DQ XORR
 DQ ZLESS  ; 0<
 DQ ZBRAN
USMR_AFT_IF:
 DQ USMR_AFT_ELSE +8- USMR_AFT_IF
 DQ DROP
 DQ ZLESS  ; 0<
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
; DQ _ELSE
 DQ BRAN
USMR_AFT_ELSE:
 DQ USMR_AFT_THEN - USMR_AFT_ELSE
 DQ SUBB
 DQ ZLESS  ; 0<
; DQ THEN
USMR_AFT_THEN:
 DQ SEMIS

; MIN
; FIGの方が効率的だ
MIN9:
 DB 83H
 DB 'MI'
 DB 'N'+80H
 DQ USMR9
MIN:
 DQ DOCOL
 DQ TDUP
 DQ GREAT    ; >
 DQ ZBRAN
MIN_AFT_IF:
 DQ MIN_AFT_THEN - MIN_AFT_IF
 DQ SWAP
; DQ THEN
MIN_AFT_THEN:
 DQ DROP
 DQ SEMIS

; MAX
; FIGの方が効率的だ
MAX9:
 DB 83H
 DB 'MA'
 DB 'X'+80H
 DQ MIN9
MAX:
 DQ DOCOL
 DQ TDUP
 DQ LESS    ; <
 DQ ZBRAN
MAX_AFT_IF:
 DQ MAX_AFT_THEN - MAX_AFT_IF
 DQ SWAP
; DQ THEN
MAX_AFT_THEN:
 DQ DROP
 DQ SEMIS

; +-
; FIGではNEGATEをMINUSで行っている
PLMN9:
 DB 82H
 DB '+'
 DB '-'+80H
 DQ MAX9
PLMN:
 DQ DOCOL
 DQ ZLESS  ; 0<
 DQ ZBRAN
PLMN_AFT_IF:
 DQ PLMN_AFT_THEN - PLMN_AFT_IF
;; 次がINOUE-FORTHではNEGATEとしていたが、FIG-FORTHに合わせてMINUSに変更した。
;; DQ NEGATE
 DQ MINUS
;

; DQ THEN
PLMN_AFT_THEN:
 DQ SEMIS



; ABS
;  OK!
ABS9:
 DB 83H
 DB 'AB'
 DB 'S'+80H
 DQ PLMN9
ABS:
 DQ DOCOL
 DQ DUPE
 DQ PLMN    ; +-
 DQ SEMIS

; D+-
; FIGではDNEGATEをDMINUで行っている
DPLMN9:
 DB 83H
 DB 'D+'
 DB '-'+80H
 DQ ABS9
DPLMN:
 DQ DOCOL
; DQ DUPE
 DQ ZLESS  ; 0<
 DQ ZBRAN
DPLMN_AFT_IF:
 DQ DPLMN_AFT_THEN - DPLMN_AFT_IF
;; FIG-FORTH版に合わせて修正した
;; DQ DNEGATE
 DQ DMINUS
;
; DQ THEN
DPLMN_AFT_THEN:
 DQ SEMIS

; DABS
;  OK!
DABS9:
 DB 84H
 DB 'DAB'
 DB 'S'+80H
 DQ DPLMN9
DABS:
 DQ DOCOL
 DQ DUPE
 DQ DPLMN    ; D+-
 DQ SEMIS

; -DUP
DDUP9:
 DB 84H
 DB '-DU'
 DB 'P'+80H
 DQ DABS9
DDUP:
 DQ DOCOL

 DQ _LIT, 8+4+2+1
 DQ DUMP_BREAK_POINT

 DQ DUPE
 DQ ZBRAN
DDUP_AFT_IF:
 DQ DDUP_AFT_THEN - DDUP_AFT_IF
 DQ DUPE
; DQ THEN
DDUP_AFT_THEN:
 DQ SEMIS

; S->D
;  OK! FIGではマシン語で書かれている
STOD9:
 DB 84H
 DB 'S->'
 DB 'D'+80H
 DQ DDUP9
STOD:
 DQ STOD_2
STOD_2:
 POP RDX
 SUB RAX,RAX
 OR RDX,RDX
 JNS STOD_AFT_THEN
STOD_AFT_IF:
 DEC RAX
STOD_AFT_THEN:
 JMP DPUSH



; M/MOD
;  OK!
MSMOD9:
 DB 85H
 DB 'M/MO'
 DB 'D'+80H
 DQ STOD9
MSMOD:
 DQ DOCOL
 DQ TOR    ; >R
 DQ _0
 DQ RAT  ; R@
 DQ USLAS  ; U/
 DQ FROMR    ; R>
 DQ SWAP
 DQ TOR    ; >R
 DQ USLAS  ; U/
 DQ FROMR    ; R>
 DQ SEMIS

; M/
;  OK!
MSLAS9:
 DB 82H
 DB 'M'
 DB '/'+80H
 DQ MSMOD9
MSLAS:
 DQ DOCOL
 DQ OVER
 DQ TOR    ; >R
 DQ TOR    ; >R
 DQ DABS
 DQ USLAS  ; U/
 DQ FROMR    ; R>
 DQ RAT  ; R@
 DQ XORR
 DQ PLMN    ; +-
 DQ SWAP
 DQ FROMR    ; R>
 DQ PLMN    ; +-
 DQ SWAP
 DQ SEMIS

; /MOD
;  OK!
SLMOD9:
 DB 84H
 DB '/MO'
 DB 'D'+80H
 DQ MSLAS9    ; M/9
SLMOD:
 DQ DOCOL
 DQ TOR    ; >R
 DQ STOD    ; S->D
 DQ FROMR    ; R>
 DQ FROMR    ; R>
 DQ MSLAS    ; M/
 DQ SEMIS

; /
;  OK!
SLASH9:
 DB 81H
 DB '/'+80H
 DQ SLMOD9
SLASH:
 DQ DOCOL
 DQ SLMOD    ; /MOD
 DQ SWAP
 DQ DROP
 DQ SEMIS

; 2DUP
;  written in ASM ok??
TDUP9:
 DB 84H
 DB '2DU'
 DB 'P'+80H
 DQ SLASH9
TDUP:
 DQ DOCOL
 DQ OVER
 DQ OVER
 DQ SEMIS

; 2DROP
_2DROP9:
 DB 85H
 DB '2DRO'
 DB 'P'+80H
 DQ TDUP9
_2DROP:
 DQ DOCOL
 DQ DROP
 DQ DROP
 DQ SEMIS

; 2@
_2FETCH9:
 DB 82H
 DB '2'
 DB '@'+80H
 DQ _2DROP9
_2FETCH:
 DQ DOCOL
 DQ DUPE
 DQ ATT  ; "@" FETCH
 DQ SWAP
; DQ _2PL
 DQ _8PL   ; set next address
 DQ ATT  ; "@" FETCH
 DQ SEMIS





; 1+
;  OK!
_1PL9:
 DB 82H
 DB '1'
 DB '+'+80H
 DQ _2FETCH9
_1PL:
 DQ DOCOL
 DQ _1
 DQ PLUS
 DQ SEMIS

; 2+
;  OK!
_2PL9:
 DB 82H
 DB '2'
 DB '+'+80H
 DQ _1PL9
_2PL:
 DQ DOCOL
 DQ _2
 DQ PLUS
 DQ SEMIS

; 8+
_8PL9:
 DB 82H
 DB '8'
 DB '+'+80H
 DQ _2PL9
_8PL:
 DQ DOCOL
 DQ _LIT,8
 DQ PLUS
 DQ SEMIS

; 1-
_1MN9:
 DB 82H
 DB '1'
 DB '-'+80H
 DQ _8PL9
_1MN:
 DQ DOCOL
 DQ _1
 DQ SUBB
 DQ SEMIS

; 2-
_2MN9:
 DB 82H
 DB '2'
 DB '-'+80H
 DQ _1MN9
_2MN:
 DQ DOCOL
 DQ _2
 DQ SUBB
 DQ SEMIS

; 8-
_8MN9:
 DB 82H
 DB '8'
 DB '-'+80H
 DQ _2MN9
_8MN:
 DQ DOCOL
 DQ _LIT,8
 DQ SUBB
 DQ SEMIS

; 2*
_2ML9:
 DB 82H
 DB '2'
 DB '*'+80H
 DQ _8MN9
_2ML:
 DQ DOCOL
 DQ DUPE
 DQ PLUS
 DQ SEMIS

; 8*
_8ML9:
 DB 82H
 DB '8'
 DB '*'+80H
 DQ _2ML9
_8ML:
 DQ _8ML_2
_8ML_2:
 POP RAX
 mov rbx,8
 MUL rbx
 JMP APUSH



; HOLD      ( c --- )
;  OK!
HOLD9:
 DB 84H
 DB 'HOL'
 DB 'D'+80H
 DQ _8ML9
HOLD:
 DQ DOCOL
 DQ MINS1
 DQ HLD
 DQ PSTOR    ; +!
 DQ HLD
 DQ ATT  ; "@" FETCH
 DQ CSTOR
 DQ SEMIS

; #        ( ud1 --- ud2 )
DIG9:
 DB 81H
 DB '#'+80H
 DQ HOLD9
DIG:
 DQ DOCOL
 DQ BASE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ ATT  ; "@" FETCH
 DQ MSMOD    ; M/MOD
 DQ ROT
 DQ _LIT,9
 DQ OVER
 DQ LESS    ; <
 DQ ZBRAN
DIG_AFT_IF:
 DQ DIG_AFT_THEN - DIG_AFT_IF
 DQ _LIT,7
 DQ PLUS
; DQ THEN
DIG_AFT_THEN:
 DQ _LIT,30h
 DQ PLUS
 DQ HOLD
 DQ SEMIS

; #S      ( ud --- 0 0 )
;  OK!
DIGS9:
 DB 82H
 DB '#'
 DB 'S'+80H
 DQ DIG9
DIGS:
 DQ DOCOL
; DQ BEGIN
DIGS_AFT_BEGIN:
 DQ  DIG    ; #
 DQ OVER
 DQ OVER
 DQ ORR
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
; DQ UNTIL
 DQ ZBRAN
DIGS_AFT_UNTIL:
 DQ DIGS_AFT_BEGIN - DIGS_AFT_UNTIL
 DQ SEMIS

; <#       ( --- )
;  OK!
BDIGS9:
 DB 82H
 DB '<'
 DB '#'+80H
 DQ DIGS9
BDIGS:
 DQ DOCOL
 DQ PAD
 DQ HLD
 DQ STORE

 DQ SEMIS

; #>         ( d --- a n )
;  OK!
EDIGS9:
 DB 82H
 DB '#'
 DB '>'+80H
 DQ BDIGS9
EDIGS:
 DQ DOCOL
 DQ _2DROP
 DQ HLD
 DQ ATT  ; "@" FETCH
 DQ PAD
 DQ OVER
 DQ SUBB
 DQ SEMIS

; SIGN       ( n ud --- ud )
;  OK!
SIGN9:
 DB 84H
 DB 'SIG'
 DB 'N'+80H
 DQ EDIGS9
SIGN:
 DQ DOCOL
 DQ ROT
 DQ ZLESS  ; 0<
 DQ ZBRAN
SIGN_AFT_IF:
 DQ SIGN_AFT_THEN - SIGN_AFT_IF
 DQ _LIT,2DH    ; ( - code )
 DQ HOLD
; DQ THEN
SIGN_AFT_THEN:
 DQ SEMIS

; COUNT         ( a --- a+1 )
;  OK!
COUNT9:
 DB 85H
 DB 'COUN'
 DB 'T'+80H
 DQ SIGN9
COUNT:
 DQ DOCOL
 DQ DUPE
 DQ _1PL
 DQ SWAP
 DQ CAT    ; C@
 DQ SEMIS

; TYPE        ( a c --- )
;  OK!
_TYPE9:
 DB 84H
 DB 'TYP'
 DB 'E'+80H
 DQ COUNT9
_TYPE:
 DQ DOCOL
 DQ DDUP    ; -DUP  ( n --- 0 / n n ) ｎはアドレス値
 DQ ZBRAN
_TYPE_1_AFT_IF:
 DQ _TYPE_1_AFT_ELSE +8- _TYPE_1_AFT_IF
 DQ OVER
 DQ PLUS
 DQ SWAP
 DQ XDO  ; ( n1 n2 --- ) n1：上限値、n2：初期値
TYPE_2_AFT_XDO:
 DQ IDO  ; ( --- n )  n：現在値
 DQ CAT    ; C@
 DQ EMIT
 DQ XLOOP
TYPE_2_AFT_XLOOP:
 DQ TYPE_2_AFT_XDO - TYPE_2_AFT_XLOOP  ;  -4*8
; 
 DQ BRAN
_TYPE_1_AFT_ELSE:
 DQ _TYPE_1_AFT_THEN - _TYPE_1_AFT_ELSE 
; DQ ELSE
 DQ DROP
_TYPE_1_AFT_THEN: 
 DQ SEMIS


; SPACE    ( --- )
;  OK!
SPACE9:
 DB 85H
 DB 'SPAC'
 DB 'E'+80H
 DQ _TYPE9
SPACE:
 DQ DOCOL
 DQ _BL
 DQ EMIT
 DQ SEMIS

; SPACES     ( n --- )
SPACES9:
 DB 86H
 DB 'SPACE'
 DB 'S'+80H
 DQ SPACE9
SPACES:
 DQ DOCOL
;; 追加２行　FIGに合わせた
 DQ _0
 DQ MAX
;;
 DQ DDUP    ; -DUP
 DQ ZBRAN
SPACES_AFT_IF:
 DQ SPACES_AFT_THEN - SPACES_AFT_IF
 DQ _0
 DQ XDO
SPACES_AFT_XDO:
 DQ SPACE
 DQ XLOOP
SPACES_AFT_XLOOP:
 DQ SPACES_AFT_XDO - SPACES_AFT_XLOOP  ;  -2*8
; DQ THEN
SPACES_AFT_THEN:
 DQ SEMIS

; -TRAILING     ( a n1 --- a n2 ; remove traviling blanks )
;  OK!
DTRAI9:
 DB 89H
 DB '-TRAILIN'
 DB 'G'+80H
 DQ SPACES9
DTRAI:
 DQ DOCOL
 DQ DUPE
 DQ _0
 DQ XDO
DTRAI_AFT_XDO:
 DQ TDUP
 DQ PLUS
 DQ _1MN
 DQ CAT    ; C@
 DQ _BL
 DQ SUBB
 DQ ZBRAN
DTRAI_AFT_IF:
 DQ DTRAI_AFT_ELSE +8- DTRAI_AFT_IF
 DQ _LEAVE
; DQ _ELSE
 DQ BRAN
DTRAI_AFT_ELSE:
 DQ DTRAI_AFT_THEN - DTRAI_AFT_ELSE
 DQ _1MN
; DQ THEN
DTRAI_AFT_THEN:
 DQ XLOOP
DTRAI_AFT_XLOOP:
 DQ DTRAI_AFT_XDO - DTRAI_AFT_XLOOP  ;  -12*8
 DQ SEMIS

; (.")      ( type in-line string )
;  OK!
PDOTQ9:
 DB 84H
 DB '(."'
 DB ')'+80H
 DQ DTRAI9
PDOTQ:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 231H

 DQ RAT  ; R@   ( n_次の文字のワード（この場合は「文字数＋文字列」の先頭アドレス）が指し示すアドレス) < a_次のワードの先頭アドレス >
 DQ COUNT  ;    ( n_上記+1 n ) < a_次のワードの先頭アドレス >
           ; COUNT ( a_文字数のアドレス --- a_文字列の先頭アドレス n_文字数)
 DQ DUPE   ;    ( n_上記+1 n n ) < a_次のワードの先頭アドレス >
 DQ _1PL   ;    ( n_上記+1 n n+1 ) < a_次のワードの先頭アドレス >
 DQ FROMR    ; R>   ( n_上記+1 n n+1 a_次のワードの先頭アドレス ) < >
 DQ PLUS       ;    ( n_上記+1 n a_次のワードの最後尾＋１のアドレス ) < >
 DQ TOR    ; >R     ( n_上記+1 n ) < a_次のワードの最後尾＋１のアドレス >


;; THEN
;PDOTQ_2_AFT_THEN:


 DQ _TYPE  ;        ( )  < a_次のワードの最後尾＋１のアドレス >
           ; TYPE ( a n --- )  アドレスａ以降に格納されているｎバイトのワードを印刷する。
 DQ SEMIS

; ."     ←   ." Hello"  もしくは　DQ DOTQ  DB 5,"Hello" 
;  OK!
DOTQ9:
 DB 0C2H
 DB '.'
 DB '"'+80H
 DQ PDOTQ9
DOTQ:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 310H


 DQ _LIT,22H   ; ( " code ) スタックに22Hが積まれ、のちのWORDで使用される

 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT  ; "@" FETCH
 DQ ZBRAN
DOTQ_AFT_IF:
 DQ DOTQ_AFT_ELSE +8- DOTQ_AFT_IF
 DQ COMP
 DQ PDOTQ    ; (.")
 DQ _WORD
; 一行追加
 DQ HERE
;
 DQ CAT    ; C@
 DQ _1PL
 DQ ALLOT
   ; ALLOTは領域を確保するだけでは？_WORDで得たアドレスからの文字列をコピーしなくては？

; DQ _ELSE
 DQ BRAN
DOTQ_AFT_ELSE:
 DQ DOTQ_AFT_THEN - DOTQ_AFT_ELSE

 DQ _WORD  ; ( c --- a ) 文字コードｃもしくはNULLコードまでが対象

 DQ BREAK_POINT
 DQ 311H


;; THEN
;DOTQ_2_AFT_THEN:


 DQ BREAK_POINT
 DQ 371H

 DQ COUNT  ; ( a1 --- a2 n )

 DQ BREAK_POINT
 DQ 372H

 DQ _TYPE  ; ( a n --- )

 DQ BREAK_POINT
 DQ 373H

; DQ THEN
DOTQ_AFT_THEN:

 DQ BREAK_POINT
 DQ 399H

 DQ SEMIS









; D.R
DDOTR9:
 DB 83H
 DB 'D.'
 DB 'R'+80H
 DQ DOTQ9
DDOTR:
 DQ DOCOL
 DQ TOR    ; >R
 DQ SWAP   ; SWAP
 DQ OVER   ; OVER
 DQ DABS   ; DABS
 DQ BDIGS  ; <#    BDIGS
 DQ DIGS   ; #S    DIGS
 DQ SIGN   ; SIGN
 DQ EDIGS  ; #>    EDIGS
 DQ FROMR  ; R>
 DQ OVER   ; OVER
 DQ SUBB   ; -
 DQ SPACES ; SPACES

 DQ BREAK_POINT
 DQ 225H

 DQ _TYPE; TYPE
 DQ SEMIS

; D.
DDOT9:
 DB 82H
 DB 'D'
 DB '.'+80H
 DQ DDOTR9
DDOT:
 DQ DOCOL
 DQ _0
 DQ DDOTR  ; 倍長数ｄを桁数ｎで印字出力する。
           ; この場合、桁数は０と設定しているということか？
 DQ SPACE
 DQ SEMIS

; .R
DOTR9:
 DB 82H
 DB '.'
 DB 'R'+80H
 DQ DDOT9
DOTR:
 DQ DOCOL
 DQ TOR    ; >R
 DQ STOD    ; S->D
 DQ FROMR    ; R>
 DQ DDOTR
 DQ SEMIS

; .
DOT9:
 DB 81H
 DB '.'+80H
 DQ DOTR9
DOT:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 226H

 DQ STOD    ; S->D
 DQ DDOT
 DQ SEMIS

; DECIMAL
;  OK!
DECIMAL9:
 DB 87H
 DB 'DECIMA'
 DB 'L'+80H
 DQ DOT9
DECIMAL:
 DQ DOCOL
 DQ _LIT,10    ; 10進数
 DQ BASE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ STORE  ; !
 DQ SEMIS

; HEX
;  OK!
HEX9:
 DB 83H
 DB 'HE'
 DB 'X'+80H
 DQ DECIMAL9
HEX:
 DQ DOCOL
 DQ _LIT,16   ; 16進数
 DQ BASE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ STORE  ; !
 DQ SEMIS

; (LINE)
; FIGに合わせること
PLINE9:
 DB 86H
 DB '(LINE'
 DB ')'+80H
 DQ HEX9
PLINE:
 DQ DOCOL
 DQ TOR    ; >R
 DQ _LIT, 64
 DQ B_BUF
 DQ SSMOD
 DQ FROMR    ; R>
 DQ BSCR
 DQ STAR
 DQ PLUS
 DQ BLOCK
 DQ PLUS
 DQ _LIT, 64
 DQ SEMIS

; .LINE
;  OK!
DLINE9:
 DB 85H
 DB '.LIN'
 DB 'E'+80H
 DQ PLINE9
DLINE:
 DQ DOCOL
 DQ PLINE    ; (LINE)
 DQ DTRAI
 DQ _TYPE
 DQ SEMIS

; LINE
LINE9:
 DB 84H
 DB 'LIN'
 DB 'E'+80H
 DQ DLINE9
LINE:
 DQ DOCOL
 DQ SCR
 DQ ATT  ; "@" FETCH
 DQ PLINE    ; (LINE)
 DQ SEMIS

; ?COMP ( --- )かな？
;  OK!
QCOMP9:
 DB 85H
 DB '?COM'
 DB 'P'+80H
 DQ LINE9
QCOMP:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT  ; "@" FETCH
 DQ ZEQU  ; "0=" ０なら1（真）、それ以外は０
 DQ _LIT,11h
 DQ QERROR  ; 真ならERROR（１１Ｈ番）、偽なら何もしない
 DQ SEMIS

; ?EXEC
;  OK!
QEXEC9:
 DB 85H
 DB '?EXE'
 DB 'C'+80H
 DQ QCOMP9
QEXEC:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT  ; "@" FETCH
 DQ _LIT,12H
 DQ QERROR
 DQ SEMIS

; ?STACK
;  OK!
QSTACK9:
 DB 86H
 DB '?STAC'
 DB 'K'+80H
 DQ QEXEC9
QSTACK:
 DQ DOCOL
 DQ SPAT    ; SP@
 DQ S0
 DQ ATT  ; "@" FETCH
 DQ SWAP
 DQ USMR    ; U<
 DQ _1
 DQ QERROR
 DQ SPAT    ; SP@
 DQ HERE
 DQ _LIT,80H
 DQ PLUS
 DQ USMR    ; U<
 DQ _LIT,7
 DQ QERROR
 DQ SEMIS
 
; ?PAIRS
;  OK!
QPAIRS9:
 DB 86H
 DB '?PAIR'
 DB 'S'+80H
 DQ QSTACK9
QPAIRS:
 DQ DOCOL
 DQ SUBB
 DQ _LIT,13H
 DQ QERROR
 DQ SEMIS
 
; ?LOADING
;  OK!
QLOADING9:
 DB 88H
 DB '?LOADIN'
 DB 'G'+80H
 DQ QPAIRS9
QLOADING:
 DQ DOCOL
 DQ BLK
 DQ ATT  ; "@" FETCH
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _LIT,16H
 DQ QERROR
 DQ SEMIS
 
; ?CSP
;  OK!
QCSP9:
 DB 84H
 DB '?CS'
 DB 'P'+80H
 DQ QLOADING9
QCSP:
 DQ DOCOL
 DQ SPAT    ; SP@
 DQ CSP
 DQ ATT  ; "@" FETCH
 DQ SUBB
 DQ _LIT,14H
 DQ QERROR
 DQ SEMIS

; !CSP
;  OK!
SCSP9:
 DB 84H
 DB '!CS'
 DB 'P'+80H
 DQ QCSP9
SCSP:
 DQ DOCOL
 DQ SPAT    ; SP@
 DQ CSP
 DQ STORE  ; !
 DQ SEMIS

; COMPILE
; １行修正済み
COMP9:
 DB 87H
 DB 'COMPIL'
 DB 'E'+80H
 DQ SCSP9
COMP:
 DQ DOCOL
 DQ QCOMP
 DQ FROMR    ; R>
 DQ DUPE
; DQ _2PL
 DQ _8PL
 DQ TOR    ; >R
 DQ ATT  ; "@" FETCH
; １行挿入。FIG資料より修正
 DQ COMMA
 DQ SEMIS
 
; [COMPILE]
; 修正済み。OK!
KKCOMPILE9:
 DB 0C9H
 DB '[COMPILE'
 DB ']'+80H
 DQ COMP9
KKCOMPILE:
;  コンパイル時、次の文字列を検索して、登録されたアドレスをCOMMAでストアする。
;  実行時は、既に登録されているアドレスからそれぞれのワードにジャンプして実行８する
 DQ DOCOL
 DQ DFIND

 DQ BREAK_POINT
 DQ 70H

 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _0
 DQ QERROR
 DQ DROP
 DQ CFA
 DQ COMMA
 DQ SEMIS







; LITERAL
; OK!
LITERAL9:
 DB 0C7H
 DB 'LITERA'
 DB 'L'+80H
 DQ KKCOMPILE9
LITERAL:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT  ; "@" FETCH
 DQ ZBRAN
LITERAL_AFT_IF:
 DQ LITERAL_AFT_THEN - LITERAL_AFT_IF
 DQ COMP
 DQ _LIT
 DQ COMMA
; DQ THEN
LITERAL_AFT_THEN:
 DQ SEMIS
 
; DLITERAL
;  OK!
DLITERAL9:
 DB 0C8H
 DB 'DLITERA'
 DB 'L'+80H
 DQ LITERAL9
DLITERAL:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT  ; "@" FETCH
 DQ ZBRAN
DLITERAL_AFT_IF:
 DQ DLITERAL_AFT_THEN - DLITERAL_AFT_IF
 DQ SWAP
 DQ LITERAL
 DQ LITERAL
; DQ THEN
DLITERAL_AFT_THEN:
 DQ SEMIS



; DEFINITIONS
;  OK!
DEFINITIONS9:
 DB 8bH
 DB 'DEFINITION'
 DB 'S'+80H
 DQ DLITERAL9
DEFINITIONS:
 DQ DOCOL
;
 DQ BREAK_POINT
 DQ 44H
;
 DQ CONTEXT
 DQ ATT  ; "@" FETCH
 DQ CURRENT
 DQ STORE  ; !
 DQ SEMIS
 
; ALLOT
;  OK!
ALLOT9:
 DB 85H
 DB 'ALLO'
 DB 'T'+80H
 DQ DEFINITIONS9
ALLOT:
 DQ DOCOL
 DQ DP
 DQ PSTOR    ; +!
 DQ SEMIS
 
; HERE
;  OK!
HERE9:
 DB 84H
 DB 'HER'
 DB 'E'+80H
 DQ ALLOT9
HERE:
 DQ DOCOL
 DQ DP
 DQ ATT  ; "@" FETCH
 DQ SEMIS
 
; PAD
;  OK!
PAD9:
 DB 83H
 DB 'PA'
 DB 'D'+80H
 DQ HERE9
PAD:
 DQ DOCOL
 DQ HERE
 DQ _LIT,44h
 DQ PLUS
 DQ SEMIS

; LATEST
;  OK!
LATEST9:
 DB 86H
 DB 'LATES'
 DB 'T'+80H
 DQ PAD9
LATEST:
 DQ DOCOL
 DQ CURRENT
 DQ ATT  ; "@" FETCH
 DQ ATT  ; "@" FETCH
 DQ SEMIS
 


; SMUDGE
;  OK!
SMUDG9:
 DB 86H
 DB 'SMUDG'
 DB 'E'+80H
 DQ LATEST9
SMUDG:
 DQ DOCOL
 DQ LATEST
 DQ _LIT,20H
 DQ TOGGL
 DQ SEMIS
 


;  OK!
TRAVERSE9:
 DB 88H
 DB 'TRAVERS'
 DB 'E'+80H
; DQ PLORIG9
 DQ SMUDG9
TRAVERSE:
 DQ DOCOL
 DQ SWAP
; DQ BEGIN
TRAVERSE_AFT_BEGIN:
 DQ OVER
 DQ PLUS
 DQ _LIT,07FH
 DQ OVER
 DQ CAT    ; C@
 DQ LESS    ; <
; DQ UNTIL
 DQ ZBRAN
TRAVERSE_AFT_UNTIL:
 DQ TRAVERSE_AFT_BEGIN - TRAVERSE_AFT_UNTIL
 DQ SWAP
 DQ DROP
 DQ SEMIS
 
; NFA
NFA9:
 DB 83H
 DB 'NF'
 DB 'A'+80H
 DQ TRAVERSE9
NFA:
 DQ DOCOL
; DQ _LIT,5
 DQ _LIT,8*2+1
 DQ SUBB
 DQ MINS1
 DQ TRAVERSE
 DQ SEMIS

; LFA
LFA9:
 DB 83H
 DB 'LF'
 DB 'A'+80H
 DQ NFA9
LFA:
 DQ DOCOL
 DQ _LIT,8*2
 DQ SUBB
 DQ SEMIS

; CFA
CFA9:
 DB 83H
 DB 'CF'
 DB 'A'+80H
 DQ LFA9
CFA:
 DQ DOCOL
; DQ _2MN
 DQ _8MN  ; SUB 8*1
 DQ SEMIS

; PFA
PFA9:
 DB 83H
 DB 'PF'
 DB 'A'+80H
 DQ CFA9
PFA:
 DQ DOCOL
 DQ _1
 DQ TRAVERSE
; DQ _LIT,5
 DQ _LIT,8*2+1
 DQ PLUS
 DQ SEMIS

; [
    ;  OK!
LBRAC9:
 DB 0C1H
 DB '['+80H
 DQ PFA9
LBRAC:
 DQ DOCOL
 DQ _0
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ STORE  ; !
 DQ SEMIS

; ]
;  OK!
RBRAC9:
 DB 0C1H
 DB ']'+80H
 DQ LBRAC9
RBRAC:
 DQ DOCOL
 DQ _LIT,0C0H
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ STORE  ; !
 DQ SEMIS

; ;
;  OK!
SEMI9:
 DB 0C1H
 DB ';'+80H
 DQ RBRAC9
SEMI:
 DQ DOCOL
 DQ QCSP
 DQ COMP
 DQ SEMIS
 DQ SMUDG
 DQ LBRAC    ; [
 DQ SEMIS

; ,
;  OK!
COMMA9:
 DB 81H
 DB ','+80H
 DQ SEMI9
COMMA:
 DQ DOCOL
 DQ HERE
 DQ STORE  ; !
 DQ _LIT,8
 DQ ALLOT
 DQ SEMIS



; C,
;  OK!
CCOMM9:
 DB 82H
 DB 'C'
 DB ','+80H
 DQ COMMA9
CCOMM:
 DQ DOCOL
 DQ HERE
 DQ CSTOR
 DQ _1
 DQ ALLOT
 DQ SEMIS

; VOCABULARY
; 修正箇所あり！ BUILD に注意！
VOCABULARY9:
 DB 08AH
 DB 'VOCABULAR'
 DB 'Y'+80H
 DQ CCOMM9
VOCABULARY:
 DQ DOCOL
 DQ BUILD
 DQ _LIT,0A081H
 DQ COMMA
 DQ CURRENT
 DQ ATT  ; "@" FETCH
 DQ CFA
 DQ COMMA
 DQ HERE
 DQ VOCLINK
 DQ ATT  ; "@" FETCH
 DQ COMMA
 DQ VOCLINK
 DQ STORE  ; !
 DQ DOES

DOVOC::
 DQ _2PL
 DQ CONTEXT
 DQ STORE
 DQ SEMIS






 
; FORGET
FORGET9:
 DB 86H
 DB 'FORGE'
 DB 'T'+80H
 DQ VOCABULARY9
FORGET:
 DQ DOCOL
 DQ CURRENT
 DQ ATT  ; "@" FETCH
 DQ CONTEXT
 DQ ATT  ; "@" FETCH
 DQ SUBB
 DQ _LIT,18H
 DQ QERROR
 DQ TICK
 DQ DUPE
 DQ FENCE
 DQ ATT  ; "@" FETCH
 DQ LESS
;
 DQ _LIT,15H
 DQ QERROR
 DQ DUPE
 DQ NFA
 DQ DP
 DQ STORE  ; !
 DQ LFA
 DQ ATT  ; "@" FETCH
 DQ CONTEXT
;
 DQ ATT  ; "@" FETCH
 DQ STORE  ; !
 DQ SEMIS
 
; <MARK
FRMARK9:
 DB 85H
 DB '<MAR'
 DB 'K'+80H
 DQ FORGET9
FRMARK:
 DQ DOCOL
 DQ HERE
 DQ SEMIS
 
; >MARK
TOMARK9:
 DB 85H
 DB '>MAR'
 DB 'K'+80H
 DQ FRMARK9
TOMARK:
 DQ DOCOL
 DQ HERE
 DQ _0
 DQ COMMA
 DQ SEMIS
 
; <RESOLVEだったのがBACKになった
FRRESOLVE9:
 DB 88H
 DB '<RESOLV'
 DB 'E'+80H
 DQ TOMARK9
FRRESOLVE:
 DQ DOCOL
 DQ HERE
 DQ SUBB
 DQ COMMA
 DQ SEMIS
 
; >RESOLVE
TORESOLVE9:
 DB 88H
 DB '>RESOLV'
 DB 'E'+80H
 DQ FRRESOLVE9
TORESOLVE:
 DQ DOCOL
 DQ HERE
 DQ OVER
 DQ SUBB
 DQ SWAP
 DQ STORE  ; !
 DQ SEMIS
 
; IF
_IF9:
 DB 0C2H
 DB 'I'
 DB 'F'+80H
 DQ TORESOLVE9
_IF:
 DQ DOCOL
 DQ COMP
 DQ ZBRAN
; 追加　FIGに合わせた。
 DQ HERE
 DQ _0
 DQ COMMA
 DQ _2
 DQ SEMIS

; THEN
THEN9:
 DB 0C4H
 DB 'THE'
 DB 'N'+80H
 DQ _IF9
THEN:
 DQ DOCOL
 DQ ENDIFF
;
 DQ SEMIS

; ELSE
_ELSE9:
 DB 0C4H
 DB 'ELS'
 DB 'E'+80H
 DQ THEN9
_ELSE:
 DQ DOCOL
 DQ _2
 DQ QPAIRS
 DQ COMP
 DQ BRAN
 DQ HERE
 DQ _0
 DQ COMMA
 DQ SWAP
 DQ _2
 DQ ENDIFF
 DQ _2
;
 DQ SEMIS


; BEGIN
BEGIN9:
 DB 0C5H
 DB 'BEGI'
 DB 'N'+80H
 DQ _ELSE9
BEGIN:
 DQ DOCOL
 DQ QCOMP
 DQ HERE
 DQ _1
 DQ SEMIS

; AGAIN
AGAIN9:
 DB 0C5H
 DB 'AGAI'
 DB 'N'+80H
 DQ BEGIN9
AGAIN:
 DQ DOCOL
 DQ _1
 DQ QPAIRS
 DQ COMP
 DQ BRAN
 DQ BACK
 DQ SEMIS

; UNTIL
UNTIL9:
 DB 0C5H
 DB 'UNTI'
 DB 'L'+80H
 DQ AGAIN9
UNTIL:
 DQ DOCOL
 DQ _1
 DQ QPAIRS
 DQ COMP
 DQ ZBRAN
 DQ BACK    ; <RESOLVEだったのがBACKになった
 DQ SEMIS
 
; WHILE
_WHILE9:
 DB 0C5H
 DB 'WHIL'
 DB 'E'+80H
 DQ UNTIL9
_WHILE:
 DQ DOCOL
 DQ _IF
 DQ _2PL
;
 DQ SEMIS
 
; REPEAT
_REPEAT9:
 DB 0C6H
 DB 'REPEA'
 DB 'T'+80H
 DQ _WHILE9
_REPEAT:
 DQ DOCOL
 DQ TOR
 DQ TOR
 DQ AGAIN
 DQ FROMR
 DQ FROMR
 DQ _2
 DQ SUBB
 DQ ENDIFF
 DQ SEMIS
 
; DO
DO9:
 DB 0C2H
 DB 'D'
 DB 'O'+80H
 DQ _REPEAT9
_DO:
 DQ DOCOL
 DQ COMP
 DQ XDO    ; (DO)
 DQ HERE
 DQ _3
 DQ SEMIS

; LOOP
_LOOP9:
 DB 0C4H
 DB 'LOO'
 DB 'P'+80H
 DQ DO9
_LOOP:
 DQ DOCOL
 DQ _3
 DQ QPAIRS
 DQ COMP
 DQ XLOOP    ; (LOOP)
 DQ BACK    ; <RESOLVEだったのがBACKになった
 DQ SEMIS

; +LOOP
PLLOOP9:
 DB 0C5H
 DB '+LOO'
 DB 'P'+80H
 DQ _LOOP9
PLLOOP:
 DQ DOCOL
 DQ _3
 DQ QPAIRS
 DQ COMP
 DQ XPLOO    ; (+LOOP)
 DQ BACK    ; <RESOLVEだったのがBACKになった
 DQ SEMIS

; LEAVE
;  written in ASM ok??
_LEAVE9:
 DB 85H
 DB 'LEAV'
 DB 'E'+80H
 DQ PLLOOP9
_LEAVE:
 DQ LEAVE_2
LEAVE_2:
 MOV RAX,[RBP]
 MOV 8[RBP],RAX
 JMP NEXT



; I
;  FIGではR@と同じことになっている。FIGに合わせること。
I9:
 DB 81H
 DB 'I'+80H
 DQ _LEAVE9
IDO:
 DQ IDO_2
IDO_2:
 MOV RAX,[RBP]
 JMP APUSH


; J
J9:
 DB 81H
 DB 'J'+80H
 DQ I9
JDO:
 DQ DOCOL
 DQ FROMR    ; R>
 DQ FROMR    ; R>
 DQ FROMR    ; R>
 DQ RAT  ; R@
 DQ YROT    ; <ROT
 DQ TOR    ; >R
 DQ TOR    ; >R
 DQ SWAP
 DQ TOR    ; >R
 DQ SEMIS

; BYE
BYE9:
 DB 0C3H
 DB 'BY'
 DB 'E'+80H
 DQ J9
BYE:
 DQ BYE_2
BYE_2:
 JMP EXIT

 
; PICK
    ; スタックの上位n1項をコピーしてTOSに複写する。
PICK9:
 DB 84H
 DB 'PIC'
 DB 'K'+80H
 DQ BYE9
PICK:
 DQ DOCOL
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*
 DQ SPAT    ; SP@
 DQ PLUS
 DQ ATT  ; "@" FETCH
 DQ SEMIS
 
; RPICK
    ; リターンスタックの上位n1項をコピーしてTOSに複写する。
RPICK9:
 DB 85H
 DB 'RPIC'
 DB 'K'+80H
 DQ PICK9
RPICK:
 DQ DOCOL
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*
 DQ RPAT    ; RP@
 DQ PLUS
 DQ ATT  ; "@" FETCH
 DQ SEMIS
 
; DEPTH
DEPTH9:
 DB 85H
 DB 'DEPT'
 DB 'H'+80H
 DQ RPICK9
DEPTH:
 DQ DOCOL
 DQ S0
 DQ ATT  ; "@" FETCH
 DQ SPAT    ; SP@
; DQ _2PL
 DQ _8PL
 DQ SUBB
; DQ TDIV
 DQ EDIV     ; 8/  TOSを８で割る。
 DQ SEMIS
 
; ROLL
; 回転によりスタックの上位n1項をTOSにする。
ROLL9:
 DB 84H
 DB 'ROL'
 DB 'L'+80H
 DQ DEPTH9
ROLL:
 DQ DOCOL
 DQ TOR    ; >R
 DQ RAT  ; R@
 DQ PICK    ; スタックの上位n1項をコピーしてTOSに複写する。
 DQ SPAT    ; SP@
 DQ DUPE
; DQ _2PL
 DQ _8PL
 DQ FROMR    ; R>
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*
 DQ YCMOVE    ; <CMOVE
 DQ DROP
 DQ SEMIS
 
; <ROLL   ( n --- ) 最上位を一番下に持ってくる
FRROLL9:
 DB 85H
 DB '<ROL'
 DB 'L'+80H
 DQ ROLL9
FRROLL:
 DQ DOCOL
 DQ TOR    ; >R  n -> ReturnStack
 DQ DUPE    ; DUP で最上位をDUPする  ( TopOfStack )
 DQ SPAT    ; SP@   TOSのアドレスをスタックへ  ( TopOfStack adr_TopOfStack  ) < n >
 DQ DUPE    ; DUP   (  TopOfStack adr_TopOfStack adr_TopOfStack  ) < n >
; DQ _2MN
 DQ _8MN  ; 8-      (  TopOfStack adr_TopOfStack adr_TopOfStack-8  ) < n >
 DQ RAT  ; R@       (  TopOfStack adr_TopOfStack adr_TopOfStack-8 n ) < n >
 DQ _1MN     ; -1     (  TopOfStack adr_TopOfStack adr_TopOfStack-8 n-1 ) < n >
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*    (  TopOfStack adr_TopOfStack adr_TopOfStack-8 (n-1)*8 ) < n >
 DQ _CMOVE  ; CMOVE  ( a1 a2 n --- ) なので ( TopOfStack )
 DQ SPAT    ; SP@   ( TopOfStack adr_TopOfStack )
 DQ FROMR    ; R>   ( TopOfStack adr_TopOfStack n )
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*   ( TopOfStack adr_TopOfStack n*8 )
 DQ PLUS    ;      ( TopOfStack adr_TopOfStack+n*8 )
 DQ STORE  ; !
 DQ SEMIS
 
; FIND
FIND9:
 DB 84H
 DB 'FIN'
 DB 'D'+80H
 DQ FRROLL9
FIND:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 5

 DQ _BL     ; blank code (20h)
 DQ _WORD   ; ( c --- a ) c:区切り文字コード, a:文字数（１バイト）と入力文字列

 DQ BREAK_POINT
 DQ 45H

 DQ CONTEXT ; WORD名の探索を行うためのボキャブラリーを示すシステム変数。初期値はFORTH+4
 DQ ATT  ; "@" FETCH
 DQ ATT  ; "@" FETCH　これでFORTHボキャブラリーの最初のWORDを指し示す。

 DQ BREAK_POINT
 DQ 9

 DQ PFIND

 DQ BREAK_POINT
 DQ 6

 DQ DUPE
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ ZBRAN
FIND_AFT_IF:
 DQ FIND_AFT_THEN - FIND_AFT_IF
 DQ DROP
 DQ HERE
 DQ LATEST
 DQ PFIND
; DQ THEN
FIND_AFT_THEN:

 DQ BREAK_POINT
 DQ 55H

 DQ SEMIS




; '
TICK9:
 DB 0C1H
 DB "'"+80H
 DQ FIND9
TICK:
 DQ DOCOL
 DQ DFIND
 DQ ZEQU
 DQ _0
 DQ QERROR
 DQ DROP
 DQ LITERAL
;
 DQ SEMIS





; WORD  ( c --- a )
;       文字コードｃまたはnullコードを区切り文字コードとして入力テキストから文字列を切り出し、入力された文字列（１バイト長）とそれに続く入力文字列が格納されたメモリ領域の先頭番地ａをスタックに置く。

_WORD9:
 DB 84H
 DB 'WOR'
 DB 'D'+80H
 DQ TICK9
_WORD:
; ( c --- a )
;  c:区切り文字コード
;  a:「文字数（１バイト）＋文字列」の先頭アドレス
 DQ DOCOL

; Q_WORD_STATE: フラグの内容をスタックにプッシュする
;   ; ０：キー入力や外部記憶装置からの入力時である、　１：それ以外である
; ーー＞いくら実験でも、もう少しまともなワードにできないものか？悩ましい。
 DQ Q_WORD_STATE
 DQ ATT

 DQ BREAK_POINT
 DQ 150H

 DQ _1
 DQ _EQ

; IF --> INTERPRETの中のFINDからWORDを呼び出した時以外の場合（フラグ＝＝１）
;        コンパイルしたワードの中に記録された文字数と文字列のデータから、それを呼び出すためのアドレス値にする場合
 DQ ZBRAN
_WORD_2_AFT_IF:
 DQ _WORD_2_AFT_ELSE +8- _WORD_2_AFT_IF
 DQ WORD_ADDRESS_SEARCH

;
; DQ BREAK_POINT
; DQ 78H

;ELSE --> INTERPRETの中のFINDからWORDを呼び出した時の場合（フラグ＝＝０）
;;        外部記憶からの入力かキーボードからの入力を文字数と文字列へのアドレス値もしくは数値へのポインタに変換する時
 DQ BRAN
_WORD_2_AFT_ELSE:
 DQ _WORD_2_AFT_THEN - _WORD_2_AFT_ELSE


 DQ _1  ; キー入力や外部記憶装置からの入力時以外にクリアする
 DQ Q_WORD_STATE
 DQ STORE  ; !


;;
 DQ BREAK_POINT
 DQ 456H
;;;
 DQ BLK    ; BLK ( --- a ) ユーザー変数BLKから呼び出されるアドレス値。インタプリタが入力文字列として処理しつつあるディスクのブロックナンバーを返す。
           ; インタプリタがコンソールから入力文字列を受け取っている場合はBLKの内容は０となる。
           ; まだディスクの確認は行われていない。今後は使用不可のままにすることを考えている。
 DQ ATT  ; "@" FETCH   ( c n_ディスクのブロックナンバー )
 DQ ZBRAN  ; BLKの内容が０の場合はELSEへ、それ以外は次のワードへ。
_WORD_AFT_IF:
 DQ _WORD_AFT_ELSE +8- _WORD_AFT_IF

;  
 DQ BLK  ; ( c a )
 DQ ATT  ; "@" FETCH     ( c n_ディスクのブロックナンバー )
 DQ BLOCK  ; ( n --- a )   ( c a_BLOCKバッファメモリ先頭アドレス )　　指定された仮想記録のブロックｎに対し、バッファメモリ領域の先頭アドレスａを返す。
; DQ _ELSE
 DQ BRAN
_WORD_AFT_ELSE:
 DQ _WORD_AFT_THEN - _WORD_AFT_ELSE
 DQ TIB    ; (c a_TIB )                テキスト入力バッファ。ａはその先頭アドレスである。バッファの大きさは８０を最小限とする。
 DQ ATT  ; "@" FETCH     (c n_TIB先頭アドレスの値（なぜ、ディスクはアドレスなのにディスプレイはバッファの先頭アドレスの値なのか？） )
           ;   TIBのアドレスが示す先には１０２４バイト＋αのレコードがあって、その先頭にはレコードの番号が書かれている。
           ;   @はそのレコード番号を読み込んでいるのではないだろうか？
; DQ THEN
_WORD_AFT_THEN:
 DQ INN   ; UserVariable >IN  ( --- a)  入力文字列の中で、バッファの初めから現在インタプリタが処理しつつある文字までのオフセット値を示すユーザー変数のアドレス。
           ;   ("to-in"と読む。）)
           ; (c BLOCKかTIBの先頭アドレス >INのアドレス )
 DQ ATT  ; "@" FETCH     ディスクだと ( c n_BLOCK先頭アドレス n_>IN )
 DQ PLUS   ; ディスクだと ( c n_BLOCK先頭アドレス+n_>IN )
 DQ SWAP   ; ディスクだと ( n_BLOCK先頭アドレス_＋_n_>IN c )
;
; DQ BREAK_POINT
; DQ 16
;
 DQ ENCLOSE  ; ( a c --- a n1 n2 n3 ;   a:文字列の先頭アドレス
;                                       c:区切り文字の文字コード
;                                      n1:文字列の先頭から、区切り文字を飛ばした文字が始まる位置までのオフセット数
;                                      n2:その文字列の区切り文字以外の文字後に現れる区切り文字の位置までのオフセット値
;                                      n3:n2での区切り文字で、そのつながりの最後の区切り文字の位置までのオフセット値
;     区切り文字を空白(20H)とする。n1-n3の文字列上の位置は以下のとおりである。
;                                  "   XXXXXX     "    
;                                      ^     ^   ^
;                                      n1    n2  n3
             ;)
             ; 
;
; DQ BREAK_POINT
; DQ 17
;
 
 DQ HERE      ; ( --- a )  次に使用可能な辞書の位置（アドレス）ａをスタックに置く。
              ;         現在は ( a n1 n2 n3 a_HERE )
 DQ _LIT,22H  ;                ( a n1 n2 n3 a_HERE 22h個（？'"'なのではないの？？ )
 DQ BLANKS    ; ( a n --- ) メモリアドレスａ以降のｎバイトのメモリ領域をASCIIコード２０ｈで満たす。
              ;         現在は ( a n1 n2 n3 )   
 DQ INN      ; >IN  ( --- a )  入力文字列に中で、バッファの初めから現在インタプリタが処理しつつある文字までのオフセット値を示すユーザー変数のアドレス。 
              ;         現在は ( a_スキャンした文字列の先頭アドレス n1 n2 n3 a_文字オフセット値 )
 DQ PSTOR    ; +!  >INの内容に追加した２０ｈを満たした領域を追加する。 現在は ( a n1 n2 )
 DQ OVER      ;    現在は ( a n1 n2 n1 )
 DQ SUBB      ;    現在は ( a n1 n2-n1 )  →目的の文字列の長さ     
 DQ TOR    ; >R    現在は ( a n1 ) < n2-n1 >
 DQ RAT  ; R@      現在は ( a n1 n2-n1 ) < n2-n1 >
 DQ HERE      ;    現在は ( a n1 n2-n1 a_HERE) < n2-n1 >
 DQ CSTOR     ;    現在は ( a n1 ) < n2-n1 >         →  次のメモリ領域の先頭アドレスに目的の文字列の長さを置く
 DQ PLUS      ;    現在は ( a+n1 ) < n2-n1 >         →目的の文字列の先頭アドレス
 DQ HERE      ;    現在は ( a+n1 a_HERE ) < n2-n1 >
 DQ _1PL      ;    現在は ( a+n1 a_HERE+1 ) < n2-n1 >  →目的の文字列の先頭アドレス、未使用領域の先頭アドレス
 DQ FROMR    ; R>  現在は ( a+n1 a_HERE2+1 n2-n1 )     →文字列の長さをリターンスタックからデータスタックに移す
 DQ _CMOVE    ; CMOVE ( a1 a2 n --- )
              ; ( )
; FIGではここはなかったので、とりあえず削除しておく-->あるのが正解
 DQ HERE      ; -->文字数＋文字列の亜鉛等アドレス
;
; 今の状態は、'.'は数値の文字列？？？のポインタがスタックにある。'."'は"文字数と文字列のポインタが欲しい場合はこのHEREを使えるようにするとＯＫとなる。

; THEN
_WORD_2_AFT_THEN:


 DQ BREAK_POINT
 DQ 19
;
DQ SEMIS



; 今回、ワード"WORD"の修正ために新規追加したワードである。

; WORD_ADDRESS_SEARCH
WORD_ADDRESS_SEARCH9:
 DB 093H
 DB 'WORD_ADDRESS_SEARC'
 DB 'H'+80H
 DQ _WORD9
WORD_ADDRESS_SEARCH:
 DQ WORD_ADDRESS_SEARCH +8

; デバッグ用ワード呼び出しレベルのパラメーターを一段上げる。
add [DEBUG_DUMP_LEVEL],1
add [SEE_THIS_WORD_ptr],8

; ワード"WORD"の次に書かれている文字数＋文字列の先頭アドレスをRSI(RDX)に、リターンスタック(RBP)にRSIの値をプッシュ。
 SUB RBP,8      ; RP  <-RP+8
 MOV [RBP],RSI  ; [RP]<-IP リターンスタックにPUSH
 MOV RSI,RDX    ; IP  <-RDX 次のワードのアドレスをIPに
                ; RSIはDOCOLの位置に設定されている。
 MOV RAX,[RBP+16]  ; [RBP+16]には処理が終わった次の実行ワードアドレスが入っている。
                   ; 今現在は文字数＋文字列の先頭アドレスが書き込まれている。
 MOV RDX,RAX
 XOR RBX,RBX
 MOV BL,[RAX]      ; BLに文字数を格納する。
 ADD RAX,RBX       ; 
 INC RAX           ; これでRAXには文字数＋文字列の次に書かれているワードのアドレスが格納される。
 MOV [RBP+16],RAX  ; [RBP+16]に次のワードのアドレスを格納する

    ; CMOVEの各レジスタへの設定値の作成 (RSI)
 MOV RAX,RDX
 INC RAX
 MOV [WORD__ADDRESS_SEARCH_RSI],RAX

    ; CMOVEの各レジスタへの設定値の作成 (RDI)
 LEA RBX,DP
 ADD RBX,8
 MOV RBX,[RBX]
 MOV RDI,_UP
 MOV RAX,[RBX+RDI]
 MOV BL,[RDX]
 MOV [RAX],BL
 INC RAX
 MOV [WORD__ADDRESS_SEARCH_RDI],RAX

    ; CMOVEの各レジスタへの設定値の作成 (RCX)
 XOR RAX,RAX
 MOV AL,[RDX]
 MOV [WORD__ADDRESS_SEARCH_RCX],RAX
 
    ; CMOVEののための転送処理を行う。
 CLD
 MOV RSI,[WORD__ADDRESS_SEARCH_RSI]
 MOV RDI,[WORD__ADDRESS_SEARCH_RDI]
 MOV RCX,[WORD__ADDRESS_SEARCH_RCX]
 REP MOVSB

; デバッグ用ワード呼び出しレベルのパラメーターを一段下げる。
 SUB [DEBUG_DUMP_LEVEL],1
 sub [SEE_THIS_WORD_ptr],8

; 確認が必要！！　WORD_ADDRESS_SEARCHではRBPを８引いて、何もしないで抜け出している。おかしくならないのか？

 MOV RSI,[RBP]
 ADD RBP,8

 MOV RAX,RDX
 JMP APUSH




; (
;  OK!
MRKK9:
 DB 0C1H
 DB '('+80H
; DQ WORD_ADDRESS_SEARCH9
 DQ _WORD9
MRKK:
 DQ DOCOL
 DQ _LIT,29H
 DQ _WORD
; 一行削除。FIGではこの行はなかった
; DQ DROP
 DQ SEMIS


;  OK!
; EXPECT   ( a n --- )　ｎ個又は復帰コードまでの文字を端末キーボードから読み取り、アドレスａ以降のメモリ領域に格納する。
;  部分的にわからない箇所があるが、OKとする                     その端末には1つまたは2つのnullコードを付け加える。
EXPECT9:
 DB 86H
 DB 'EXPEC'
 DB 'T'+80H
 DQ MRKK9
EXPECT:
 DQ DOCOL
 DQ OVER   ; ( a n a )
 DQ PLUS   ; ( a a+n )
 DQ OVER   ; ( a a+n a )  ここでは ( a a+n=>n1 a=>n2 )

 DQ XDO    ; DO ( n1 n2 --- ) n1:インデックスの限界値、n2:インデックスの初期値
           ;              結果は ( a ) < a_XDO a_XDO+n >
EXPECT_AFT_XDO:

; DQ BREAK_POINT
; DQ 31H

 DQ _KEY     ; キーボードからのキー入力を待ち、入力された文字コードｃをスタックに置く。
 DQ DUPE    ;                    ( a c c ) < a_XDO a_XDO+n >;
 DQ _LIT,8   ; c==08h('BS')?     ( a c c 08h ) < a_XDO a_XDO+n >

 DQ _EQ     ;_EQ ( n1 n2 --- f )　なので ( a c f ) < a_XDO a_XDO+n >

 DQ     ZBRAN
EXPECT_1_AFT_IF:
 DQ     EXPECT_1_AFT_ELSE +8- EXPECT_1_AFT_IF
 DQ DROP
 DQ DUPE
;
 DQ     IDO      ; ( --- n )  現在のスタックは  ( a c a a_XDO+n ) < a_XDO a_XDO+n >
 DQ     _EQ     ;_EQ ( n1 n2 --- f )　なので ( a c f ) < a_XDO a_XDO+n >


 DQ     DUPE  ;  ( a c c ) < a_XDO a_XDO+n >
 DQ     FROMR    ; R>  ( a c c a_XDO+n  ) < a_XDO >
; DQ   _2MN
 DQ     _8MN    ;      ( a c c (a_XDO+n)-8 ) < a_XDO >
 DQ     PLUS
 DQ     TOR    ; >R
;; DQ     SUBB

; 挿入
; IF
 DQ ZBRAN
EXPECT_4_AFT_IF:
 DQ EXPECT_4_AFT_ELSE +8- EXPECT_4_AFT_IF
 DQ _LIT
 DQ BELL
; ELSE
 DQ BRAN
EXPECT_4_AFT_ELSE:
 DQ EXPECT_4_AFT_THEN -EXPECT_4_AFT_ELSE
 DQ _LIT
 DQ BSOUT ; ENDIF
;

; DQ   _ELSE
 DQ     BRAN
EXPECT_1_AFT_ELSE:
 DQ     EXPECT_1_AFT_THEN - EXPECT_1_AFT_ELSE
EXPECT_4_AFT_THEN:
 DQ     DUPE
 DQ     _LIT,0DH
 DQ     _EQ

 DQ       ZBRAN
EXPECT_2_AFT_IF:
 DQ       EXPECT_2_AFT_ELSE +8- EXPECT_2_AFT_IF
 DQ       _LEAVE  ; ( --- ) ループのカウントを最大値に書き換えて、DO...LOOPを脱出する
 DQ       DROP
 DQ       _BL  ; ブランク（空白）コード（２０Ｈ）
 DQ       _0

; DQ     _ELSE
 DQ       BRAN
EXPECT_2_AFT_ELSE:
 DQ       EXPECT_2_AFT_THEN - EXPECT_2_AFT_ELSE
 DQ       DUPE

; DQ       THEN
EXPECT_2_AFT_THEN:

 DQ     IDO
 DQ     CSTOR
 DQ     _0
 DQ     IDO
 DQ     _1PL
 DQ     STORE  ; !

; DQ   THEN
EXPECT_1_AFT_THEN:
;EXPECT_3_AFT_THEN:

 DQ   EMIT

 DQ XLOOP
EXPECT_AFT_XLOOP:
 DQ EXPECT_AFT_XDO-EXPECT_AFT_XLOOP  ; -37*8
 DQ DROP
 DQ SEMIS



 
; QUERY
QUERY9:
 DB 85H
 DB 'QUER'
 DB 'Y'+80H
 DQ EXPECT9
QUERY:
 DQ DOCOL
 DQ TIB
 DQ ATT  ; "@" FETCH
 DQ TIBLEN
 DQ EXPECT
 DQ _0
 DQ INN   ; >IN 
 DQ STORE  ; !
 DQ SEMIS
 
; x
;;;  イミディエイトモードでのnullコードなので、文字列の最後に実行されるのだろうか？
;;;  これが記述されている SCR # 329 では
;;;   8081 HERE : x ... ; ! IMMEDIATE null
;;;  となっている。x(NULL)がまだ理解できていない。
x9:
 DB 0C1H
 DB 00H+80H
 DQ QUERY9
x:
 DQ DOCOL
 DQ BLK
 DQ ATT  ; "@" FETCH
 DQ ZBRAN
x_AFT_IF:
 DQ x_AFT_ELSE +8- x_AFT_IF
 DQ _1
 DQ BLK
 DQ PSTOR    ; +!
 DQ _0
 DQ INN   ; >IN 
 DQ STORE  ; !

;; 本行追加。FIGへの対応
 DQ BLK
 DQ ATT
 DQ BSCR  ; B/SCR
 DQ _1
 DQ SUBB
 DQ ANDD
 DQ _0
; IF
 DQ ZBRAN
x_AFT_IF_2:
 DQ x_AFT_IF_2

 DQ QEXEC
 DQ FROMR    ; R>
 DQ DROP
; DQ _ELSE
 DQ BRAN
x_AFT_ELSE:
 DQ x_AFT_THEN - x_AFT_ELSE

 DQ FROMR    ; R>
 DQ DROP
; DQ THEN
x_AFT_THEN:
 DQ SEMIS
 
;  OK!
; (NUMBER)
PNUMB9:
 DB 88H
 DB '(NUMBER'
 DB ')'+80H
 DQ x9
PNUMB:
 DQ DOCOL
; DQ BEGIN
PNUMB_1_AFT_BEGIN:
 DQ _1PL
 DQ DUPE
 DQ TOR    ; >R
 DQ CAT    ; C@
 DQ BASE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ ATT  ; "@" FETCH
 DQ DIGIT

; DQ _WHILE
 DQ ZBRAN
PNUMB_1_AFT_WHILE:
 DQ PNUMB_1_AFT_REPEAT +8- PNUMB_1_AFT_WHILE
 DQ SWAP
 DQ BASE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ ATT  ; "@" FETCH
 DQ USTAR  ; U*
 DQ DROP
 DQ ROT
 DQ BASE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ ATT  ; "@" FETCH
 DQ USTAR  ; U*
 DQ DPLUS

 DQ   DPL
 DQ   ATT  ; "@" FETCH
 DQ   _1PL
 DQ   ZBRAN
PNUMB_AFT_IF:
 DQ   PNUMB_AFT_THEN - PNUMB_AFT_IF
 DQ   _1
 DQ   DPL
 DQ   PSTOR    ; +!
; DQ THEN
PNUMB_AFT_THEN:
 DQ   FROMR    ; R>

; DQ _REPEAT
 DQ BRAN
PNUMB_1_AFT_REPEAT:
 DQ PNUMB_1_AFT_BEGIN - PNUMB_1_AFT_REPEAT
 DQ FROMR    ; R>
 DQ SEMIS
 


; NUMBER
;  OK! １行修正した。
NUMBER9:
 DB 86H
 DB 'NUMBE'
 DB 'R'+80H
 DQ PNUMB9
NUMBER:
 DQ DOCOL
 DQ _0
 DQ _0
 DQ ROT
 DQ DUPE
 DQ _1PL
 DQ CAT    ; C@
 DQ _LIT,2DH

 DQ _EQ
 DQ DUPE
 DQ TOR    ; >R
 DQ PLUS
 DQ MINS1

; DQ BEGIN
NUMBER_1_AFT_BEGIN:
 DQ DPL
 DQ STORE  ; !
 DQ PNUMB
 DQ DUPE
 DQ CAT    ; C@
 DQ _BL
 DQ SUBB

; DQ _WHILE
 DQ ZBRAN
NUMBER_1_AFT_WHILE:
 DQ NUMBER_1_AFT_REPEAT +8- NUMBER_1_AFT_WHILE
 DQ DUPE
 DQ CAT    ; C@
 DQ _LIT,2EH
 DQ SUBB
 DQ _0


 DQ BREAK_POINT
 DQ 400H


 DQ QERROR
 DQ _0
; DQ _REPEAT
 DQ BRAN
NUMBER_1_AFT_REPEAT:
 DQ NUMBER_1_AFT_BEGIN - NUMBER_1_AFT_REPEAT

 DQ DROP
 DQ FROMR    ; R>
 DQ ZBRAN
NUMBER_AFT_IF:
 DQ NUMBER_AFT_THEN - NUMBER_AFT_IF
;; 一行修正。どうも言葉の間違いのようで、FIGでは DMINU と書かれていた。
;; DQ DNEGATE
 DQ DMINUS
; DQ THEN
NUMBER_AFT_THEN:
 DQ SEMIS
 
; +BUF
;  OKと考えます→修正の結果ＯＫ
PBUF9:
 DB 84H
 DB '+BU'
 DB 'F'+80H
 DQ NUMBER9
PBUF:
 DQ DOCOL
 DQ _LIT, CO  ; CO EQU KBBUF+4  (KBBUF == 128)
 DQ PLUS
 DQ DUPE
 DQ LIMIT
 DQ _EQ
 DQ ZBRAN
PBUF_AFT_IF:
 DQ PBUF_AFT_THEN - PBUF_AFT_IF
 DQ DROP
 DQ FIRST
; DQ THEN
PBUF_AFT_THEN:
 DQ DUPE
 DQ PREV
 DQ ATT  ; "@" FETCH
 DQ SUBB
 DQ SEMIS
 
; UPDATE
;  OK!
UPDAT9:
 DB 86H
 DB 'UPDAT'
 DB 'E'+80H
 DQ PBUF9
UPDAT:
 DQ DOCOL
 DQ PREV
 DQ ATT  ; "@" FETCH
 DQ ATT  ; "@" FETCH
; DQ _LIT,8000H
 DQ _LIT,SYS_LIMIT
 DQ ORR
 DQ PREV
 DQ STORE  ; !
 DQ SEMIS
 
; EMPTY-BUFFERS
;  OK!
MTBUF9:
 DB 8DH
 DB 'EMPTY-BUFFER'
 DB 'S'+80H
 DQ UPDAT9
MTBUF:
 DQ DOCOL
 DQ FIRST
 DQ LIMIT
 DQ OVER
 DQ SUBB
 DQ ERASE
 DQ SEMIS
 
; SAVE-BUFFERS
SAVEBUFFERS9:
 DB 8cH
 DB 'SAVE-BUFFER'
 DB 'S'+80H
 DQ MTBUF9
SAVEBUFFERS:
 DQ DOCOL
 DQ NOBUF  ; #BUFF
 DQ _1PL
 DQ _0
 DQ XDO
SAVEBUFFERS_AFT_XDO:
; DQ _LIT,7FFFH
 DQ _LIT,SYS_LIMIT -1
 DQ BUFFE
 DQ DROP
 DQ XLOOP
SAVEBUFFERS_AFT_XLOOP:
 DQ SAVEBUFFERS_AFT_XDO - SAVEBUFFERS_AFT_XLOOP
 DQ SEMIS
 
; DR0
DRZER9:
 DB 83H
 DB 'DR'
 DB '0'+80H
 DQ SAVEBUFFERS9
DRZER:
 DQ DOCOL
 DQ _0
 DQ OFSET
 DQ STORE  ; !
 DQ SEMIS
 
; DR1
DRONE9:
 DB 83H
 DB 'DR'
 DB '1'+80H
 DQ DRZER9
DRONE:
 DQ DOCOL
 DQ DENSTY, ATT
 DQ ZBRAN
DR1_AFT_IF:
 DQ DR1_AFT_ELSE +8- DR1_AFT_IF
 DQ _LIT, SPDRV2
 DQ BRAN
DR1_AFT_ELSE:
 DQ DR1_AFT_THEN - DR1_AFT_ELSE
 DQ _LIT, SPDRV1
DR1_AFT_THEN:
 DQ OFSET, STORE
 DQ SEMIS



; R/W
; DISK系のワードはすっきりしたもの、考え方が必要。
; 例えば、形式をFIG-FORTHとそろえた方がいいのではないか？、など。
RSLW9:
 DB 83H
 DB 'R/'
 DB 'W'+80H
 DQ DRONE9
RSLW:
 DQ DOCOL
;
 DQ USE, ATT
 DQ TOR
 DQ SWAP, SPBLK
 DQ STAR, ROT
 DQ USE, STORE
 DQ SPBLK, _0
 DQ XDO
RSLW_AFT_DO:
 DQ OVER, OVER
 DQ TSCALC, SETIO
 DQ ZBRAN
RSLW_AFT_IF:
 DQ RSLW_AFT_ELSE +8- RSLW_AFT_IF
 DQ SECRD
 DQ BRAN
RSLW_AFT_ELSE:
 DQ RSLW_AFT_THEN - RSLW_AFT_ELSE
 DQ SECWT
RSLW_AFT_THEN:
 DQ _1PL
 DQ _LIT, 80H
 DQ USE, PSTOR
 DQ XLOOP
RSLW_AFT_XLOOP:
 DQ RSLW_AFT_DO - RSLW_AFT_XLOOP
 DQ DROP, DROP
 DQ FROMR, USE
 DQ STORE, SEMIS




 
; BUFFER
; 一行追加。OK!
BUFFE9:
 DB 86H
 DB 'BUFFE'
 DB 'R'+80H
 DQ RSLW9
BUFFE:
 DQ DOCOL
 DQ USE
 DQ ATT  ; "@" FETCH
 DQ DUPE
 DQ TOR    ; >R

; DQ BEGIN
BUFFE_AFT_BEGIN:
 DQ PBUF    ; +BUF
; DQ UNTIL
 DQ ZBRAN
BUFFE_AFT_UNTIL:
 DQ BUFFE_AFT_BEGIN - BUFFE_AFT_UNTIL
 DQ USE
 DQ STORE  ; !
 DQ RAT  ; R@
;; FIGより１行追加
 DQ ATT
;;
 DQ ZLESS  ; 0<

 DQ   ZBRAN
BUFFE_AFT_IF:
 DQ   BUFFE_AFT_THEN - BUFFE_AFT_IF
 DQ   RAT
; DQ   _2PL
 DQ   _8PL
 DQ   RAT
 DQ   ATT  ; "@" FETCH
; DQ   _LIT,7FFFH
 DQ   _LIT,SYS_LIMIT
 DQ   ANDD
 DQ     _0
 DQ     RSLW    ; R/W
; DQ   THEN
BUFFE_AFT_THEN:
 DQ RAT  ; R@
 DQ STORE  ; !
 DQ RAT  ; R@
 DQ PREV
 DQ STORE  ; !
 DQ FROMR    ; R>
; DQ _2PL
 DQ _8PL
 DQ SEMIS
 
; BLOCK
BLOCK9:
 DB 85H
 DB 'BLOC'
 DB 'K'+80H
 DQ BUFFE9
BLOCK:
 DQ DOCOL
 DQ _OFFSET
 DQ ATT  ; "@" FETCH
 DQ PLUS
 DQ TOR    ; >R
 DQ PREV
 DQ ATT  ; "@" FETCH
 DQ DUPE
 DQ ATT  ; "@" FETCH
 DQ RAT  ; R@
 DQ SUBB
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*

 DQ ZBRAN
BLOCK_1_AFT_IF:
 DQ BLOCK_1_AFT_THEN - BLOCK_1_AFT_IF

; DQ   BEGIN
BLOCK_3_AFT_BEGIM:
 DQ   PBUF    ; +BUF
 DQ   ZEQU  ; "0=" ０なら1、それ以外は０

 DQ     ZBRAN
BLOCK_2_AFT_IF:
 DQ     BLOCK_2_AFT_THEN - BLOCK_2_AFT_IF
 DQ     DROP
 DQ     RAT
 DQ     BUFFE
 DQ     DUPE
 DQ     RAT
 DQ     _1
 DQ     RSLW    ; R/W
; DQ     _2MN
 DQ     _8MN
; DQ     THEN
BLOCK_2_AFT_THEN:

 DQ     DUPE
 DQ     ATT  ; "@" FETCH
 DQ     RAT
 DQ     SUBB
; DQ     _2ML    ; 2*
 DQ     _8ML    ; 8*
 DQ     ZEQU  ; "0=" ０なら1、それ以外は０

; DQ   UNTIL
 DQ ZBRAN
BLOCK_3_AFT_UNTIL:
 DQ BLOCK_3_AFT_BEGIM - BLOCK_3_AFT_UNTIL
 DQ   DUPE
 DQ   PREV
 DQ   STORE  ; !

; DQ THEN
BLOCK_1_AFT_THEN:
 DQ FROMR    ; R>
 DQ DROP
; DQ _2PL
 DQ _8PL
 DQ SEMIS


 
; SET-IO
SETIO9:
 DB 86H
 DB 'SET-I'
 DB 'O'+80H
 DQ BLOCK9
SETIO:
 DQ SETIO_2
SETIO_2:
; MOV RCX,USE+2
 MOV RCX,USE+8
 CALL SDMAO
; MOV RCX,CS
; CALL SDMAS
; MOV RCX,SEC+2
 MOV RCX,SEC+8
 CALL SSEC
; MOV RCX,TRACK+2
 MOV RCX,TRACK+8
 CALL STRK
 JMP NEXT



 
; SET-DRIVE
SETDRV9:
 DB 89H
 DB 'SET-DRIV'
 DB 'E'+80H
 DQ SETIO9
SETDRV:
; MOV RCX,DRIVE+2
 MOV RCX,DRIVE+8
 CALL SDSK
 JMP NEXT

 
 
; T&SCALC
TSCALC9:
 DB 87H
 DB 'T&SCAL'
 DB 'C'+80H
 DQ SETDRV9
TSCALC:
 DQ DOCOL, DENSTY
 DQ ATT
 DQ ZBRAN
TSCALC_AFT_1_IF:
 DQ TSCALC_AFT_1_THEN - TSCALC_AFT_1_IF
 DQ _LIT, SPDRV2
 DQ SLMOD
 DQ _LIT, MXDRV, MIN
 DQ DUPE, DRIVE
 DQ ATT, _EQ
 DQ ZBRAN
TSCALC_AFT_2_IF:
 DQ TSCALC_AFT_2_ELSE +8- TSCALC_AFT_2_IF
 DQ DROP
 DQ BRAN
TSCALC_AFT_2_ELSE:
 DQ TSCALC_AFT_2_THEN - TSCALC_AFT_2_ELSE
 DQ DRIVE, STORE
 DQ SETDRV
TSCALC_AFT_2_THEN:
 DQ _LIT, SPT2
 DQ SLMOD, TRACK
 DQ STORE, _1PL
 DQ SEC, STORE
 DQ SEMIS

 ; SINGLE DENSITY
TSCALC_AFT_1_THEN:
 DQ _LIT, SPDRV1
 DQ SLMOD
 DQ _LIT, MXDRV, MIN
 DQ DUPE, DRIVE
 DQ ATT, _EQ
 DQ ZBRAN
TSCALC_AFT_3_IF:
 DQ TSCALC_AFT_3_ELSE +8- TSCALC_AFT_3_IF
 DQ DROP
 DQ BRAN
TSCALC_AFT_3_ELSE:
 DQ TSCALC_AFT_3_THEN - TSCALC_AFT_3_ELSE
 DQ DRIVE, STORE
 DQ SETDRV
TSCALC_AFT_3_THEN:
 DQ _LIT, SPT1
 DQ SLMOD, TRACK
 DQ STORE, _1PL
 DQ SEC, STORE
 DQ SEMIS



 
; SEC-READ
SECRD9:
 DB 88H
 DB 'SEC-REA'
 DB 'D'+80H
 DQ TSCALC9
SECRD:
 DQ SECRD_2
SECRD_2:
 CALL GSEC
 MOV AH,0
; MOV [DSKERR+2], AX  ; SAVE ERROR STATUS
 MOV [DSKERR2 +8], RAX  ; SAVE ERROR STATUS
 JMP NEXT

 
; SEC-WRITE
SECWT9:
 DB 89H
 DB 'SEC-WRIT'
 DB 'E'+80H
 DQ SECRD9
SECWT:
 DQ SECWT_2
SECWT_2:
 CALL PSEC
 MOV AH,0
; MOV DSKERR+2, AX  ; SAVE ERROR STATUS
 MOV [DSKERR2 +8],RAX  ; SAVE ERROR STATUS
 JMP NEXT


 


 
; FLASH
FLASH9:
 DB 85H
 DB 'FLAS'
 DB 'H'+80H
 DQ SECWT9
FLASH:
 DQ DOCOL
 DQ NOBUF, _1PL
 DQ _0, XDO
FLASH_AFT_XDO:
 DQ _0, BUFFE
 DQ DROP
 DQ XLOOP
FLASH_AFT_XLOOP:
 DQ FLASH_AFT_XDO - FLASH_AFT_XLOOP
 DQ SEMIS












; 以下のDIRECT BIOS CALL FUNCTIONは記入しただけで、何の確認も行っていない。
; The following DIRECT BIOS CALL FUNCTION was just filled in and nothing was checked.


;***********************************
; DIRECT BIOS CALL FUNCTION
;***********************************

; SELECT DISK: ENTER PARAMETER IN REG CL.
SDSK:
 MOV [DCBIOS_SELECT_DISK],CL
 RET


; SET TRACK: ENTER PARAMETER IN REG CL.
STRK:
 MOV [DCBIOS_SET_TRACK],CL
 RET


; SET SECTOR: ENTER PARAMETER IN REG CL.
SSEC:
 MOV [DCBIOS_SET_SECTOR],CL
 RET


; SET DMA OFFSET: ENTER PARAMETER IN REG CL.
SDMAO:
 MOV [DCBIOS_SET_DMA_OFFSET],CL
 RET


; GET (READ) SECTER: ENTER PARAMETER IN REG CL.
GSEC:


 MOV [DCBIOS_SELECT_DISK],CL
 RET


; PUT (WRITE) SECTER: ENTER PARAMETER IN REG CL.
PSEC:
 MOV [DCBIOS_SELECT_DISK],CL
 RET













; INTERPRET
; 
INTERPRET9:
 DB 89H
 DB 'INTERPRE'
 DB 'T'+80H
 DQ FLASH9
INTERPRET:
 DQ DOCOL

; DQ BEGIN

INTERPRET_4_AFT_BEGIN:

 DQ BREAK_POINT
 DQ 10333H

 DQ _0  ; キー入力や外部記憶装置からの入力時である
 DQ Q_WORD_STATE
 DQ STORE  ; !

 DQ BREAK_POINT
 DQ 333H

 DQ DFIND  ; ( --- a ) でいいのだろうか？

 DQ BREAK_POINT
 DQ 334H

 DQ DDUP    ; -DUP

 DQ   ZBRAN
INTERPRET_1_AFT_IF:
 DQ   INTERPRET_1_AFT_ELSE +8- INTERPRET_1_AFT_IF

 DQ DUPE

 DQ   STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ   ATT  ; "@" FETCH
 DQ   LESS    ; <

 DQ     ZBRAN
INTERPRET_2_AFT_IF:
 DQ     INTERPRET_2_AFT_ELSE +8- INTERPRET_2_AFT_IF


 DQ CFA
 DQ     COMMA
; DQ     _ELSE
 DQ     BRAN
INTERPRET_2_AFT_ELSE:
 DQ     INTERPRET_2_AFT_THEN - INTERPRET_2_AFT_ELSE


 DQ _0
 DQ Q_WORD_STATE
 DQ STORE  ; !


 DQ BREAK_POINT
 DQ 33401H

 DQ CFA
 DQ     EXEC
; DQ     THEN
INTERPRET_2_AFT_THEN:
 DQ     QSTACK

; DQ   _ELSE
 DQ   BRAN
INTERPRET_1_AFT_ELSE:
 DQ   INTERPRET_1_AFT_THEN - INTERPRET_1_AFT_ELSE
 DQ   HERE
 DQ   NUMBER
 DQ   DPL
 DQ   ATT  ; "@" FETCH
 DQ   _1PL

 DQ     ZBRAN
INTERPRET_3_AFT_IF:
 DQ     INTERPRET_3_AFT_ELSE +8- INTERPRET_3_AFT_IF
 DQ DLITERAL

; DQ     _ELSE
 DQ     BRAN
INTERPRET_3_AFT_ELSE:
 DQ     INTERPRET_3_AFT_THEN - INTERPRET_3_AFT_ELSE
 DQ     DROP
 DQ LITERAL

; DQ     THEN
INTERPRET_3_AFT_THEN:
 DQ     QSTACK

; DQ   THEN
INTERPRET_1_AFT_THEN:

; DQ AGAIN
 DQ BRAN
INTERPRET_4_AFT_AGAIN:
 DQ INTERPRET_4_AFT_BEGIN - INTERPRET_4_AFT_AGAIN

;; DQ SEMIS







 
; QUIT
QUIT9:
 DB 84H
 DB 'QUI'
 DB 'T'+80H
 DQ INTERPRET9
QUIT:
 DQ DOCOL
 DQ _0
 DQ BLK
 DQ STORE  ; !
 DQ LBRAC    ; [  ( --- )  入力文字列に対するコンパイル作業を中止し、実行モードとする。
            ;             "left-bracket" と読む。
; DQ BEGIN
QUIT_2_AFT_BEGIN:
 DQ RPST0    ; RP!

 DQ BREAK_POINT
 DQ 400H
;
 DQ _CR
 DQ QUERY
 DQ INTERPRET

 DQ BREAK_POINT
 DQ 401H

 DQ   STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ   ATT  ; "@" FETCH
 DQ   ZEQU  ; "0=" ０なら1、それ以外は０
 DQ   ZBRAN
QUIT_AFT_IF:
 DQ   QUIT_AFT_THEN - QUIT_AFT_IF
 DQ   PDOTQ   ; (.")
 DB   3,' OK'

; DQ   THEN
QUIT_AFT_THEN:

; DQ AGAIN
 DQ BRAN
QUIT_2_AFT_AGAIN:
 DQ QUIT_2_AFT_BEGIN - QUIT_2_AFT_AGAIN

; DQ SEMIS





; ABORT
; 
ABORT9:
 DB 85H
 DB 'ABOR'
 DB 'T'+80H
 DQ QUIT9
ABORT:
 DQ DOCOL
 DQ SPST0    ; SP!  ; パラメータスタックポインタを変数Ｓ０の値に初期化する
 DQ DECIMAL

 ;
 ;DQ DRZER

 ; 挿入。
  DQ QSTACK
  DQ _CR
  DQ PDOTQ
  DB 13H
  DB 'ToUnderstandFORTH  '
  DQ PDOTQ
  DB 13H
  DB '(Fig-Forth X64) '
  DB FIGREL+30H, ADOT, FIGREV+30H


 DQ BREAK_POINT
 DQ 50H

 DQ FORTH
 DQ DEFINITIONS

 DQ BREAK_POINT
 DQ 51H

 DQ ABORT_INIT

 DQ QUIT
; DQ SEMIS  ; -->ここでは必要ない
 


; ABORT_INIT
ABORT_INIT_9:
 DB 8AH
 DB 'ABORT_INI'
 DB 'T'+80H
 DQ ABORT9
ABORT_INIT:
; DQ $+8
 DQ ABORT_INIT_2
ABORT_INIT_2:
 MOV [DEBUG_DUMP_LEVEL],0
 lea rax, SEE_THIS_WORD_STACK_TOP
 mov [SEE_THIS_WORD_ptr],rax
 jmp next



; MESSAGE
MESSAGE9:
 DB 87H
 DB 'MESSAG'
 DB 'E'+80H
 DQ ABORT_INIT_9
MESSAGE:
 DQ DOCOL

 DQ WARNING
 DQ ATT  ; "@" FETCH

 DQ BREAK_POINT
 DQ 305

 DQ ZBRAN
MESSAGE_1_AFT_IF:
 DQ MESSAGE_1_AFT_ELSE +8- MESSAGE_1_AFT_IF
 DQ DDUP    ; -DUP

 DQ   ZBRAN
MESSAGE_2_AFT_IF:
 DQ   MESSAGE_2_AFT_THEN - MESSAGE_2_AFT_IF
 DQ _LIT, 4
;
 DQ   _OFFSET
 DQ   ATT  ; "@" FETCH
 DQ BSCR
 DQ SLASH
 DQ   SUBB
 DQ   DLINE
 DQ   SPACE
; DQ   THEN
MESSAGE_2_AFT_THEN:

; DQ _ELSE
 DQ BRAN
MESSAGE_1_AFT_ELSE:
 DQ MESSAGE_1_AFT_THEN - MESSAGE_1_AFT_ELSE
 DQ PDOTQ    ; (.")
 DB 6,' MSG# '
; 
 DQ BREAK_POINT
 DQ 77H

 DQ DOT    ; .

; DQ THEN
MESSAGE_1_AFT_THEN:
 DQ SEMIS
 

; ERROR
;  OK!
ERROR9:
 DB 85H
 DB 'ERRO'
 DB 'R'+80H
 DQ MESSAGE9
ERROR:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 226H

 DQ WARNING
 DQ ATT  ; "@" FETCH
 DQ ZLESS  ; 0<
 DQ ZBRAN
ERROR_1_AFT_IF:
 DQ ERROR_1_AFT_THEN - ERROR_1_AFT_IF
; 修正。FIGに従いABORTからPABORに。
 DQ PABOR
; DQ THEN
ERROR_1_AFT_THEN:
 
 DQ DOTQ    ; ."  ( --- )
 DB 3,' =>'


 DQ BREAK_POINT
 DQ 227H

 DQ HERE
 DQ COUNT  ; ( a1 --- a2 n )
 DQ _TYPE  ; ( a n --- )
; TYPEで印字されて、いったん完了する。


 DQ BREAK_POINT
 DQ 2271H

 DQ DOTQ    ; ."  ( --- )
 DB 3,' ? '
 DQ MESSAGE
 DQ SPST0    ; SP!  ; パラメータスタックポインタを変数Ｓ０の値に初期化する
 DQ BLK
 DQ ATT  ; "@" FETCH
 DQ DDUP    ; -DUP
 DQ ZBRAN
ERROR_2_AFT_IF:
 DQ ERROR_2_AFT_THEN - ERROR_2_AFT_IF

 DQ BREAK_POINT
 DQ 228H

 DQ INN   ; >IN 
 DQ ATT  ; "@" FETCH
 DQ SWAP
; DQ THEN
ERROR_2_AFT_THEN:

 DQ BREAK_POINT
 DQ 229H

 DQ QUIT
; 一行削除。FIGでないことに気が付いて削除した。
; DQ SEMIS






; ?ERROR ( f N --- )
;  OK!
QERROR9:
 DB 86H
 DB '?ERRO'
 DB 'R'+80H
 DQ ERROR9
QERROR:
 DQ DOCOL
 DQ SWAP
; DQ ZBRAN,_0and0
 DQ ZBRAN
QERROR_AFT_IF:
 DQ QERROR_AFT_ELSE +8- QERROR_AFT_IF
 DQ ERROR
 DQ BRAN
; DQ _ELSE
QERROR_AFT_ELSE:
 DQ QERROR_AFT_THEN - QERROR_AFT_ELSE
 DQ DROP
; DQ THEN
QERROR_AFT_THEN:
 DQ SEMIS








; LOAD
; 未修正。どのように修正するかをdisk系の開発時に考えておくこと→当面は対応しないで、簡易的にＣ＋＋のFOPEN/FCLOSE/F_COUTで対応することにした。

LOAD9:
 DB 84H
 DB 'LOA'
 DB 'D'+80H
 DQ QERROR9
LOAD:
 DQ DOCOL
 DQ BLK
 DQ ATT  ; "@" FETCH
 DQ TOR    ; >R
 DQ INN   ; >IN 
 DQ ATT  ; "@" FETCH
 DQ TOR    ; >R
 DQ _0
 DQ INN   ; >IN 
 DQ STORE  ; !
; 追加
 DQ BSCR, STAR
;
 DQ BLK
 DQ STORE  ; !
 DQ INTERPRET
SCREEN:
 DQ FROMR    ; R>
 DQ INN   ; >IN 
 DQ STORE  ; !
 DQ FROMR    ; R>
 DQ BLK
 DQ STORE  ; !
 DQ SEMIS

; -->
; どのように修正するかをdisk系の開発時に考えておくこと
ARROR9:
 DB 0C3H
 DB '--'
 DB '>'+80H
 DQ LOAD9
ARROR:
 DQ DOCOL
 DQ QLOADING
 DQ _0
 DQ INN   ; >IN 
 DQ STORE  ; !
;
 DQ BSCR
 DQ BLK
 DQ ATT
 DQ OVER
 DQ MODD
 DQ SUBB
;
; DQ _1
 DQ BLK
 DQ PSTOR    ; +!
 DQ SEMIS



; ID.  ( nfa --- ; print word's name ) nfa: name field address ワードの最も先頭のアドレス（例えばIDDOT9:）
;  OK!
IDDOT9:
 DB 83H
 DB 'ID'
 DB '.'+80H
 DQ ARROR9
IDDOT:
 DQ DOCOL
 DQ PAD         ; ( HERE+44H )  →ワークエリア確保のためのポインタ？？？
; 二行入れ替え。FILLが入ってないし、間違いと思われる。→間違いではないようだ。元に戻した。
 DQ _LIT,22H
 DQ BLANKS
; DQ _LIT, 20H
; DQ _LIT, 5FH
; DQ _FILL       ; FILL ( a n b --- )  アドレスa以降nバイトのメモリ領域をバイトデータbによって満たす。
                ; ()  →HERE+44H以降に5FHを20Hバイト分満たす。
;
 DQ DUPE  ; ( nfa nfa )
 DQ PFA   ; ( nfa pfa )
 DQ LFA   ; ( nfa lfa )
 DQ OVER  ; ( nfa lfa nfa )
 DQ SUBB  ; ( nfa lfa-nfa )
 DQ PAD   ; ( nfa lfa-nfa HERE+44H )
 DQ SWAP  ; ( nfa HERE+44H lfa-nfa )
 DQ _CMOVE  ; nfaからHERA+44Hにlfa-nfa（８*（２＋ネームフィールド分）バイト）分転送する。
           ; ( )
 DQ PAD    ; ( HERE+44H )
 DQ COUNT  ; COUNT (a1 --- a2 n ) アドレスa1にある１バイト長の数値をnとする。a2はa1+1とする。
           ; ( HERE+44H+1 アドレスHERE+44Hの１バイトの値 )
 DQ _LIT,01FH  ;  ( HERE+44H+1 アドレスHERE+44Hの１バイトの値 1FH )
 DQ ANDD       ;  ( HERE+44H+1 (アドレスHERE+44Hの１バイトの値 and 1FH) )
 DQ _TYPE      ; TYPE ( a n --- ) →アドレスa以降に格納されているnバイトのコードを印字出力する。
               ; ( )
 DQ SPACE      ; SPACE ( --- ) →スペース（ブランク）をひとつ書く。
 DQ SEMIS






; (;CODE)
;  OKかな？
PSCOD9:
 DB 87H
 DB '(;CODE'
 DB ')'+80H
 DQ IDDOT9
PSCOD:
 DQ DOCOL
 DQ FROMR    ; R>
 DQ LATEST
 DQ PFA
 DQ CFA
;; 
 DQ STORE  ; !
 DQ SEMIS_3

 
; ;CODE
;  OKかな？ FIG対応で追加した
      ; (;CODE)でワードを終了するとDOCOLが１回余分に使われるため、
      ; TRACE表示が狂ってしまう。そのためにSEMIS_3ではTRACE表示の
      ; カウントを１回多めに減らしている。;CODEでは行っていない。

SEMIC9:
 DB 85H
 DB ';COD'
 DB 'E'+80H
 DQ PSCOD9
SEMIC:
 DQ DOCOL
 DQ QCSP
 DQ COMP   ; COMPILE
 DQ PSCOD  ; (;CODE)
 DQ LBRAC  ; []
SEMI1:
 DQ NOOP   ; ( ASSEMBLER ??? )
 DQ SEMIS











;; これ以下はFIG-FORTHで定義されたものである

;
; QUERY KEYBORD FOR KEY PRESSED
;
; (TRUE = CHAR READY, FALSE = NO CHAR)
;
; CALLED FROM "?TERMINAL".
;
; USE 'KEY' TO GET KEY VALUE.
;
PQTER:
; CALL CSET

 OR AL,AL
 JZ PQTER1
 MOV AL,1
PQTER1:
 MOV AH,0
 JMP APUSH


; CONSOLE INPUT ROUTINE
;
; WAITS FOR A KEYBOARD CHARACTER.
;
; CONTROL-P KEY WILL TOGGLE PRINTER
; ECHO FLAG.
;
; CALLED FROM "KEY".
;
PKEY:
; MOV RBX,[FILE_INPUT_NOW +8]
 LEA RBX,FILE_INPUT_NOW
 ADD RBX,8
 MOV RBX,[RBX]
 OR RBX,RBX
 JZ PKEY_01

PKEY_04:
 mov rdx,7          ; 7:F_CIN

 call TO_CPP_IO

 CMP RAX,0DH
 JE PKEY_04
 CMP RAX,0AH
 JE PKEY_05
 CMP RAX,-1
 JE PKEY_02

 JMP PKEY_03

PKEY_05:
 MOV RAX,0DH
 JMP PKEY_03

PKEY_02:
 XOR RAX,RAX
; MOV [FILE_INPUT_NOW +8],RAX
 LEA RBX,FILE_INPUT_NOW
 ADD RBX,8
 MOV [RBX],RAX

; JMP PKEY_03

PKEY_01:
 CALL CI
 CMP AL,DLE
 JNE PKEY1
 XOR EPRINT,1  ; TOGGLE ECHO
 JMP PKEY

PKEY1:
 MOV RBX,RAX
 XOR RAX,RAX
 MOV AL,BL
PKEY_03:
 JMP APUSH


; CONSOLE/PRINTER CHARACTER OUTPUT
;
; CALLED FROM "EMIT".
;
PEMIT:
 DQ PEMIT_2
PEMIT_2:
 POP RAX
 CALL POUT

;;;;実験中
; INC RSI
;;;;実験中

 JMP NEXT


; CRLF TO CONSOLE/PRINTER
;
; CALLED FROM 'CR'
;
PCR:
 MOV AL,ACR
 CALL POUT
 MOV AL,LF
 CALL POUT
 JMP NEXT


; TRUE CONSOLE/PRINTER OUTPUT ROUTINE
;
POUT:
 CALL CHO        ; CONSOLE OUT
 TEST EPRINT, 1  ; PRINTER ECHO?
 JZ POUT1
 CALL LO
POUT1: RET


; PRINTER ECHO FLAG 'EPRINT', SEE parameter area '.data'





; 次のEXITは本システム用に修正してある。
 
; EXIT
; このシステムを抜けてＯＳに制御を移す。
EXIT:

 call call_C_Exit






; GET KEYBOARD STATUS
;
;   EXIT: REG 
;
;;   p->SCANVAL = key_state*0x100+c;
;;    AH:key_state, AL:c　
CSTAT:

; JMP F_OUT_2
 MOV RDX,6

 call TO_CPP_IO

 RET



; CONSOLE INPUT
;
; WAIT FOR KEY FROM KEYBOARD
;
CI::
; JMP CIN
 MOV RDX,1

 call TO_CPP_IO

 RET


; CONSOLE OUTPUT
;
; OUTPUT CHARACTER IN REG AL
; TO CONSOLE.
;
; EXIT:

CHO:
; JMP COUT
 MOV RDX,2

 call TO_CPP_IO

 RET




; LIST OUTPUT
;
; OUTPUTS CHARACTER IN REG AL
; TO LIST DEVICE (PRINTER)
; 実際はファイルのF_COUT.outに出力されます。
;
LO:
; JMP F_OUT
 MOV RDX,3

 call TO_CPP_IO

 RET






















; M*
MSTAR9:
 DB 82H
 DB 'M'
 DB '/'+80H
 DQ SEMIC9
MSTAR:
 DQ DOCOL
 DQ TDUP
 DQ XORR
 DQ TOR
 DQ ABS
 DQ SWAP
 DQ ABS
 DQ USTAR
 DQ FROMR
 DQ DPLMN
 DQ SEMIS


; *
STAR9:
 DB 81H
 DB '*'+80H
 DQ MSTAR9
STAR:
 DQ DOCOL
 DQ MSTAR
 DQ DROP
 DQ SEMIS


; MOD 
MODD9:
 DB 83H
 DB 'MO'
 DB 'D'+80H
 DQ STAR9
MODD:
 DQ DOCOL
 DQ SLMOD
 DQ DROP
 DQ SEMIS


; */MOD 
SSMOD9:
 DB 85H
 DB '*/MO'
 DB 'D'+80H
 DQ MODD9
SSMOD:
 DQ DOCOL
 DQ TOR
 DQ MSTAR
 DQ FROMR
 DQ MSLAS
 DQ SEMIS


; */ 
SSLA9:
 DB 82H
 DB '*'
 DB '/'+80H
 DQ SSMOD9
SSLA:
 DQ DOCOL
 DQ SSMOD
 DQ SWAP
 DQ DROP
 DQ SEMIS


; BACK
BACK9:
 DB 84H
 DB 'BAC'
 DB 'K'+80H
 DQ SSLA9
BACK:
 DQ DOCOL
 DQ HERE
 DQ SUBB
 DQ COMMA
 DQ SEMIS


; ENDIF
ENDIFF9:
 DB 85H
 DB 'ENDI'
 DB 'F'+80H
 DQ BACK9
ENDIFF:
 DQ DOCOL
 DQ QCOMP
 DQ _2
 DQ QPAIRS
 DQ HERE
 DQ OVER
 DQ SUBB
 DQ SWAP
 DQ STORE
 DQ SEMIS


; END
_END9:
 DB 83H
 DB 'EN'
 DB 'D'+80H
 DQ ENDIFF9
_END:
 DQ DOCOL
 DQ UNTIL
 DQ SEMIS


; ?
QUES9:
 DB 81H
 DB '?'+80H
 DQ _END9
QUES:
 DQ DOCOL
 DQ ATT
 DQ DOT
 DQ SEMIS


; U.
UDOT9:
 DB 82H
 DB 'U'
 DB '.'+80H
 DQ QUES9
UDOT:
 DQ DOCOL
 DQ _0
 DQ DDOT
 DQ SEMIS


; VLIST
VLIST9:
 DB 85H
 DB 'VLIS'
 DB 'T'+80H
 DQ UDOT9
VLIST:
 DQ DOCOL
 DQ _LIT, 80H
 DQ OUTT
 DQ STORE
 DQ CONTEXT
 DQ ATT
 DQ ATT
VLIST_AFT_BEGIN:
 DQ OUTT
 DQ ATT
 DQ CSLL
 DQ GREAT
 DQ ZBRAN
VLIST_AFT_IF:
 DQ VLIST_AFT_THEN - VLIST_AFT_IF
 DQ _CR
 DQ _0
 DQ OUTT
 DQ STORE
VLIST_AFT_THEN:
 DQ DUPE
 DQ IDDOT
 DQ SPACE
 DQ SPACE
 DQ PFA
 DQ LFA
 DQ ATT
 DQ DUPE
 DQ _0
 DQ QTERM
 DQ ORR
 DQ ZBRAN
VLIST_AFT_UNTIL:
 DQ VLIST_AFT_BEGIN - VLIST_AFT_UNTIL
 DQ DROP
 DQ SEMIS




; LIST
LISTC9:
 DB 84H
 DB 'LIS'
 DB 'T'+80H
 DQ VLIST9
LISTC:
 DQ DOCOL, DECIMAL
 DQ _CR, DUPE
 DQ SCR, STORE
 DQ PDOTQ
 DB 6, 'SCR # '
 DQ DOT
 DQ _LIT, 10H
 DQ _0, XDO
LIST_AFT_XDO:
 DQ _CR, IDO
 DQ _LIT, 3
 DQ DOTR, SPACE
 DQ IDO, SCR
 DQ ATT, DLINE
 DQ QTERM
 DQ ZBRAN
LIST_AFT_IF:
 DQ LIST_AFT_THEN - LIST_AFT_IF
 DQ _LEAVE
LIST_AFT_THEN:
 DQ XLOOP
LIST_AFT_XLOOP:
 DQ LIST_AFT_XDO - LIST_AFT_XLOOP
 DQ _CR
 DQ SEMIS


; INDEX
INDEX9:
 DB 85H
 DB 'INDE'
 DB 'X'+80H
 DQ LISTC9
INDEX:
 DQ DOCOL
 DQ _LIT, FF  ; CNTRL CODE (FF:Form Feed)
 DQ EMIT, _CR
 DQ _1PL, SWAP
 DQ XDO
INDEX_AFT_XDO:
 DQ _CR, IDO
 DQ _LIT, 3
 DQ DOTR, SPACE
 DQ _0, IDO
 DQ DLINE, QTERM
 DQ ZBRAN
INDEX_AFT_IF:
 DQ INDEX_AFT_THEN - INDEX_AFT_IF
 DQ _LEAVE
INDEX_AFT_THEN:
 DQ XLOOP
INDEX_AFT_XLOOP:
 DQ INDEX_AFT_XDO - INDEX_AFT_XLOOP
 DQ SEMIS



; TRIAD
TRIAD9:
 DB 85H
 DB 'TRIA'
 DB 'D'+80H
 DQ INDEX9
TRIAD:
 DQ DOCOL
 DQ _LIT, 0FFH
 DQ EMIT
 DQ _LIT, 3
 DQ SLASH
 DQ _LIT, 3
 DQ STAR
 DQ _LIT, 3
 DQ OVER, PLUS
 DQ SWAP
 DQ XDO
TRIAD_AFT_XDO:
 DQ _CR
 DQ IDO
 DQ LISTC
 DQ QTERM  ; ?TERMINAL
 DQ ZBRAN
TRIAD_AFT_IF:
 DQ TRIAD_AFT_THEN - TRIAD_AFT_IF
 DQ _LEAVE
TRIAD_AFT_THEN:
TRIAD_AFT_XLOOP:
 DQ XLOOP
 DQ TRIAD_AFT_XDO - TRIAD_AFT_XLOOP
 DQ _CR
 DQ _LIT, 15
 DQ MESSAGE, _CR
 DQ SEMIS




 


; .CPU
DOTCPU9:
 DB 84H
 DB '.CP'
 DB 'U'+80H
 DQ TRIAD9
DOTCPU:
 DQ DOCOL
 DQ BASE, ATT  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ _LIT, 36
 DQ BASE, STORE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ _LIT, 22H
 DQ PORIG, TAT
 DQ DDOT
 DQ BASE, STORE  ; 数の基底を持つユーザー変数（１０だと１０進数）
 DQ SEMIS





 
; SERCH_WORD
SERCH_WORD9::
 DB 8AH
 DB 'SERCH_WOR'
 DB 'D'+80H
 DQ DOTCPU9
SERCH_WORD:
; DQ DOCOL
; DQ SEMIS
 DQ SERCH_WORD_2 
SERCH_WORD_2:
; 最初のワードのアドレス(NFA)設定
 LEA RBX,FORTH4
 MOV RBX,[RBX]

; NFA→LFA

; しまった、ここ何も考えていない。後で修正すること。！

;LOOP:
SERCH_WORD_1:


; デバッグ用の現在のワードのNFAのアドレス値をげ面に表示する

;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ SERCH_WORD_SKIP01

 PUSH RBX
 PUSH RCX
 PUSH RDX

    MOV     R8,RBX
    LEA     rdx,WORD_ADDR_OF_SERCH_WORD
    lea     rcx, PRT_FORM_OF_SERCH_WORD

    call    printf

 POP RDX
 POP RCX
 POP RBX

SERCH_WORD_SKIP01:


;;; RDX<-RBX
;; MOV RDX,RBX
; RBXが.DATAや.CODEの範囲内か？
; MOV RCX,[CHECK_ADDR_NEW]
; MOV [CHECK_ADDR_OLD],R10
 MOV RCX,ORIG
 CMP RBX,RCX
 JL SERCH_WORD_63
 MOV RCX,CODE_END
 CMP RBX,RCX
 JLE SERCH_WORD_5

SERCH_WORD_63:
 MOV RCX,UVR
 CMP RBX,RCX
 JL SERCH_WORD_62
 MOV RCX,SYS_LIMIT
 CMP RBX,RCX
 JG SERCH_WORD_62
 
;  NO: エラー処理１へ


; RBXが０か？
 OR RBX,RBX
;  YES: 終了処理へ
;  NO : RBX<-RDX, JMP LOOP

 JZ SERCH_WORD_END

;; MOV RBX,RDX
SERCH_WORD_5:

 XOR RAX,RAX  ; NFAの最初１バイトのチェック
 MOV AL,[RBX]
 MOV CL,1FH
 AND AL,CL
 JZ SERCH_WORD_62  ; ワード名のサイズが０の場合はエラー処理へ

;   ; ワード名の最後尾以外が7FH以下であることを確認する
; MOV R8,RAX
 MOV R8,RAX
 MOV R9,RBX
 XOR R10,R10

 INC R9
 DEC R8            ; ワード名が１文字の場合は次の処理へ
 JZ SERCH_WORD_72


SERCH_WORD_71:     ; ワード名が２文字の場合
 MOV CL,80H
 MOV R10B,[R9]
 AND R10B,CL
 JNZ SERCH_WORD_62 ; ワード名の最後尾でないのに７ビット目が１になっている場合はエラー処理へ
 INC R9
 DEC R8
 JNZ SERCH_WORD_71 ; 次の文字が最後尾でなければ処理を繰り返す

SERCH_WORD_72:
 ADD RBX,RAX
 MOV AL,[RBX]
 MOV CL,80H
 AND AL,CL
 JZ SERCH_WORD_62
; ADD RBX,1+8
 INC RBX
 MOV RBX,[RBX]

; 次のアドレスが０なら終了する
 XOR RAX,RAX
 CMP RBX,RAX
 JE SERCH_WORD_END




 JMP SERCH_WORD_1



;正常終了処理:
SERCH_WORD_END:

 JMP NEXT

;エラー処理１:
SERCH_WORD_62:


;    MOV     R8,RBX
;    LEA     rdx,ERROR_MESSAGE_OF_SERCH_WORD
    lea     rcx, PRT_FORM_OF_SERCH_WORD_ERROR

    call    printf

 JMP NEXT



; 79-STANDARD
FORTH79STD9::
  ; ラベルを：：で定義するとPUBLICとなる
  ;
 DB 8bH
 DB '79-STANDAR'
 DB 'D'+80H
 DQ SERCH_WORD9
FORTH79STD:
 DQ DOCOL
 DQ SEMIS
 
;END CLD9


  ret

TestProc endp


















; void myFunc(void) 画面上にこの次に処理を行うワード名を出力する。
; デフォルトは PUBLIC
; myFunc PROC PRIVATE
myFunc PROC

start:

 push rax
 push rbx
 push rcx
 push rdx
 push rsi
 push r8
 push r9
 push r10
 push r11



 push rax
 push rcx

 
 xor rax,rax
 mov ax,[DEBUG_DUMP_LEVEL]
 mov [DEBUG_DUMP_LEVEL2],ax


dump_word_loop01:
    mov ax,[DEBUG_DUMP_LEVEL2]
     and ax,ax
    jz  dump_word_loop02

;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
    lea     r8, HELLOSTR
    mov     dx, SCAN_VAL_20H
    lea     rcx, PRINTFORMAT1

    call    printf_s
    sub [DEBUG_DUMP_LEVEL2],1
    jmp  dump_word_loop01

dump_word_loop02:
 pop rcx
 pop rax





 mov cl,32                ; 最大文字数は３１ビットだなぁ。修正するか？
; mov rsi,[SEE_THIS_WORD]  ; 目的のWORDのName Fieldの先頭アドレスをrsiに転送する
 mov rsi,[SEE_THIS_WORD_ptr]  ; 目的のWORDのName Fieldの先頭アドレスをrsiに転送する
   MOV RDI,[SEE_THIS_WORD_ptr]  ; デバッグ用行

 OR RDI,RDI
 JZ error_myFunc_PROC_03

 mov rsi,[rsi]
 sub rsi,8+1              ; 前のWORDの先頭アドレスを示すポインタ（８バイト）をスキップ
 mov al,[rsi]             ; WORD名の最後の文字をalレジスタへ
 and al,080h              ; 最後の文字であることを示す７ビット目が１であるかをチェックする
 jz error_myFunc_PROC_01               ; もしも７ビット目が１でなければ間違いである。ここでのエラー処理をどうするべきか？未定
loop01:
 dec rsi
 dec cl
 jz error_myFunc_PROC_02               ; 文字列で００ｈが使われるのはｎｕｌｌの時のみと考える。
                          ; ｎｕｌｌでは１文字だけなので８０ｈとなる。００ｈはエラーとした。 
 mov al,[rsi]
 and al,080h
 jz loop01                ; ７ビット目に１が現れるまで１バイトをさかのぼっていく。

loop02:
 inc rsi        ; Name Fieldの先頭アドレス＋１（WORD名の文字列）を順にアクセスする
 mov al,[rsi]
 and al,080h    ; もし文字の７ビット目が１であれば、文字列の最後である。
 jnz skip01     ; 文字列のスキャンの終了

 push rax
 push rcx
 xor rcx,rcx
 mov cl,[rsi]
 mov rdx,rcx
 mov rbx,rcx    ; １バイトの文字を８バイト長に変換してrbxへコピーする


;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
    lea     r8, HELLOSTR          ; 
;    mov     edx, SCANVAL         ; すでに求めているので除外
    lea     rcx, PRINTFORMAT1     ; 一文字のフォーマット文字列
    call    printf_s


 pop rcx
 pop rax

 jmp loop02

skip01:
 push rax
 push rcx
 xor rcx,rcx       ; 最後の文字を出力する。
 mov cl,[rsi]
 and cl,07fh       ; 最後の文字には７ビット目に１が格納されているので除外する
 mov rdx,rcx

;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
    lea     r8, HELLOSTR
;    mov     edx, SCANVAL
    lea     rcx, PRINTFORMAT2
    call    printf_s

 pop rcx
 pop rax



 jmp skip_myFunc     ; 終了処理へ




error_myFunc_PROC_01:

; ERR_myFunc_PROC_01 DB 'myFunc PROC: The seventh bit on both ends of the NFA was not 1.'
;                              ; myFunc PROC: NFAの両端の第７ビット目が１でなかった

 lea rcx,ERR_myFunc_PROC_01
 call _putwch

 lea     rcx, SCANPROMPT_error
 call _getwch

 jmp skip_myFunc
;


error_myFunc_PROC_02:

; ERR_myFunc_PROC_02 DB 'myFunc PROC: The length of the NFA word name is more than 32 bytes.'
;                              ; myFunc PROC: NFAのワード名の長さが３２バイト以上です

 lea rcx,ERR_myFunc_PROC_02
 call _putwch


 lea     rcx, SCANPROMPT_error
 call _getwch

 jmp skip_myFunc
;



error_myFunc_PROC_03:

; ERR_myFunc_PROC_03 DB 'myFunc PROC: This is an unregistered word name.'
;                              ; myFunc PROC: 登録されていないワード名です

 lea rcx,ERR_myFunc_PROC_03
 call _putwch


 lea     rcx, SCANPROMPT_error
 call _getwch

 jmp skip_myFunc
;

 lea     rcx, SCANPROMPT
 call _getwch
;以下はキー入力待ちの時に表示された画面の様子です
;64
;p
;
;この時に”２”を入力すると、レジスタは次の状態だった
;RAX = 0000000000000032 RBX = 0000000000000042 RCX = 00000000FFFFFFFF RDX = 0000000000000000 RSI = 0000000000000000 RDI = 0000000000000000 R8  = 0000008D285DF5F8 R9  = 0000008D285DF700 R10 = 0000000000000000 R11 = 0000008D285DF870 R12 = 0000000000000000 R13 = 0000000000000000 R14 = 0000000000000000 R15 = 0000000000000000 RIP = 00007FF6E47E26BF RSP = 0000008D285DF8B0 RBP = 0000008D285DF900 EFL = 00000204 
;
; なんでcall printf_sの時に"Enter a number: "が表示されて
; call putchの時に"p"だけだった
;  call getchがどうして変化するのかわからない。
;   
;

 mov     rcx,rax

 push rax
 push rcx
 mov     rcx, '#'
 call _putwch
 pop rcx
 pop rax

 push rax
 push rcx
 mov     rcx, '#'
 call _putwch
 pop rcx
 pop rax

 push rax
 push rcx
 mov     rcx, '#'
 call _putwch
 pop rcx
 pop rax


 lea     rcx, SCANPROMPT
 call _getwch


 lea     rcx, SCANPROMPT
 call _getwch




skip_myFunc:
    ;------ スタックの解放

 pop r11
 pop r10
 pop r9
 pop r8
 pop rsi
 pop rdx
 pop rcx
 pop rbx
 pop rax



    ret
myFunc ENDP












; void myFunc2(void) 画面上に以前実行中だったワードを並べて出力する。最近に実行したワードから、一番最初に実行したワードへの順で表示する。
; デフォルトは PUBLIC
; myFunc PROC PRIVATE
myFunc2 PROC




start:

 push rax
 push rbx
 push rcx
 push rdx
 push rsi
 push r8
 push r9
 push r10
 push r11



;
 mov rcx,[SEE_THIS_WORD_ptr]

loop_myFunc2_01:
 lea rbx,SEE_THIS_WORD_STACK_TOP
 cmp rbx,rcx
 jae  skip_myFunc2_02

 push rcx
 mov rax,[SEE_THIS_WORD_ptr]
 sub rax,rcx
 add rax,rbx



 mov cl,32                ; 最大文字数は３１ビットだなぁ。修正するか？
; mov rsi,[SEE_THIS_WORD]  ; 目的のWORDのName Fieldの先頭アドレスをrsiに転送する
 mov rsi,[rax]              ; 目的のWORDのName Fieldの先頭アドレスをrsiに転送する
 sub rsi,8+1              ; 前のWORDの先頭アドレスを示すポインタ（８バイト）をスキップ
 mov al,[rsi]             ; WORD名の最後の文字をalレジスタへ
 and al,080h              ; 最後の文字であることを示す７ビット目が１であるかをチェックする
 jz error01               ; もしも７ビット目が１でなければ間違いである。ここでのエラー処理をどうするべきか？未定
loop01:
 dec rsi
 dec cl
 jz error01               ; 文字列で００ｈが使われるのはｎｕｌｌの時のみと考える。
                          ; ｎｕｌｌでは１文字だけなので８０ｈとなる。００ｈはエラーとした。 
 mov al,[rsi]
 and al,080h
 jz loop01                ; ７ビット目に１が現れるまで１バイトをさかのぼっていく。

loop02:
 inc rsi        ; Name Fieldの先頭アドレス＋１（WORD名の文字列）を順にアクセスする
 mov al,[rsi]
 and al,080h    ; もし文字の７ビット目が１であれば、文字列の最後である。
 jnz skip01     ; 文字列のスキャンの終了

 push rax
 push rcx
 sub     rsp, 28h


 xor rcx,rcx
 mov cl,[rsi]
 mov rdx,rcx
 mov rbx,rcx    ; １バイトの文字を８バイト長に変換してrbxへコピーする


;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
    lea     r8, HELLOSTR          ; 
;    mov     edx, SCANVAL         ; すでに求めているので除外
    lea     rcx, PRINTFORMAT3     ; 一文字のフォーマット文字列
    call    printf_s

 add     rsp, 28h

 pop rcx
 pop rax

 jmp loop02

skip01:

 sub     rsp, 28h
 push rax
 push rcx
 xor rcx,rcx       ; 最後の文字を出力する。
 mov cl,[rsi]
 and cl,07fh       ; 最後の文字には７ビット目に１が格納されているので除外する
 mov rdx,rcx

;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
    lea     r8, HELLOSTR
;    mov     edx, SCANVAL
    lea     rcx, PRINTFORMAT4
    call    printf_s


 add     rsp, 28h
 pop rcx
 pop rax



 jmp skip_myFunc     ; 終了処理へ




error01:

 mov     rcx, '#'

 push rax
 push rcx
 call _putwch
 pop rcx
 pop rax


 lea     rcx, SCANPROMPT
 call _getwch




 lea     rcx, SCANPROMPT
 call _getwch
;以下はキー入力待ちの時に表示された画面の様子です
;64
;p
;
;この時に”２”を入力すると、レジスタは次の状態だった
;RAX = 0000000000000032 RBX = 0000000000000042 RCX = 00000000FFFFFFFF RDX = 0000000000000000 RSI = 0000000000000000 RDI = 0000000000000000 R8  = 0000008D285DF5F8 R9  = 0000008D285DF700 R10 = 0000000000000000 R11 = 0000008D285DF870 R12 = 0000000000000000 R13 = 0000000000000000 R14 = 0000000000000000 R15 = 0000000000000000 RIP = 00007FF6E47E26BF RSP = 0000008D285DF8B0 RBP = 0000008D285DF900 EFL = 00000204 
;
; なんでcall printf_sの時に"Enter a number: "が表示されて
; call putchの時に"p"だけだった
;  call getchがどうして変化するのかわからない。
;   
;

 mov     rcx,rax

 push rax
 push rcx
 call _putwch
 pop rcx
 pop rax

 push rax
 push rcx
 call _putwch
 pop rcx
 pop rax

 push rax
 push rcx
 call _putwch
 pop rcx
 pop rax


 lea     rcx, SCANPROMPT
 call _getwch


 lea     rcx, SCANPROMPT
 call _getwch

skip_myFunc:
    ;------ スタックの解放

;
; mov rcx,[SEE_THIS_WORD_ptr]
 pop rcx
 sub rcx,8
 jmp loop_myFunc2_01


skip_myFunc2_02:


;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
    lea     r8, HELLOSTR
;    mov     edx, SCANVAL
    lea     rcx, PRINTFORMAT5
    call    printf_s


 pop r11
 pop r10
 pop r9
 pop r8
 pop rsi
 pop rdx
 pop rcx
 pop rbx
 pop rax



    ret
myFunc2 ENDP









; void dumpReg(void) 現在のレジスタ値を表示する。
; デフォルトは PUBLIC
; dumpReg PROC PRIVATE

;; 現在のレジスタの表示する種類を設定し、それらの値を表示する。
;; The child subroutine sets the type of current registers to be displayed and displays their values.
;Usage.
;
; mov r11,64+32+16+8+4+2+1     ; display RAX-RBP reg.
; call dumpReg
;


dumpReg PROC

;;;dumpReg::





    sub     rsp, 28h

;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r10],r10  ; display Regs.
 MOV R10,[TRACE_SET+8]
 MOV R10,[R10]
 OR R10,R10
    mov R10,[save_r10]  ; display Regs.
 JZ dumpReg_skip99


    mov [save_rax],rax  ; r10= 000001
    mov [save_rbx],rbx  ; r10= 000010
    mov [save_rcx],rcx  ; r10= 000100
    mov [save_rdx],rdx  ; r10= 001000
    mov [save_rsi],rsi  ; r10= 010000
    mov [save_rbp],rbp  ; r10= 100000
    mov [save_r8 ],r8   ; display Regs.
    mov [save_r9 ],r9   ; display Regs.
;    mov [save_r10],r10  ; display Regs.
    mov [save_r11],r11  ; display Regs.

    xchg rax,rsp
    mov [save_rsp],rax
    xchg rax,rsp


;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
;    lea     r8, HELLOSTR
;    mov     edx, SCANVAL
;    lea     rcx, PRINTFORMAT
;   ; call    printf
;    mov     rdx, WORD_SCANVAL

    mov     r11,[save_r11]
    and     r11,1          ; RAXに格納された値
    jz     dumpReg_skip1     
    mov     r8 ,[save_rax]
;    mov     r8 ,[save_r10]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rax_PRINTFORMAT

    call    printf

dumpReg_skip1:

    mov     r11,[save_r11]
    and     r11,2          ; RBXに格納された値
    jz     dumpReg_skip2     
    mov     r8 ,[save_rbx]
;    mov     r8 ,[save_r10]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rbx_PRINTFORMAT

    call    printf

dumpReg_skip2:

    mov     r11,[save_r11]
    and     r11,4          ; RCXに格納された値
    jz     dumpReg_skip3     
    mov     r8 ,[save_rcx]
;    mov     r8 ,[save_r10]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rcx_PRINTFORMAT

    call    printf

dumpReg_skip3:

    mov     r11,[save_r11]
    and     r11,8          ; RDXに格納された値
    jz     dumpReg_skip4     
    mov     r8 ,[save_rdx]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rdx_PRINTFORMAT

    call    printf

dumpReg_skip4:

    mov     r11,[save_r11]
    and     r11,16          ; RSIに格納された値
    jz     dumpReg_skip5     
    mov     r8 ,[save_rsi]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsi_PRINTFORMAT

    call    printf

dumpReg_skip5:

    mov     r11,[save_r11]
    and     r11,32          ; RBPに格納された値
    jz     dumpReg_skip6     
    mov     r8 ,[save_rbp]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rbp_PRINTFORMAT

    call    printf

dumpReg_skip6:


    mov     r11,[save_r11]
    and     r11,64               ; RSPに格納された値
    jz     dumpReg_skip7     
    mov     r8 ,[save_rsp]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsp_PRINTFORMAT

    call    printf

dumpReg_skip7:


    mov     r11,[save_r11]
    and     r11, 8*1024          ; RDXに格納されたアドレスの先のメモリの値
    jz     dumpReg_skip8     
    mov     r8 ,[save_rdx]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rdx2_PRINTFORMAT

    call    printf

dumpReg_skip8:


    mov     r11,[save_r11]
    and     r11,16*1024          ; RSIに格納されたアドレスの先のメモリの値（現在インストラクションポインタが示すアドレスの先のメモリの内容）
    jz     dumpReg_skip9     
    mov     r8 ,[save_rsi]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsi2_PRINTFORMAT

    call    printf

dumpReg_skip9:


    mov     r11,[save_r11]
    and     r11,32*1024          ; RBPに格納されたアドレスの先のメモリの値（直前にプッシュしたリターンスタックが示すアドレスの先のメモリの内容）
    jz     dumpReg_skip10     
    mov     r8 ,[save_rbp]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rbp2_PRINTFORMAT

    call    printf

dumpReg_skip10:


    mov     r11,[save_r11]
    and     r11,64*1024          ; RSPに格納されたアドレスの先のメモリの値（直前にプッシュしたデータスタックが示すアドレスの先のメモリの内容）
    jz     dumpReg_skip11     
    mov     r8 ,[save_rsp]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsp2_PRINTFORMAT

    call    printf

dumpReg_skip11:






    mov r11,[save_r11]
    mov r10,[save_r10]
    mov r9 ,[save_r9 ]
    mov r8 ,[save_r8 ]
    mov rbp,[save_rbp]
    mov rsi,[save_rsi]
    mov rdx,[save_rdx]
    mov rcx,[save_rcx]
    mov rbx,[save_rbx]
    mov rax,[save_rax]


dumpReg_skip99:


    add     rsp, 28h

    ret

dumpReg ENDP















; void dumpParam(void) 現在のスタックの最初と２段目にあたるスタック値が格納されているメモリの値を表示する。一番最近に設定されたBREAK_POINTOの値を表示する。
; デフォルトは PUBLIC
; dumpParam PROC PRIVATE

; 現在のスタックポインタ（最上位、２番目）と番号を表示する。
; Display the current stack pointer (topmost and second) and number.
;Usage.
;
; mov r11,4+2+1                ; display TOP OF STACK, 2ND OF STACK, NUMBER.
; call dumpParam
;

dumpParam PROC

;;;dumpParam::

    sub     rsp, 28h

    mov [save_rax],rax  ; r10= 000001
    mov [save_rbx],rbx  ; r10= 000010
    mov [save_rcx],rcx  ; r10= 000100
    mov [save_rdx],rdx  ; r10= 001000
    mov [save_rsi],rsi  ; r10= 010000
    mov [save_rbp],rbp  ; r10= 100000
    mov [save_r8 ],r8   ; display Regs.
    mov [save_r9 ],r9   ; display Regs.
    mov [save_r10],r10  ; display Regs.
    mov [save_r11],r11  ; display Regs.

    xchg rax,rsp
    mov [save_rsp],rax
    xchg rax,rsp


;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
;    lea     r8, HELLOSTR
;    mov     edx, SCANVAL
;    lea     rcx, PRINTFORMAT
;   ; call    printf
;    mov     rdx, WORD_SCANVAL

;; 画面に表示されるレジスタの種類を設定、表示する。
;;
; mov r11,64+32+16+8+4+2+1         ; display RAX reg.
; lea r10,WORD_NAME_BREAK_POINT
; call dumpParam
;

    mov     r11,[save_r11]
    and     r11,1          ; 000001
    jz     dumpParam_skip1     
    mov     r8 ,[WORK_BREAK_POINT_RAX]
;    mov     r8 ,[r8]
;    mov     r8 ,[save_r10]
;    mov     rdx,[WORD_NAME_BREAK_POINT_RAX]
    lea     rdx, WORD_NAME_BREAK_POINT_RAX
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip1:

    mov     r11,[save_r11]
    and     r11,2          ; 000010
    jz     dumpParam_skip2     
    mov     r8 ,[WORK_BREAK_POINT_RBX]

;    mov     r8 ,[r8]
;    mov     r8 ,[save_r10]
;    mov     rdx,[WORD_NAME_BREAK_POINT_RBX]
    lea     rdx, WORD_NAME_BREAK_POINT_RBX
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip2:

    mov     r11,[save_r11]
    and     r11,4          ; 000100
    jz     dumpParam_skip3     
    mov     r8 ,[WORK_BREAK_POINT_NUMBER]

;    mov     r8 ,[r8]
;    mov     r8 ,[save_r10]
;    mov     rdx,[WORD_NAME_BREAK_POINT_NUMBER]
    lea     rdx, WORD_NAME_BREAK_POINT_NUMBER
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip3:

    mov     r11,[save_r11]
    and     r11,8          ; 001000
    jz     dumpParam_skip4     
;    mov     r8 ,[save_rdx]
;    mov     rdx,[save_r10]
  lea     rdx, WORD_NAME_BREAK_POINT_MESSAGE
      lea     rcx, PRT_FORM_MESSAGE

    call    printf

dumpParam_skip4:

    mov     r11,[save_r11]
    and     r11,16          ; 010000
    jz     dumpParam_skip5     
    mov     r8 ,[save_rsi]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip5:

    mov     r11,[save_r11]
    and     r11,32          ; 100000
    jz     dumpParam_skip6     
    mov     r8 ,[save_rbp]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip6:


    mov     r11,[save_r11]
    and     r11,64          ; 1000000
    jz     dumpParam_skip7     
    mov     r8 ,[save_rsp]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip7:


    mov     r11,[save_r11]
    and     r11, 8*1024          ; 100000
    jz     dumpParam_skip8     
    mov     r8 ,[save_rdx]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip8:


    mov     r11,[save_r11]
    and     r11,16*1024          ; 100000
    jz     dumpParam_skip9     
    mov     r8 ,[save_rsi]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip9:


    mov     r11,[save_r11]
    and     r11,32*1024          ; 100000
    jz     dumpParam_skip10     
    mov     r8 ,[save_rbp]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip10:


    mov     r11,[save_r11]
    and     r11,64*1024          ; 100000
    jz     dumpParam_skip11     
    mov     r8 ,[save_rsp]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

    call    printf

dumpParam_skip11:







    mov r11,[save_r11]
    mov r10,[save_r10]
    mov r9 ,[save_r9 ]
    mov r8 ,[save_r8 ]
    mov rbp,[save_rbp]
    mov rsi,[save_rsi]
    mov rdx,[save_rdx]
    mov rcx,[save_rcx]
    mov rbx,[save_rbx]
    mov rax,[save_rax]


    add     rsp, 28h

    ret

dumpParam ENDP












; void call_C_entry( ) 関数の定義
; デフォルトは PUBLIC

; call call_C_entry
;    input  - rcx:pointer of struct VAR_SET
;             rdx:command No.
;                1:CIN
;                2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
;    (output - rax:return value (pointer of struct VAR_SET))


call_C_entry PROC


    xchg rax,rsp
    mov [call_C_entry_save_rsp],rax ;コールした後のリターンスタックの値を[call_C_entry_save_rsp]に保存する。
    mov rax,[PTR_STACK]  ;           退避エリアの最初の退避アドレス（８バイト）が書かれたPTR_STACK内のアドレスをRAX(RSP)に書込む。
    xchg rax,rsp
    mov [call_C_entry_save_rbp],rbp

    sub     rsp, 28h



    xchg rax,rsp
    mov [PTR_STACK],rax  ;           退避エリアの最終退避アドレス（８バイト）をPTR_STACK内に保存する。
    mov rax,[RET_call_C_entry_save_rsp] ; [call_C_entry_save_rsp]内にあるコールした後のリターンスタックの値をRAX(RSP)に書込む。
    xchg rax,rsp
    mov rbp,[RET_call_C_entry_save_rbp]
    
;    mov rax,[call_C_entry_save_rcx]
    mov rax,rcx



   ret




call_C_entry ENDP



; void call_C_ExitFromOS( ) 関数の定義
; デフォルトは PUBLIC

; call call_C_exit
;    input  - rcx:pointer of struct VAR_SET
;             rdx:command No.
;                1:CIN
;                2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
;    (output - rax:return value (pointer of struct VAR_SET))


;call_C_ExitFromOS PROC
;




 ;   xchg rax,rsp
;    mov [call_C_entry_save_rsp],rax ;コールした後のリターンスタックの値を[call_C_entry_save_rsp]に保存する。
;    mov rax,[PTR_STACK]  ;           退避エリアの最初の退避アドレス（８バイト）が書かれたPTR_STACK内のアドレスをRAX(RSP)に書込む。
;    xchg rax,rsp
;    mov [call_C_entry_save_rbp],rbp 
;
;    sub     rsp, 28h



;    xchg rax,rsp
;    mov [PTR_STACK],rax  ;           退避エリアの最終退避アドレス（８バイト）をPTR_STACK内に保存する。
;    mov rax,[RET_call_C_entry_save_rsp] ; [call_C_entry_save_rsp]内にあるコールした後のリターンスタックの値をRAX(RSP)に書込む。
;    xchg rax,rsp
;    mov rbp,[RET_call_C_entry_save_rbp]
;
;    mov rdx,999h          ; 1:CIN
; mov rcx,[RET_call_C_entry_save_rcx]
;; mov rcx,[rcx]
; mov [rcx+ 8],rdx
; mov rcx,RET_call_C_entry_save_rcx
; mov [call_C_entry_save_rcx],rcx
;
;    mov rax,rcx



;   ret;




;call_C_ExitFromOS ENDP


; void call_C_exit( ) 関数の定義
; デフォルトは PUBLIC

; call call_C_entry
;    (input  - rcx:pointer of struct VAR_SET
;             rdx:command No.
;                1:CIN
;                2:COUT )
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
;    output - rax:return value (pointer of struct VAR_SET)

call_C_exit PROC



 mov r8,[rcx + 16]  ; r8: Display Trace WORD name  0:OFF else:ON
 lea r9,TRACE_SET   ; r9: Address of the first parameter of WORD “TRACE_SET (variable)”
 mov [r9 + 8],r8    ;     WORD「TRACE_SET（変数）」の第１パラメータのアドレス
 
    xchg rax,rsp
    mov [RET_call_C_entry_save_rsp],rax  ; コールした後のリターンスタックの値を[call_C_entry_save_rsp]内に保存する。
    mov rax,[PTR_STACK]    ;         PTR_STACK内に保存した退避エリアの最終退避アドレス（８バイト）をRAX(RSP)に書込む。
    xchg rax,rsp
    mov [RET_call_C_entry_save_rbp],rbp  ; コールした後のリターンスタックの値を[call_C_entry_save_rsp]内に保存する。




    add     rsp, 28h

    xchg rax,rsp
    mov [PTR_STACK],rax  ;             RAX(RSP)内にある退避エリアの最初の退避アドレス（８バイト）を[PTR_STACK]に退避する。
    mov rax,[call_C_entry_save_rsp]  ; [call_C_entry_save_rsp]にあるコールした後のリターンスタックの値（８バイト）をRAX(RSP)に書込む。
    xchg rax,rsp
    mov rbp,[call_C_entry_save_rbp]  ; [call_C_entry_save_rsp]にあるコールした後のリターンスタックの値（８バイト）をRAX(RSP)に書込む。

    mov rax,rcx

    ret

call_C_exit ENDP



CHECK_MEM_WRITE proc


CHK_M_W6:


 mov [save_rax_3],rax
 mov [save_rcx_3],rcx
 mov [save_rdx_3],rdx
 mov [save_r8_3],r8
 mov [save_r9_3],r9
 mov [save_r10_3],r10
 mov [save_r11_3],r11

    sub     rsp, 28h

; PUSH R10
; PUSH R9
; MOV R8,[R8]
; OR R8,R8
;; JNZ PFIN1
;; 異常検出処理
; JZ CHK_M_W_61
; MOV R10,[CHECK_ADDR_NEW]
; MOV [CHECK_ADDR_OLD],R10
 MOV R10,ORIG
 CMP R8,R10
 JL CHK_M_W_63
 MOV R10,CODE_END
 CMP R8,R10
 JLE CHK_M_W1

CHK_M_W_63:
; MOV R10,UVR
 MOV R10,DATA_START
 CMP R8,R10
 JL CHK_M_W_62
 MOV R10,SYS_LIMIT
 CMP R8,R10
 JG CHK_M_W_62

; JMP CHK_M_W1
CHK_M_W1:
; POP R9
; POP R10

    add     rsp, 28h


 mov rax,[save_rax_3]
 mov rcx,[save_rcx_3]
 mov rdx,[save_rdx_3]
 mov r8,[save_r8_3]
 mov r9,[save_r9_3]
 mov r10,[save_r10_3]
 mov r11,[save_r11_3]

 RET


CHK_M_W_62:
; MOV R10,[CHECK_ADDR_OLD]
; MOV R11,R8

;; エラーによる実行終了
; XOR RAX,RAX
; MOV [RAX],RAX

; ７）画面に表示されるレジスタの種類を設定、表示する。
;






    LEA     rdx,WORD_NAME_BREAK_POINT_R8
    lea     rcx, PRT_FORM_Param

;    PUSH R9
    mov [save_r9_4],r9
    call    printf
;    POP R9
    mov r9,[save_r9_4]

    MOV     R8,R9
    LEA     rdx,WORD_NAME_BREAK_POINT_R9
    lea     rcx, PRT_FORM_Param

    call    printf

    LEA     rdx,ORIG
    LEA     r8 ,CODE_END
    lea     rcx, PRT_FORM_FROM_TO

    call    printf

    LEA     rdx,DATA_START
    LEA     r8 ,SYS_LIMIT
    lea     rcx, PRT_FORM_FROM_TO

    call    printf

 mov r11,32+16+8+4+2+1         ; display RAX-RBP reg.
 call dumpReg

  mov r11,8+4+2+1         ; display TOP OF STACK, 2ND OF STACK, NUMBER.
 call dumpParam


 lea     rcx, SCANPROMPT_error
 call _getwch

; 確認のために停止させないで億

; mov rax,[save_rax_3]
; mov rcx,[save_rcx_3]
; mov rdx,[save_rdx_3]
; mov r8,[save_r8_3]
; mov r9,[save_r9_3]
; mov r10,[save_r10_3]
; mov r11,[save_r11_3]



 jmp CHK_M_W1



CHK_M_W_7:
 CALL CI
 CMP RAX,'Y'
 JNE CHK_M_W_7
 JMP CLD9  ; COLD START


;CHK_M_W_61:
; MOV RAX,0
; JMP APUSH


CHECK_MEM_WRITE  ENDP





CODE_END:





 END

; 修正履歴
;20240418
; wordの+ORIGINを削除した。ORIGINやORIGを削除していたので。
; C@をFORTH言語からマシン語に修正。
;


; CONSTANT定数、VARIABLE変数がWORD化されていなかった。そのため、C!で書込もうとした
;   アドレスが０だった。
;; ****USER_VALIABLE****
;; ORG UP
;;
;;_USE:
;;         DQ FIRST ; not used
;;_PREV:
;;         DQ FIRST ; not used
;;_DISK_ERROR:
;;         DQ 0 ; not used


;; _UPは将来マルチになることを考えて、ここはラベルではなくて、
;; _UPから何バイト目であるかを使った方がいい。
;;_UP:
;;         DQ 0AAAAH      ; not used
;;         DQ 0      ; not used
;;         DQ 0      ; not used
;;ADR_S0:
;;         DQ INITS0 ; S0
;;ADR_R0:
;;         DQ INITR0 ; R0
;;ADR_TIB:
;;         DQ INITS0 ; TIB



