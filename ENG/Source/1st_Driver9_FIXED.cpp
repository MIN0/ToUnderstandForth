#include <stdio.h>
#include <Windows.h>
#include <conio.h>
#include <ctype.h>

/* extern "C" unsigned int __stdcall myFunc(unsigned int dwValue); */
extern "C" struct VAR_SET* TestProc(struct VAR_SET* c);
extern "C" struct VAR_SET* call_C_entry(struct VAR_SET* c);
extern "C" struct VAR_SET* call_C_exit(struct VAR_SET* c);


/*
CALL_c_EXITはBYEをEXITに名前を変えたので、ここのEXITはBACKとかにするか？

*/



struct VAR_SET
{
	long long SCANVAL;         /*  -->[rcx +  0] */
	long long COM_NO;          /*  -->[rcx +  8] */
	long long SYS_MASSAGE_ON_OFF;     /*  -->[rcx + 16] */
	long long CHECK_RSI;       /*  -->[rcx + 8*3] ワードの実行でスタックの以上増加がないか調べようと思って追加した*/
	long long CHECK_RSP;       /*  -->[rcx + 8*4] */
	long long CHECK_RBP;       /*  -->[rcx + 8*5] */
//	char      key_state;    /*  -->[rcx + xxx] */
	char      MSGBUF[10];      /*  -->[rcx + 8*6] */

};

VAR_SET* C_Rtn;
VAR_SET* Call_Rtn;
struct VAR_SET* p;

VAR_SET c;

FILE* stream1;
FILE* stream2;
FILE** stream_ptr;
FILE** stream_ptr2;
errno_t err;
errno_t err2;



/*
   ; input  - rax:Input value
   ;          rcx:pointer of struct VAR_SET
   ;          rdx:command No.
   ;             1:CIN
   ;             2:COUT
   ;             3:F_COUT
   ;             4:F_OPEN     PFLAG
   ;             5:F_CLOSE
   ; output - rax:Output value  (not used)

*/


/*int main(int argc, _TCHAR* argv[])*/
int main(int argc, char** argv)
{

	p = &c;
	p->SCANVAL = 0xA5A5;
	p->COM_NO = 0x999;
	p->SYS_MASSAGE_ON_OFF = 0;  // Display Trace WORD name  0:OFF else:ON
//	p->key_state = 0;
	p->MSGBUF[0] = '1';
	p->MSGBUF[1] = 0;
	stream_ptr = &stream1;
	stream_ptr2 = &stream2;


	int zap;
	int loop_on = true;


	//printf_s("%llx :%llx\n", p->SCANVAL, p->COM_NO);


	Call_Rtn = TestProc(&c);
	p = &c;
	if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
		printf_s("%llx :%llx\n", Call_Rtn->SCANVAL, p->COM_NO);
	};

	p = &c;
	switch (p->COM_NO)
	{
	case 1:  /* 1:CIN */
	{
		p->SCANVAL = _getch();
		if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
			printf_s("_getch:%llx\n", p->SCANVAL);
		};
	//	printf_s("_getch:%llx\n", p->SCANVAL);

		break;
	}
	case 2:  /* 2:COUT */
	{
		zap = putchar((char)p->SCANVAL);
		break;
	}
	case 3:  /* 3:F_COUT */
	{
		zap = fputc((char)p->SCANVAL, *stream_ptr);
		break;
	}
	case 4:  /* 4:F_OPEN */
		   // Open for write
	{
		err = fopen_s(stream_ptr, "F_COUT.out", "w+");
		if (err == 0)
		{
			if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
				printf_s("The file 'F_COUT.out' was opened\n");
			};
			//			printf("The file 'F_COUT.out' was opened\n");
			p->SCANVAL = err;
		}
		else
		{
			if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
				printf_s("The file 'F_COUT.out' was not opened\n");
			};
			//			printf("The file 'F_COUT.out' was not opened\n");
			p->SCANVAL = err;
		}

		err2 = fopen_s(stream_ptr2, "F_CIN.out", "r");
		if (err2 == 0)
		{
			if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
				printf_s("The file 'F_CIN.out' was opened\n");
			};
			//			printf("The file 'F_COUT.out' was opened\n");
			p->SCANVAL = err2;
		}
		else
		{
			if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
				printf_s("The file 'F_CIN.out' was not opened\n");
			};
			//			printf("The file 'F_COUT.out' was not opened\n");
			p->SCANVAL = err2;
		}


		break;
	}
	case 5:  /* 5:F_CLOSE*/
              // Close stream if it isn't NULL
	{
		if (*stream_ptr)
		{
			err = fclose(*stream_ptr);
			if (err == 0)
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_COUT.out' was closed\n");
				};
				//				printf("The file 'crt_fopen_s.c' was closed\n");
			}
			else
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_COUT.out' was not closed\n");
				};
				//				printf("The file 'crt_fopen_s.c' was not closed\n");
			}
		};

		if (*stream_ptr2)
		{
			err2 = fclose(*stream_ptr2);
			if (err2 == 0)
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_CIN.out' was closed\n");
				};
				//				printf("The file 'crt_fopen_s.c' was closed\n");
			}
			else
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_CIN.out' was not closed\n");
				};
				//				printf("The file 'crt_fopen_s.c' was not closed\n");
			}
		};

		break;
	}

	case 6:  /* 6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT */
	{
		//			char key_state = _kbhit();
		//			//		p->SCANVAL = 0;
		//			char c = 0;
		//			if (key_state != 0) {
		//				c = _getch();
		//				switch (c) {
		//				case 0x03:
		//					break;
		//				default:
		//					if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
		//						printf_s("key_state=%d  input_char=%x\n", key_state, c);
		//					};
		//					//				printf_s("key_state=%d  input_char=%x\n", key_state, c);
		//				}
		//			}
		//			p->SCANVAL = key_state * 0x100 + c;

		p->SCANVAL = _kbhit();
/* _kbhit() 
構文  C
int _kbhit( void );

戻り値
_kbhit はキーが押されていた場合に 0 以外の値を返します。 それ以外の場合は 0 を返します。*/

		break;
	}
	case 7:  /* 7:F_CIN */
	{
		if (feof(stream2) == 0)
		{
			p->SCANVAL = fgetc(*stream_ptr2);
		}
		else
		{
			p->SCANVAL = -1;
		}

		break;
	}

	//	case 7:  /* 7:SYS_MASSAGE_ON */
