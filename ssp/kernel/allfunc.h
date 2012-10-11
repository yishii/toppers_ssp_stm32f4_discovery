/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 *
 *  Copyright (C) 2005-2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010 by Naoki Saito
 *             Nagoya Municipal Industrial Research Institute, JAPAN
 *  Copyright (C) 2011-2012 by Meika Sugimoto
 * 
 *  上記著作権者は，以下の (1)〜(4) の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改変・
 *  再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作権
 *      表示，この利用条件および下記の無保証規定が，そのままの形でソース
 *      コード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使用
 *      できる形で再配布する場合には，再配布に伴うドキュメント（利用者マ
 *      ニュアルなど）に，上記の著作権表示，この利用条件および下記の無保
 *      証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使用
 *      できない形で再配布する場合には，次のいずれかの条件を満たすこと．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著作
 *        権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに報
 *        告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損害
 *      からも，上記著作権者およびTOPPERSプロジェクトを免責すること．また，
 *      本ソフトウェアのユーザまたはエンドユーザからのいかなる理由に基づ
 *      く請求からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 * 
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者およ
 *  びTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的に対す
 *  る適合性も含めて，いかなる保証も行わない．また，本ソフトウェアの利用
 *  により直接的または間接的に生じたいかなる損害に関しても，その責任を負
 *  わない．
 * 
 */

/*
 *		すべての関数をコンパイルするための定義
 */

#ifndef TOPPERS_ALLFUNC_H
#define TOPPERS_ALLFUNC_H

/* startup.c */
#define TOPPERS_sta_ker
#define TOPPERS_ext_ker

/* task.c */
#define TOPPERS_get_ipriself
#define TOPPERS_get_ipri
#define TOPPERS_tskini
#define TOPPERS_tsksched
#define TOPPERS_tskrun
#define TOPPERS_tskdsp
#define TOPPERS_tskact
#define TOPPERS_tskdmt


/* task_manage.c */
#define TOPPERS_act_tsk
#define TOPPERS_iact_tsk

/* sys_manage.c */
#define TOPPERS_loc_cpu
#define TOPPERS_iloc_cpu
#define TOPPERS_unl_cpu
#define TOPPERS_iunl_cpu
#define TOPPERS_dis_dsp
#define TOPPERS_ena_dsp
#define TOPPERS_sns_ctx
#define TOPPERS_sns_loc
#define TOPPERS_sns_dsp
#define TOPPERS_sns_dpn
#define TOPPERS_sns_ker

/* interrupt.c */
#define TOPPERS_intini
#define TOPPERS_dis_int
#define TOPPERS_ena_int

/* exception.c */
#define TOPPERS_excini

/* time_event.c */
#define TOPPERS_tmevtini
#define TOPPERS_tmevtenq
#define TOPPERS_tmevtdeq
#define TOPPERS_sig_tim

/* cyclic.c */
#define TOPPERS_cycini
#define TOPPERS_sta_cyc
#define TOPPERS_stp_cyc
#define TOPPERS_cyccal

/* alarm.c */
#define TOPPERS_almini
#define TOPPERS_sta_alm
#define TOPPERS_stp_alm
#define TOPPERS_almcal

/* time_manage.c */
#define TOPPERS_get_tim

#endif /* TOPPERS_ALLFUNC_H */
