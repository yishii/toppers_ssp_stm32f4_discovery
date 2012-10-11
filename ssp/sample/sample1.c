/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 *
 * 
 *  Copyright (C) 2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010-2012 by Meika Sugimoto
 * 
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 * 
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 * 
 */
 
 /*
 *  TOPPERS/SSPのサンプルプログラム
 */

#include <kernel.h>
#include <sil.h>
#include <t_syslog.h>
#include "kernel_cfg.h"
#include "syssvc/serial.h"

#include "sample1.h"


/*
 *  システムサービスのエラーハンドリング
 */
#define SVC(expression)											\
	if((expression) < 0)										\
	{															\
		syslog(LOG_NOTICE , "Error at %s : %s caused by %s." ,	\
			__FILE__ , __LINE__ , #expression);					\
	}

/*
 *  並列実行されるタスクへのメッセージ領域
 */
char_t message[3];

/*
 *  ループ回数
 */
ulong_t	task_loop;		/* タスク内でのループ回数 */

void init_task(intptr_t exinf)
{
#ifndef TASK_LOOP
	volatile ulong_t	i;
	SYSTIM	stime1, stime2;
#endif /* TASK_LOOP */
	
	/* シリアルポートのオープン */
	SVC(serial_opn_por(SIO_PORTID));
	SVC(serial_ctl_por(SIO_PORTID , IOCTL_CRLF));
	
	/* 起動メッセージの出力 */
	syslog(LOG_INFO , "Sample program starts.");
	
	/* 周期ハンドラの起動 */
	SVC(sta_cyc(MAIN_CYC));
	
	/*
 	 *  ループ回数の設定
	 *
	 *  TASK_LOOPがマクロ定義されている場合，測定せずに，TASK_LOOPに定
	 *  義された値を，タスク内でのループ回数とする．
	 *
	 *  MEASURE_TWICEがマクロ定義されている場合，1回目の測定結果を捨て
	 *  て，2回目の測定結果を使う．1回目の測定は長めの時間が出るため．
	 */
#ifdef TASK_LOOP
	task_loop = TASK_LOOP;
#else /* TASK_LOOP */

	task_loop = LOOP_REF;
	SVC(get_tim(&stime1));
	for (i = 0; i < task_loop; i++);
	SVC(get_tim(&stime2));
	task_loop = LOOP_REF * 400UL / (stime2 - stime1);

#endif /* TASK_LOOP */

}


void main_task(intptr_t exinf)
{
	static ID tskid = TASK1;
	static uint_t tskno = 1;
	char_t c;
	

	/* シリアルポートからの文字受信 */
	if(serial_rea_dat(SIO_PORTID , &c , 1) > 0)
	{
		switch(c)
		{
		case 'e':
		case 'z':
		case 'Z':
		case 'r':
			message[tskno] = c;
		    break;
		case '1':
			tskid = TASK1;
			tskno = 0;
			break;
		case '2':
			tskid = TASK2;
			tskno = 1;
			break;
		case '3':
			tskid = TASK3;
			tskno = 2;
			break;
		case 'a':
			syslog(LOG_INFO, "#act_tsk(%d)", tskno);
			SVC(act_tsk(tskid));
			break;
		case 'b':
			syslog(LOG_INFO, "#sta_alm(1, 5000)");
			SVC(sta_alm(ALM1 , 5000));
			break;
		case 'B':
			syslog(LOG_INFO, "#stp_alm(1)");
			SVC(stp_alm(ALM1));
			break;
		case 'c':
			syslog(LOG_INFO, "sta_cyc(1)");
			SVC(sta_cyc(CYC1));
			break;
		case 'C':
			syslog(LOG_INFO, "stp_cyc(1)");
			SVC(stp_cyc(CYC1));
			break;
		case 'Q':
			syslog(LOG_NOTICE, "Sample program ends.");
			SVC(ext_ker());
			break;
		default:
			/* エラー表示 */
			syslog(LOG_INFO , "Unknown command.");
			break;
		}
	}
}


void task(intptr_t exinf)
{
	/* exinfはタスク番号  */
	uint_t tskno = (uint_t)exinf;
	static int_t		n = 0;
	char_t command;
	volatile ulong_t i;
	const char	*graph[] = { "|", "  +", "    *" };
	bool_t cont = true;
	
	do
	{
		for (i = 0; i < task_loop; i++)
			;
		
		/* タスク番号の表示 */
		syslog(LOG_NOTICE, "task%d is running (%03d).   %s",
										tskno, ++n, graph[tskno-1]);
		
		/* コマンド取得，メッセージ領域をクリア */
		command = message[tskno - 1];
		message[tskno - 1] = 0;
		
		switch(command)
		{
		case 'e':
			cont = false;
			syslog(LOG_INFO, "#%d#ext_tsk()", tskno);
			break;
		case 'z':
			syslog(LOG_NOTICE, "#%d#raise CPU exception", tskno);
			RAISE_CPU_EXCEPTION;
			break;
		default:
			break;
		}
	}while(cont == true);
}


void alarm_handler(intptr_t exinf)
{
	ID tskid = (ID)exinf;
	
	syslog(LOG_INFO , "Alarm handler is raised.");
	SVC(iact_tsk(tskid));
}

void main_task_cychdr(intptr_t exinf)
{
	ID tskid = (ID)exinf;
	
	(void)iact_tsk(tskid);
}

void cyclic_handler(intptr_t exinf)
{
	syslog(LOG_INFO , "Cyclic handler is raised.");
}

#ifdef TEST_EXC
void exc_handler(void *p_excinf)
{
	syslog(LOG_INFO , "CPU exception handler.");
	syslog(LOG_INFO , "Kernel exit.");
	
	(void)ext_ker();
}
#endif /* TEST_EXC */

