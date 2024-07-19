;
;
;
;
; SEMISと(;CODE)の使い方
; 　あるWORDの定義で、コンパイル時の定義では最後のWORDは(;CODE)を使う。コンパイルモード
; の終了を表すWORD（例えばDOSE>や(;CODE)など）の定義にはコンパイルモードの最終WORDはSEMISを使う。
;
; emit内のpflagが未定義
; do->loopでloopの次に戻り値を追加すること
; ｃｉｎのEXTERN scanf_s: PROC のレジスタを確認すること
; ４）COUTで
;    mov rcx,[save_rax]
;    call putchar
; を使用したら、RBPが指し示すエリアの内容があちこち書き換えられていた。これでは使えない。
;
; ワードの"<"の名前を _DIGIT になっている。なぜだろう？もう思い出せない。
;
;
;
;
;
;
;
;
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


; 定数の定義
;MB_OK               EQU     0
;MB_ICONINFORMATION  EQU     40h
;MSGBUFLEN           EQU     64



;EXTERN  FORTH79STD9:NEAR


;; ORG 100H
;
;ORIG EQU 0
;B_BUF EQU 400H
;BFLEN EQU 404H
;;LIMIT EQU ORIG+8000H-100
;; LIMIT EQU 8000H-100
;;FIRST EQU LIMIT - BFLEN * _BUFF
;;UP EQU FIRST - 60
;;S0_TOP EQU UP-800
;
;_BL EQU 20
;C_L EQU 40
;ZERO EQU _LIT,0
;0 EQU 0
;1 EQU 1
;2 EQU 2
;3 EQU 3
;MINS1 EQU -1
;TIBLEN EQU 50H
;MSGSCR EQU 3
;_BUFF EQU 2
;INITS0 EQU S0_TOP ;本当にいいんだろうか？
;INITR0 EQU UP-2   ;本当にいいんだろうか？
;INITDP EQU S0_TOP ;本当にいいんだろうか？
;INITS0 EQU DATA_STACK_AREA ;本当にいいんだろうか？
;INITR0 EQU RETURN_STACK_END   ;本当にいいんだろうか？
;INITDP EQU DATA_STACK_AREA ;本当にいいんだろうか？
;_32BITto16BIT EQU 100H-ORIG

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

;*********メモリマップ（現在の相対番地の考え方）
;
; .data
;
; ****USER_VALIABLE****
;UVR:
;         DQ 0 ; not used
;         DQ 0 ; not used
;         DQ 0 ; not used
;S0       DQ INITS0 ; S0
;R0       DQ INITR0 ; R0
;TIB      DQ INITS0 ; TIB
;   .....
;
; ****DATA STACK AREA******
;DATA_STACK_AREA:
;  QWORD 4000 DUP (?)
;DATA_STACK_END:
;
; ****RETURN_STACK AREA******
;RETURN_STACK_AREA:
;  QWORD 1000 DUP (?)
;RETURN_STACK_END:
;
; ***FORTH***
;FORTH9:
;
;.code
;
; ****FORTH_INNER_INTERPRETER****
;
;DPUSH: PUSH RDX
;APUSH: PUSH RAX
;NEXT: LODSQ ; RAX <- (RIP)
; MOV RBX,RAX ; IP <- IP+2
;NEXT1: MOV RDX,RBX
; INC RDX ; SET W
; JMP QWORD PTR [RBX] ; JUMP TO (IP)
;
; ****FORTH_DICTIONARY****
;
; ***LIT***
;LIT9:
;   （以下略）
;   ...
;
;*** COLD STATE VECTOR COMES HERE ***
;
;CLD9:
; CLD
; MOV RSI,OFFSET CLD1 ; SET UP IP
; MOV RSP,QWORD PTR S0 ; SET UP SP
; MOV RBP,QWORD PTR R0 ; SET UP RP
; JMP NEXT
;CLD1:
; DQ COLD
;
; ***COLD***
;COLD9:
; DB 84H
; DB 'COL'
; DB 'D'+80H
; DQ WARM9
;COLD:
; DQ DOCOL
; DQ LIT,UVR ; set user variables
; DQ LIT,UP,ATT64
; DQ LIT,50
; DQ _CMOVE
; DQ EMPBUF ; EMPTY-BUFFERS
; DQ ABORT ; ABORT

;
;   （以下、WORDの集まりが続く）

; *** 79-STANDARD ***
;FORTH79STD9::
;  ; ラベルを：：で定義するとPUBLICとなる
;  ;
; DB 8bH
; DB '79-STANDAR'
; DB 'D'+80H
; DQ PSCOD9
;FORTH79STD:
; DQ DOCOL
; DQ SEMIS
;

; ********そのため、以下の定数を修正した***********************
;S0_TOP =     UP-800
;INITS0 =     S0_TOP ;本当にいいんだろうか？
;INITR0 =     UP-2   ;本当にいいんだろうか？
;UP     =     FIRST - 60
;FIRST  =     LIMIT - BFLEN * 2 (_BUFF) 
;             LIMIT - BFLEN * 1  
;LIMIT  =     8000H


; ****USER_VALIABLE****
;UVR:







;;;;;;;;;.data 

; .data

;; ****USER_VALIABLE****
;
;
;_USE:
;         DQ FIRST ; not used
;_PREV:
;         DQ FIRST ; not used
;_DISK_ERROR:
;         DQ 0 ; not used
;UVR:
;         DQ 0 ; not used
;         DQ 0 ; not used
;         DQ 0 ; not used
;S0       DQ INITS0 ; S0
;R0       DQ INITR0 ; R0
;TIB      DQ INITS0 ; TIB
;_WIDTH    DQ 31 ; WIDTH
;WARNING  DQ 0 ; WARNING
;FENCE    DQ INITDP ; FENCE
;DP       DQ INITDP ; DP
;VOC_LINK DQ FORTH6 ; VOCLINK
;BLK      DQ 0 ; BLK
;DNIP      DQ 0 ; >IN
;_OUT      DQ 0 ; OUT
;SCR      DQ 0 ; SCR
;DRIVE    DQ 0 ; DRIVE
;CONTEXT  DQ FORTH4 ; CONTEXT
;CURRENT  DQ FORTH4 ; CURRENT
;STATE    DQ 0 ; STATE  ; 実行時は０、コンパイル中の時は０以外
;BASE     DQ 10 ; BASE
;DPL      DQ -1 ; DPL
;_FLD      DQ 0 ; FLD
;CSP      DQ 0 ; CSP
;RSRP       DQ 0 ; R#
;HLD      DQ 0 ; HLD
;
;
;  ;_USE DQ FIRST
;  ;_PREV DQ FIRST
;  ;_DISK_ERROR DQ 0
;


; 初期化したデータのセグメント
; BYTE は DB（Define BYTE の意）という書き方もあり。

.LISTALL
.data
SCANPROMPT      BYTE    "Enter a number: ", 0
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
WORD_NAME_@64            BYTE    "WORD=@64:",0
WORD_NAME_PLUS           BYTE    "WORD=+:",0
WORD_NAME_DOUSE          BYTE    "WORD=DO-USER:",0
WORD_NAME_DOCON          BYTE    "WORD=DO-CONSOLE:",0
WORD_NAME_DOVAR          BYTE    "WORD=DO-VARIABLE:",0
WORD_NAME_BREAK_POINT    BYTE    "WORD=BREAK_POINT:",0


DUMMY                   BYTE     "WORK_BREAK_POINT_RAX",0
WORK_BREAK_POINT_RAX     QWORD   1
WORK_BREAK_POINT_RBX     QWORD   1
WORK_BREAK_POINT_NUMBER     QWORD   99H

buf_WORK_BREAK_POINT_RAX        qword   0
buf_WORK_BREAK_POINT_RBX        qword   0

PRT_FORM_Param                  BYTE    " %s : =%llx", 0Dh, 0Ah, 0
WORD_NAME_BREAK_POINT_RAX       BYTE    "BREAK_POINT_RAX",0
WORD_NAME_BREAK_POINT_RBX       BYTE    "BREAK_POINT_RBX",0
WORD_NAME_BREAK_POINT_NUMBER    BYTE    "BREAK_POINT_NUMBER",0



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
save_r10     QWORD   9999h
save_r11     QWORD   0AAAAh
save_rsp     QWORD   0BBBBh

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


; ****USER_VALIABLE****
; ORG UP

;_USE:
;         DQ FIRST ; not used
;_PREV:
;         DQ FIRST ; not used
;_DISK_ERROR:
;         DQ 0 ; not used

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
         DQ 0      ; _OUT
         DQ 0      ; SCR
         DQ 0      ; DRIVE
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
         DQ 0      ; >IN
         DQ 0      ; _OUT
         DQ 0      ; SCR
         DQ 0      ; DRIVE
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



; ****DATA STACK AREA******
; ORG S0_TOP
;
;DATA_STACK_AREA:
;  QWORD 4000 DUP (?)
;DATA_STACK_END:
;


; ****RETURN_STACK AREA******
; ORG S0_TOP
;
;RETURN_STACK_AREA:
;  QWORD 1000 DUP (?)
;RETURN_STACK_END:
;  QWORD 1    DUP (?)






; FORTH
FORTH9:
 DB 85H
 DB 'FORT'
 DB 'H'+80H
; DQ 0               ; 次のアドレスはないから0を置いている。正しいだろうか？
 DQ _OFFSET9               ; 次のアドレスはないから0を置いている。正しいだろうか？
FORTH:
 DQ DOVOC           ; DOVOC
 DB 081H
 DB 0A0H
FORTH4::             ; 変数LATESTの示すアドレスはここ
; DQ _OFFSET9
 DQ FORTH9
FORTH6::
 DQ 0 ;Address = 0

;








; S0  ; 
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
BLK9:
 DB 83H
 DB 'BL'
 DB 'K'+80H
 DQ VOCLINK9      ;LATESTのアドレス
BLK:
 DQ DOUSE
 DQ 11*8      ; the data of STATE
;


; >IN  ; 
DNIP9:
 DB 83H
 DB '>I'
 DB 'N'+80H
 DQ BLK9      ;LATESTのアドレス
DNIP:
 DQ DOUSE
 DQ 12*8      ; the data of STATE
;


; OUT  ; 
_OUT9:
 DB 83H
 DB 'OU'
 DB 'T'+80H
 DQ DNIP9      ;LATESTのアドレス
_OUT:
 DQ DOUSE
 DQ 13*8      ; the data of STATE
;


; SCR  ; 
SCR9:
 DB 83H
 DB 'SC'
 DB 'R'+80H
 DQ _OUT9      ;LATESTのアドレス
SCR:
 DQ DOUSE
 DQ 14*8      ; the data of STATE
;


; DRIVE  ; 
DRIVE9:
 DB 85H
 DB 'DRIV'
 DB 'E'+80H
 DQ SCR9      ;LATESTのアドレス
DRIVE:
 DQ DOUSE
 DQ 15*8      ; the data of STATE
;


; CONTEXT  ; 
CONTEXT9:
 DB 87H
 DB 'CONTEX'
 DB 'T'+80H
 DQ DRIVE9      ;LATESTのアドレス
CONTEXT:
 DQ DOUSE
 DQ 16*8      ; the data of STATE
;


; CURRENT  ; 
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
 DQ 100H      ; the data of STATE
;

; B/BUF  ; 
B_BUF9:
 DB 85H
 DB 'B/BU'
 DB 'F'+80H
 DQ ORIGIN9      ;LATESTのアドレス
B_BUF:
 DQ DOCON  ; CONSTANT
 DQ 400H      ; the data of STATE
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
FIRST9:
 DB 85H
 DB 'FIRS'
 DB 'T'+80H
 DQ LIMIT9      ;LATESTのアドレス
FIRST:
 DQ DOCON  ; CONSTANT
 DQ SYS_FIRST      ; the data of STATE
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
C_L9:
 DB 83H
 DB 'C/'
 DB 'L'+80H
 DQ _BL9      ;LATESTのアドレス
C_L:
 DQ DOCON  ; CONSTANT
 DQ 40H      ; the data of STATE
;

; 0  ; 
_0_9:
 DB 81H
 DB '0'+80H
 DQ C_L9      ;LATESTのアドレス
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

; #BUFF  ; 
IGTBUFF9:
 DB 85H
 DB '#BUF'
 DB 'F'+80H
 DQ MSGSCR9      ;LATESTのアドレス
IGTBUFF:
 DQ DOCON  ; CONSTANT
 DQ 2      ; the data of STATE
;


;********** Variables *****************

; USE  ; 
USE9:
 DB 83H
 DB 'US'
 DB 'E'+80H
 DQ IGTBUFF9      ; #BUFF  LATESTのアドレス
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
;
DISK_ERROR9:
 DB 83H
 DB 'DISK-ERRO'
 DB 'R'+80H
 DQ PREV9      ;LATESTのアドレス
DISK_ERROR:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE

;
PFLAG9:    ; プリンターフラグ　 ０ならばプリンターに出力しない。
 DB 85H
 DB 'PFLA'
 DB 'G'+80H
 DQ DISK_ERROR9      ;LATESTのアドレス
PFLAG:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE

;; 
;; INTERNAL_PROCESSING   WORDワードにおいて初期化時や内部処理時は１で、端末キーボードから入力バッファ上に転送された文字列の処理時は０となる。
;INTR_PROC9:
; DB 80H+19
; DB 'INTERNAL_PROCESSIN'
; DB 'G'+80H
; DQ PFLAG9 
;INTR_PROC:
; DQ DOVAR  ; VARIABLE
; DQ 0      ; the data of STATE


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



;
USE_KCOMP_WORD9:    ; プリンターフラグ　0の時は接続されていない
 DB 8EH
 DB 'USE_KCOMP_WOR'
 DB 'D'+80H
 DQ TRACE_SET9      ;LATESTのアドレス
USE_KCOMP_WORD:
 DQ DOVAR  ; VARIABLE
 DQ 1      ; the data of STATE

;
_OFFSET9:    ; プリンターフラグ　0の時は接続されていない
 DB 86H
 DB 'OFFSE'
 DB 'T'+80H
 DQ USE_KCOMP_WORD9      ;LATESTのアドレス
_OFFSET:
 DQ DOVAR  ; VARIABLE
 DQ 0      ; the data of STATE





;;
;HLD9:
; DB 83H
; DB 'HL'
; DB 'D'+80H
; DQ IGTMSGSCR9      ; #MSGSCR  LATESTのアドレス
;HLD:
; DQ DOCON  ; CONSTANT
; DQ 24*8      ; the data of STATE
;

;;
;IMMEDIATE9:
; DB 89H
; DB 'IMMEDIAT'
; DB 'E'+80H
; DQ IGTMSGSCR9      ;LATESTのアドレス
;IMMEDIATE:
; DQ DOCON  ; CONSTANT
; DQ 24*8      ; the data of STATE
;









; ******FREE AREA*************
;
;FREE_AREA_START:
;  QWORD 4000 DUP (?)
;FREE_AREA_END:
;  QWORD 1    DUP (?)



  QWORD 400 DUP (09AH)  ; こちらにも念のため空間を開けた

FREE_AREA_START:
  BYTE  "FREE_AREA_START"
  QWORD 4000 DUP (0ABH)

INITR0:;本当にいいんだろうか？
  BYTE  "INTR0_AREA_START"
   QWORD 800 DUP (0BCH)
INITS0:
;   QWORD 1 DUP (?)
;  BYTE  "INTS0_AREA_START"
;  BYTE   7,"FORTH ",0
  BYTE   500 DUP (0H)






;UP:
;   QWORD 60 DUP (?)
SYS_FIRST:
  BYTE 404H DUP (01)  ;  BYTE  BFLEN DUP (?)
  BYTE 404H DUP (02)  ;  BYTE  BFLEN DUP (?)

; ******LIMIT DATA AREA*******

SYS_LIMIT:





; 初期化しないデータのセグメント
; DWORD は DD（Define DWORD の意）という書き方もあり。
.data?
;SCANVAL         DWORD   ?
;MSGBUF          BYTE    MSGBUFLEN dup (?)


TEST2 DWORD ?

STACK_AREA      QWORD   100 dup (?)
STACK_TOP       QWORD   ?

RBP_STACK_TOP       QWORD   ?
RBP_STACK_AREA      QWORD   100 dup (?)

SEE_THIS_WORD_STACK_TOP   QWORD   ?
SEE_THIS_WORD_STACK_AREA  QWORD  100 dup (?)
SEE_THIS_WORD_ptr         QWORD   ?





.code

TestProc proc



; ORIG: NOP


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


;
; ORG LIMIT+8
;
; NOP


; ****FORTH_INNER_INTERPRETER****

NEXT1:
    mov [save_r8],R8  ; display Regs.
    mov [save_r9],R9  ; display Regs.

;       lea r8,SEE_THIS_WORD
       mov r8,[rsi]
