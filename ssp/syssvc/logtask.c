/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010-2012 by Meika Sugimoto
 * 
 *  �嵭����Ԥϡ��ʲ���(1)��(4)�ξ������������˸¤ꡤ�ܥ��եȥ���
 *  �����ܥ��եȥ���������Ѥ�����Τ�ޤࡥ�ʲ�Ʊ���ˤ���ѡ�ʣ������
 *  �ѡ������ۡʰʲ������ѤȸƤ֡ˤ��뤳�Ȥ�̵���ǵ������롥
 *  (1) �ܥ��եȥ������򥽡��������ɤη������Ѥ�����ˤϡ��嵭������
 *      ��ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ��꤬�����Τޤޤη��ǥ���
 *      ����������˴ޤޤ�Ƥ��뤳�ȡ�
 *  (2) �ܥ��եȥ������򡤥饤�֥������ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ�����Ǻ����ۤ�����ˤϡ������ۤ�ȼ���ɥ�����ȡ�����
 *      �ԥޥ˥奢��ʤɡˤˡ��嵭�����ɽ�����������Ѿ�浪��Ӳ���
 *      ��̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *  (3) �ܥ��եȥ������򡤵�����Ȥ߹���ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ��ʤ����Ǻ����ۤ�����ˤϡ����Τ����줫�ξ�����������
 *      �ȡ�
 *    (a) �����ۤ�ȼ���ɥ�����ȡ����Ѽԥޥ˥奢��ʤɡˤˡ��嵭����
 *        �ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *    (b) �����ۤη��֤��̤�������ˡ�ˤ�äơ�TOPPERS�ץ��������Ȥ�
 *        ��𤹤뤳�ȡ�
 *  (4) �ܥ��եȥ����������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������뤤���ʤ�»
 *      ������⡤�嵭����Ԥ����TOPPERS�ץ��������Ȥ����դ��뤳�ȡ�
 *      �ޤ����ܥ��եȥ������Υ桼���ޤ��ϥ���ɥ桼������Τ����ʤ���
 *      ͳ�˴�Ť����ᤫ��⡤�嵭����Ԥ����TOPPERS�ץ��������Ȥ�
 *      ���դ��뤳�ȡ�
 * 
 *  �ܥ��եȥ������ϡ�̵�ݾڤ��󶡤���Ƥ����ΤǤ��롥�嵭����Ԥ�
 *  ���TOPPERS�ץ��������Ȥϡ��ܥ��եȥ������˴ؤ��ơ�����λ�����Ū
 *  ���Ф���Ŭ������ޤ�ơ������ʤ��ݾڤ�Ԥ�ʤ����ޤ����ܥ��եȥ���
 *  �������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������������ʤ�»���˴ؤ��Ƥ⡤��
 *  ����Ǥ�����ʤ���
 * 
 *  @(#) $Id: logtask.c 1111 2008-06-12 08:42:26Z ertl-hiro $
 */

/*
 *		�����ƥ����������
 */

#include <kernel.h>
#include <t_syslog.h>
#include <log_output.h>
#include "syssvc/serial.h"
#include "syssvc/syslog.h"
#include "logtask.h"

/*
 *  �����ƥ�����������ν�����Υݡ���ID
 */
static ID	logtask_portid;

/*
 *  ���ꥢ�륤�󥿥ե������ؤ�1ʸ������
 */
static void
logtask_putc(char_t c)
{
	serial_wri_dat(logtask_portid, &c, 1);
}

/*
 *  �����������ν��������
 */

void logtask_initialize(ID log_portid)
{
	logtask_portid = log_portid;
	serial_opn_por(logtask_portid);
	syslog_msk_log(LOG_UPTO(LOG_NOTICE), LOG_UPTO(LOG_EMERG));
	syslog_1(LOG_NOTICE, "System logging task is started on port %d.",
													logtask_portid);
}
/*
 *  �����ƥ����������������
 */
void
logtask_main(intptr_t exinf)
{
	SYSLOG	syslog;
	static uint_t	lost = 0;
	ER_UINT	rercd;
	
	while ((rercd = syslog_rea_log(&syslog)) >= 0) {
		lost += (uint_t) rercd;
		if (syslog.logtype >= LOG_TYPE_COMMENT) {
			if (lost > 0U) {
				syslog_lostmsg(lost, logtask_putc);
				lost = 0U;
			}
			syslog_print(&syslog, logtask_putc);
			logtask_putc('\n');
		}
	}
	if (lost > 0U) {
		syslog_lostmsg(lost, logtask_putc);
	}
}

void cychdr_act_logtsk(intptr_t exinf)
{
	iact_tsk((ID)exinf);
}

/*
 *  �����ƥ�����������ν�λ����
 */
void
logtask_terminate(intptr_t exinf)
{
	char_t	c;
	SYSLOG	syslog;
	bool_t	msgflg = false;
	ER_UINT	rercd;

	/*
	 *  ���ꥢ�륤�󥿥ե������ɥ饤�Ф������Хåե������Ѥ��줿�ǡ���
	 *  �����٥���ϵ�ǽ���Ѥ��ƽ��Ϥ��롥
	 */
	while (serial_get_chr(logtask_portid, &c)) {
		target_fput_log(c);
	}

	/*
	 *  �����Хåե��˵�Ͽ���줿������������٥���ϵ�ǽ���Ѥ��ƽ�
	 *  �Ϥ��롥
	 */
	while ((rercd = syslog_rea_log(&syslog)) >= 0) {
		if (!msgflg) {
			/*
			 *  �����Хåե��˻Ĥä���������Ǥ��뤳�Ȥ򼨤�ʸ������
			 *  �Ϥ��롥
			 */
			syslog_printf("-- buffered messages --\n", NULL, target_fput_log);
			msgflg = true;
		}
		if (rercd > 0) {
			syslog_lostmsg((uint_t) rercd, target_fput_log);
		}
		if (syslog.logtype >= LOG_TYPE_COMMENT) {
			syslog_print(&syslog, target_fput_log);
			target_fput_log('\n');
		}
	}
}