//	{
//		zap = putchar((char)p->SCANVAL);
//		break;
//	}
//	case 2:  /* 8:SYS_MASSAGE_Off */
//	{
//		zap = putchar((char)p->SCANVAL);
//		break;
//	}

	};

	while (loop_on) {
		/* WHILE[WORD*/

		C_Rtn = call_C_exit(&c);

		p = &c;
		if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
			printf_s("%llx(%c) :%llx\n", C_Rtn->SCANVAL, C_Rtn->SCANVAL, p->COM_NO);
		};
//		printf_s("%llx :%llx\n", C_Rtn->SCANVAL, p->COM_NO);

		switch (p->COM_NO)
		{
		case 1:  /* 1:CIN */
		{
			p->SCANVAL = _getch();
			if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
				printf_s("_getch:%llx\n", p->SCANVAL);
			};
//			printf_s("_getch:%llx\n", p->SCANVAL);
			break;
		}
		case 2:  /* 2:COUT */
		{
			zap = putchar((char)p->SCANVAL);
			break;
		}

		case 3:  /* 3:F_COUT */
		{
			zap = fputc((char)p->SCANVAL, *stream_ptr);
			break;
		}
		case 4:  /* 4:F_OPEN */
			   // Open for write
		{
			err = fopen_s(stream_ptr, "F_COUT.out", "w+");
			if (err == 0)
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_COUT.out' was opened\n");
				};
//				printf("The file 'F_COUT.out' was opened\n");
				p->SCANVAL = err;
			}
			else
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_COUT.out' was not opened\n");
				};
//				printf("The file 'F_COUT.out' was not opened\n");
				p->SCANVAL = err;
			}

			err2 = fopen_s(stream_ptr2, "F_CIN.out", "r");
			if (err2 == 0)
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_CIN.out' was opened\n");
				};
				//			printf("The file 'F_COUT.out' was opened\n");
				p->SCANVAL = err2;
			}
			else
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_CIN.out' was not opened\n");
				};
				//			printf("The file 'F_COUT.out' was not opened\n");
				p->SCANVAL = err2;
			}



			break;
		}
		case 5:  /* 5:F_CLOSE*/
                   // Close stream if it isn't NULL
		{
		if (*stream_ptr)
		{
			err = fclose(*stream_ptr);
			if (err == 0)
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'crt_fopen_s.c' was closed\n");
				};
//				printf("The file 'crt_fopen_s.c' was closed\n");
			}
			else
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'crt_fopen_s.c' was not closed\n");
				};
//				printf("The file 'crt_fopen_s.c' was not closed\n");
			}
		}

		if (*stream_ptr2)
		{
			err2 = fclose(*stream_ptr2);
			if (err2 == 0)
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_CIN.out' was closed\n");
				};
				//				printf("The file 'crt_fopen_s.c' was closed\n");
			}
			else
			{
				if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
					printf_s("The file 'F_CIN.out' was not closed\n");
				};
				//				printf("The file 'crt_fopen_s.c' was not closed\n");
			}
		};

		break;
		}

		case 6:  /* 6:CHK_KEY_STAT : CHECK STATE OF KEY INPUT */
		{
//			char key_state = _kbhit();
//			//		p->SCANVAL = 0;
//			char c = 0;
//			if (key_state != 0) {
//				c = _getch();
//				switch (c) {
//				case 0x03:
//					break;
//				default:
//					if (Call_Rtn->SYS_MASSAGE_ON_OFF != 0) {
//						printf_s("key_state=%d  input_char=%x\n", key_state, c);
//					};
//					//				printf_s("key_state=%d  input_char=%x\n", key_state, c);
//				}
//			}
//			p->SCANVAL = key_state * 0x100 + c;

			p->SCANVAL = _kbhit();
			/* _kbhit()
			構文  C
			int _kbhit( void );

			戻り値
			_kbhit はキーが押されていた場合に 0 以外の値を返します。 それ以外の場合は 0 を返します。*/


			break;
		}
		case 7:  /* 7:F_CIN */
		{
			if (feof(stream2) == 0)
			{
				p->SCANVAL = fgetc(*stream_ptr2);
			}
			else
			{
				p->SCANVAL = -1;
			}

			break;
		}


		case 0x8:  /* 7:TRACE ON/OFF */
		{
			Call_Rtn->SYS_MASSAGE_ON_OFF = p->SCANVAL;

				break;
		}








		case 0x999:  /* 999:EXIT SYSTEM */
		{
			loop_on = false;
			break;
		}
		};


/*
		Call_Rtn = call_C_entry(&c);
		p = &c;
		printf_s("%llx :%llx\n", Call_Rtn->SCANVAL, p->COM_NO);

		p = &c;
		switch (p->COM_NO)
		{
		case 1:  /* 1:CIN * /
			p->SCANVAL = _getch();
			printf_s("_getch\n", p->SCANVAL);
			break;

		case 2:  /* 2:COUT * /
			zap = putchar((char)p->SCANVAL);
			break;

		default:
			break;
		};
 */



	};


	return 0;  /* */
}