;       mov [SEE_THIS_WORD],r8
       mov r9,[SEE_THIS_WORD_ptr]
       mov [r9],r8

    mov R9,[save_r9]  ; display Regs.
    mov R8,[save_r8]  ; display Regs.

    JMP NEXT1_9


DPUSH: PUSH RDX
APUSH: PUSH RAX
NEXT:
    mov [save_r8],R8  ; display Regs.
    mov [save_r9],R9  ; display Regs.

;       lea r8,SEE_THIS_WORD
       mov r8,[rsi]
;       mov [SEE_THIS_WORD],r8
       mov r9,[SEE_THIS_WORD_ptr]
       mov [r9],r8

    mov R9,[save_r9]  ; display Regs.
    mov R8,[save_r8]  ; display Regs.

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

;    ;------ スタックの確保と整列
;    sub     rsp, 28h
;
;    ;------ myFunc();
;    ;       ここに直接処理を書いてもよいが、
;    ;       内部 (PRIVATE) 関数の呼び出しにしてみる。
;    call    myFunc
;
;    ;------ 戻り値の設定
;    mov     eax, 200
;
;    ;------ スタックの解放
;    add     rsp, 28h
;    ret


;  TRACE_SETの内容が０だったら何もしない。スキップする。
    mov [save_r8],R8  ; display Regs.
 MOV R8,[TRACE_SET+8]
 MOV R8,[R8]
 OR R8,R8
    mov R8,[save_r8]  ; display Regs.

 JZ FORTH_INNER_INTERPRETER_SKIP01

       call myFunc
       call myFunc2

;; 変数TIBが書き変わったらnopに進む（そこにブレイクポイントを設定すること）。
; mov [save_reg_ADR_TIB],rax
; mov rax,[ADR_TIB]
; mov rax,[rax]
; cmp rax,[check_dat_ADR_TIB]
; jz check_dat_2
; nop
;check_dat_2: 
; mov rax,[save_reg_ADR_TIB]
;
;; WORK_BREAK_POINT_RAX
; LEA RAX,WORK_BREAK_POINT_RAX
; MOV RAX,[WORK_BREAK_POINT_RAX]
; MOV RAX,[WORK_BREAK_POINT_RBX]


FORTH_INNER_INTERPRETER_SKIP01:

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
 DQ TRACE_SET
 DQ STORE64  ; !64
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
 DQ TRACE_SET
 DQ STORE64  ; !64
 DQ SEMIS



 
; BYE
; このシステムを抜けてＯＳに制御を移す。
_BYE9:
 DB 83H
 DB 'BY'
 DB 'E'+80H
 DQ TRACE_OFF9
_BYE:
; DQ CCLOSE     <--ここにワードをそのまま挿入してはいけない！これができるのはDOCOLだけ！
 DQ _BYE_2
_BYE_2:

 call call_C_bye
 


;    xchg rax,rsp
;    mov rax,[RET_call_C_entry_save_rsp+8]
;    xchg rax,rsp
;
;    mov rcx,[RET_call_C_entry_save_rcx]
;    mov rax,567h
;    mov [rcx],rax
;    mov rcx,RET_call_C_entry_save_rcx
;    mov [call_C_entry_save_rcx],rcx
;
;    ret





 
; CR   
_CR9:
 DB 82H
 DB 'C'
 DB 'R'+80H
 DQ _BYE9
_CR:
; DQ $+8
; DQ _CR_2
;_CR_2:
; LODSQ
;
; NOP
;
; mov r11,64+32+16+8+4+2+1         ; display RAX reg.
; lea r10,WORD_NAME_BREAK_POINT
; call dumpReg

 DQ DOCOL
; DQ   KDTDQ   ; (.")
; DB   2,0dh,0ah
 DQ _LIT, 0DH
 DQ COUT
 DQ _LIT, 0AH
 DQ COUT
 DQ SEMIS

 
;; <   ( n1 n2 --- f )
;SMR9:
; DB 81H
; DB '<'+80H
; DQ _CR9
;SMR:
; DQ SMR_2
;SMR_2:
; POP RAX      ; pop n2
; POP RBX      ; pop n1
; SUB RBX,RAX  ; RBX = RBX - RAX ( set Flags )
; XOR RAX,RAX  ; RAX = 0
; JGE SMR_JGE  ; jmp RBX >= RAX
; DEC RAX      ;  RAX -= 1
;SMR_JGE:
; JMP APUSH


; 0.0   -> _0and0
_0and09:
 DB 83H
 DB '0.'
 DB '0'+80H
; DQ 0 ; end of dictionary
 DQ _CR9
_0and0:
; DQ $+8
 DQ _0and0_2
_0and0_2:

 xor rax,rax
 push rax
 push rax


 JMP NEXT

; 
; BREAK_POINT
BREAK_POINT9:
 DB 8BH
 DB 'BREAK_POIN'
 DB 'T'+80H
; DQ 0 ; end of dictionary
 DQ _0and09
BREAK_POINT:
 DQ BREAK_POINT_2
BREAK_POINT_2:



;  ここ、何をやっているのかわからなくなってきた。この外部レジスタは退避用？→修正済み

; １）RAX,RBXの退避
 mov  [buf_WORK_BREAK_POINT_RAX],rax
 mov  [buf_WORK_BREAK_POINT_RBX],rbx

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

; ５）RAX,RBXの復帰
 mov  rbx,[buf_WORK_BREAK_POINT_RBX]
 mov  rax,[buf_WORK_BREAK_POINT_RAX]

; ６）４）で判断して、TRACE_SETの内容が０だったら次の７）をスキップする
 JZ BREAK_POINT_SKIP01


; ７）画面に表示されるレジスタの種類を設定、表示する。
;
 mov r11,4+2+1         ; display RAX reg.
; lea r10,WORD_NAME_BREAK_POINT
 call dumpParam


; ８）終了する（次へジャンプする）
BREAK_POINT_SKIP01:

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







;FIND:
; DQ DOCOL
;
; DQ BREAK_POINT
; DQ 5
;
; DQ _BL     ; blank code (20h)
; DQ _WORD   ; ( c --- a ) c:区切り文字コード, a:文字数（１バイト）と入力文字列
;
; DQ BREAK_POINT
; DQ 8
;
; DQ CONTEXT ; WORD名の探索を行うためのボキャブラリーを示すシステム変数。初期値はFORTH+4
; DQ ATT64  ; "@" FETCH
; DQ ATT64  ; "@" FETCH　これでFORTHボキャブラリーの最初のWORDを指し示す。
;
; DQ BREAK_POINT
; DQ 9
;
; DQ KFIND
;
; DQ BREAK_POINT
; DQ 6
;







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

 mov r11,2+1         ; display  Regs. RAX,RBX
 lea r10,WORD_NAME_LIT
 call dumpReg

   mov [EXECUTE_SEE_THIS_WORD],rbx
   lea r10,EXECUTE_SEE_THIS_WORD
;   mov [EXECUTE_SEE_THIS_WORD_ptr],r10
;   lea r10,[EXECUTE_SEE_THIS_WORD_ptr]
   mov [SEE_THIS_WORD_ptr],r10
   call myFunc





;;  TRACE_SETの内容が０だったら何もしない。スキップする。
;    mov [save_r8],R8  ; display Regs.
; MOV R8,[TRACE_SET+8]
; MOV R8,[R8]
; OR R8,R8
;    mov R8,[save_r8]  ; display Regs.
;
; JZ FORTH_INNER_INTERPRETER_SKIP02
;
;       call myFunc
;       call myFunc2
;
;
;FORTH_INNER_INTERPRETER_SKIP02:
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
 lea r10,WORD_NAME_LIT
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

; SP!
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
SEMIS9:
 DB 82H
 DB ';'
 DB 'S'+80H
 DQ RPST09
SEMIS:
; DQ $+8
 DQ SEMIS_2

SEMIS_3:
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

; -
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

; D-
DSUB9:
 DB 82H
 DB 'D'
 DB '-'+80H
 DQ DPLUS9
DSUB:
; DQ $+8
 DQ DSUB_2
DSUB_2:
 POP RBX
 POP RCX
 POP RAX
 POP RDX
 SUB RDX,RCX
 SBB RAX,RBX
 JMP DPUSH

; OVER
OVER9:
 DB 84H
 DB 'OVE'
 DB 'R'+80H
 DQ DSUB9
OVER:
; DQ $+8
 DQ OVER_2
OVER_2:
 POP RDX
 POP RAX
 PUSH RAX
 JMP DPUSH

; DROP
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

; @64
ATT64_9:
 DB 83H
 DB '@6'
 DB '4'+80H
 DQ TOGGL9
ATT64:
; DQ $+8
 DQ ATT64_2
ATT64_2:
 POP RBX
; XOR RAX,RAX
; ??これでいいのだろうか？
 MOV RAX,[RBX]  ; ここは悩むところ

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_@64
 call dumpReg

 JMP APUSH

; !64
STORE64_9:
 DB 83H
 DB '!6'
 DB '4'+80H
 DQ ATT64_9
STORE64:
; DQ $+8
 DQ STORE64_2
STORE64_2:
 POP RBX
 POP RAX
 MOV [RBX],RAX
 JMP NEXT


; @32
ATT32_9:
 DB 83H
 DB '@3'
 DB '2'+80H
 DQ STORE64_9
ATT32:
; DQ $+8
 DQ ATT32_2
ATT32_2:
 POP RBX
 XOR RAX,RAX
; ??これでいいのだろうか？
 MOV EAX,[RBX]  ; ここは悩むところ
 JMP APUSH

; !32
STORE32_9:
 DB 83H
 DB '!3'
 DB '2'+80H
 DQ ATT32_9
STORE32:
; DQ $+8
 DQ STORE32_2
STORE32_2:
 POP RBX
 POP RAX
 MOV [RBX],EAX
 JMP NEXT


; @
ATT9:
 DB 81H
 DB '@'+80H
 DQ STORE32_9
ATT:
; DQ $+8
 DQ ATT_2
ATT_2:
 POP RBX
 XOR RAX,RAX
; ??これでいいのだろうか？
 MOV AX,[RBX]  ; ここは悩むところ
; MOV RAX,[RBX]  ; ここは悩むところ
                ; １６ビット分のデータは＋６～７バイト目になるはず
 JMP APUSH

; !
STORE9:
 DB 81H
 DB '!'+80H
 DQ ATT9
STORE:
; DQ $+8
 DQ STORE_2
STORE_2:
 POP RBX
 POP RAX
 MOV [RBX],AX
 JMP NEXT

; C!
CSTOR9:
 DB 82H
 DB 'C'
 DB '!'+80H
 DQ STORE9
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
COLON9:
 DB 0C1H
 DB ':'+80H
 DQ CSTOR9
COLON:
 DQ DOCOL
 DQ QEXEC ; ?EXEC
 DQ SCSP    ; !CSP ; !CSP
 DQ CURRENT ; CURRENT
 DQ ATT64 ; @

; DQ BREAK_POINT
; DQ 41H

 DQ CONTEXT ; CONTEXT
 DQ STORE64 ; !
 DQ PCREAT    ; (CREATE) ; (CREATE)
 DQ RBRAC ; ]
 DQ PSCOD ; (;CODE)
DOCOL:

add [DEBUG_DUMP_LEVEL],1

add [SEE_THIS_WORD_ptr],8

; INC RDX
;  ADD RDX,1   ここも悩んだが、NEXTで処理することにした
; DEC BP
; DEC BP
 SUB RBP,8      ; RP  <-RP+8
 MOV [RBP],RSI  ; [RP]<-IP リターンスタックにPUSH
 MOV RSI,RDX    ; IP  <-RDX 次のワードのアドレスをIPに
 JMP NEXT

; CONSTANT
CON9:
 DB 88H
 DB 'CONSTAN'
 DB 'T'+80H
 DQ COLON9
CON:
 DQ DOCOL
 DQ PCREAT    ; (CREATE) ; (CREATE)
 DQ SMUDG ; SMUDGE
 DQ COMMA8 ; ,
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
VAR9:
 DB 88H
 DB 'VARIABL'
 DB 'E'+80H
 DQ CON9
VAR:
 DQ DOCOL
; DQ ZERO ; 0
 DQ _0
 DQ CON ; CONSTANT
 DQ PSCOD ; (;CODE)
DOVAR::
;;; INC RDX
;;; ADD RDX,1
 PUSH RDX

 mov r11,1         ; display RAX reg.
 lea r10,WORD_NAME_DOVAR
 call dumpReg

 JMP NEXT

; 2CONSTANT
TCON9:
 DB 89H
 DB '2CONSTAN'
 DB 'T'+80H
 DQ VAR9
TCON:
 DQ DOCOL
 DQ CON ; CONSTANT
 DQ COMMA8 ; ,
 DQ PSCOD ; (;CODE)
; INC RDX
; ADD RDX,1
 MOV RBX,RDX
 MOV RAX,[RBX]
 MOV RDX,[RBX+8]
 JMP DPUSH

; 2VARIABLE
TVAR9:
 DB 89H
 DB '2VARIABL'
 DB 'E'+80H
 DQ TCON9
TVAR:
 DQ DOCOL
 DQ VAR ; VARIABLE
; DQ ZERO ; 0
 DQ _0
 DQ COMMA8 ; ,
;; テキストでのＢＵＧと思われる。１行追加。
 DQ PSCOD ; (;CODE)

; INC RDX
; ADD RDX,1
 PUSH RDX
 JMP NEXT

; USER
USER9:
 DB 84H
 DB 'USE'
 DB 'R'+80H
 DQ TVAR9
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
DOES9:
 DB 0C5H
 DB 'DOES'
 DB '>'+80H
 DQ USER9
DOES:
 DQ DOCOL
 DQ COMP,PSCOD       ; COMPILE (;CODE)
;; DQ COMP
;; DB 7,'(;CODE)'
 DQ _LIT,0E9H        ; jump code  JMP near
; DQ _LIT,0FFH        ; これどうもおかしいようだ？？jump code 「20240606_1632_JMP命令のコードはFFとなることに注意！」
 DQ CCOMM            ; C,
 DQ _LIT,XDOES-2     ; ADDRESS OF xdoes-2
 DQ HERE,SUBB,COMMA8 ; HERE - ,
 DQ SEMIS
XDOES: XCHG RBP,RSP  ; リターンスタックとパラメータスタックを入れ替える
 PUSH RSI            ; リターンスタックに次のWORDのアドレスをPUSHしている。
 XCHG RBP,RSP
 MOV RSI,[RBX]       ; 今処理しようとしているRSIが示すアドレスの内容をRSIに移動。
; ADD RSI,3H
;ここの３hは1WORD+1Byteの値です。
; MASM64bitでは1QWORD+1Byteつまり8+1となります。
 ADD RDX,9  ; アドレス１個分をスキップした
 PUSH RDX
 JMP NEXT

; FILL
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
; MOV BX,DS
; MOV ES,BX
 CLD
 REP STOSB  ; ＲＣＸ回バイトのコピー（転送）を行う？
 JMP NEXT

; CREATE
CREAT9:
 DB 86H
 DB 'CREAT'
 DB 'E'+80H
 DQ _FILL9
CREAT:
 DQ DOCOL
 DQ PCREAT ; (CREATE)
 DQ SMUDG ; SMUDGE
 DQ PSCOD ; (;CODE)
; INC RDX
; ADD RDX,1
 PUSH RDX
 JMP NEXT

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
 DQ CREAT9
WARM:
 DQ DOCOL
 DQ EMPBUF ; EMPTY-BUFFERS
 DQ ABORT ; ABORT


;
;アセンブラの違い　　　　[アセンブラ][ＭＡＳＭ][ＮＡＳＭ]
;https://yang2005.hatenadiary.org/entry/20050530/1119019733
;
;PTR   :MOV AL,byte ptr [200h]
;OFFSET;アドレスを代入する場合、MASMでは
;　　　　MOV AX,offset MSG
;

; COLD STATE VECTOR COMES HERE

CLD9:

; MOV RBP,ORIG
; MOV R8,0FFFFFFFFFH
; MOV R8W,4
; XOR R10,R10
; MOV R10W,R8W
; MOV R8,R10
; MOV AX,[RBP+R8]


; MOV EAX,CS
; MOV DS,EAX
; MOV ES,EAX
; MOV SS,EAX
 CLD                 ; Clears the DF flag in the EFLAGS register. 
; MOV R8,ORIG
; MOV R8,STACK_AREA
; MOV R8,STACK_AREA+800

;; SET TRACE SETTING PARAM from CPP

 mov r8,[rcx + 16]  ; r8: Display Trace WORD name  0:OFF else:ON
 lea r9,TRACE_SET   ; r9: Address of the first parameter of WORD “TRACE_SET (variable)”
 mov [r9 + 8],r8    ;     WORD「TRACE_SET（変数）」の第１パラメータのアドレス
 




 MOV RSI,OFFSET CLD1 ; SET UP IP
 ; RSIはOFFSET
  ; MOV ESP,WORD PTR ORIG+10H ; SET UP SP
  ; MOV EBP,WORD PTR ORIG+12H ; SET UP RP
 MOV RSP,QWORD PTR ADR_S0 ; SET UP SP
   sub     rsp, 28h
; RSPはアドレス
 MOV RBP,QWORD PTR ADR_R0 ; SET UP RP
; RBPはアドレス

; 追加処理
;clear the top of string buffer 
; mov [save_reg_ADR_TIB],rax
; mov [check_dat_ADR_TIB],0
; mov rax,[save_reg_ADR_TIB]

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

; COUTのテスト→成功
; DQ _LIT, 43H
; DQ COUT

;; CINのテスト
; DQ CIN
; DQ CIN
; DQ _BYE
;;


; DQ BREAK_POINT
; DQ 42H
;

 DQ CTST     ; ここでエラーが発生する。FOPENできない。20240607

 DQ _LIT,1
 DQ PFLAG
 DQ STORE64

;; DQ _LIT,044H
;; DQ F_COUT
;; DQ _LIT,044H
;; DQ F_COUT
;; DQ _LIT,044H
;; DQ F_COUT
;; DQ _LIT,044H
;; DQ F_COUT
;;; DQ EMIT
;; DQ CCLOSE
;; DQ _BYE
;
;;; これはCで書かないといけないのでは？まだ考えなくてはならないことがある。フラグを自由に切り替えても問題が起こらないこと。


 DQ CONTEXT
 DQ ATT64
 DQ ATT64


 DQ TRACE_ON

;; DQ _1
;; DQ INTR_PROC  ; ; INTERNAL_PROCESSING   ( --- a ) DOVAR  WORDワードにおいて初期化時や内部処理時は１で、端末キーボードから入力バッファ上に転送された文字列の処理時は０となる。
;; DQ STORE64

 DQ _LIT
 DQ UVR ; set user variables
; DQ _LIT, UP,ATT64
 DQ UP
; DQ _LIT,50H
 DQ _LIT,200      ; UPからの変数の個数２５個✖８Byte=200
 DQ _CMOVE
 DQ EMPBUF ; EMPTY-BUFFERS
 DQ ABORT ; ABORT

; KEY
KEY9:
 DB 83H
 DB 'KE'
 DB 'Y'+80H
 DQ COLD9
KEY:
 DQ DOCOL

 DQ BREAK_POINT
 DQ 50H


 DQ CIN
 DQ SEMIS

; ?TERMINAL
QTERM9:
 DB 89H
 DB '?TERMINA'
 DB 'L'+80H
 DQ KEY9
QTERM:
 DQ DOCOL
 DQ CTST
 DQ SEMIS

; EMIT    ( 0 --- )
                    ; TOSにある文字コードを出力印字する。
EMIT9:
 DB 84H
 DB 'EMI'
 DB 'T'+80H
 DQ QTERM9
EMIT:
 DQ DOCOL
 DQ DUPE ; DUP
;
 DQ BREAK_POINT
 DQ 22H
;
 DQ COUT
 DQ PFLAG ; print flagが０ならばプリンターに出力しない。
 DQ ATT64 ; @
 DQ ZBRAN ; IF
EMIT_AFT_IF:
;; DQ EMIT1
 DQ EMIT_AFT_ELSE +8- EMIT_AFT_IF
 DQ POUT
 DQ BRAN ; _ELSE
EMIT_AFT_ELSE:
;; DQ EMIT2
;;EMIT1:
 DQ EMIT_AFT_THEN-EMIT_AFT_ELSE
 DQ DROP ; DROP
;;EMIT2:
EMIT_AFT_THEN:
 DQ SEMIS ; THEN

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


;    sub     rsp, 28h


;fopen_sの参考書式
;errno_t fopen_s(
;   FILE** pFile,            -> lea     rcx,ptr_fb_File
;   const char *filename,    -> lea     rdx,FILE_NAME
;   const char *mode         -> lea     r8,key_w_plus
;);
; 返り値：オープンしたストリームを制御するオブジェクトへのポインタを返す。オープン操作が失敗したとき、空ポインタを返す。

;
;; mov     [RegSata_rcx],rcx
;
; lea     r8,key_w_plus
; lea     rdx,FILE_NAME
; lea     rcx,ptr_fb_File
; call    fopen_s            ; 返り値(RAX)：０で成功、それ以外はエラーコード
; 
;; mov rcx,[rcx]
; mov [ptr_fb_File],rax
;
; MOV     RAX,[RAX]
; cmp     rax,0
; jz      CTST_FALSE
; mov     rax,1
;CTST_FALSE:
;
;    add     rsp, 28h
;
; JMP APUSH

 mov rdx,4          ; 4:F_OPEN
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx],rax
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ; output - rax:Output value  (not used)

 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov RAX,[rcx+ 0]
 


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
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value (not used)
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ; output - rax:Output value

 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov RAX,[rcx+ 0]
 


 JMP APUSH

;COUT
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
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx],rax
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ; output - rax:Output value  (not used)

 JMP NEXT


;F_COUT
; 
F_COUT9:
 DB 86H
 DB 'F_COU'
 DB 'T'+80H
 DQ COUT9
F_COUT:
; DQ $+8
 DQ F_COUT_2
F_COUT_2:
; POP RDX
; MOV AH,2
; INT 21H

 pop rax

; call put_char

; mov rax,123h
 mov rdx,3          ; 3:F_COUT
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx],rax
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ; output - rax:Output value  (not used)

 JMP NEXT

 
; CCLOSE
; 
CCLOSE9:
 DB 86H
 DB 'CCLOS'
 DB 'E'+80H
 DQ F_COUT9
CCLOSE:
; DQ $+8
 DQ CCLOSE_2
CCLOSE_2:
; call get_char

; mov     rcx,[ptr_fb_File]
; call    fclose
;; 返り値：ストリームのクローズに成功したときは0を返し、何らかのエラーを検出したときEOFを返す。
; JMP NEXT


 mov rdx,5          ; 5:F_CLOSE
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx],rax
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ; output - rax:Output value  (not used)

 JMP NEXT



; POUT
POUT9:
 DB 84H
 DB 'POU'
 DB 'T'+80H
 DQ CCLOSE9
POUT:
; DQ $+8
 DQ POUT_2
POUT_2:
; POP RDX
; MOV AH,5
; INT 21H

;; pop     r8
; lea     r8,SCANPROMPT_03
; lea     rdx,SCANPROMPT_03f
; mov     rcx,[ptr_fb_File]
; call    fprintf_s          ; 返り値(RAX)：表示する文字数
;; 


 pop rax

; call put_char

; mov rax,123h
 mov rdx,3          ; 3:F_COUT
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx],rax
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

 call call_C_entry
   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
   ; output - rax:Output value  (not used)

 JMP NEXT




; READ
READ9:
 DB 84H
 DB 'REA'
 DB 'D'+80H
 DQ POUT9
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


















; ENCLOSE
;
;
;＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
;
; 実験のためにINITS0:にテスト用の文字列「 BYTE   7,"FORTH ",0 」 を設定している。-->ユーザーが入力した文字列として認識するだろうか？
;
;;FREE_AREA_START:
;;  BYTE  "FREE_AREA_START"
;;  QWORD 4000 DUP (?)
;;
;;INITR0:;本当にいいんだろうか？
;;  BYTE  "INTR0_AREA_START"
;;   QWORD 800 DUP (?)
;;INITS0:
;;  BYTE   7,"FORTH ",0
;;  BYTE   100 DUP (0)
;
;
;
;
;１）まず最初に与える文字列として、08 20 46 4f 52 54 48 20 00 を与えてみた。
;１ー１）BREAK_POINT 16 （ENCLOSEを実行する前のrspの指し示すアドレス
;
;0x00007FF6A38A3B9C  20 00 00 00 00 00 00 00 ac 3b 8a a3 f6 7f 00 00 08 20 46 4f 52 54 48 20 00 00 00 00 00 00 00 00   .......ｬ;・｣・.... FORTH ........
;
;TOP OF STACK:20 00 00 00 00 00 00 00
;STACK 2     :ac 3b 8a a3 f6 7f 00 00
;  ->08 20 46 4f 52 54 48 20 00 00 (. FORTH ..)
;
;
;１－２）BREAK_POINT 17 （ENCLOSEを実行した後のrspの指し示すアドレス
;0x00007FF6A38A3B8C  02 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ac 3b 8a a3 f6 7f 00 00  ........................ｬ;・｣・...
;0x00007FF6A38A3BAC  08 20 46 4f 52 54 48 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  . FORTH ........................
;
;TOP OF STACK:02 00 00 00 00 00 00 00
;STACK 2     :01 00 00 00 00 00 00 00
;STACK 3     :00 00 00 00 00 00 00 00
;STACK 4     :ac 3b 8a a3 f6 7f 00 00
;この後は文字列テーブル:08 20 46 4f 52 54 48 20
;
;なんで、STACK 3は０なんだろう？→スタックの並びは上から下だから。
;  TOP OF STACK -> n3  最初から２番目のデリミターキャラクタのオフセット
;  STACK 2      -> n2  最初のデリミターキャラクタのオフセット（最初が空白だったので１番目となった）
;  STACK 3      -> n1  最初のデリミターでないキャラクタのオフセット（最初が空白だったので０番目となった）
;  STACK 4      -> a   文字列の先頭アドレス
;
;
;
;
;２）次に与える文字列として、07 46 4f 52 54 48 20 00 を与えてみた。
;
;２ー１）BREAK_POINT 16 （ENCLOSEを実行する前のrspの指し示すアドレス
;
;0x00007FF7BA0B3B9C  20 00 00 00 00 00 00 00 ac 3b 0b ba f7 7f 00 00 07 46 4f 52 54 48 20 00 00 00 00 00 00 00 00 00   .......ｬ;.ｺ・....FORTH .........
;
;
;２－２）BREAK_POINT 17 （ENCLOSEを実行した後のrspの指し示すアドレス
;
;0x00007FF7BA0B3B8C  07 00 00 00 00 00 00 00 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ac 3b 0b ba f7 7f 00 00  ........................ｬ;.ｺ・...
;0x00007FF7BA0B3BAC  07 46 4f 52 54 48 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  .FORTH .........................
;
;TOP OF STACK:07 00 00 00 00 00 00 00
;STACK 2     :06 00 00 00 00 00 00 00
;STACK 3     :00 00 00 00 00 00 00 00
;STACK 4     :ac 3b 0b ba f7 7f 00 00
;  00007FF7BA0B3BAC-> 07 46 4f 52 54 48 20 00
;この後は文字列テーブル:07 46 4f 52 54 48 20 00
;
;
;
;

ENCLOSE9:
 DB 87H
 DB 'ENCLOS'
 DB 'E'+80H
 DQ WRITE9
ENCLOSE:
 DQ DOCOL
;
 DQ BREAK_POINT
 DQ 1
;
 DQ OVER
 DQ DUPE
 DQ TOR    ; >R

; DQ BEGIN
ENCLOSE_1_AFT_BEGIN:
 DQ _2DUP
 DQ CFETCH    ; C@
 DQ _EQ
 DQ OVER
 DQ CFETCH    ; C@
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _NOT
 DQ ANDD
; DQ _WHILE
 DQ ZBRAN
ENCLOSE_1_AFT_WHILE:
 DQ ENCLOSE_1_AFT_REPEAT +8- ENCLOSE_1_AFT_WHILE
 DQ _1PL
; DQ _REPEAT
 DQ BRAN
ENCLOSE_1_AFT_REPEAT:
 DQ ENCLOSE_1_AFT_BEGIN - ENCLOSE_1_AFT_REPEAT


 DQ DUPE
 DQ TOR    ; >R
 DQ _1PL

; DQ BEGIN
ENCLOSE_2_AFT_BEGIN:
 DQ _2DUP
 DQ CFETCH    ; C@
 DQ NTEQ    ; <>
 DQ OVER
 DQ CFETCH    ; C@
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _NOT
 DQ ANDD
; DQ _WHILE
 DQ ZBRAN
ENCLOSE_2_AFT_WHILE:
 DQ ENCLOSE_2_AFT_REPEAT +8- ENCLOSE_2_AFT_WHILE
 DQ _1PL
; DQ _REPEAT
 DQ BRAN
ENCLOSE_2_AFT_REPEAT:
 DQ ENCLOSE_2_AFT_BEGIN - ENCLOSE_2_AFT_REPEAT

 DQ SWAP
 DQ DROP
 DQ FROMR    ; R>

 DQ RAT  ; R@
 DQ SUBB
 DQ SWAP
 DQ FROMR    ; R>
 DQ SUBB
 DQ DUPE
 DQ _1PL
 DQ SEMIS

; (FIND)  ( a1 a2 --- a / ff ;
; a1:top address of text string to be tested for matching
; a2:name field address at which dictionary seaching is started
; a :compilation address of the word found
; ff:unfound, false flag )
KFIND9:
 DB 86H
 DB '(FIND'
 DB ')'+80H
 DQ ENCLOSE9
KFIND:
 DQ DOCOL        ;     ( a1 a2 )

 DQ BREAK_POINT
 DQ 220H


; DQ BEGIN
KFIND_4_AFT_BEGIN:

 DQ OVER    ;       ( a1 a2 a1 )

 DQ _2DUP     ;       ( a1 a2 a1 a2 a1 )
 DQ CFETCH    ; C@    ( a1 a2 a1 a2 n1 ) n1はa1検索する見本データ列の文字数を示す
 DQ SWAP      ;       ( a1 a2 a1 n1 a2 )
 DQ CFETCH    ; C@    ( a1 a2 a1 n1 n2 ) n2はa2検索するツリーから拾ったデータ文字列の文字数を示す
 DQ _LIT,3FH  ;       ( a1 a2 a1 n1 n2 3FH ) 3FHはn2から文字数だけを抽出するマスク
 DQ ANDD      ;       ( a1 a2 a1 n1 n2の文字数 )
 DQ _EQ       ; n1＝＝n2の文字数　であれば１、それ以外は０

 DQ   ZBRAN   ; 条件分岐（等しくなかったら分岐する）
KFIND_1_AFT_IF:
 DQ   KFIND_1_AFT_ELSE+8-KFIND_1_AFT_IF
; DQ   BEGIN  ; BEGIN - AGAIN のループの開始点
KFIND_5_AFT_BEGIN:
 DQ   _1PL     ;       ( a1 a2+1 )
 DQ   SWAP     ;       ( a2+1 a1 )
 DQ   _1PL     ;       ( a2+1 a1+1 )
 DQ   SWAP     ;       ( a1+1 a2+1 )
 DQ   _2DUP    ;       ( a1+1 a2+1 a1+1 a2+1 )
 DQ   CFETCH    ; C@   ( a1+1 a2+1 a1+1 n_a2+1 )
 DQ   SWAP
 DQ   CFETCH    ; C@   ( a1+1 a2+1 n_(a2+1) n_(a1+1) )
 DQ   NTEQ    ; <>    n_(a2+1) ＜＞ n_(a1+1) 等しくないなら１、それ以外は０
; DQ   UNTIL
 DQ   ZBRAN   ; 条件分岐。つまり、n_(a2+1) ＜＞ n_(a1+1) が成り立てば１（次行のワードへ）、それ以外は０（BEGINへジャンプ）
KFIND_5_AFT_UNTIL:
 DQ   KFIND_5_AFT_BEGIN -KFIND_5_AFT_UNTIL


 DQ     CFETCH    ; C@      ( a1+m a2+m n_(a2+m) )     → 検索した文字列の合わなかった最後の１文字
 DQ     OVER      ;         ( a1+m a2+m n_(a2+m) a2+m )
 DQ     CFETCH    ; C@      ( a1+m a2+m n_(a2+m) n_(a2+m) )
 DQ     _LIT,7FH  ;         ( a1+m a2+m n_(a2+m) n_(a2+m) 7FH )　→辞書の文字列の最後の１バイトはBit7が１なので、それをクリアする
 DQ     ANDD      ;         ( a1+m a2+m n_(a2+m) n_(a2+m)_AND_7FH )
 DQ     _EQ       ; n_(a2+m)＝＝n_(a2+m)_AND_7FH の文字数同士を比較して、等しければ１、それ以外は０

 DQ     ZBRAN     ; 条件分岐（等しくなかったら分岐する）
KFIND_2_AFT_IF:
 DQ     KFIND_2_AFT_THEN - KFIND_2_AFT_IF
 DQ     SWAP      ;         ( a2+m a1+m )
 DQ     DROP      ;         ( a2+m )
; DQ     _3       ; 一つ下のリンクフィールド、さらに下のコンピレーションフィールドのアドレスをスタックに置く
 DQ     _LIT,8+1  ; これにより、(FIND)の処理が終わると目的のWORDのコンピレーションアドレスがプッシュされていることになる
 DQ     PLUS      ;
; DQ     EXIT
KFIND_7_AFT_EXIT:
 DQ BREAK_POINT
 DQ 222H
 DQ SEMIS


KFIND_2_AFT_THEN:
; DQ THEN
 DQ     _1MN       ; (TOS) = (TOS)-1

; DQ   _ELSE
 DQ   BRAN
KFIND_1_AFT_ELSE:
 DQ   KFIND_1_AFT_THEN-KFIND_1_AFT_ELSE

                   ;       ( a1 a2 )
 DQ   DROP         ;       ( a1 )

KFIND_1_AFT_THEN:
; DQ   THEN
; DQ   BEGIN
KFIND_6_AFT_BEGIN:

 DQ   _1PL         ;       ( a1+m )
 DQ   DUPE         ;       ( a1+m a1+m )



 DQ   CFETCH    ; C@       ( a1+m n_(a1+m) )
 DQ   _LIT,80H    ;        ( a1+m n_(a1+m) 80H)
 DQ   ANDD        ;        ( a1+m n_(a1+m)_AND_80H)

; バグかと思い、ここに1行挿入した。が、パラメータは1個だった。誤り。
; DQ     _EQ

; DQ   UNTIL
 DQ   ZBRAN         ;      n_(a1+m)_AND_80Hが00HならBEGINへ戻る。それ以外（80H）は次のWORDへ進む
KFIND_6_AFT_UNTIL:
 DQ   KFIND_6_AFT_BEGIN - KFIND_6_AFT_UNTIL
 
 DQ   _1PL         ;       ( a1+m+1 ) つまり、ひとつ前のWORDを示すリンクフィールドのアドレス
 DQ   ATT64  ; "@" FETCH   ( n_(a1+m+1) ) それが指し示すワードのネームフィールドの先頭アドレス
 DQ   DUPE         ;       ( n_(a1+m+1) n_(a1+m+1) )
 DQ   ZEQU  ; "0=" ０なら1、それ以外は０

 DQ     ZBRAN      ;       ( n_(a1+m+1) f )
KFIND_3_AFT_IF:
 DQ     KFIND_3_AFT_THEN - KFIND_3_AFT_IF
 DQ     _2DROP     ; 一つ多めにDROPしている。戻り番地？
 DQ     _0         ; 一つ多めのところを０に書き換えた
; DQ     EXIT      ; 脱出
KFIND_8_AFT_EXIT:
 DQ SEMIS
 

; DQ     THEN
KFIND_3_AFT_THEN:

; BREAK_POINT
; DQ BREAK_POINT
; DQ 3

; DQ AGAIN     ; 無限ループでジャンプ
 DQ BRAN
KFIND_4_AFT_AGAIN:
 DQ KFIND_4_AFT_BEGIN - KFIND_4_AFT_AGAIN


; DIGIT
DIGIT9:
 DB 85H
 DB 'DIGI'
 DB 'T'+80H
 DQ KFIND9
DIGIT:
 DQ DOCOL
 DQ SWAP
 DQ _LIT,30H
 DQ SUBB
 DQ DUPE
 DQ ZLESS  ; 0<

 DQ ZBRAN
DIGIT_1_AFT_IF:
 DQ DIGIT_1_AFT_ELSE +8- DIGIT_1_AFT_IF
 DQ _2DROP
 DQ _0

; DQ _ELSE
 DQ BRAN
DIGIT_1_AFT_ELSE:
 DQ DIGIT_1_AFT_THEN - DIGIT_1_AFT_ELSE
 DQ DUPE
 DQ _LIT,9
 DQ BGR    ; >

 DQ   ZBRAN
DIGIT_2_AFT_IF:
 DQ   DIGIT_2_AFT_ELSE +8- DIGIT_2_AFT_IF
 DQ   _LIT,7
 DQ   SUBB
 DQ   DUPE
 DQ   _LIT,0AH
 DQ   _DIGIT    ; <

 DQ     ZBRAN
DIGIT_3_AFT_IF:
 DQ     DIGIT_3_AFT_ELSE +8- DIGIT_3_AFT_IF
 DQ     _2DROP
 DQ     _0

; DQ     _ELSE
 DQ     BRAN
DIGIT_3_AFT_ELSE:
 DQ     DIGIT_3_AFT_THEN - DIGIT_3_AFT_ELSE
 DQ     _2DUP
 DQ     BGR    ; >

 DQ       ZBRAN
DIGIT_4_AFT_IF:
 DQ       DIGIT_2_AFT_ELSE +8- DIGIT_2_AFT_IF
 DQ       SWAP
 DQ       _1
; DQ       _ELSE
 DQ       BRAN
DIGIT_4_AFT_ELSE:
 DQ       DIGIT_2_AFT_THEN - DIGIT_2_AFT_ELSE
 DQ       _2DROP
 DQ       _0
; DQ       THEN
DIGIT_4_AFT_THEN:

; DQ     THEN
DIGIT_3_AFT_THEN:

; DQ   _ELSE
 DQ   BRAN
DIGIT_2_AFT_ELSE:
 DQ   DIGIT_2_AFT_THEN - DIGIT_2_AFT_ELSE
 DQ   _2DUP
 DQ   BGR    ; >
 DQ     ZBRAN
DIGIT_5_AFT_IF:
 DQ     DIGIT_5_AFT_ELSE +8- DIGIT_5_AFT_IF
 DQ     SWAP
 DQ     DROP
 DQ     _1
; DQ     _ELSE
 DQ     BRAN
DIGIT_5_AFT_ELSE:
 DQ     DIGIT_5_AFT_THEN - DIGIT_5_AFT_ELSE
 DQ     _2DROP
 DQ     _0
; DQ     THEN
DIGIT_5_AFT_THEN:

; DQ   THEN
DIGIT_2_AFT_THEN:

; DQ THEN
DIGIT_1_AFT_THEN:

 DQ SEMIS

; NEGATE
NEGATE9:
 DB 86H
 DB 'NEGAT'
 DB 'E'+80H
 DQ DIGIT9
NEGATE:
 DQ DOCOL
 DQ _0
 DQ SWAP
 DQ SUBB
 DQ SEMIS

; DNEGATE
DNEGATE9:
 DB 87H
 DB 'DNEGAT'
 DB 'E'+80H
 DQ NEGATE9
DNEGATE:
 DQ DOCOL
 DQ TOR    ; >R
 DQ TOR    ; >R
 DQ _0and0
; 0.0をどうするか→0と0のＤだと気が付いた。→_0and0とする。
;
 DQ FROMR    ; R>
 DQ FROMR    ; R>
 DQ DSUB
 DQ SEMIS

; +!
PSTORE9:
 DB 82H
 DB '+'
 DB '!'+80H
 DQ DNEGATE9
PSTORE:
 DQ DOCOL
 DQ SWAP
 DQ OVER
 DQ ATT64  ; "@" FETCH
 DQ PLUS
 DQ SWAP
 DQ STORE64  ; !64
 DQ SEMIS

;;FILL
; DB 84H
; DB 'FIL'
; DB 'L'+80H
; DQ 371
;FILL:
; DQ DOCOL
; DQ YROT    ; <ROT
; DQ OVER
; DQ PLUS
; DQ SWAP
; DQ _DO
; DQ DUPE
; DQ I
; DQ CSTOR
; DQ LOOP
; DQ DROP
; DQ SEMIS

; ERASE
ERASE9:
 DB 85H
 DB 'ERAS'
 DB 'E'+80H
 DQ PSTORE9
ERASE:
 DQ DOCOL
 DQ _0
 DQ _FILL
 DQ SEMIS

; BLANKS
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
CFETCH9:
 DB 82H
 DB 'C'
 DB '@'+80H
 DQ YROT9
CFETCH:
; DQ DOCOL
; DQ ATT64  ; "@" FETCH
; DQ _LIT,0FFH
; DQ ANDD
; DQ SEMIS

; DQ $+8
 DQ CFETCH_2
CFETCH_2:

 POP RBX
 XOR RAX,RAX   ; これ重要！
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
 DQ CFETCH9
_CMOVE:
 DQ DOCOL
 DQ ROT
 DQ SWAP
 DQ OVER
 DQ PLUS
 DQ SWAP
 DQ XDO
_CMOVE_AFT_XDO:
 DQ I
 DQ CFETCH    ; C@
 DQ OVER
 DQ CSTOR
 DQ _1PL            ; 次のアドレスへの変化分の１
 DQ XLOOP
_CMOVE_AFT_XLOOP:
 DQ _CMOVE_AFT_XDO-_CMOVE_AFT_XLOOP  ;  -6*8            ; WORDのLOOPの定義よりアドレスのジャンプが必要。コンパイル時に<RESOLVEがその変化分の値を挿入してくれる。
                    ; XDOの次のIまで６ブロック。「Iのアドレス－現在のアドレス」なので負の値となる。
 DQ DROP
 DQ SEMIS

; <CMOVE
YCMOVE9:
 DB 86H
 DB '<CMOV'
 DB 'E'+80H
 DQ _CMOVE9
YCMOVE:
 DQ DOCOL
 DQ SWAP
 DQ OVER
 DQ PLUS
 DQ _1MN
 DQ YROT    ; <ROT
 DQ OVER
 DQ PLUS
 DQ _1MN
 DQ XDO
YCMOVE_AFT_DO:
 DQ I
 DQ CFETCH    ; C@
 DQ OVER
 DQ CSTOR
 DQ _1MN
 DQ MINS1
 DQ XPLOO    ; +LOOP
YCMOVE_AFT_PLOOP:
 DQ YCMOVE_AFT_DO - YCMOVE_AFT_PLOOP
 DQ DROP
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
_DIGIT9:
 DB 81H
 DB '<'+80H
 DQ NTEQ9
_DIGIT:
 DQ DOCOL
 DQ SUBB
 DQ ZLESS  ; 0<
 DQ SEMIS

; >
BGR9:
 DB 81H
 DB '>'+80H
 DQ _DIGIT9
BGR:
 DQ DOCOL
 DQ SWAP
 DQ _DIGIT
 DQ SEMIS

; U<
USMR9:
 DB 82H
 DB 'U'
 DB '<'+80H
 DQ BGR9
USMR:
 DQ DOCOL
 DQ _2DUP
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
MIN9:
 DB 83H
 DB 'MI'
 DB 'N'+80H
 DQ USMR9
MIN:
 DQ DOCOL
 DQ _2DUP
 DQ BGR    ; >
 DQ ZBRAN
MIN_AFT_IF:
 DQ MIN_AFT_THEN - MIN_AFT_IF
 DQ SWAP
; DQ THEN
MIN_AFT_THEN:
 DQ DROP
 DQ SEMIS

; MAX
MAX9:
 DB 83H
 DB 'MA'
 DB 'X'+80H
 DQ MIN9
MAX:
 DQ DOCOL
 DQ _2DUP
 DQ _DIGIT    ; <
 DQ ZBRAN
MAX_AFT_IF:
 DQ MAX_AFT_THEN - MAX_AFT_IF
 DQ SWAP
; DQ THEN
MAX_AFT_THEN:
 DQ DROP
 DQ SEMIS

; +-
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
 DQ NEGATE
; DQ THEN
PLMN_AFT_THEN:
 DQ SEMIS

; ABS
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
DPLMN9:
 DB 83H
 DB 'D+'
 DB '-'+80H
 DQ ABS9
DPLMN:
 DQ DOCOL
 DQ DUPE
 DQ ZLESS  ; 0<
 DQ ZBRAN
DPLMN_AFT_IF:
 DQ DPLMN_AFT_THEN - DPLMN_AFT_IF
 DQ DNEGATE
; DQ THEN
DPLMN_AFT_THEN:
 DQ SEMIS

; DABS
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

; ?DUP
QDUP9:
 DB 84H
 DB '?DU'
 DB 'P'+80H
 DQ DABS9
QDUP:
 DQ DOCOL
 DQ DUPE
 DQ ZBRAN
QDUP_AFT_IF:
 DQ QDUP_AFT_THEN - QDUP_AFT_IF
 DQ DUPE
; DQ THEN
QDUP_AFT_THEN:
 DQ SEMIS

; S->D
STOD9:
 DB 84H
 DB 'S->'
 DB 'D'+80H
 DQ QDUP9
STOD:
 DQ DOCOL
 DQ DUPE
 DQ ZLESS  ; 0<
 DQ ZBRAN
STOD_AFT_IF:
 DQ STOD_AFT_ELSE +8- STOD_AFT_IF
 DQ MINS1
; DQ _ELSE
STOD_AFT_ELSE:
 DQ STOD_AFT_THEN - STOD_AFT_ELSE
 DQ _0
; DQ THEN
STOD_AFT_THEN:
 DQ SEMIS

; M/MOD
MSSMOD9:
 DB 85H
 DB 'M/MO'
 DB 'D'+80H
 DQ STOD9
MSSMOD:
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
MSS9:
 DB 82H
 DB 'M'
 DB '/'+80H
 DQ MSSMOD9
MSS:
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
SSMOD9:
 DB 84H
 DB '/MO'
 DB 'D'+80H
 DQ MSS9    ; M/9
SSMOD:
 DQ DOCOL
 DQ TOR    ; >R
 DQ STOD    ; S->D
 DQ FROMR    ; R>
 DQ FROMR    ; R>
 DQ MSS    ; M/
 DQ SEMIS

; /
_SS9:
 DB 81H
 DB '/'+80H
 DQ SSMOD9
_SS:
 DQ DOCOL
 DQ SSMOD    ; /MOD
 DQ SWAP
 DQ DROP
 DQ SEMIS

; 2DUP
_2DUP9:
 DB 84H
 DB '2DU'
 DB 'P'+80H
 DQ _SS9
_2DUP:
 DQ DOCOL
 DQ OVER
 DQ OVER
 DQ SEMIS

; 2DROP
_2DROP9:
 DB 85H
 DB '2DRO'
 DB 'P'+80H
 DQ _2DUP9
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
 DQ ATT64  ; "@" FETCH
 DQ SWAP
; DQ _2PL
 DQ _8PL   ; set next address
 DQ ATT64  ; "@" FETCH
 DQ SEMIS

; 1+
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
 DQ _2MN9
_8ML:
 DQ DOCOL
 DQ DUPE
 DQ PLUS
 DQ DUPE
 DQ PLUS
 DQ DUPE
 DQ PLUS
 DQ SEMIS
; DQ _8ML_2
;_8ML_2:
; POP RAX
; mov rbx,8
; MUL rbx
; JMP APUSH



; HOLD      ( c --- )
HOLD9:
 DB 84H
 DB 'HOL'
 DB 'D'+80H
 DQ _2ML9
HOLD:
 DQ DOCOL
 DQ MINS1
 DQ HLD
 DQ PSTORE    ; +!
 DQ HLD

;; 一行削除。→fig-83forthで確認したら間違ってなかった。削除撤回します。
;; DQ ATT64  ; "@" FETCH
 DQ ATT64  ; "@" FETCH
 DQ CSTOR
 DQ SEMIS

; #        ( ud1 --- ud2 )
IGT9:
 DB 81H
 DB '#'+80H
 DQ HOLD9
IGT:
 DQ DOCOL
 DQ BASE
 DQ ATT64  ; "@" FETCH
 DQ MSSMOD    ; M/MOD
 DQ ROT
 DQ _LIT,9
 DQ OVER
 DQ _DIGIT    ; <
 DQ ZBRAN
IGT_AFT_IF:
 DQ IGT_AFT_THEN - IGT_AFT_IF
 DQ _LIT,7
 DQ PLUS
; DQ THEN
IGT_AFT_THEN:
 DQ _LIT,30h
 DQ PLUS
 DQ HOLD
 DQ SEMIS

; #S      ( ud --- 0 0 )
IGTS9:
 DB 82H
 DB '#'
 DB 'S'+80H
 DQ IGT9
IGTS:
 DQ DOCOL
; DQ BEGIN
IGTS_AFT_BEGIN:
 DQ  IGT    ; #
 DQ _2DUP
 DQ ORR
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
; DQ UNTIL
 DQ ZBRAN
IGTS_AFT_UNTIL:
 DQ IGTS_AFT_BEGIN - IGTS_AFT_UNTIL
 DQ SEMIS

; <#       ( --- )
UPIGT9:
 DB 82H
 DB '<'
 DB '#'+80H
 DQ IGTS9
UPIGT:
 DQ DOCOL
 DQ PAD
 DQ HLD
; DQ ATT64  ; "@" FETCH
; DQ PAD
; DQ OVER
; DQ SUBB
 DQ STORE64

 DQ SEMIS

; #>         ( d --- a n )
IGTDN9:
 DB 82H
 DB '#'
 DB '>'+80H
 DQ UPIGT9
IGTDN:
 DQ DOCOL
 DQ _2DROP
 DQ HLD
 DQ ATT64  ; "@" FETCH
 DQ PAD
 DQ OVER
 DQ SUBB
 DQ SEMIS

; SIGN       ( n ud --- ud )
SIGN9:
 DB 84H
 DB 'SIG'
 DB 'N'+80H
 DQ IGTDN9
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
 DQ CFETCH    ; C@
 DQ SEMIS

; TYPE        ( a c --- )
_TYPE9:
 DB 84H
 DB 'TYP'
 DB 'E'+80H
 DQ COUNT9
_TYPE:
 DQ DOCOL
 DQ QDUP    ; ?DUP
 DQ ZBRAN
_TYPE_AFT_IF:
 DQ _TYPE_AFT_THEN - _TYPE_AFT_IF
 DQ OVER
 DQ PLUS
 DQ SWAP
 DQ XDO
TYPE_AFT_XDO:
 DQ I
 DQ CFETCH    ; C@
 DQ EMIT
 DQ XLOOP
TYPE_AFT_XLOOP:
 DQ TYPE_AFT_XDO - TYPE_AFT_XLOOP  ;  -4*8
; DQ _ELSE
 DQ BRAN
_TYPE_AFT_ELSE:
 DQ _TYPE_AFT_THEN - _TYPE_AFT_ELSE 
 DQ DROP
; DQ THEN
_TYPE_AFT_THEN: 
 DQ SEMIS

; SPACE    ( --- )
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
 DQ QDUP    ; ?DUP
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
MNTRAILING9:
 DB 89H
 DB '-TRAILIN'
 DB 'G'+80H
 DQ SPACES9
MNTRAILING:
 DQ DOCOL
 DQ DUPE
 DQ _0
 DQ XDO
MNTRAILING_AFT_XDO:
 DQ _2DUP
 DQ PLUS
 DQ _1MN
 DQ CFETCH    ; C@
 DQ _BL
 DQ SUBB
 DQ ZBRAN
MNTRAILING_AFT_IF:
 DQ MNTRAILING_AFT_ELSE +8- MNTRAILING_AFT_IF
 DQ _LEAVE
; DQ _ELSE
 DQ BRAN
MNTRAILING_AFT_ELSE:
 DQ MNTRAILING_AFT_THEN - MNTRAILING_AFT_ELSE
 DQ _1MN
; DQ THEN
MNTRAILING_AFT_THEN:
 DQ XLOOP
MNTRAILING_AFT_XLOOP:
 DQ MNTRAILING_AFT_XDO - MNTRAILING_AFT_XLOOP  ;  -12*8
 DQ SEMIS

; (.")      ( type in-line string )
KDTDQ9:
 DB 84H
 DB '(."'
 DB ')'+80H
 DQ MNTRAILING9
KDTDQ:
 DQ DOCOL
 DQ RAT  ; R@   ( n_次の文字のワード（この場合は「文字数＋文字列」の先頭アドレス）が指し示すアドレス) < a_次のワードの先頭アドレス >
 DQ COUNT  ;    ( n_上記+1 n ) < a_次のワードの先頭アドレス >
           ; COUNT ( a_文字数のアドレス --- a_文字列の先頭アドレス n_文字数)
 DQ DUPE   ;    ( n_上記+1 n n ) < a_次のワードの先頭アドレス >
 DQ _1PL   ;    ( n_上記+1 n n+1 ) < a_次のワードの先頭アドレス >
 DQ FROMR    ; R>   ( n_上記+1 n n+1 a_次のワードの先頭アドレス ) < >
 DQ PLUS       ;    ( n_上記+1 n a_次のワードの最後尾＋１のアドレス ) < >
 DQ TOR    ; >R     ( n_上記+1 n ) < a_次のワードの最後尾＋１のアドレス >
 DQ _TYPE  ;        ( )  < a_次のワードの最後尾＋１のアドレス >
           ; TYPE ( a n --- )  アドレスａ以降に格納されているｎバイトのワードを印刷する。
 DQ SEMIS

; ."     ←   ." Hello"  もしくは　DQ DTDQ  DB 5,"Hello" 
DTDQ9:
 DB 0C2H
 DB '.'
 DB '"'+80H
 DQ KDTDQ9
DTDQ:
 DQ DOCOL
 DQ _LIT,22H   ; ( " code )
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT64  ; "@" FETCH
 DQ ZBRAN
DTDQ_AFT_IF:
 DQ DTDQ_AFT_ELSE +8- DTDQ_AFT_IF
 DQ COMP
 DQ KDTDQ    ; (.")
 DQ _WORD
 DQ CFETCH    ; C@
 DQ _1PL
 DQ ALLOT
; DQ _ELSE
 DQ BRAN
DTDQ_AFT_ELSE:
 DQ DTDQ_AFT_THEN - DTDQ_AFT_ELSE
 DQ _WORD
 DQ COUNT
 DQ _TYPE
; DQ THEN
DTDQ_AFT_THEN:
 DQ SEMIS




; D.R
DDTR9:
 DB 83H
 DB 'D.'
 DB 'R'+80H
 DQ DTDQ9
DDTR:
 DQ DOCOL
 DQ TOR    ; >R
 DQ SWAP   ; SWAP
 DQ OVER   ; OVER
 DQ DABS   ; DABS
 DQ UPIGT  ; <#
 DQ IGTS   ; #S
 DQ SIGN   ; SIGN
 DQ IGTDN  ; #>
 DQ FROMR  ; R>
 DQ OVER   ; OVER
 DQ SUBB   ; -
 DQ SPACES ; SPACES
 DQ _TYPE; TYPE
 DQ SEMIS

; D.
DDT9:
 DB 82H
 DB 'D'
 DB '.'+80H
 DQ DDTR9
DDT:
 DQ DOCOL
 DQ _0
 DQ DDTR
 DQ SPACE
 DQ SEMIS

; .R
DTR9:
 DB 82H
 DB '.'
 DB 'R'+80H
 DQ DDT9
DTR:
 DQ DOCOL
 DQ TOR    ; >R
 DQ STOD    ; S->D
 DQ FROMR    ; R>
 DQ DDTR
 DQ SEMIS

; .
_DT9:
 DB 81H
 DB '.'+80H
 DQ DTR9
_DT:
 DQ DOCOL
 DQ STOD    ; S->D
 DQ DDT
 DQ SEMIS

; DECIMAL
DECIMAL9:
 DB 87H
 DB 'DECIMA'
 DB 'L'+80H
 DQ _DT9
DECIMAL:
 DQ DOCOL
 DQ _LIT,0AH
 DQ BASE
 DQ STORE64  ; !64
 DQ SEMIS

; HEX
HEX9:
 DB 83H
 DB 'HE'
 DB 'X'+80H
 DQ DECIMAL9
HEX:
 DQ DOCOL
 DQ _LIT,10H
 DQ BASE
 DQ STORE64  ; !64
 DQ SEMIS

; (LINE)
KLINE9:
 DB 86H
 DB '(LINE'
 DB ')'+80H
 DQ HEX9
KLINE:
 DQ DOCOL
 DQ TOR    ; >R
 DQ C_L
 DQ B_BUF
   ; DQ */MOD
 DQ FROMR    ; R>
 DQ PLUS
 DQ BLOCK
 DQ PLUS
 DQ C_L
 DQ SEMIS

; .LINE
DTLINE9:
 DB 85H
 DB '.LIN'
 DB 'E'+80H
 DQ KLINE9
DTLINE:
 DQ DOCOL
 DQ KLINE    ; (LINE)
 DQ MNTRAILING
 DQ _TYPE
 DQ SEMIS

; LINE
LINE9:
 DB 84H
 DB 'LIN'
 DB 'E'+80H
 DQ DTLINE9
LINE:
 DQ DOCOL
 DQ SCR
 DQ ATT64  ; "@" FETCH
 DQ KLINE    ; (LINE)
 DQ SEMIS

; ?COMP ( --- )かな？
QCOMP9:
 DB 85H
 DB '?COM'
 DB 'P'+80H
 DQ LINE9
QCOMP:
 DQ DOCOL
 DQ _LIT
  DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
;??? DQ ATT64  ; "@" FETCH
 DQ ATT64  ; "@" FETCH
 DQ ZEQU  ; "0=" ０なら1（真）、それ以外は０
 DQ _LIT,11h
 DQ QERROR  ; 真ならERROR、偽なら何もしない？？
 DQ SEMIS

; ?EXEC
QEXEC9:
 DB 85H
 DB '?EXE'
 DB 'C'+80H
 DQ QCOMP9
QEXEC:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT64  ; "@" FETCH
 DQ _LIT,12
 DQ QERROR
 DQ SEMIS

; ?STACK
QSTACK9:
 DB 86H
 DB '?STAC'
 DB 'K'+80H
 DQ QEXEC9
QSTACK:
 DQ DOCOL
 DQ SPAT    ; SP@
 DQ S0
 DQ ATT64  ; "@" FETCH
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
QPAIRS9:
 DB 86H
 DB '?PAIR'
 DB 'S'+80H
 DQ QSTACK9
QPAIRS:
 DQ DOCOL
 DQ _EQ
 DQ _NOT
 DQ _LIT,13
 DQ QERROR
 DQ SEMIS
 
; ?LOADING
QLOADING9:
 DB 88H
 DB '?LOADIN'
 DB 'G'+80H
 DQ QPAIRS9
QLOADING:
 DQ DOCOL
 DQ BLK
 DQ ATT64  ; "@" FETCH
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _LIT,16
 DQ QERROR
 DQ SEMIS
 
; ?CSP
QCSP9:
 DB 84H
 DB '?CS'
 DB 'P'+80H
 DQ QLOADING9
QCSP:
 DQ DOCOL
 DQ SPAT    ; SP@
 DQ CSP
 DQ ATT64  ; "@" FETCH
 DQ SUBB
 DQ _LIT,14
 DQ QERROR
 DQ SEMIS

; !CSP
SCSP9:
 DB 84H
 DB '!CS'
 DB 'P'+80H
 DQ QCSP9
SCSP:
 DQ DOCOL
 DQ SPAT    ; SP@
 DQ CSP
 DQ STORE64  ; !64
 DQ SEMIS

; COMPILE
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
 DQ ATT64  ; "@" FETCH
 DQ SEMIS
 
; [COMPILE]
KKCOMPILE9:
 DB 0C9H
 DB '[COMPILE'
 DB ']'+80H
 DQ COMP9
KKCOMPILE:
;  コンパイル時、次の文字列を検索して、登録されたアドレスをCOMMA8でストアする。
;  実行時は、既に登録されているアドレスからそれぞれのワードにジャンプして実行８する
 DQ DOCOL
 DQ FIND

 DQ BREAK_POINT
 DQ 70H

 DQ QDUP    ; ?DUP
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _0
 DQ QERROR
 DQ COMMA8
 DQ SEMIS


;; [COMPILE] FIND ?DUP 0= 0 ?ERROR , ; IMMEDIATE
;;  -->
;
;;  : [COMPILE]  ( --- a )
;                
;                ?COMP
;     ( コンパイル時 )  IF FIND ?DUP 0= 0 ?ERROR , 
;     ( 実行時 )        ELSE   
;                         DQ JUMP_ASM
;                       JUMP_ASM:
;                         LEA RAX,LABEL_COUNT
;                         JMP APUSH
;                       LABEL_COUNT:
;                         DB  5
;                       LABEL_STR:
;                         DB "FORTH"
;
;                       THEN



 
;; [COMPILE]
;KKCOMPILE9:
; DB 0C9H
; DB '[COMPILE'
; DB ']'+80H
; DQ COMP9
;KKCOMPILE:
;;  コンパイル時、次の文字列を検索して、登録されたアドレスをCOMMA8でストアする。
;;  実行時は、既に登録されているアドレスからそれぞれのワードにジャンプして実行８する
; DQ DOCOL
;
; DQ BREAK_POINT
; DQ 60H
;
; DQ QCOMP  ;?COMP
; 
; DQ ZBRAN
;KKCOMP_AFT_IF:
; DQ KKCOMP_AFT_ELSE +8- KKCOMP_AFT_IF
;
; DQ FIND
; DQ QDUP    ; ?DUP
; DQ ZEQU  ; "0=" ０なら1、それ以外は０
; DQ _0
; DQ QERROR
; DQ COMMA8
;
; DQ BRAN
;KKCOMP_AFT_ELSE:
; DQ KKCOMP_AFT_THEN - KKCOMP_AFT_ELSE
;
; DQ _0
; DQ _0
;                         DQ KKCOMP_JUMP_ASM
;                       KKCOMP_JUMP_ASM::
;                         LEA RAX,KKCOMP_LABEL_COUNT
;                         JMP APUSH
;                       KKCOMP_LABEL_COUNT:
;                         DB  5
;                       KKCOMP_LABEL_STR:
;                        DB "FORTH"
;
;
;KKCOMP_AFT_THEN:
;
; DQ SEMIS









; LITERAL
LITERAL9:
 DB 0C7H
 DB 'LITERA'
 DB 'L'+80H
 DQ KKCOMPILE9
LITERAL:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT64  ; "@" FETCH
 DQ ZBRAN
LITERAL_AFT_IF:
 DQ LITERAL_AFT_THEN - LITERAL_AFT_IF
 DQ COMP
 DQ _LIT
 DQ COMMA8
; DQ THEN
LITERAL_AFT_THEN:
 DQ SEMIS
 
; DLITERAL
DLITERAL9:
 DB 0C8H
 DB 'DLITERA'
 DB 'L'+80H
 DQ LITERAL9
DLITERAL:
 DQ DOCOL
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ ATT64  ; "@" FETCH
 DQ ZBRAN
DLITERAL_AFT_IF:
 DQ DLITERAL_AFT_THEN - DLITERAL_AFT_IF
 DQ SWAP
 DQ KKCOMPILE    ; [COMPILE]
; DQ LITERAL
 DB 7,'LITERAL'
 DQ KKCOMPILE    ; [COMPILE]
; DQ LITERAL
 DB 7,'LITERAL'
; DQ THEN
DLITERAL_AFT_THEN:
 DQ SEMIS
 
; DEFINITIONS
DEFINITIONS9:
 DB 8bH
 DB 'DEFINITION'
 DB 'S'+80H
 DQ DLITERAL9
DEFINITIONS:
 DQ DOCOL


 DQ BREAK_POINT
 DQ 44H
;
 DQ CONTEXT
 DQ ATT64  ; "@" FETCH
 DQ CURRENT
 DQ STORE64  ; !64
 DQ SEMIS
 
; ALLOT
ALLOT9:
 DB 85H
 DB 'ALLO'
 DB 'T'+80H
 DQ DEFINITIONS9
ALLOT:
 DQ DOCOL
 DQ DP
 DQ PSTORE    ; +!
 DQ SEMIS
 
; HERE
HERE9:
 DB 84H
 DB 'HER'
 DB 'E'+80H
 DQ ALLOT9
HERE:
 DQ DOCOL
 DQ DP
 DQ ATT64  ; "@" FETCH
 DQ SEMIS
 
; PAD
PAD9:
 DB 83H
 DB 'PA'
 DB 'D'+80H
 DQ HERE9
PAD:
 DQ DOCOL
 DQ HERE
 DQ _LIT,54h
 DQ PLUS
 DQ SEMIS

; LATEST
LATEST9:
 DB 86H
 DB 'LATES'
 DB 'T'+80H
 DQ PAD9
LATEST:
 DQ DOCOL
 DQ CURRENT
 DQ ATT64  ; "@" FETCH
 DQ ATT64  ; "@" FETCH
 DQ SEMIS
 
;; TOGGLE
; DB 86H
; DB 'TOGGL'
; DB 'E'+80H
; DQ 1897
;TOGGL:
; DQ DOCOL
; DQ OVER
; DQ CFETCH    ; C@
; DQ XORR
; DQ SWAP
; DQ CSTOR
; DQ SEMIS
 
; SMUDGE
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
 
;; +ORIGIN
;PLORIG9:
; DB 87H
; DB '+ORIGI'
; DB 'N'+80H
; DQ SMUDG9
;PLORIG:
; DQ DOCOL
; DQ ORIG
; DQ PLUS
; DQ SEMIS
 
; TRAVERSE
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
 DQ CFETCH    ; C@
 DQ _DIGIT    ; <
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
 DQ _LIT,5
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
 DQ _LIT,4
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
 DQ _8MN
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
 DQ _LIT,5
 DQ PLUS
 DQ SEMIS

; [
MEKG9:
 DB 0C1H
 DB '['+80H
 DQ PFA9
MEKG:
 DQ DOCOL
 DQ _0
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ STORE64  ; !64
 DQ SEMIS

; ]
RBRAC9:
 DB 0C1H
 DB ']'+80H
 DQ MEKG9
RBRAC:
 DQ DOCOL
 DQ _LIT,0C0H
 DQ STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ STORE64  ; !64
 DQ SEMIS

; ;
KRN9:
 DB 0C1H
 DB ';'+80H
 DQ RBRAC9
KRN:
 DQ DOCOL
 DQ QCSP
 DQ COMP
; DQ SEMIS
 DB 2,';S'
 DQ SMUDG
 DQ KKCOMPILE    ; [COMPILE]
; DQ MEKG    ; [
 DQ 1,'['
 DQ SEMIS

; ,8
COMMA8_9:
 DB 82H
 DB ','
 DB '8'+80H
 DQ KRN9
COMMA8:
 DQ DOCOL
 DQ HERE
 DQ STORE64  ; !64
 DQ _LIT,8
 DQ ALLOT
 DQ SEMIS
; ,
COMMA9:
 DB 81H
 DB ','+80H
 DQ COMMA8_9
COMMA:
 DQ DOCOL
 DQ HERE
 DQ STORE64  ; !64
 DQ _LIT,2
 DQ ALLOT
 DQ SEMIS

; C,
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
VOCABULARY9:
 DB 08AH
 DB 'VOCABULAR'
 DB 'Y'+80H
 DQ CCOMM9
VOCABULARY:
 DQ DOCOL
 DQ CREAT
 DQ _LIT,0A081H
 DQ COMMA8
 DQ CURRENT
 DQ ATT64  ; "@" FETCH
 DQ CFA
 DQ COMMA8
 DQ HERE
 DQ VOCLINK
 DQ ATT64  ; "@" FETCH
 DQ COMMA8
 DQ VOCLINK
 DQ STORE64  ; !64
 DQ DOES

DOVOC::
; DQ DOCOL
; DQ _8PL
; DQ CONTEXT
; DQ STORE64  ; !64
; DQ SEMIS
 MOV RAX,[RBX]
 ADD RAX,8*2
 MOV RBX,16*8+_UP  ; CONTEXT
 MOV [RBX],RAX
 JMP NEXT




 
; FORGET
FORGET9:
 DB 86H
 DB 'FORGE'
 DB 'T'+80H
 DQ VOCABULARY9
FORGET:
 DQ DOCOL
 DQ CURRENT
 DQ ATT64  ; "@" FETCH
 DQ CONTEXT
 DQ ATT64  ; "@" FETCH
 DQ SUBB
 DQ _LIT,18
 DQ QERROR
 DQ KKCOMPILE    ; [COMPILE]
; DQ DUPE
 DB 3,'DUP'
 DQ FENCE
 DQ ATT64  ; "@" FETCH
 DQ SUBB
 DQ _LIT,15
 DQ QERROR
 DQ DUPE
 DQ NFA
 DQ DP
 DQ STORE64  ; !64
 DQ LFA
 DQ ATT64  ; "@" FETCH
 DQ CURRENT
 DQ ATT64  ; "@" FETCH
 DQ STORE64  ; !64
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
 DQ COMMA8
 DQ SEMIS
 
; <RESOLVE
FRRESOLVE9:
 DB 88H
 DB '<RESOLV'
 DB 'E'+80H
 DQ TOMARK9
FRRESOLVE:
 DQ DOCOL
 DQ HERE
 DQ SUBB
 DQ COMMA8
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
 DQ STORE64  ; !64
 DQ SEMIS
 
; IF
_IF9:
 DB 0C2H
 DB 'I'
 DB 'F'+80H
 DQ TORESOLVE9
_IF:
 DQ DOCOL
 DQ QCOMP
 DQ COMP
 DQ ZBRAN
 DQ TOMARK    ; >MARK
 DQ _1
 DQ SEMIS

; THEN
THEN9:
 DB 0C4H
 DB 'THE'
 DB 'N'+80H
 DQ _IF9
THEN:
 DQ DOCOL
 DQ _1
 DQ QPAIRS
 DQ TORESOLVE    ; >RESOLVE
 DQ SEMIS

; ELSE
_ELSE9:
 DB 0C4H
 DB 'ELS'
 DB 'E'+80H
 DQ THEN9
_ELSE:
 DQ DOCOL
 DQ _1
 DQ QPAIRS
 DQ COMP
 DQ BRAN
 DQ TOMARK    ; >MARK
 DQ SWAP
 DQ TORESOLVE    ; >RESOLVE
 DQ _1
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
 DQ FRMARK    ; <MARK
 DQ _3
 DQ SEMIS

; AGAIN
AGAIN9:
 DB 0C5H
 DB 'AGAI'
 DB 'N'+80H
 DQ BEGIN9
AGAIN:
 DQ DOCOL
 DQ _3
 DQ QPAIRS
 DQ COMP
 DQ BRAN
 DQ FRRESOLVE    ; <RESOLVE
 DQ SEMIS

; UNTIL
UNTIL9:
 DB 0C5H
 DB 'UNTI'
 DB 'L'+80H
 DQ AGAIN9
UNTIL:
 DQ DOCOL
 DQ _3
 DQ QPAIRS
 DQ COMP
 DQ ZBRAN
 DQ FRRESOLVE    ; <RESOLVE
 DQ SEMIS
 
; WHILE
_WHILE9:
 DB 0C5H
 DB 'WHIL'
 DB 'E'+80H
 DQ UNTIL9
_WHILE:
 DQ DOCOL
 DQ _3
 DQ QPAIRS
 DQ COMP
 DQ ZBRAN
 DQ TOMARK    ; >MARK
 DQ _LIT,4
 DQ SEMIS
 
; REPEAT
_REPEAT9:
 DB 0C6H
 DB 'REPEA'
 DB 'T'+80H
 DQ _WHILE9
_REPEAT:
 DQ DOCOL
 DQ _LIT,4
 DQ QPAIRS
 DQ COMP
 DQ BRAN
 DQ SWAP
 DQ FRRESOLVE    ; <RESOLVE
 DQ TORESOLVE    ; >RESOLVE
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
 DQ FRMARK    ; <MARK
 DQ _2
 DQ SEMIS

; LOOP
_LOOP9:
 DB 0C4H
 DB 'LOO'
 DB 'P'+80H
 DQ DO9
_LOOP:
 DQ DOCOL
 DQ _2
 DQ QPAIRS
 DQ COMP
 DQ XLOOP    ; (LOOP)
 DQ FRRESOLVE    ; <RESOLVE
 DQ SEMIS

; +LOOP
PLLOOP9:
 DB 0C5H
 DB '+LOO'
 DB 'P'+80H
 DQ _LOOP9
PLLOOP:
 DQ DOCOL
 DQ _2
 DQ QPAIRS
 DQ COMP
 DQ XPLOO    ; (+LOOP)
 DQ FRRESOLVE    ; <RESOLVE
 DQ SEMIS

; LEAVE
_LEAVE9:
 DB 85H
 DB 'LEAV'
 DB 'E'+80H
 DQ PLLOOP9
_LEAVE:
 DQ DOCOL
 DQ FROMR    ; R>
 DQ FROMR    ; R>
 DQ DUPE
 DQ FROMR    ; R>
 DQ DROP
 DQ TOR    ; >R
 DQ TOR    ; >R
 DQ TOR    ; >R
 DQ SEMIS

; I
I9:
 DB 81H
 DB 'I'+80H
 DQ _LEAVE9
I:
 DQ DOCOL
 DQ FROMR    ; R>
 DQ RAT  ; R@
 DQ SWAP
 DQ TOR    ; >R
 DQ SEMIS

; J
J9:
 DB 81H
 DB 'J'+80H
 DQ I9
J:
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

; EXIT
EXIT9:
 DB 0C4H
 DB 'EXI'
 DB 'T'+80H
 DQ J9
EXIT:
 DQ DOCOL
 DQ QCOMP
 DQ COMP
 DQ SEMIS
 DQ SEMIS
 
; PICK
    ; スタックの上位n1項をコピーしてTOSに複写する。
PICK9:
 DB 84H
 DB 'PIC'
 DB 'K'+80H
 DQ EXIT9
PICK:
 DQ DOCOL
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*
 DQ SPAT    ; SP@
 DQ PLUS
 DQ ATT64  ; "@" FETCH
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
 DQ ATT64  ; "@" FETCH
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
 DQ ATT64  ; "@" FETCH
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
; DQ RAT  ; R@       (  TopOfStack adr_TopOfStack adr_TopOfStack-8 n ) < n >
; DQ _1PL     ;      (  TopOfStack adr_TopOfStack adr_TopOfStack-8 n+1 ) < n >
;; DQ _2ML    ; 2*
; DQ _8ML    ; 8*    (  TopOfStack adr_TopOfStack adr_TopOfStack-8 (n+1)*8 ) < n >
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
 DQ STORE64  ; !64
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
 DQ ATT64  ; "@" FETCH
 DQ ATT64  ; "@" FETCH　これでFORTHボキャブラリーの最初のWORDを指し示す。

 DQ BREAK_POINT
 DQ 9

 DQ KFIND

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
 DQ KFIND
; DQ THEN
FIND_AFT_THEN:


 DQ BREAK_POINT
 DQ 55H

 DQ SEMIS
 
; '
CMM9:
 DB 0C1H
 DB "'"+80H
 DQ FIND9
CMM:
 DQ DOCOL
 DQ FIND
 DQ QDUP    ; ?DUP
 DQ ZEQU  ; "0=" ０なら1、それ以外は０
 DQ _0
 DQ QERROR
 DQ KKCOMPILE    ; [COMPILE]
; DQ LITERAL
 DB 7,'LITERAL'
 DQ SEMIS
 
; WORD  ( c --- a )
;       文字コードｃまたはnullコードを区切り文字コードとして入力テキストから文字列を切り出し、入力された文字列（１バイト長）とそれに続く入力文字列が格納されたメモリ領域の先頭番地ａをスタックに置く。


;＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
;
;１）まず最初に与える文字列として、08 20 46 4f 52 54 48 20 00 を与えてみた。
;１ー１）BREAK_POINT 5   FIND内のWORDを実行する前のrspの指し示すアドレス
;
;0x00007FF7D46A3BAC  07 46 4f 52 54 48 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  .FORTH .........................
;
;TOP OF STACK:なし
;
;
;
;１－２）BREAK_POINT 8   FIND内のWORDを実行した後のrspの指し示すアドレス
;
;
;0x00007FF7D46A3BA4  8d a5 69 d4 f7 7f 00 00 07 46 4f 52 54 48 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ・･iﾔ・....FORTH .................
;
;TOP OF STACK:8d a5 69 d4 f7 7f 00 00
;  00007FF7D469A58D -> 06 07 46 4f 52 54 48 20 20 20 20 20 20 20   ０６文字数で、07 46 4f 52 54 48が文字列？？
;STACK 2     :なし
;
;
;

_WORD9:
 DB 84H
 DB 'WOR'
 DB 'D'+80H
 DQ CMM9
_WORD:
; ( c --- a )
;  c:区切り文字コード
;  a:「文字数（１バイト）＋文字列」の先頭アドレス
 DQ DOCOL

 
; DQ INTR_PROC  ; ; INTERNAL_PROCESSING   ( --- a ) DOVAR  WORDワードにおいて初期化時や内部処理時は１で、端末キーボードから入力バッファ上に転送された文字列の処理時は０となる。
; DQ ATT64  ; "@" FETCH
; DQ _0
; DQ _EQ
; DQ ZBRAN  ; BLKの内容が０の場合はELSEへ、それ以外は次のワードへ。
;; IF n_INTERNAL_PROCESSING == 0 （端末キーボードから入力バッファ上に転送された文字列の処理時）
;_WORD_2_AFT_IF:
; DQ _WORD_2_AFT_ELSE +8- _WORD_2_AFT_IF

 DQ USE_KCOMP_WORD
 DQ ATT64
 DQ _1
 DQ _EQ
 DQ ZBRAN
; IF INTERPRETの中のFINDでWORDが実行される時ジャンプ
_WORD_2_AFT_IF:
 DQ _WORD_2_AFT_ELSE +8- _WORD_2_AFT_IF

; 以下はINTERPRETの中のFINDでWORDが実行される以外の時
; （ワードのアドレスの列で[COMPILE]+???が実行されるとき）

 DQ BREAK_POINT
 DQ 78H
 DQ WORD_ADDRESS_SEARCH

; ELSE
; 以下はコンパイル時
DQ BRAN
_WORD_2_AFT_ELSE:
 DQ _WORD_2_AFT_THEN - _WORD_2_AFT_ELSE

;
; DQ BREAK_POINT
; DQ 4
;;
 DQ BLK  ; ( c a )
           ; BLK ( --- a ) インタプリタが入力文字列として処理しつつあるディスクのブロックナンバーを持つユーザー変数のアドレス。
           ; インタプリタがコンソールから入力文字列を受け取っている場合はBLKの内容は０となる。

 DQ ATT64  ; "@" FETCH   ( c n_ディスクのブロックナンバー )
 DQ ZBRAN  ; BLKの内容が０の場合はELSEへ、それ以外は次のワードへ。
_WORD_AFT_IF:
 DQ _WORD_AFT_ELSE +8- _WORD_AFT_IF

;  
 DQ BLK  ; ( c a )
 DQ ATT64  ; "@" FETCH     ( c n_ディスクのブロックナンバー )
 DQ BLOCK  ; ( n --- a )   ( c a_BLOCKバッファメモリ先頭アドレス )　　指定された仮想記録のブロックｎに対し、バッファメモリ領域の先頭アドレスａを返す。
; DQ _ELSE
 DQ BRAN
_WORD_AFT_ELSE:
 DQ _WORD_AFT_THEN - _WORD_AFT_ELSE
 DQ TIB    ; (c a_TIB )                テキスト入力バッファ。ａはその先頭アドレスである。バッファの大きさは８０を最小限とする。
 DQ ATT64  ; "@" FETCH     (c n_TIB先頭アドレスの値（なぜ、ディスクはアドレスなのにディスプレイはバッファの先頭アドレスの値なのか？） )
           ;   TIBのアドレスが示す先には１０２４バイト＋αのレコードがあって、その先頭にはレコードの番号が書かれている。
           ;   @64はそのレコード番号を読み込んでいるのではないだろうか？
; DQ THEN
_WORD_AFT_THEN:
 DQ DNIP   ; UserVariable >IN  ( --- a)  入力文字列の中で、バッファの初めから現在インタプリタが処理しつつある文字までのオフセット値を示すユーザー変数のアドレス。
           ;   ("to-in"と読む。）)
 DQ ATT64  ; "@" FETCH     ディスクだと ( c n_BLOCK先頭アドレス n_>IN )
 DQ PLUS   ; ディスクだと ( c n_BLOCK先頭アドレス_＋_n_>IN )
 DQ SWAP   ; ディスクだと ( n_BLOCK先頭アドレス_＋_n_>IN c )
;
; DQ BREAK_POINT
; DQ 16
;
 DQ ENCLOSE  ; ( a c --- a n1 n2 n3 ;
             ;)
             ; WORDを
;
; DQ BREAK_POINT
; DQ 17
;
 
 DQ HERE      ; ( --- a )  次に使用可能な辞書の位置（アドレス）ａをスタックに置く。
              ;         現在は ( a n1 n2 n3 a_HERE )
 DQ _LIT,22H  ;                ( a n1 n2 n3 a_HERE 22h個（？'"'なのではないの？？ )
 DQ BLANKS    ; ( a n --- ) メモリアドレスａ以降のｎバイトのメモリ領域をASCIIコード２０ｈで満たす。
              ;         現在は ( a n1 n2 n3 )   
 DQ DNIP      ; >IN  ( --- a )  入力文字列に中で、バッファの初めから現在インタプリタが処理しつつある文字までのオフセット値を示すユーザー変数のアドレス。 
              ;         現在は ( a_スキャンした文字列の先頭アドレス n1 n2 n3 a_文字オフセット値 )
 DQ PSTORE    ; +!  >INの内容に追加した２０ｈを満たした領域を追加する。 現在は ( a n1 n2 )
 DQ OVER      ;    現在は ( a n1 n2 n1 )
 DQ SUBB      ;    現在は ( a n1 n2 )     
 DQ TOR    ; >R    現在は ( a n1 n2 ) < n1 >
 DQ RAT  ; R@      現在は ( a n1 n2 n1 ) < n1 >
 DQ HERE      ;    現在は ( a n1 n2 n1 a_HERE1) < n1 >
 DQ CSTOR     ;    現在は ( a n1 n2 ) < n1 >           次のメモリ領域に最初にデリミタでないキャラクタのオフセット値を置く
 DQ PLUS      ;    現在は ( a n1+n2 ) < n1 > 
 DQ HERE      ;    現在は ( a n1+n2 a_HERE2 ) < n1 >
 DQ _1PL      ;    現在は ( a n1+n2 a_HERE2+1 ) < n1 >
 DQ FROMR    ; R>  現在は ( a n1+n2 a_HERE2+1 n1 )
 DQ _CMOVE    ; ( a1 a2 n --- )
 DQ HERE
 ;


; THEN
_WORD_2_AFT_THEN:


 DQ BREAK_POINT
 DQ 19
;
DQ SEMIS


; WORD_ADDRESS_SEARCH
WORD_ADDRESS_SEARCH9:
 DB 093H
 DB 'WORD_ADDRESS_SEARC'
 DB 'H'+80H
 DQ _WORD9
WORD_ADDRESS_SEARCH:
; DQ BREAK_POINT
; DQ 78H
 DQ WORD_ADDRESS_SEARCH +8
 MOV RBX,RBP
 ADD RBX,8*2
 MOV RAX,[RBX]              ; RAX <- 文字数（１バイト）＋文字列（Ｎ個）へのポインタ
 MOV RCX,RAX
 XOR RDX,RDX
 MOV DL, [RAX]     ; RAXが示すアドレスから、文字列の個数（Ｎ個）分ずらす

 ADD RCX,RDX     ; RAXが示すアドレスから、文字列の個数（Ｎ個）分ずらす
 INC RCX                    ; そして、文字数（１バイト）分ずらす。
 MOV [RBX],RCX
 JMP APUSH





; (
MRKK9:
 DB 0C1H
 DB '('+80H
; DQ WORD_ADDRESS_SEARCH9
 DQ _WORD9
MRKK:
 DQ DOCOL
 DQ _LIT,29H
 DQ _WORD
 DQ DROP
 DQ SEMIS

; EXPECT   ( a n --- )　ｎ個又は復帰コードまでの文字を端末キーボードから読み取り、アドレスａ以降のメモリ領域に格納する。
;                       その端末には1つまたは2つのnullコードを付け加える。
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
 DQ KEY     ; キーボードからのキー入力を待ち、入力された文字コードｃをスタックに置く。

 DQ BREAK_POINT
 DQ 31H




 DQ DUPE    ;                    ( a c c ) < a_XDO a_XDO+n >;
 DQ _LIT,8   ; c==08h('BS')?     ( a c c 08h ) < a_XDO a_XDO+n >
 DQ _EQ     ;_EQ ( n1 n2 --- f )　なので ( a c f ) < a_XDO a_XDO+n >

 DQ     ZBRAN
EXPECT_1_AFT_IF:
 DQ     EXPECT_1_AFT_ELSE +8- EXPECT_1_AFT_IF
;       ; c != 08h('BS')
 DQ     OVER   ;  ( a c a ) < a_XDO a_XDO+n >
 DQ     I      ; ( --- n )  現在のスタックは  ( a c a a_XDO+n ) < a_XDO a_XDO+n >
 DQ     _EQ     ;_EQ ( n1 n2 --- f )　なので ( a c f ) < a_XDO a_XDO+n >

; ;  この後にどこへJUMPするのかわからない？このままでいいのか？
; ; 　仮にEXIT処理を書いて、コメントにしておく.
;    テストしてみて問題がなければ何もしないこと
;
; DQ     NOT
; DQ     ZBRAN
;EXPECT_3_AFT_IF:
; DQ     EXPECT_3_AFT_THEN - EXPECT_3_AFT_IF
;
;;     ; スキャンが終了時
; DQ     LEAVE  ; ( --- ) DO ... LOOP の中で用いられ、そのループから強制的に抜け出すことを指令する。
; DQ     BRAN
;EXPECT_1_AFT_LEAVE:
; DQ     EXPECT_1_AFT_THEN - EXPECT_1_AFT_LEAVE
;
;
;EXPECT_3_AFT_THEN:

 DQ     DUPE  ;  ( a c c ) < a_XDO a_XDO+n >
 DQ     FROMR    ; R>  ( a c c a_XDO+n  ) < a_XDO >
; DQ   _2MN
 DQ     _8MN    ;      ( a c c (a_XDO+n)-8 ) < a_XDO >
 DQ     PLUS
 DQ     TOR    ; >R
 DQ     SUBB

; DQ   _ELSE
 DQ     BRAN
EXPECT_1_AFT_ELSE:
 DQ     EXPECT_1_AFT_THEN - EXPECT_1_AFT_ELSE
 DQ     DUPE
 DQ     _LIT,0DH
 DQ     _EQ

 DQ       ZBRAN
EXPECT_2_AFT_IF:
 DQ       EXPECT_2_AFT_ELSE +8- EXPECT_2_AFT_IF
 DQ       _LEAVE
 DQ       DROP
 DQ       _BL
 DQ       _0

; DQ     _ELSE
 DQ       BRAN
EXPECT_2_AFT_ELSE:
 DQ       EXPECT_2_AFT_THEN - EXPECT_2_AFT_ELSE
 DQ       DUPE

; DQ       THEN
EXPECT_2_AFT_THEN:

 DQ     I
 DQ     CSTOR
 DQ     _0
 DQ     I
 DQ     _1PL
 DQ     STORE64  ; !64

; DQ   THEN
EXPECT_1_AFT_THEN:
EXPECT_3_AFT_THEN:

 DQ   EMIT

 DQ XLOOP
EXPECT_AFT_XLOOP:
 DQ EXPECT_AFT_XDO-EXPECT_AFT_XLOOP  ; -37*8
 DQ DROP
 DQ SEMIS

; DQ EXPECT_2
;EXPECT_2:
;
;; ここから文字列の入力待ちルーチンが恥じます。
;


 
; QUERY
QUERY9:
 DB 85H
 DB 'QUER'
 DB 'Y'+80H
 DQ EXPECT9
QUERY:
 DQ DOCOL
 DQ TIB
 DQ ATT64  ; "@" FETCH
 DQ TIBLEN
 DQ EXPECT
 DQ _0
 DQ DNIP   ; >IN 
 DQ STORE64  ; !64
 DQ SEMIS
 
; x
;;;  イミディエイトモードでのnullコードなので、文字列の最後に実行されるのだろうか？
;;;  これが記述されている SCR # 329 では
;;;   8081 HERE : x ... ; ! IMMEDIATE null
;;;  となっている。
x9:
 DB 0C1H
 DB 00H+80H
 DQ QUERY9
x:
 DQ DOCOL
 DQ BLK
 DQ ATT64  ; "@" FETCH
 DQ ZBRAN
x_AFT_IF:
 DQ x_AFT_ELSE +8- x_AFT_IF
 DQ _1
 DQ BLK
 DQ PSTORE    ; +!
 DQ _0
 DQ DNIP   ; >IN 
 DQ STORE64  ; !64
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
 
; CONVERT
CONVERT9:
 DB 87H
 DB 'CONVER'
 DB 'T'+80H
 DQ x9
CONVERT:
 DQ DOCOL
; DQ BEGIN
CONVERT_1_AFT_BEGIN:
 DQ _1PL
 DQ DUPE
 DQ TOR    ; >R
 DQ CFETCH    ; C@
 DQ BASE
 DQ ATT64  ; "@" FETCH
 DQ DIGIT

; DQ _WHILE
 DQ ZBRAN
CONVERT_1_AFT_WHILE:
 DQ CONVERT_1_AFT_REPEAT +8- CONVERT_1_AFT_WHILE
 DQ SWAP
 DQ BASE
 DQ ATT64  ; "@" FETCH
 DQ USTAR  ; U*
 DQ DROP
 DQ ROT
 DQ BASE
 DQ ATT64  ; "@" FETCH
 DQ USTAR  ; U*
 DQ DPLUS

 DQ   DPL
 DQ   ATT64  ; "@" FETCH
 DQ   _1PL
 DQ   ZBRAN
CONVERT_AFT_IF:
 DQ   CONVERT_AFT_THEN - CONVERT_AFT_IF
 DQ   _1
 DQ   DPL
 DQ   PSTORE    ; +!
; DQ THEN
CONVERT_AFT_THEN:
 DQ   FROMR    ; R>

; DQ _REPEAT
 DQ BRAN
CONVERT_1_AFT_REPEAT:
 DQ CONVERT_1_AFT_BEGIN - CONVERT_1_AFT_REPEAT
 DQ FROMR    ; R>
 DQ SEMIS
 
; NUMBER
NUMBER9:
 DB 86H
 DB 'NUMBE'
 DB 'R'+80H
 DQ CONVERT9
NUMBER:
 DQ DOCOL
 DQ _0and0
 DQ ROT
 DQ DUPE
 DQ _1PL
 DQ CFETCH    ; C@
 DQ _LIT,2DH

 DQ _EQ
 DQ DUPE
 DQ TOR    ; >R
 DQ PLUS
 DQ MINS1

; DQ BEGIN
NUMBER_1_AFT_BEGIN:
 DQ DPL
 DQ STORE64  ; !64
 DQ CONVERT
 DQ DUPE
 DQ CFETCH    ; C@
 DQ _BL
 DQ SUBB

; DQ _WHILE
 DQ ZBRAN
NUMBER_1_AFT_WHILE:
 DQ NUMBER_1_AFT_REPEAT +8- NUMBER_1_AFT_WHILE
 DQ DUPE
 DQ CFETCH    ; C@
 DQ _LIT,2EH
 DQ SUBB
 DQ _0
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
 DQ DNEGATE
; DQ THEN
NUMBER_AFT_THEN:
 DQ SEMIS
 
; +BUF
PLBUF9:
 DB 84H
 DB '+BU'
 DB 'F'+80H
 DQ NUMBER9
PLBUF:
 DQ DOCOL
 DQ BFLEN
 DQ PLUS
 DQ DUPE
 DQ LIMIT
 DQ _EQ
 DQ ZBRAN
PLBUF_AFT_IF:
 DQ PLBUF_AFT_THEN - PLBUF_AFT_IF
 DQ DROP
 DQ FIRST
; DQ THEN
PLBUF_AFT_THEN:
 DQ DUPE
 DQ PREV
 DQ ATT64  ; "@" FETCH
 DQ SUBB
 DQ SEMIS
 
; UPDATE
UPDATE9:
 DB 86H
 DB 'UPDAT'
 DB 'E'+80H
 DQ PLBUF9
UPDATE:
 DQ DOCOL
 DQ PREV
 DQ ATT64  ; "@" FETCH
 DQ ATT64  ; "@" FETCH
; DQ _LIT,8000H
 DQ _LIT,SYS_LIMIT
 DQ ORR
 DQ PREV
 DQ STORE64  ; !64
 DQ SEMIS
 
; EMPTY-BUFFERS
EMPBUF9:
 DB 8DH
 DB 'EMPTY-BUFFER'
 DB 'S'+80H
 DQ UPDATE9
EMPBUF:
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
 DQ EMPBUF9
SAVEBUFFERS:
 DQ DOCOL
 DQ IGTBUFF  ; #BUFF
 DQ _1PL
 DQ _0
 DQ XDO
SAVEBUFFERS_AFT_XDO:
; DQ _LIT,7FFFH
 DQ _LIT,SYS_LIMIT -1
 DQ BUFFER
 DQ DROP
 DQ XLOOP
SAVEBUFFERS_AFT_XLOOP:
 DQ SAVEBUFFERS_AFT_XDO - SAVEBUFFERS_AFT_XLOOP
 DQ SEMIS
 
; DR0
_DR09:
 DB 83H
 DB 'DR'
 DB '0'+80H
 DQ SAVEBUFFERS9
_DR0:
 DQ DOCOL
 DQ _0
 DQ DRIVE
 DQ STORE64  ; !64
 DQ SEMIS
 
; DR1
_DR19:
 DB 83H
 DB 'DR'
 DB '1'+80H
 DQ _DR09
_DR1:
 DQ DOCOL
 DQ _1
 DQ DRIVE
 DQ STORE64  ; !64
 DQ SEMIS

; R/W
RSSW9:
 DB 83H
 DB 'R/'
 DB 'W'+80H
 DQ _DR19
RSSW:
 DQ DOCOL
 DQ TOR    ; >R
 DQ DRIVE
 DQ ATT64  ; "@" FETCH
 DQ YROT    ; <ROT
;
;
; DQ REC/BLK  -->定数かな？なんにせよ、ここの操作でR/Wするセクタアドレスと数を求めなくてはならない。


;;;ここにBREAK_POINTのような記述があった。修正する。20240531
;;;    sub     rsp, 28h
;;;
;;;
;;; lea     rcx, SCANPROMPT_stop
;;; call _getwch
;;;
;;;    add     rsp, 28h

 DQ BREAK_POINT
 DQ 100H
;;;




 DQ SWAP
 DQ OVER
 DQ USTAR  ; U*
 DQ FROMR    ; R>
 DQ ZBRAN
RSSW_AFT_IF:
 DQ RSSW_AFT_ELSE +8- RSSW_AFT_IF
 DQ RREC
; DQ _ELSE
 DQ BRAN
RSSW_AFT_ELSE:
 DQ RSSW_AFT_THEN - RSSW_AFT_ELSE
 DQ WREC
; DQ THEN
RSSW_AFT_THEN:
 DQ _1
 DQ ANDD
 DQ DISK_ERROR
 DQ STORE64  ; !64
 DQ SEMIS
 
; BUFFER
BUFFER9:
 DB 86H
 DB 'BUFFE'
 DB 'R'+80H
 DQ RSSW9
BUFFER:
 DQ DOCOL
 DQ USE
 DQ ATT64  ; "@" FETCH
 DQ DUPE
 DQ TOR    ; >R

; DQ BEGIN
BUFFER_AFT_BEGIN:
 DQ PLBUF    ; +BUF
; DQ UNTIL
 DQ ZBRAN
BUFFER_AFT_UNTIL:
 DQ BUFFER_AFT_BEGIN - BUFFER_AFT_UNTIL
 DQ USE
 DQ STORE64  ; !64
 DQ RAT  ; R@
 DQ ZLESS  ; 0<

 DQ   ZBRAN
BUFFER_AFT_IF:
 DQ   BUFFER_AFT_THEN - BUFFER_AFT_IF
 DQ   RAT
; DQ   _2PL
 DQ   _8PL
 DQ   RAT
 DQ   ATT64  ; "@" FETCH
; DQ   _LIT,7FFFH
 DQ   _LIT,SYS_LIMIT
 DQ   ANDD
 DQ     _0
 DQ     RSSW    ; R/W
; DQ   THEN
BUFFER_AFT_THEN:
 DQ RAT  ; R@
 DQ STORE64  ; !64
 DQ RAT  ; R@
 DQ PREV
 DQ STORE64  ; !64
 DQ FROMR    ; R>
; DQ _2PL
 DQ _8PL
 DQ SEMIS
 
; BLOCK
BLOCK9:
 DB 85H
 DB 'BLOC'
 DB 'K'+80H
 DQ BUFFER9
BLOCK:
 DQ DOCOL
 DQ _OFFSET
 DQ ATT64  ; "@" FETCH
 DQ PLUS
 DQ TOR    ; >R
 DQ PREV
 DQ ATT64  ; "@" FETCH
 DQ DUPE
 DQ ATT64  ; "@" FETCH
 DQ RAT  ; R@
 DQ SUBB
; DQ _2ML    ; 2*
 DQ _8ML    ; 8*

 DQ ZBRAN
BLOCK_1_AFT_IF:
 DQ BLOCK_1_AFT_THEN - BLOCK_1_AFT_IF

; DQ   BEGIN
BLOCK_3_AFT_BEGIM:
 DQ   PLBUF    ; +BUF
 DQ   ZEQU  ; "0=" ０なら1、それ以外は０

 DQ     ZBRAN
BLOCK_2_AFT_IF:
 DQ     BLOCK_2_AFT_THEN - BLOCK_2_AFT_IF
 DQ     DROP
 DQ     RAT
 DQ     BUFFER
 DQ     DUPE
 DQ     RAT
 DQ     _1
 DQ     RSSW    ; R/W
; DQ     _2MN
 DQ     _8MN
; DQ     THEN
BLOCK_2_AFT_THEN:

 DQ     DUPE
 DQ     ATT64  ; "@" FETCH
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
 DQ   STORE64  ; !64

; DQ THEN
BLOCK_1_AFT_THEN:
 DQ FROMR    ; R>
 DQ DROP
; DQ _2PL
 DQ _8PL
 DQ SEMIS
 
; INTERPRET
INTERPRET9:
 DB 89H
 DB 'INTERPRE'
 DB 'T'+80H
 DQ BLOCK9
INTERPRET:
 DQ DOCOL

; DQ BEGIN

;;一行抹消。INTERPRETにはBEGINは必要ないと判断した
;INTERPRET_4_AFT_BEGIN:

 DQ _0
 DQ USE_KCOMP_WORD
 DQ STORE64  ; !64

 DQ FIND

 DQ _1
 DQ USE_KCOMP_WORD
 DQ STORE64  ; !64

 DQ QDUP    ; ?DUP

 DQ   ZBRAN
INTERPRET_1_AFT_IF:
 DQ   INTERPRET_1_AFT_ELSE +8- INTERPRET_1_AFT_IF

; １行追加（FINDでプッシュしたアドレスが消費されて肝心の実行時やコンパイル時の処理ができていないバグ）
 DQ DUPE

 DQ   STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ   ATT64  ; "@" FETCH
 DQ   _DIGIT    ; <

 DQ     ZBRAN
INTERPRET_2_AFT_IF:
 DQ     INTERPRET_2_AFT_ELSE +8- INTERPRET_2_AFT_IF

 DQ     COMMA8
; DQ     _ELSE
 DQ     BRAN
INTERPRET_2_AFT_ELSE:
 DQ     INTERPRET_2_AFT_THEN - INTERPRET_2_AFT_ELSE
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
 DQ   ATT64  ; "@" FETCH
 DQ   _1PL

 DQ     ZBRAN
INTERPRET_3_AFT_IF:
 DQ     INTERPRET_3_AFT_ELSE +8- INTERPRET_3_AFT_IF
 DQ     KKCOMPILE    ; [COMPILE]
; DQ     DLITERAL
 DB     8,'DLITERAL'

; DQ     _ELSE
 DQ     BRAN
INTERPRET_3_AFT_ELSE:
 DQ     INTERPRET_3_AFT_THEN - INTERPRET_3_AFT_ELSE
 DQ     DROP
 DQ     KKCOMPILE    ; [COMPILE]
; DQ     LITERAL
 DB     7,'LITERAL'

; DQ     THEN
INTERPRET_3_AFT_THEN:
 DQ     QSTACK

; DQ   THEN
INTERPRET_1_AFT_THEN:

;;ここのAGAINの部分を削除した。INTERPRETにはAGAINは不要と判断した
;; DQ AGAIN
; DQ BRAN
;INTERPRET_4_AFT_AGAIN:
; DQ INTERPRET_4_AFT_BEGIN - INTERPRET_4_AFT_AGAIN

 DQ SEMIS
 
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
 DQ STORE64  ; !64
 DQ KKCOMPILE    ; [COMPILE]
; DQ MEKG    ; [  ( --- )  入力文字列に対するコンパイル作業を中止し、実行モードとする。
 DB 1,'['
            ;             "left-bracket" と読む。

; DQ BEGIN
QUIT_2_AFT_BEGIN:
 DQ RPST0    ; RP!
;

 DQ BREAK_POINT
 DQ 21H


;
 DQ _CR
 DQ QUERY
 DQ INTERPRET

 DQ   STATE  ; ユーザー変数　実行時は０、コンパイル中の時は０以外
 DQ   ATT64  ; "@" FETCH
 DQ   ZEQU  ; "0=" ０なら1、それ以外は０
 DQ   ZBRAN
QUIT_AFT_IF:
 DQ   QUIT_AFT_THEN - QUIT_AFT_IF
 DQ   KDTDQ   ; (.")
 DB   5,'  OK '

; DQ   THEN
QUIT_AFT_THEN:

; DQ AGAIN
 DQ BRAN
QUIT_2_AFT_AGAIN:
 DQ QUIT_2_AFT_BEGIN - QUIT_2_AFT_AGAIN
 DQ SEMIS
 
; ABORT
ABORT9:
 DB 85H
 DB 'ABOR'
 DB 'T'+80H
 DQ QUIT9
ABORT:
 DQ DOCOL
 DQ SPST0    ; SP!
 DQ DECIMAL
 DQ _DR0


 DQ BREAK_POINT
 DQ 50H



;; DQ KKCOMPILE    ; [COMPILE]
;;;  コンパイル時、次の文字列を検索して、登録されたアドレスをCOMMA8でストアする。
;;;  実行時は、既に登録されているアドレスからそれぞれのワードにジャンプして実行８する
;;; DQ FORTH
;; DB 5,'FORTH'
;;; DB 'FORTH' -> これは文字列を入力バッファから読み込んでコンパイルするときの状態。

; DQ LIT,FORTH
; DQ COMMA8

 DQ KKCOMPILE    ; [COMPILE]
; DQ FORTH
 DB 5,'FORTH'



 DQ DEFINITIONS

 DQ BREAK_POINT
 DQ 51H

 DQ ABORT_INIT

 DQ QUIT
 DQ SEMIS
 

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
 DQ ATT64  ; "@" FETCH

 DQ ZBRAN
MESSAGE_1_AFT_IF:
 DQ MESSAGE_1_AFT_ELSE +8- MESSAGE_1_AFT_IF
 DQ QDUP    ; ?DUP

 DQ   ZBRAN
MESSAGE_2_AFT_IF:
 DQ   MESSAGE_2_AFT_THEN - MESSAGE_2_AFT_IF
 DQ   IGTBUFF  ; #BUFF
 DQ   _OFFSET
 DQ   ATT64  ; "@" FETCH
 DQ   SUBB
 DQ   DTLINE
 DQ   SPACE
; DQ   THEN
MESSAGE_2_AFT_THEN:

; DQ _ELSE
 DQ BRAN
MESSAGE_1_AFT_ELSE:
 DQ MESSAGE_1_AFT_THEN - MESSAGE_1_AFT_ELSE
 DQ KDTDQ    ; (.")
 DB 6,' MSG# '
; 
 DQ BREAK_POINT
 DQ 77H

 DQ _DT    ; .

; DQ THEN
MESSAGE_1_AFT_THEN:
 DQ SEMIS
 
; ERROR
ERROR9:
 DB 85H
 DB 'ERRO'
 DB 'R'+80H
 DQ MESSAGE9
ERROR:
 DQ DOCOL
 DQ WARNING
 DQ ATT64  ; "@" FETCH
 DQ ZLESS  ; 0<
 DQ ZBRAN
ERROR_1_AFT_IF:
 DQ ERROR_1_AFT_THEN - ERROR_1_AFT_IF
 DQ ABORT
; DQ THEN
ERROR_1_AFT_THEN:
 DQ HERE
 DQ COUNT
 DQ _TYPE
 DQ DTDQ    ; ."
 DB 3,' ? '
   ; DQ ? 文字列はどう表現するのか？
   ; DQ "
 DQ MESSAGE
 DQ SPST0    ; SP!
 DQ BLK
 DQ ATT64  ; "@" FETCH
 DQ QDUP    ; ?DUP
 DQ ZBRAN
ERROR_2_AFT_IF:
 DQ ERROR_2_AFT_THEN - ERROR_2_AFT_IF
 DQ DNIP   ; >IN 
 DQ ATT64  ; "@" FETCH
 DQ SWAP
; DQ THEN
ERROR_2_AFT_THEN:
 DQ QUIT
 DQ SEMIS

; ?ERROR ( f N --- )
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

;  DQ QERROR5
;QERROR5:
;  POP RBX ;(ID number)
;  POP RAX ;(flag)
;  OR RAX,RAX  ; 真（１）　偽（０）
;  JE QERROR3
;
;  ; ERROR処理
; ; PUSH RBX
;;  MOV [RSP],RSI
;;  SUB RSP,8
;;  LEA RSI, QERROR4
;;  JMP NEXT
; add [DEBUG_DUMP_LEVEL],1
; SUB RBP,8      ; RP  <-RP+8
; MOV [RBP],RSI  ; [RP]<-IP リターンスタックにPUSH
;; MOV RSI,RDX    ; IP  <-RDX 次のワードのアドレスをIPに
; MOV RSI,QERROR4    ; IP  <-RDX 次のワードのアドレスをIPに
; JMP NEXT
;
;
;QERROR4:
;  DQ ERROR
;  DQ SEMIS
;
;QERROR3:
;  ; DROP処理
;;  POP RAX
;  JMP NEXT

; LOAD
LOAD9:
 DB 84H
 DB 'LOA'
 DB 'D'+80H
 DQ QERROR9
LOAD:
 DQ DOCOL
 DQ BLK
 DQ ATT64  ; "@" FETCH
 DQ TOR    ; >R
 DQ DNIP   ; >IN 
 DQ ATT64  ; "@" FETCH
 DQ TOR    ; >R
 DQ _0
 DQ DNIP   ; >IN 
 DQ STORE64  ; !64
 DQ BLK
 DQ STORE64  ; !64
 DQ INTERPRET
 DQ FROMR    ; R>
 DQ DNIP   ; >IN 
 DQ STORE64  ; !64
 DQ FROMR    ; R>
 DQ BLK
 DQ STORE64  ; !64
 DQ SEMIS

; -->
ARR9:
 DB 0C3H
 DB '--'
 DB '>'+80H
 DQ LOAD9
ARR:
 DQ DOCOL
 DQ QLOADING
 DQ _0
 DQ DNIP   ; >IN 
 DQ STORE64  ; !64
 DQ _1
 DQ BLK
 DQ PSTORE    ; +!
 DQ SEMIS

; ID.
IDDT9:
 DB 83H
 DB 'ID'
 DB '.'+80H
 DQ ARR9
IDDT:
 DQ DOCOL
 DQ PAD
 DQ _LIT,22H
 DQ BLANKS
 DQ DUPE
 DQ PFA
 DQ LFA
 DQ OVER
 DQ SUBB
 DQ PAD
 DQ SWAP
 DQ _CMOVE
 DQ PAD
 DQ COUNT
 DQ _LIT,01FH
 DQ ANDD
 DQ _TYPE
 DQ SPACE
 DQ SEMIS

; (CREATE)
PCREAT9:
 DB 88H
 DB '(CREATE'
 DB ')'+80H
 DQ IDDT9
PCREAT:
 DQ DOCOL
 DQ FIND
 DQ QDUP    ; ?DUP
 DQ ZBRAN
PCREAT_AFT_IF:
 DQ PCREAT_AFT_THEN - PCREAT_AFT_IF
;
;
;
 DQ _CR
; DQ _3
 DQ _LIT,8+1
 DQ SUBB
 DQ IDDT    ; ID.
 DQ MINS1
 DQ TRAVERSE
 DQ IDDT    ; ID.
 DQ _LIT,4
; DQ _LIT,8*2
 DQ MESSAGE
 DQ SPACE
; DQ THEN
PCREAT_AFT_THEN:
 DQ HERE
 DQ DUPE
 DQ CFETCH    ; C@
 DQ _WIDTH
 DQ ATT64  ; "@" FETCH
 DQ _1PL
 DQ ALLOT
 DQ DUPE
 DQ _LIT,0A0H
 DQ TOGGL
 DQ HERE
 DQ _1MN
 DQ _LIT,80H
 DQ TOGGL
 DQ LATEST
 DQ COMMA8
 DQ CURRENT
 DQ ATT64  ; "@" FETCH
 DQ STORE64  ; !64
 DQ HERE
; DQ _2PL
 DQ _8PL
 DQ COMMA8
 DQ SEMIS
 
; (;CODE)
PSCOD9:
 DB 87H
 DB '(;CODE'
 DB ')'+80H
 DQ PCREAT9
PSCOD:
 DQ DOCOL
 DQ FROMR    ; R>
 DQ LATEST
 DQ _1
 DQ TRAVERSE
; DQ _3
 DQ _LIT,8+1
 DQ PLUS
 DQ STORE64  ; !64
 DQ SEMIS_3
 
; 79-STANDARD
FORTH79STD9::
  ; ラベルを：：で定義するとPUBLICとなる
  ;
 DB 8bH
 DB '79-STANDAR'
 DB 'D'+80H
 DQ PSCOD9
FORTH79STD:
 DQ DOCOL
 DQ SEMIS
 
;END CLD9


  ret






TestProc endp






; void myFunc(void) 関数の定義
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
 mov rsi,[SEE_THIS_WORD_PTR]  ; 目的のWORDのName Fieldの先頭アドレスをrsiに転送する
   MOV RDI,[SEE_THIS_WORD_PTR]  ; デバッグ用行
 mov rsi,[rsi]
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



; void myFunc(void) 関数の定義
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
; push rax
; push rcx
;
; 
; xor rax,rax
; mov ax,[DEBUG_DUMP_LEVEL
; mov [DEBUG_DUMP_LEVEL2],ax
;
;
;dump_word_loop01:
;    mov ax,[DEBUG_DUMP_LEVEL2]
;     and ax,ax
;    jz  dump_word_loop02
;
;    ;------ printf("number=%d, str=%s\r\n", SCANVAL, &HELLOSTR);
;    lea     r8, HELLOSTR
;    mov     dx, SCAN_VAL_20H
;    lea     rcx, PRINTFORMAT1
;
;    call    printf_s
;    sub [DEBUG_DUMP_LEVEL2],1
;    jmp  dump_word_loop01
;
;dump_word_loop02:
; pop rcx
; pop rax
;


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





; void dumpReg(void) 関数の定義
; デフォルトは PUBLIC
; dumpReg PROC PRIVATE
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
    and     r11,1          ; 000001
    jz     dumpReg_skip1     
    mov     r8 ,[save_rax]
;    mov     r8 ,[save_r10]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rax_PRINTFORMAT

    call    printf

dumpReg_skip1:

    mov     r11,[save_r11]
    and     r11,2          ; 000010
    jz     dumpReg_skip2     
    mov     r8 ,[save_rbx]
;    mov     r8 ,[save_r10]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rbx_PRINTFORMAT

    call    printf

dumpReg_skip2:

    mov     r11,[save_r11]
    and     r11,4          ; 000100
    jz     dumpReg_skip3     
    mov     r8 ,[save_rcx]
;    mov     r8 ,[save_r10]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rcx_PRINTFORMAT

    call    printf

dumpReg_skip3:

    mov     r11,[save_r11]
    and     r11,8          ; 001000
    jz     dumpReg_skip4     
    mov     r8 ,[save_rdx]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rdx_PRINTFORMAT

    call    printf

dumpReg_skip4:

    mov     r11,[save_r11]
    and     r11,16          ; 010000
    jz     dumpReg_skip5     
    mov     r8 ,[save_rsi]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsi_PRINTFORMAT

    call    printf

dumpReg_skip5:

    mov     r11,[save_r11]
    and     r11,32          ; 100000
    jz     dumpReg_skip6     
    mov     r8 ,[save_rbp]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rbp_PRINTFORMAT

    call    printf

dumpReg_skip6:


    mov     r11,[save_r11]
    and     r11,64          ; 1000000
    jz     dumpReg_skip7     
    mov     r8 ,[save_rsp]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsp_PRINTFORMAT

    call    printf

dumpReg_skip7:


    mov     r11,[save_r11]
    and     r11, 8*1024          ; 100000
    jz     dumpReg_skip8     
    mov     r8 ,[save_rdx]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rdx2_PRINTFORMAT

    call    printf

dumpReg_skip8:


    mov     r11,[save_r11]
    and     r11,16*1024          ; 100000
    jz     dumpReg_skip9     
    mov     r8 ,[save_rsi]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsi2_PRINTFORMAT

    call    printf

dumpReg_skip9:


    mov     r11,[save_r11]
    and     r11,32*1024          ; 100000
    jz     dumpReg_skip10     
    mov     r8 ,[save_rbp]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rbp2_PRINTFORMAT

    call    printf

dumpReg_skip10:


    mov     r11,[save_r11]
    and     r11,64*1024          ; 100000
    jz     dumpReg_skip11     
    mov     r8 ,[save_rsp]
    mov     r8 ,[r8]
    mov     rdx,[save_r10]
    lea     rcx, WORD_rsp2_PRINTFORMAT

    call    printf

dumpReg_skip11:





;; １）変数TIBが書き変わったらnopに進む（そこにブレイクポイントを設定すること）。
; mov [save_reg_ADR_TIB],rax
; mov rax,[ADR_TIB]
; mov rax,[rax]
; cmp rax,[check_dat_ADR_TIB]
; jz check_dat_2
; nop
;check_dat_2: 
; mov rax,[save_reg_ADR_TIB]
;
;; ２）WORK_BREAK_POINT_RAX　レジスタからの読み出しテスト。ここにブレークポイントを設定する
; LEA RAX,WORK_BREAK_POINT_RAX
; LEA RAX,WORK_BREAK_POINT_RBX
; MOV RAX,[RAX]
; MOV RAX,[RBX]







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



; void dumpParam(void) 関数の定義
; デフォルトは PUBLIC
; dumpParam PROC PRIVATE
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
    mov     r8 ,[save_rdx]
    mov     rdx,[save_r10]
    lea     rcx, PRT_FORM_Param

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





;; １）変数TIBが書き変わったらnopに進む（そこにブレイクポイントを設定すること）。
; mov [save_reg_ADR_TIB],rax
; mov rax,[ADR_TIB]
; mov rax,[rax]
; cmp rax,[check_dat_ADR_TIB]
; jz check_dat_2
; nop
;check_dat_2: 
; mov rax,[save_reg_ADR_TIB]
;
;; ２）WORK_BREAK_POINT_RAX　レジスタからの読み出しテスト。ここにブレークポイントを設定する
; LEA RAX,WORK_BREAK_POINT_RAX
; LEA RAX,WORK_BREAK_POINT_RBX
; MOV RAX,[RAX]
; MOV RAX,[RBX]









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



; void call_C_bye( ) 関数の定義
; デフォルトは PUBLIC

; call call_C_bye
;    input  - rcx:pointer of struct VAR_SET
;             rdx:command No.
;                1:CIN
;                2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAGとは別に設定している。一番愚直な方法を選んだ。
   ;             5:F_CLOSE
;    (output - rax:return value (pointer of struct VAR_SET))


call_C_bye PROC


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

    mov rdx,999h          ; 1:CIN
 mov rcx,[RET_call_C_entry_save_rcx]
; mov rcx,[rcx]
 mov [rcx+ 8],rdx
 mov rcx,RET_call_C_entry_save_rcx
 mov [call_C_entry_save_rcx],rcx

    mov rax,rcx



   ret




call_C_bye ENDP


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
